-- Quem Disse Isso? — setup completo (migrations + dados de exemplo). Cole tudo no SQL Editor do Supabase e rode uma vez.

-- ===== supabase/migrations/20261016000000_init.sql =====
-- Quem Disse Isso? — schema inicial
--
-- Princípio de segurança: o cliente NUNCA lê `quotes` diretamente (sem policies = sem acesso).
-- Todo o jogo passa por funções SECURITY DEFINER que não revelam a resposta correta antes de
-- o jogador responder, e que calculam tempo e pontuação no servidor.

-- ---------------------------------------------------------------- tabelas

create table public.people (
  id               uuid primary key default gen_random_uuid(),
  name             text not null,
  slug             text not null unique,
  category         text not null,            -- politica, futebol, musica, tv, internet...
  country          text,
  bio_short        text,
  image_url        text not null,
  image_type       text not null default 'foto' check (image_type in ('foto', 'ilustracao')),
  image_credit     text,
  image_license    text,
  image_source_url text,
  is_demo          boolean not null default false,  -- dados de exemplo; remover antes de publicar
  created_at       timestamptz not null default now()
);

create table public.quotes (
  id               uuid primary key default gen_random_uuid(),
  person_id        uuid not null references public.people (id),
  text             text not null,
  language         text not null default 'pt',
  said_on          date,
  context          text,                     -- linha neutra e opcional da revelação
  vibe             text,                     -- tag interna de curadoria (nunca exibida)
  source_type      text check (source_type in ('video', 'entrevista', 'post', 'discurso', 'musica', 'materia')),
  source_url       text not null,
  source_timestamp text,                     -- ex.: '12:34' quando a fonte é vídeo
  archive_url      text,                     -- snapshot no Wayback Machine
  difficulty       smallint not null default 2 check (difficulty between 1 and 3),
  status           text not null default 'draft' check (status in ('draft', 'verified', 'rejected')),
  verified_at      timestamptz,
  is_demo          boolean not null default false,
  created_at       timestamptz not null default now()
);
create index quotes_status_idx on public.quotes (status);
create index quotes_person_idx on public.quotes (person_id);

create table public.daily_challenges (
  day        date primary key,
  quote_ids  uuid[] not null
);

create table public.game_sessions (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users (id) on delete cascade,
  mode          text not null check (mode in ('solo', 'daily', 'shared')),
  category      text,
  daily_day     date,
  total_rounds  int not null,
  score         int not null default 0,
  correct       int not null default 0,
  streak        int not null default 0,
  best_streak   int not null default 0,
  jokers        jsonb not null default '{}'::jsonb,
  status        text not null default 'playing' check (status in ('playing', 'finished')),
  created_at    timestamptz not null default now(),
  finished_at   timestamptz
);
create index game_sessions_user_idx on public.game_sessions (user_id, created_at desc);
create unique index game_sessions_daily_uniq on public.game_sessions (user_id, daily_day) where mode = 'daily';

create table public.game_rounds (
  id               uuid primary key default gen_random_uuid(),
  session_id       uuid not null references public.game_sessions (id) on delete cascade,
  position         int not null,
  quote_id         uuid not null references public.quotes (id),
  option_ids       uuid[] not null,          -- 4 pessoas, já embaralhadas
  eliminated_ids   uuid[] not null default '{}',
  extra_seconds    int not null default 0,
  served_at        timestamptz,
  answered_at      timestamptz,
  chosen_person_id uuid,
  correct          boolean,
  skipped          boolean not null default false,
  points           int not null default 0,
  unique (session_id, position)
);

-- ---------------------------------------------------------------- acesso às tabelas

alter table public.people          enable row level security;
alter table public.quotes          enable row level security;
alter table public.daily_challenges enable row level security;
alter table public.game_sessions   enable row level security;
alter table public.game_rounds     enable row level security;

revoke all on public.people, public.quotes, public.daily_challenges,
              public.game_sessions, public.game_rounds from anon, authenticated;

-- Pessoas (nome/foto) são públicas; o que revela a resposta é a relação pessoa↔frase.
grant select on public.people to anon, authenticated;
create policy people_read on public.people for select using (true);

