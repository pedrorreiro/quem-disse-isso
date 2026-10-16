-- Revisão manual: só um admin aprova frases e fotos.
--
-- Fluxo: frases entram como 'draft' (por SQL ou pelo painel) → o admin revisa uma por uma em /admin.
-- Fotos de pessoas também passam por aprovação. O jogo só usa frases 'verified' de pessoas com foto aprovada.

create table public.admins (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.admins enable row level security;
revoke all on public.admins from anon, authenticated;

create function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from admins where user_id = auth.uid())
$$;

-- ---------------------------------------------------------------- pessoas: foto com aprovação

alter table public.people
  alter column image_url drop not null,
  add column wikidata_id       text,
  add column photo_status      text not null default 'pending' check (photo_status in ('pending', 'approved', 'rejected')),
  add column photo_reviewed_by uuid references auth.users (id),
  add column photo_reviewed_at timestamptz;

-- ---------------------------------------------------------------- frases: quem aprovou

alter table public.quotes
  add column verified_by uuid references auth.users (id),
  add column review_note text;

-- Trava no banco: nada vira 'verified'/'approved' sem um admin registrado como responsável,
-- nem por SQL direto (inserts de candidatas, seeds, scripts).
create function public._guard_quote_verify() returns trigger
language plpgsql as $$
begin
  if new.status = 'verified'
     and (tg_op = 'INSERT' or old.status is distinct from 'verified' or old.verified_by is distinct from new.verified_by)
     and not exists (select 1 from public.admins where user_id = new.verified_by) then
    raise exception 'only_admin_can_verify';
  end if;
  return new;
end $$;

create function public._guard_photo_approve() returns trigger
language plpgsql as $$
begin
  if new.photo_status = 'approved'
     and (tg_op = 'INSERT' or old.photo_status is distinct from 'approved' or old.image_url is distinct from new.image_url)
     and not exists (select 1 from public.admins where user_id = new.photo_reviewed_by) then
    raise exception 'only_admin_can_approve_photo';
  end if;
  return new;
end $$;

create trigger quotes_2_guard before insert or update on public.quotes
  for each row execute function public._guard_quote_verify();
create trigger people_2_guard before insert or update on public.people
  for each row execute function public._guard_photo_approve();

-- Trocar a foto de uma pessoa aprovada volta para 'pending'.
create function public._photo_reset() returns trigger
language plpgsql as $$
begin
  if new.image_url is distinct from old.image_url and new.photo_reviewed_by is not distinct from old.photo_reviewed_by then
    new.photo_status := 'pending';
    new.photo_reviewed_by := null;
    new.photo_reviewed_at := null;
  end if;
  return new;
end $$;
create trigger people_1_photo_reset before update on public.people
  for each row execute function public._photo_reset();

-- ---------------------------------------------------------------- o jogo só usa conteúdo aprovado

create or replace function public._pick_options(p_quote_id uuid) returns uuid[]
language plpgsql volatile security definer set search_path = public as $$
declare
  v_diff    smallint;
  v_pid     uuid;
  v_cat     text;
  v_country text;
  v_wrong   uuid[];
begin
  select q.difficulty, p.id, p.category, p.country
    into v_diff, v_pid, v_cat, v_country
    from quotes q join people p on p.id = q.person_id
   where q.id = p_quote_id;

  select array_agg(id) into v_wrong from (
    select id from people
     where id <> v_pid and photo_status = 'approved'
     order by
       case v_diff
         when 1 then case when category <> v_cat then 0 else 1 end
         when 3 then case when category = v_cat and country is not distinct from v_country then 0
                          when category = v_cat then 1 else 2 end
         else        case when category = v_cat then 0 else 1 end
       end,
       random()
     limit 3
  ) s;

  if v_wrong is null or cardinality(v_wrong) < 3 then
    raise exception 'not_enough_people';
  end if;

  return (select array_agg(x order by random()) from unnest(array_append(v_wrong, v_pid)) x);
end $$;

