-- Tipo da frase: "polemica" (deu repercussão, o critério original) ou "iconica" (bordão, meme, fala que o
-- público sabe de cor). O jogador escolhe na home; o padrão do app é Icônicas.

alter table public.quotes add column if not exists kind text not null default 'polemica'
  check (kind in ('polemica', 'iconica'));
alter table public.game_sessions add column if not exists kind text;

create or replace view public.playable_quotes as
  select q.id, q.person_id, q.text, q.language, q.said_on, q.context, q.vibe, q.source_type, q.source_url,
         q.source_timestamp, q.archive_url, q.difficulty, q.status, q.verified_at, q.is_demo, q.created_at,
         q.verified_by, q.review_note, q.kind
    from quotes q join people p on p.id = q.person_id
   where q.status = 'verified' and p.photo_status = 'approved';

-- Sorteio do solo agora filtra também pelo tipo (nulo = todos). Diário, frase compartilhada e desafio
-- continuam misturando.
drop function if exists public.start_game(text, text, uuid);
create function public.start_game(
  p_mode     text,
  p_category text default null,
  p_quote_id uuid default null,
  p_kind     text default null
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
  if p_kind is not null and p_kind not in ('polemica', 'iconica') then raise exception 'invalid_kind'; end if;

  if p_mode = 'solo' then
    v_jokers := '{"fifty":1,"time":1,"skip":1}';
    select array_agg(id) into v_ids from (
      select q.id
        from playable_quotes q
        join people p on p.id = q.person_id
        left join (
          select r.quote_id, max(r.served_at) as last_seen
            from game_rounds r join game_sessions s on s.id = r.session_id
           where s.user_id = v_uid and r.served_at is not null
           group by r.quote_id
        ) seen on seen.quote_id = q.id
       where (p_category is null or p.category = p_category)
         and (p_kind is null or q.kind = p_kind)
       order by seen.last_seen nulls first,   -- inéditas, depois as vistas há mais tempo
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

  insert into game_sessions (user_id, mode, category, kind, daily_day, total_rounds, jokers)
  values (v_uid, p_mode, p_category, case when p_mode = 'solo' then p_kind end, v_day, cardinality(v_ids), v_jokers)
  returning id into v_sid;

  foreach v_qid in array v_ids loop
    v_pos := v_pos + 1;
    insert into game_rounds (session_id, position, quote_id, option_ids)
    values (v_sid, v_pos, v_qid, public._pick_options(v_qid));
  end loop;

  return v_sid;
end $$;

revoke all on function public.start_game(text, text, uuid, text) from public, anon, authenticated;
grant execute on function public.start_game(text, text, uuid, text) to authenticated;

-- Progresso por categoria e tipo.
create or replace function public.my_progress() returns jsonb
language sql stable security definer set search_path = public as $$
  with seen as (
    select distinct r.quote_id
      from game_rounds r join game_sessions s on s.id = r.session_id
     where s.user_id = auth.uid() and r.answered_at is not null
  )
  select coalesce(jsonb_agg(jsonb_build_object('category', category, 'kind', kind, 'total', total, 'seen', seen)
                            order by category, kind), '[]')
    from (
      select p.category, q.kind, count(*)::int as total, count(seen.quote_id)::int as seen
        from playable_quotes q
        join people p on p.id = q.person_id
        left join seen on seen.quote_id = q.id
       group by p.category, q.kind
    ) c
$$;

-- Admin: o tipo entra nos campos editáveis e na criação.
create or replace function public._quote_fields(p jsonb) returns jsonb
language sql immutable as $$
  select coalesce(jsonb_object_agg(key, value), '{}') from jsonb_each(p)
   where key in ('person_id', 'text', 'language', 'said_on', 'context', 'vibe', 'source_type',
                 'source_url', 'source_timestamp', 'archive_url', 'difficulty', 'kind')
$$;

create or replace function public.admin_create_quote(p jsonb) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  v_id uuid;
  f jsonb := public._quote_fields(p);
begin
  perform public._require_admin();
  insert into quotes (person_id, text, language, said_on, context, vibe, source_type,
                      source_url, source_timestamp, archive_url, difficulty, kind, status)
  values ((f->>'person_id')::uuid, f->>'text', coalesce(f->>'language', 'pt'), (f->>'said_on')::date,
          nullif(f->>'context', ''), nullif(f->>'vibe', ''), nullif(f->>'source_type', ''),
          f->>'source_url', nullif(f->>'source_timestamp', ''), nullif(f->>'archive_url', ''),
          coalesce((f->>'difficulty')::smallint, 2), coalesce(nullif(f->>'kind', ''), 'polemica'), 'draft')
  returning id into v_id;
  return v_id;
end $$;

create or replace function public.admin_review_quote(
  p_quote_id uuid, p_action text, p_fields jsonb default '{}'::jsonb, p_note text default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
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
    kind             = coalesce(nullif(f->>'kind', ''), kind),
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

-- Dados: Reality inteiro é icônico.
update quotes q set kind = 'iconica' from people p where p.id = q.person_id and p.category = 'reality';

