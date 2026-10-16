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
