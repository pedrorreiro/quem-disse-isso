-- Limite de uso por usuário nas RPCs que gravam estado de jogo.
-- Contador só no banco (sem RLS policies: só funções SECURITY DEFINER acessam).
-- Uma chamada recusada faz rollback junto, então só chamadas aceitas contam.

create table if not exists public.rate_limit_hits (
  user_id uuid not null,
  action  text not null,
  hit_at  timestamptz not null default now()
);
create index if not exists rate_limit_hits_lookup on public.rate_limit_hits (user_id, action, hit_at);
alter table public.rate_limit_hits enable row level security;

create or replace function public._rate_limit(p_action text, p_max int, p_window interval)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_uid uuid := auth.uid();
  v_n   int;
begin
  if v_uid is null then raise exception 'not_authenticated'; end if;
  delete from rate_limit_hits
   where user_id = v_uid and action = p_action and hit_at < now() - p_window;
  select count(*) into v_n from rate_limit_hits
   where user_id = v_uid and action = p_action and hit_at >= now() - p_window;
  if v_n >= p_max then raise exception 'rate_limited'; end if;
  insert into rate_limit_hits (user_id, action) values (v_uid, p_action);
end $function$;

revoke execute on function public._rate_limit(text, int, interval) from public, anon, authenticated;

-- start_game: 30 partidas por hora
create or replace function public.start_game(p_mode text, p_category text DEFAULT NULL::text, p_quote_id uuid DEFAULT NULL::uuid, p_kind text DEFAULT NULL::text, p_replay boolean DEFAULT false)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid     uuid := auth.uid();
  v_sid     uuid;
  v_day     date;
  v_ids     uuid[];
  v_jokers  jsonb := '{}'::jsonb;
  v_qid     uuid;
  v_pos     int := 0;
begin
  perform public._rate_limit('start_game', 30, interval '1 hour');
  if v_uid is null then raise exception 'not_authenticated'; end if;
  if p_kind is not null and p_kind not in ('polemica', 'iconica') then raise exception 'invalid_kind'; end if;

  if p_mode = 'solo' then
    v_jokers := '{"fifty":1,"time":1,"skip":1}';
    select array_agg(id) into v_ids from (
      select q.id
        from playable_quotes q
        join people p on p.id = q.person_id
        left join (
          select r.quote_id, max(r.served_at) as last_seen, bool_or(r.answered_at is not null) as answered
            from game_rounds r join game_sessions s on s.id = r.session_id
           where s.user_id = v_uid and r.served_at is not null
           group by r.quote_id
        ) seen on seen.quote_id = q.id
       where (p_category is null or p.category = p_category)
         and (p_kind is null or q.kind = p_kind)
         and (p_replay or not coalesce(seen.answered, false))
       order by seen.last_seen nulls first,
                random()
       limit 10
    ) s;

    if (v_ids is null or cardinality(v_ids) = 0) and not p_replay and exists (
      select 1 from playable_quotes q join people p on p.id = q.person_id
       where (p_category is null or p.category = p_category)
         and (p_kind is null or q.kind = p_kind)
    ) then
      raise exception 'all_seen';
    end if;

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
end $function$;

-- next_round: 300 por hora
create or replace function public.next_round(p_session_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_s     game_sessions;
  v_r     game_rounds;
begin
  perform public._rate_limit('next_round', 300, interval '1 hour');
  select * into v_s from game_sessions where id = p_session_id and user_id = auth.uid();
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

  return public._round_json(v_r.id) || jsonb_build_object(
    'seconds_left', round(greatest(0, public.round_seconds() - extract(epoch from (now() - v_r.served_at)))::numeric, 1)
  );
end $function$;

-- answer_round: 300 por hora
create or replace function public.answer_round(p_round_id uuid, p_person_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
  v_next     uuid;
begin
  perform public._rate_limit('answer_round', 300, interval '1 hour');
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
  v_total   := public.round_seconds();
  v_timeout := p_person_id is null or v_elapsed > v_total + 2;
  v_correct := not v_timeout and p_person_id = v_q.person_id;

  if v_correct then
    v_mult   := 1 + least(v_s.streak, 4) * 0.25;
    v_points := round((greatest(100 - 25 * cardinality(v_r.eliminated_ids), 25)
                       + 100 * greatest(0, 1 - v_elapsed / v_total)) * v_mult);
    v_streak := v_s.streak + 1;
  end if;

  update game_rounds
     set answered_at = now(), chosen_person_id = p_person_id, correct = v_correct
   where id = v_r.id;

  update game_sessions
     set score       = score + v_points,
         correct     = correct + case when v_correct then 1 else 0 end,
         streak      = v_streak,
         best_streak = greatest(best_streak, v_streak)
   where id = v_s.id
   returning * into v_s;

  select id into v_next from game_rounds
   where session_id = v_s.id and answered_at is null order by position limit 1;
  if v_next is null then
    update game_sessions set status = 'finished', finished_at = now() where id = v_s.id;
  end if;

  return jsonb_build_object(
    'correct',    v_correct,
    'timed_out',  v_timeout,
    'points',     v_points,
    'multiplier', v_mult,
    'streak',     v_s.streak,
    'score',      v_s.score,
    'finished',   v_next is null,
    'chosen_person_id', p_person_id,
    'quote_id',   v_q.id,
    'person', jsonb_build_object(
      'id', v_p.id, 'name', v_p.name, 'image_url', v_p.image_url, 'image_credit', v_p.image_credit,
      'image_license', v_p.image_license, 'image_source_url', v_p.image_source_url),
    'quote', jsonb_build_object(
      'text', v_q.text, 'said_on', v_q.said_on, 'context', v_q.context,
      'source_type', v_q.source_type,
      'source_url', case when v_p.category <> 'reality' then v_q.source_url end,
      'source_timestamp', v_q.source_timestamp, 'archive_url', v_q.archive_url),
    'next', case when v_next is not null then public._round_json(v_next) end,
    'summary', case when v_next is null then jsonb_build_object('finished', true) || public._session_summary(v_s.id) end
  );
end $function$;

-- create_challenge: 30 por hora
create or replace function public.create_challenge(p_session_id uuid, p_name text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_s    game_sessions;
  v_id   uuid;
  v_name text := nullif(left(btrim(coalesce(p_name, '')), 30), '');
begin
  perform public._rate_limit('create_challenge', 30, interval '1 hour');
  select * into v_s from game_sessions where id = p_session_id and user_id = auth.uid();
  if not found then raise exception 'session_not_found'; end if;
  if v_s.status <> 'finished' or v_s.mode not in ('solo', 'daily', 'challenge') then
    raise exception 'session_not_finished';
  end if;

  insert into challenges (session_id, name) values (p_session_id, v_name)
  on conflict (session_id) do update set name = coalesce(excluded.name, challenges.name)
  returning id into v_id;
  return v_id;
end $function$;

-- start_challenge: 60 por hora
create or replace function public.start_challenge(p_challenge_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid  uuid := auth.uid();
  v_c    challenges;
  v_src  game_sessions;
  v_sid  uuid;
  v_ids  uuid[];
  v_qid  uuid;
  v_pos  int := 0;
begin
  perform public._rate_limit('start_challenge', 60, interval '1 hour');
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
end $function$;