-- Sessões: o jogador só enxerga as próprias (placar). Rodadas e frases só via RPC.
grant select on public.game_sessions to authenticated;
create policy sessions_own on public.game_sessions for select to authenticated
  using (user_id = (select auth.uid()));

-- ---------------------------------------------------------------- constantes

create function public.round_seconds() returns int
language sql immutable as $$ select 20 $$;

-- ---------------------------------------------------------------- helpers internos

-- Escolhe as 4 opções de uma frase (a correta + 3 erradas) já embaralhadas.
-- Dificuldade 1: erradas preferem outras categorias. 2: mesma categoria. 3: mesma categoria e país.
create function public._pick_options(p_quote_id uuid) returns uuid[]
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
     where id <> v_pid
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

-- Resumo da sessão (usado ao finalizar e pelo cartão de compartilhamento).
create function public._session_summary(p_session_id uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'session_id',   s.id,
    'mode',         s.mode,
    'daily_day',    s.daily_day,
    'status',       s.status,
    'score',        s.score,
    'correct',      s.correct,
    'total_rounds', s.total_rounds,
    'best_streak',  s.best_streak,
    'results', coalesce((
      select jsonb_agg(
               case when r.answered_at is null then 'pending'
                    when r.skipped            then 'skipped'
                    when r.correct            then 'correct'
                    else 'wrong' end
               order by r.position)
        from game_rounds r where r.session_id = s.id), '[]'::jsonb)
  )
  from game_sessions s where s.id = p_session_id
$$;

-- ---------------------------------------------------------------- API do jogo

-- Cria uma partida. mode: 'solo' (10 rodadas), 'daily' (5, iguais para todos) ou 'shared' (1 frase).
create function public.start_game(
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
        from quotes q join people p on p.id = q.person_id
       where q.status = 'verified'
         and (p_category is null or p.category = p_category)
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
        select id from quotes where status = 'verified' order by random() limit 5
      ) s
      on conflict (day) do nothing;
      select quote_ids into v_ids from daily_challenges where day = v_day;
    end if;

  elsif p_mode = 'shared' then
    if not exists (select 1 from quotes where id = p_quote_id and status = 'verified') then
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

-- Devolve a próxima rodada pendente (idempotente: recarregar a página não reinicia o relógio).
-- Quando não há mais rodadas, finaliza a sessão e devolve o resumo.
create function public.next_round(p_session_id uuid) returns jsonb
language plpgsql volatile security definer set search_path = public as $$
declare
  v_uid   uuid := auth.uid();
  v_s     game_sessions;
  v_r     game_rounds;
  v_text  text;
  v_total int;
  v_opts  jsonb;
begin
  select * into v_s from game_sessions where id = p_session_id and user_id = v_uid;
  if not found then raise exception 'session_not_found'; end if;

  select * into v_r from game_rounds
   where session_id = v_s.id and answered_at is null
   order by position limit 1 for update;

  if not found then
    update game_sessions set status = 'finished', finished_at = coalesce(finished_at, now())
     where id = v_s.id and status <> 'finished';
    return jsonb_build_object('finished', true) || public._session_summary(v_s.id);
  end if;

  if v_r.served_at is null then
    update game_rounds set served_at = now() where id = v_r.id returning * into v_r;
  end if;

  select text into v_text from quotes where id = v_r.quote_id;

  select jsonb_agg(jsonb_build_object(
           'id', p.id, 'name', p.name, 'image_url', p.image_url, 'image_credit', p.image_credit
         ) order by o.ord)
    into v_opts
    from unnest(v_r.option_ids) with ordinality o(id, ord)
    join people p on p.id = o.id;

  v_total := public.round_seconds() + v_r.extra_seconds;

  return jsonb_build_object(
    'finished',      false,
    'round_id',      v_r.id,
    'position',      v_r.position,
    'total_rounds',  v_s.total_rounds,
    'quote_text',    v_text,
    'options',       v_opts,
    'eliminated',    to_jsonb(v_r.eliminated_ids),
    'total_seconds', v_total,
    'seconds_left',  round(greatest(0, v_total - extract(epoch from (now() - v_r.served_at)))::numeric, 1),
    'score',         v_s.score,
    'streak',        v_s.streak,
    'jokers',        v_s.jokers
  );