-- Frases jogáveis: verificadas e de pessoa com foto aprovada.
create view public.playable_quotes with (security_invoker = true) as
  select q.* from public.quotes q join public.people p on p.id = q.person_id
   where q.status = 'verified' and p.photo_status = 'approved';
revoke all on public.playable_quotes from anon, authenticated;

create or replace function public.start_game(
  p_mode     text,
  p_category text default null,
  p_quote_id uuid default null
) returns uuid
language plpgsql volatile security definer set search_path = public as $$
declare
  v_uid     uuid := auth.uid();
  v_sid     uuid;
  v_day     date;
  v_ids     uuid[];
  v_jokers  jsonb := '{}'::jsonb;
  v_qid     uuid;
  v_pos     int := 0;
begin
  if v_uid is null then raise exception 'not_authenticated'; end if;

  if p_mode = 'solo' then
    v_jokers := '{"fifty":1,"time":1,"skip":1}';
    select array_agg(id) into v_ids from (
      select q.id
        from playable_quotes q join people p on p.id = q.person_id
       where p_category is null or p.category = p_category
       order by exists (select 1 from game_rounds r join game_sessions s on s.id = r.session_id
                         where s.user_id = v_uid and r.quote_id = q.id),   -- inéditas primeiro
                random()
       limit 10
    ) s;

  elsif p_mode = 'daily' then
    v_day := (now() at time zone 'America/Sao_Paulo')::date;
    select id into v_sid from game_sessions where user_id = v_uid and mode = 'daily' and daily_day = v_day;
    if found then return v_sid; end if;

    select quote_ids into v_ids from daily_challenges where day = v_day;
    if v_ids is null then
      insert into daily_challenges (day, quote_ids)
      select v_day, array_agg(id) from (
        select id from playable_quotes order by random() limit 5
      ) s
      having count(*) > 0
      on conflict (day) do nothing;
      select quote_ids into v_ids from daily_challenges where day = v_day;
    end if;

  elsif p_mode = 'shared' then
    if not exists (select 1 from playable_quotes where id = p_quote_id) then
      raise exception 'quote_not_found';
    end if;
    v_ids := array[p_quote_id];

  else
    raise exception 'invalid_mode';
  end if;

  if v_ids is null or cardinality(v_ids) = 0 then raise exception 'no_quotes'; end if;

  insert into game_sessions (user_id, mode, category, daily_day, total_rounds, jokers)
  values (v_uid, p_mode, p_category, v_day, cardinality(v_ids), v_jokers)
  returning id into v_sid;

  foreach v_qid in array v_ids loop
    v_pos := v_pos + 1;
    insert into game_rounds (session_id, position, quote_id, option_ids)
    values (v_sid, v_pos, v_qid, public._pick_options(v_qid));
  end loop;

  return v_sid;
end $$;

