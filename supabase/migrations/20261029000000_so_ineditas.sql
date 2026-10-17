-- Solo só sorteia frases que o jogador ainda não respondeu (as mesmas que a barra de progresso conta,
-- em qualquer modo). Se sobraram 1 de 10, a partida tem 1 rodada. Categoria toda respondida: 'all_seen',
-- e o app pergunta se quer jogar de novo; aí p_replay = true volta ao sorteio antigo (vistas há mais
-- tempo primeiro).

drop function if exists public.start_game(text, text, uuid, text);
create function public.start_game(
  p_mode     text,
  p_category text default null,
  p_quote_id uuid default null,
  p_kind     text default null,
  p_replay   boolean default false
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
          select r.quote_id, max(r.served_at) as last_seen, bool_or(r.answered_at is not null) as answered
            from game_rounds r join game_sessions s on s.id = r.session_id
           where s.user_id = v_uid and r.served_at is not null
           group by r.quote_id
        ) seen on seen.quote_id = q.id
       where (p_category is null or p.category = p_category)
         and (p_kind is null or q.kind = p_kind)
         and (p_replay or not coalesce(seen.answered, false))
       order by seen.last_seen nulls first,   -- inéditas, depois as vistas há mais tempo
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
end $$;

revoke all on function public.start_game(text, text, uuid, text, boolean) from public, anon, authenticated;
grant execute on function public.start_game(text, text, uuid, text, boolean) to authenticated;