end $$;

-- Remove opções erradas (até 2 no total). Cada eliminação reduz os pontos da rodada.
create function public._eliminate(p_round_id uuid, p_target int) returns uuid[]
language plpgsql volatile security definer set search_path = public as $$
declare
  v_r     game_rounds;
  v_right uuid;
  v_wrong uuid[];
  v_n     int;
begin
  select * into v_r from game_rounds where id = p_round_id for update;
  select person_id into v_right from quotes where id = v_r.quote_id;
  v_wrong := array(
    select o from unnest(v_r.option_ids) o
     where o <> v_right and not (o = any(v_r.eliminated_ids))
     order by random());
  v_n := least(p_target - cardinality(v_r.eliminated_ids), cardinality(v_wrong));
  if v_n > 0 then
    update game_rounds set eliminated_ids = eliminated_ids || v_wrong[1:v_n]
     where id = p_round_id returning eliminated_ids into v_r.eliminated_ids;
  end if;
  return v_r.eliminated_ids;
end $$;

-- Elimina mais uma opção errada (usado pela dica automática por tempo).
create function public.eliminate_option(p_round_id uuid) returns jsonb
language plpgsql volatile security definer set search_path = public as $$
declare
  v_r game_rounds;
begin
  select r.* into v_r from game_rounds r join game_sessions s on s.id = r.session_id
   where r.id = p_round_id and s.user_id = auth.uid();
  if not found then raise exception 'round_not_found'; end if;
  if v_r.answered_at is not null or v_r.served_at is null then raise exception 'round_not_active'; end if;

  return to_jsonb(public._eliminate(p_round_id, least(cardinality(v_r.eliminated_ids) + 1, 2)));
end $$;

-- Curingas: 'fifty' (deixa só 2 opções), 'time' (+5 s), 'skip' (pula sem pontuar).
create function public.use_joker(p_round_id uuid, p_joker text) returns jsonb
language plpgsql volatile security definer set search_path = public as $$
declare
  v_r game_rounds;
  v_s game_sessions;
begin
  select r.* into v_r from game_rounds r join game_sessions s on s.id = r.session_id
   where r.id = p_round_id and s.user_id = auth.uid() for update of r;
  if not found then raise exception 'round_not_found'; end if;
  if v_r.answered_at is not null or v_r.served_at is null then raise exception 'round_not_active'; end if;

  select * into v_s from game_sessions where id = v_r.session_id for update;
  if coalesce((v_s.jokers ->> p_joker)::int, 0) < 1 then raise exception 'no_joker'; end if;

  if p_joker = 'fifty' then
    perform public._eliminate(p_round_id, 2);
  elsif p_joker = 'time' then
    update game_rounds set extra_seconds = extra_seconds + 5 where id = p_round_id;
  elsif p_joker = 'skip' then
    update game_rounds set skipped = true, answered_at = now() where id = p_round_id;
  else
    raise exception 'invalid_joker';
  end if;

  update game_sessions
     set jokers = jsonb_set(jokers, array[p_joker], to_jsonb((jokers ->> p_joker)::int - 1))
   where id = v_s.id
   returning jokers into v_s.jokers;

  select * into v_r from game_rounds where id = p_round_id;
  return jsonb_build_object(
    'jokers',        v_s.jokers,
    'eliminated',    to_jsonb(v_r.eliminated_ids),
    'total_seconds', public.round_seconds() + v_r.extra_seconds,
    'skipped',       v_r.skipped
  );
end $$;

-- Responde uma rodada. p_person_id nulo = estourou o tempo.
-- Pontos: (base 100 − 25 por opção eliminada, mín. 25) + bônus de velocidade (0–100),
-- multiplicados pelo combo: x1 → x2 (+0,25 por acerto seguido, até 4).
create function public.answer_round(p_round_id uuid, p_person_id uuid default null) returns jsonb
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
      'id', v_p.id, 'name', v_p.name, 'image_url', v_p.image_url, 'image_credit', v_p.image_credit),
    'quote', jsonb_build_object(
      'text', v_q.text, 'said_on', v_q.said_on, 'context', v_q.context,
      'source_type', v_q.source_type, 'source_url', v_q.source_url,
      'source_timestamp', v_q.source_timestamp, 'archive_url', v_q.archive_url)
  );
