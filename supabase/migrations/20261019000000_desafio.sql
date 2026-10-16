-- Desafiar um amigo: o amigo joga as MESMAS frases de uma partida terminada e, no fim,
-- compara o próprio resultado com o de quem desafiou. Pode rodar mais de uma vez.

create table if not exists public.challenges (
  id          uuid primary key default gen_random_uuid(),
  session_id  uuid not null unique references public.game_sessions (id) on delete cascade,
  name        text check (char_length(name) <= 30),
  created_at  timestamptz not null default now()
);
alter table public.challenges enable row level security;
revoke all on public.challenges from anon, authenticated;

alter table public.game_sessions add column if not exists challenge_id uuid references public.challenges (id) on delete set null;
alter table public.game_sessions drop constraint if exists game_sessions_mode_check;
alter table public.game_sessions add constraint game_sessions_mode_check
  check (mode in ('solo', 'daily', 'shared', 'challenge'));
create unique index if not exists game_sessions_challenge_uniq
  on public.game_sessions (user_id, challenge_id) where mode = 'challenge';

-- Resumo da partida agora diz de qual desafio ela veio.
create or replace function public._session_summary(p_session_id uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'session_id',   s.id,
    'mode',         s.mode,
    'daily_day',    s.daily_day,
    'challenge_id', s.challenge_id,
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

-- Cria (ou renomeia) o desafio de uma partida terminada. Um desafio por partida.
create or replace function public.create_challenge(p_session_id uuid, p_name text default null) returns uuid
language plpgsql volatile security definer set search_path = public as $$
declare
  v_s    game_sessions;
  v_id   uuid;
  v_name text := nullif(left(btrim(coalesce(p_name, '')), 30), '');
begin
  select * into v_s from game_sessions where id = p_session_id and user_id = auth.uid();
  if not found then raise exception 'session_not_found'; end if;
  if v_s.status <> 'finished' or v_s.mode not in ('solo', 'daily', 'challenge') then
    raise exception 'session_not_finished';
  end if;

  insert into challenges (session_id, name) values (p_session_id, v_name)
  on conflict (session_id) do update set name = coalesce(excluded.name, challenges.name)
  returning id into v_id;
  return v_id;
end $$;

-- Dados públicos do desafio: nome e resultado de quem desafiou (nunca as frases).
create or replace function public.get_challenge(p_challenge_id uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object('id', c.id, 'name', c.name) || public._session_summary(c.session_id)
         - 'session_id' - 'score' - 'status' - 'challenge_id' - 'daily_day'
    from challenges c where c.id = p_challenge_id
$$;

-- Começa (ou retoma) a partida do desafio. Quem desafiou recebe a própria partida de volta.
create or replace function public.start_challenge(p_challenge_id uuid) returns uuid
language plpgsql volatile security definer set search_path = public as $$
declare
  v_uid  uuid := auth.uid();
  v_c    challenges;
  v_src  game_sessions;
  v_sid  uuid;
  v_ids  uuid[];
  v_qid  uuid;
  v_pos  int := 0;
begin
  if v_uid is null then raise exception 'not_authenticated'; end if;
  select * into v_c from challenges where id = p_challenge_id;
  if not found then raise exception 'challenge_not_found'; end if;
  select * into v_src from game_sessions where id = v_c.session_id;
  if v_src.user_id = v_uid then return v_src.id; end if;

  select id into v_sid from game_sessions where user_id = v_uid and mode = 'challenge' and challenge_id = v_c.id;
  if found then return v_sid; end if;

  -- mesmas frases, na mesma ordem (pulando alguma que tenha saído do jogo depois)
  select array_agg(r.quote_id order by r.position) into v_ids
    from game_rounds r where r.session_id = v_src.id and r.quote_id in (select id from playable_quotes);
  if v_ids is null or cardinality(v_ids) = 0 then raise exception 'no_quotes'; end if;

  insert into game_sessions (user_id, mode, challenge_id, total_rounds, jokers)
  values (v_uid, 'challenge', v_c.id, cardinality(v_ids), '{"fifty":1,"time":1,"skip":1}')
  returning id into v_sid;

  foreach v_qid in array v_ids loop
    v_pos := v_pos + 1;
    insert into game_rounds (session_id, position, quote_id, option_ids)
    values (v_sid, v_pos, v_qid, public._pick_options(v_qid));
  end loop;
  return v_sid;
end $$;

revoke all on function public._session_summary(uuid), public.create_challenge(uuid, text),
  public.get_challenge(uuid), public.start_challenge(uuid) from public, anon, authenticated;
grant execute on function public.create_challenge(uuid, text), public.start_challenge(uuid) to authenticated;
grant execute on function public.get_challenge(uuid) to anon, authenticated;