create or replace function public.get_quote_preview(p_quote_id uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object('text', text) from playable_quotes where id = p_quote_id
$$;

-- Crédito da foto na revelação (licenças CC exigem atribuição).
create or replace function public.answer_round(p_round_id uuid, p_person_id uuid default null) returns jsonb
language plpgsql volatile security definer set search_path = public as $$
declare
  v_r        game_rounds;
  v_s        game_sessions;
  v_q        quotes;
  v_p        people;
  v_elapsed  numeric;
  v_total    int;
  v_timeout  boolean;
  v_correct  boolean;
  v_mult     numeric := 1;
  v_points   int := 0;
  v_streak   int := 0;
  v_pending  int;
begin
  select r.* into v_r from game_rounds r join game_sessions s on s.id = r.session_id
   where r.id = p_round_id and s.user_id = auth.uid() for update of r;
  if not found then raise exception 'round_not_found'; end if;
  if v_r.answered_at is not null then raise exception 'already_answered'; end if;
  if v_r.served_at is null then raise exception 'round_not_served'; end if;
  if p_person_id is not null and not (p_person_id = any(v_r.option_ids)) then
    raise exception 'invalid_option';
  end if;

  select * into v_s from game_sessions where id = v_r.session_id for update;
  select * into v_q from quotes where id = v_r.quote_id;
  select * into v_p from people where id = v_q.person_id;

  v_elapsed := extract(epoch from (now() - v_r.served_at));
  v_total   := public.round_seconds() + v_r.extra_seconds;
  v_timeout := p_person_id is null or v_elapsed > v_total + 2;   -- 2 s de tolerância de rede
  v_correct := not v_timeout and p_person_id = v_q.person_id;

  if v_correct then
    v_mult   := 1 + least(v_s.streak, 4) * 0.25;
    v_points := round((greatest(100 - 25 * cardinality(v_r.eliminated_ids), 25)
                       + 100 * greatest(0, 1 - v_elapsed / v_total)) * v_mult);
    v_streak := v_s.streak + 1;
  end if;

  update game_rounds
     set answered_at = now(), chosen_person_id = p_person_id, correct = v_correct, points = v_points
   where id = v_r.id;

  update game_sessions
     set score       = score + v_points,
         correct     = correct + case when v_correct then 1 else 0 end,
         streak      = v_streak,
         best_streak = greatest(best_streak, v_streak)
   where id = v_s.id
   returning * into v_s;

  select count(*) into v_pending from game_rounds where session_id = v_s.id and answered_at is null;
  if v_pending = 0 then
    update game_sessions set status = 'finished', finished_at = now() where id = v_s.id;
  end if;

  return jsonb_build_object(
    'correct',    v_correct,
    'timed_out',  v_timeout,
    'points',     v_points,
    'multiplier', v_mult,
    'streak',     v_s.streak,
    'score',      v_s.score,
    'finished',   v_pending = 0,
    'chosen_person_id', p_person_id,
    'quote_id',   v_q.id,
    'person', jsonb_build_object(
      'id', v_p.id, 'name', v_p.name, 'image_url', v_p.image_url, 'image_credit', v_p.image_credit,
      'image_license', v_p.image_license, 'image_source_url', v_p.image_source_url),
    'quote', jsonb_build_object(
      'text', v_q.text, 'said_on', v_q.said_on, 'context', v_q.context,
      'source_type', v_q.source_type, 'source_url', v_q.source_url,
      'source_timestamp', v_q.source_timestamp, 'archive_url', v_q.archive_url)
  );
end $$;

-- Página pública de créditos das fotos.
create function public.photo_credits() returns jsonb
language sql stable security definer set search_path = public as $$
  select coalesce(jsonb_agg(jsonb_build_object(
           'name', name, 'image_url', image_url, 'image_credit', image_credit,
           'image_license', image_license, 'image_source_url', image_source_url) order by name), '[]')
    from people where photo_status = 'approved'
$$;

-- Pessoas visíveis ao público: só as com foto aprovada.
drop policy people_read on public.people;
create policy people_read on public.people for select using (photo_status = 'approved');

-- ---------------------------------------------------------------- API do admin

create function public._require_admin() returns void
language plpgsql stable security definer set search_path = public as $$
begin
  if not public.is_admin() then raise exception 'forbidden'; end if;
end $$;

-- Painel: contadores.
create function public.admin_overview() returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  perform public._require_admin();
  return jsonb_build_object(
    'quotes_draft',    (select count(*) from quotes where status = 'draft'),
    'quotes_verified', (select count(*) from quotes where status = 'verified'),
    'quotes_rejected', (select count(*) from quotes where status = 'rejected'),
    'photos_pending',  (select count(*) from people where photo_status = 'pending' and image_url is not null),
    'people_no_photo', (select count(*) from people where image_url is null),
    'playable',        (select count(*) from playable_quotes)
  );
end $$;

-- Lista de pessoas (para revisar fotos e escolher o autor de uma frase).
create function public.admin_people() returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  perform public._require_admin();
  return coalesce((select jsonb_agg(to_jsonb(p) - 'created_at' order by p.photo_status <> 'pending', p.name)
                     from people p), '[]');
end $$;

-- Fila de frases em rascunho, mais antigas primeiro.
create function public.admin_quote_queue() returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  perform public._require_admin();
  return coalesce((
    select jsonb_agg(to_jsonb(q) || jsonb_build_object('person', jsonb_build_object(
             'id', p.id, 'name', p.name, 'category', p.category, 'image_url', p.image_url,
             'photo_status', p.photo_status)) order by q.created_at)
      from quotes q join people p on p.id = q.person_id
     where q.status = 'draft'), '[]');
end $$;

-- Campos editáveis de uma frase (o resto é controlado pelas funções).
create function public._quote_fields(p jsonb) returns jsonb
language sql immutable as $$
  select coalesce(jsonb_object_agg(key, value), '{}') from jsonb_each(p)
   where key in ('person_id', 'text', 'language', 'said_on', 'context', 'vibe', 'source_type',
                 'source_url', 'source_timestamp', 'archive_url', 'difficulty')
$$;

-- Cria uma frase nova (sempre como rascunho).
create function public.admin_create_quote(p jsonb) returns uuid
language plpgsql volatile security definer set search_path = public as $$
declare
  v_id uuid;
  f jsonb := public._quote_fields(p);
begin
  perform public._require_admin();
  insert into quotes (person_id, text, language, said_on, context, vibe, source_type,
                      source_url, source_timestamp, archive_url, difficulty, status)
  values ((f->>'person_id')::uuid, f->>'text', coalesce(f->>'language', 'pt'), (f->>'said_on')::date,
          nullif(f->>'context', ''), nullif(f->>'vibe', ''), nullif(f->>'source_type', ''),
          f->>'source_url', nullif(f->>'source_timestamp', ''), nullif(f->>'archive_url', ''),
          coalesce((f->>'difficulty')::smallint, 2), 'draft')
  returning id into v_id;
  return v_id;
end $$;

-- Revisa uma frase: 'approve' | 'reject' | 'save' (só salva edições) | 'reopen' (volta a rascunho).
-- p_fields traz as edições feitas na tela; são aplicadas antes da mudança de status.
create function public.admin_review_quote(p_quote_id uuid, p_action text, p_fields jsonb default '{}', p_note text default null)
returns jsonb
language plpgsql volatile security definer set search_path = public as $$
declare
  f jsonb := public._quote_fields(coalesce(p_fields, '{}'));
  v_q quotes;
begin
  perform public._require_admin();
  if p_action not in ('approve', 'reject', 'save', 'reopen') then raise exception 'invalid_action'; end if;

  update quotes set
    person_id        = coalesce((f->>'person_id')::uuid, person_id),
    text             = coalesce(f->>'text', text),
    language         = coalesce(f->>'language', language),
    said_on          = case when f ? 'said_on' then (nullif(f->>'said_on', ''))::date else said_on end,
    context          = case when f ? 'context' then nullif(f->>'context', '') else context end,
    vibe             = case when f ? 'vibe' then nullif(f->>'vibe', '') else vibe end,
    source_type      = case when f ? 'source_type' then nullif(f->>'source_type', '') else source_type end,
    source_url       = coalesce(nullif(f->>'source_url', ''), source_url),
    source_timestamp = case when f ? 'source_timestamp' then nullif(f->>'source_timestamp', '') else source_timestamp end,
    archive_url      = case when f ? 'archive_url' then nullif(f->>'archive_url', '') else archive_url end,
    difficulty       = coalesce((f->>'difficulty')::smallint, difficulty),
    review_note      = coalesce(p_note, review_note),
    status           = case p_action when 'approve' then 'verified' when 'reject' then 'rejected'
                                     when 'reopen' then 'draft' else status end,
    verified_by      = case p_action when 'approve' then auth.uid() when 'save' then verified_by else null end,
    verified_at      = case p_action when 'approve' then now() when 'save' then verified_at else null end
  where id = p_quote_id
  returning * into v_q;

  if not found then raise exception 'quote_not_found'; end if;
  return to_jsonb(v_q);
end $$;

-- Cria/atualiza uma pessoa. Trocar a foto volta o status para 'pending' (trigger).
create function public.admin_upsert_person(p jsonb) returns uuid
language plpgsql volatile security definer set search_path = public as $$
declare
  v_id uuid := (p->>'id')::uuid;
begin
  perform public._require_admin();
  if v_id is null then
    insert into people (name, slug, category, country, bio_short, wikidata_id,
                        image_url, image_type, image_credit, image_license, image_source_url)
    values (p->>'name', p->>'slug', p->>'category', nullif(p->>'country', ''), nullif(p->>'bio_short', ''),
            nullif(p->>'wikidata_id', ''), nullif(p->>'image_url', ''), coalesce(nullif(p->>'image_type', ''), 'foto'),
            nullif(p->>'image_credit', ''), nullif(p->>'image_license', ''), nullif(p->>'image_source_url', ''))
    returning id into v_id;
  else
    update people set
      name             = coalesce(p->>'name', name),
      slug             = coalesce(p->>'slug', slug),
      category         = coalesce(p->>'category', category),
      country          = case when p ? 'country' then nullif(p->>'country', '') else country end,
      bio_short        = case when p ? 'bio_short' then nullif(p->>'bio_short', '') else bio_short end,
      wikidata_id      = case when p ? 'wikidata_id' then nullif(p->>'wikidata_id', '') else wikidata_id end,
      image_url        = case when p ? 'image_url' then nullif(p->>'image_url', '') else image_url end,
      image_type       = coalesce(nullif(p->>'image_type', ''), image_type),
      image_credit     = case when p ? 'image_credit' then nullif(p->>'image_credit', '') else image_credit end,
      image_license    = case when p ? 'image_license' then nullif(p->>'image_license', '') else image_license end,
      image_source_url = case when p ? 'image_source_url' then nullif(p->>'image_source_url', '') else image_source_url end
    where id = v_id;
    if not found then raise exception 'person_not_found'; end if;
  end if;
  return v_id;
end $$;

-- Aprova ou rejeita a foto de uma pessoa.
create function public.admin_review_photo(p_person_id uuid, p_action text) returns void
language plpgsql volatile security definer set search_path = public as $$
begin
  perform public._require_admin();
  if p_action not in ('approve', 'reject') then raise exception 'invalid_action'; end if;
  update people set
    photo_status      = case p_action when 'approve' then 'approved' else 'rejected' end,
    photo_reviewed_by = auth.uid(),
    photo_reviewed_at = now()
  where id = p_person_id and image_url is not null;
  if not found then raise exception 'person_not_found'; end if;
end $$;

-- ---------------------------------------------------------------- permissões

revoke all on function
  public.is_admin(), public._guard_quote_verify(), public._guard_photo_approve(), public._photo_reset(), public._require_admin(),
  public._quote_fields(jsonb), public.photo_credits(), public.admin_overview(), public.admin_people(),
  public.admin_quote_queue(), public.admin_create_quote(jsonb), public.admin_review_quote(uuid, text, jsonb, text),
  public.admin_upsert_person(jsonb), public.admin_review_photo(uuid, text)
  from public, anon, authenticated;

-- create or replace preserva as permissões anteriores; reforçando:
revoke all on function public._pick_options(uuid), public.start_game(text, text, uuid),
  public.get_quote_preview(uuid), public.answer_round(uuid, uuid) from public, anon, authenticated;
grant execute on function public.start_game(text, text, uuid), public.answer_round(uuid, uuid) to authenticated;
grant execute on function public.get_quote_preview(uuid), public.photo_credits() to anon, authenticated;

grant execute on function
  public.is_admin(), public.admin_overview(), public.admin_people(), public.admin_quote_queue(),
  public.admin_create_quote(jsonb), public.admin_review_quote(uuid, text, jsonb, text),
  public.admin_upsert_person(jsonb), public.admin_review_photo(uuid, text)
  to authenticated;