end $$;

create function public.get_session_summary(p_session_id uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  if not exists (select 1 from game_sessions where id = p_session_id and user_id = auth.uid()) then
    raise exception 'session_not_found';
  end if;
  return public._session_summary(p_session_id);
end $$;

-- Prévia pública para o link de compartilhamento (/q/<id>) e a imagem Open Graph.
-- Expõe SÓ o texto da frase, nunca o autor.
create function public.get_quote_preview(p_quote_id uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object('text', text) from quotes where id = p_quote_id and status = 'verified'
$$;

-- ---------------------------------------------------------------- permissões das funções

revoke all on function
  public.round_seconds(), public._pick_options(uuid), public._session_summary(uuid), public._eliminate(uuid, int),
  public.start_game(text, text, uuid), public.next_round(uuid), public.eliminate_option(uuid),
  public.use_joker(uuid, text), public.answer_round(uuid, uuid), public.get_session_summary(uuid),
  public.get_quote_preview(uuid)
  from public, anon, authenticated;

grant execute on function
  public.start_game(text, text, uuid), public.next_round(uuid), public.eliminate_option(uuid),
  public.use_joker(uuid, text), public.answer_round(uuid, uuid), public.get_session_summary(uuid)
  to authenticated;

grant execute on function public.get_quote_preview(uuid) to anon, authenticated;

-- ===== supabase/migrations/20261017000000_review.sql =====
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

-- ===== supabase/migrations/20261018000000_alternativas.sql =====
-- Alternativas que fazem sentido: as 3 opções erradas saem da mesma área (futebol, música...),
-- do mesmo gênero e do mesmo "lado" (brasileiro x gringo) de quem disse a frase.
-- Também aumenta o tempo de cada rodada para 30 s. Pode rodar mais de uma vez.

create or replace function public.round_seconds() returns int
language sql immutable as $$ select 30 $$;

alter table public.people add column if not exists area   text;
alter table public.people add column if not exists gender text;
alter table public.people drop constraint if exists people_gender_check;
alter table public.people add constraint people_gender_check check (gender in ('m', 'f'));

-- área = categoria, exceto os gringos, que vão para a área em que atuam
update public.people set area = category where area is null and category <> 'gringos';

update public.people p set area = coalesce(p.area, v.area), gender = coalesce(p.gender, v.gender)
from (values
  ('edmundo', 'futebol', 'm'), ('felipe-melo', 'futebol', 'm'), ('joel-santana', 'futebol', 'm'), ('neto', 'futebol', 'm'),
  ('neymar', 'futebol', 'm'), ('pele', 'futebol', 'm'), ('renato-gaucho', 'futebol', 'm'), ('romario', 'futebol', 'm'),
  ('ronaldo-fenomeno', 'futebol', 'm'), ('vampeta', 'futebol', 'm'),
  ('cristiano-ronaldo', 'futebol', 'm'), ('diego-maradona', 'futebol', 'm'), ('jose-mourinho', 'futebol', 'm'),
  ('lionel-messi', 'futebol', 'm'), ('zlatan-ibrahimovic', 'futebol', 'm'),
  ('elon-musk', 'internet', 'm'), ('mrbeast', 'internet', 'm'), ('kanye-west', 'musica', 'm'),
  ('madonna', 'musica', 'f'), ('kim-kardashian', 'tv', 'f'), ('donald-trump', 'politica', 'm'),
  ('carlinhos-maia', 'internet', 'm'), ('casimiro', 'internet', 'm'), ('felipe-castanhari', 'internet', 'm'),
  ('felipe-neto', 'internet', 'm'), ('gil-do-vigor', 'internet', 'm'), ('whindersson-nunes', 'internet', 'm'),
  ('gretchen', 'internet', 'f'), ('ines-brasil', 'internet', 'f'), ('jojo-todynho', 'internet', 'f'),
  ('karol-conka', 'internet', 'f'), ('kefera-buchmann', 'internet', 'f'), ('narcisa-tamborindeguy', 'internet', 'f'),
  ('virginia-fonseca', 'internet', 'f'),
  ('caetano-veloso', 'musica', 'm'), ('fabio-jr', 'musica', 'm'), ('gilberto-gil', 'musica', 'm'),
  ('gusttavo-lima', 'musica', 'm'), ('lobao', 'musica', 'm'), ('luan-santana', 'musica', 'm'),
  ('ney-matogrosso', 'musica', 'm'), ('roberto-carlos', 'musica', 'm'), ('tim-maia', 'musica', 'm'),
  ('zeca-pagodinho', 'musica', 'm'), ('anitta', 'musica', 'f'), ('ivete-sangalo', 'musica', 'f'),
  ('rita-lee', 'musica', 'f'), ('pabllo-vittar', 'musica', 'f'),
  ('ciro-gomes', 'politica', 'm'), ('eduardo-bolsonaro', 'politica', 'm'), ('jair-bolsonaro', 'politica', 'm'),
  ('lula', 'politica', 'm'), ('michel-temer', 'politica', 'm'), ('dilma-rousseff', 'politica', 'f'),
  ('damares-alves', 'politica', 'f'), ('janja', 'politica', 'f'),
  ('datena', 'tv', 'm'), ('faustao', 'tv', 'm'), ('galvao-bueno', 'tv', 'm'), ('silvio-santos', 'tv', 'm'),
  ('ana-maria-braga', 'tv', 'f'), ('luciana-gimenez', 'tv', 'f'), ('xuxa', 'tv', 'f')
) as v(slug, area, gender)
where p.slug = v.slug;

-- Cada opção errada ganha "pontos de estranheza"; ficam as 3 com menos (empate: sorteio).
create or replace function public._pick_options(p_quote_id uuid) returns uuid[]
language plpgsql volatile security definer set search_path = public as $$
declare
  v_diff    smallint;
  v_p       people;
  v_wrong   uuid[];
begin
  select q.difficulty into v_diff from quotes q where q.id = p_quote_id;
  select p.* into v_p from quotes q join people p on p.id = q.person_id where q.id = p_quote_id;

  select array_agg(id) into v_wrong from (
    select id from people o
     where o.id <> v_p.id and o.photo_status = 'approved'
     order by
       (case when coalesce(o.area, o.category) <> coalesce(v_p.area, v_p.category) then 8 else 0 end)
     + (case when o.gender is not null and v_p.gender is not null and o.gender <> v_p.gender then 6 else 0 end)
     + (case when (o.country = 'BR') is distinct from (v_p.country = 'BR') then 3 else 0 end)
     + (case when o.category <> v_p.category then 1 else 0 end)
     + (case when v_diff >= 3 and o.country is distinct from v_p.country then 1 else 0 end),
       random()
     limit 3
  ) s;

  if v_wrong is null or cardinality(v_wrong) < 3 then
    raise exception 'not_enough_people';
  end if;

  return (select array_agg(x order by random()) from unnest(array_append(v_wrong, v_p.id)) x);
end $$;

-- Painel: área e gênero editáveis.
create or replace function public.admin_upsert_person(p jsonb) returns uuid
language plpgsql volatile security definer set search_path = public as $$
declare
  v_id uuid := (p->>'id')::uuid;
begin
  perform public._require_admin();
  if v_id is null then
    insert into people (name, slug, category, area, gender, country, bio_short, wikidata_id,
                        image_url, image_type, image_credit, image_license, image_source_url)
    values (p->>'name', p->>'slug', p->>'category', coalesce(nullif(p->>'area', ''), p->>'category'), nullif(p->>'gender', ''),
            nullif(p->>'country', ''), nullif(p->>'bio_short', ''),
            nullif(p->>'wikidata_id', ''), nullif(p->>'image_url', ''), coalesce(nullif(p->>'image_type', ''), 'foto'),
            nullif(p->>'image_credit', ''), nullif(p->>'image_license', ''), nullif(p->>'image_source_url', ''))
    returning id into v_id;
  else
    update people set
      name             = coalesce(p->>'name', name),
      slug             = coalesce(p->>'slug', slug),
      category         = coalesce(p->>'category', category),
      area             = case when p ? 'area' then nullif(p->>'area', '') else area end,
      gender           = case when p ? 'gender' then nullif(p->>'gender', '') else gender end,
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

revoke all on function public._pick_options(uuid), public.admin_upsert_person(jsonb) from public, anon, authenticated;
grant execute on function public.admin_upsert_person(jsonb) to authenticated;

-- ===== supabase/seed.sql =====
-- DADOS DE EXEMPLO (is_demo = true): pessoas e frases FICTÍCIAS só para testar o ritmo do jogo.
-- Tudo entra como rascunho/foto pendente: aprove em /admin para jogar.
-- Antes de publicar:  delete from quotes where is_demo;  delete from people where is_demo;

insert into people (name, slug, category, country, image_url, image_type, image_credit, image_license, is_demo) values
  ('Zeca Chuteira', 'zeca-chuteira', 'futebol', 'BR', '/demo/p01.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Dedé Marcador', 'dede-marcador', 'futebol', 'BR', '/demo/p02.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Tonhão da Várzea', 'tonhao-da-varzea', 'futebol', 'BR', '/demo/p03.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Marlene Sertaneja', 'marlene-sertaneja', 'musica', 'BR', '/demo/p04.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('DJ Paçoca', 'dj-pacoca', 'musica', 'BR', '/demo/p05.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Bruninho do Pagode', 'bruninho-do-pagode', 'musica', 'BR', '/demo/p06.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Tia Neide', 'tia-neide', 'tv', 'BR', '/demo/p07.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Seu Lauro', 'seu-lauro', 'tv', 'BR', '/demo/p08.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Rita Novelinha', 'rita-novelinha', 'tv', 'BR', '/demo/p09.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Cazé Influ', 'caze-influ', 'internet', 'BR', '/demo/p10.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Mari Dicas', 'mari-dicas', 'internet', 'BR', '/demo/p11.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Juninho Reação', 'juninho-reacao', 'internet', 'BR', '/demo/p12.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true);

insert into quotes (person_id, text, language, said_on, context, source_type, source_url, difficulty, status, verified_at, is_demo)
select p.id, v.text, 'pt', date '2024-01-01', 'Trecho fictício de exemplo', 'video', 'https://example.com/demo/' || v.n, v.diff, 'draft', null, true
from (values
  ('zeca-chuteira', 1, 'Eu não perdi o pênalti, a bola é que escolheu o outro lado.', 1),
  ('zeca-chuteira', 2, 'Estou 100% focado, só falta o resto dos 100%.', 2),
  ('dede-marcador', 3, 'Marcação cerrada é quando eu cuido do adversário até depois do jogo.', 2),
  ('tonhao-da-varzea', 4, 'Na várzea a gente joga por amor e pelo churrasco.', 1),
  ('marlene-sertaneja', 5, 'Meu novo álbum tem 14 faixas, todas sobre o mesmo corno.', 1),
  ('dj-pacoca', 6, 'Se o grave não te fez repensar a vida, aumenta mais.', 2),
  ('bruninho-do-pagode', 7, 'Eu só canto o que eu já chorei.', 3),
  ('tia-neide', 8, 'Boa noite, e se você chegou agora, a culpa não é minha.', 1),
  ('seu-lauro', 9, 'Vale mil reais, mas pra você, que é meu amigo, vale mil e cinquenta.', 2),
  ('rita-novelinha', 10, 'Essa cena eu gravei três vezes, na terceira o cachorro entendeu a emoção.', 3),
  ('caze-influ', 11, 'Gente, não é publi, mas se fosse eu estaria mais bem vestido.', 1),
  ('mari-dicas', 12, 'Acorda às 4h, bebe 3 litros d''água e culpa a Mercúrio retrógrado.', 2),
  ('juninho-reacao', 13, 'Reagindo ao meu próprio vídeo reagindo ao meu vídeo anterior.', 2),
  ('caze-influ', 14, 'Deixa o like, que eu deixo o resto pro algoritmo.', 3)
) as v(slug, n, text, diff) join people p on p.slug = v.slug;
