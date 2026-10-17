-- Jogo instantâneo: o navegador não espera o servidor para mostrar acerto/erro nem para ir à próxima.
--  * Cada rodada traz `answer_key` = sha256("<round_id>:<id de quem disse>"). O navegador confere a carta
--    escolhida na hora; o placar continua sendo calculado só em answer_round.
--    Não é segredo forte (dá para testar as 4 opções), só tira o nome da resposta do tráfego.
--  * answer_round já devolve a próxima rodada (`next`, ainda sem relógio) ou o resumo (`summary`).
--    O relógio da rodada só começa quando next_round é chamado.
-- Pode rodar mais de uma vez.

-- Conteúdo da rodada, sem o relógio (served_at não muda).
create or replace function public._round_json(p_round_id uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'finished',      false,
    'round_id',      r.id,
    'position',      r.position,
    'total_rounds',  s.total_rounds,
    'quote_text',    q.text,
    'options', (
      select jsonb_agg(jsonb_build_object(
               'id', p.id, 'name', p.name, 'image_url', p.image_url, 'image_credit', p.image_credit
             ) order by o.ord)
        from unnest(r.option_ids) with ordinality o(id, ord)
        join people p on p.id = o.id),
    'eliminated',    to_jsonb(r.eliminated_ids),
    'total_seconds', public.round_seconds() + r.extra_seconds,
    'score',         s.score,
    'streak',        s.streak,
    'jokers',        s.jokers,
    'answer_key',    encode(sha256(convert_to(r.id::text || ':' || q.person_id::text, 'UTF8')), 'hex')
  )
  from game_rounds r
  join game_sessions s on s.id = r.session_id
  join quotes q on q.id = r.quote_id
  where r.id = p_round_id
$$;

create or replace function public.next_round(p_session_id uuid) returns jsonb
language plpgsql volatile security definer set search_path = public as $$
declare
  v_s     game_sessions;
  v_r     game_rounds;
  v_total int;
begin
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

  v_total := public.round_seconds() + v_r.extra_seconds;
  return public._round_json(v_r.id) || jsonb_build_object(
    'seconds_left', round(greatest(0, v_total - extract(epoch from (now() - v_r.served_at)))::numeric, 1)
  );
end $$;

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
  v_next     uuid;
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
      'source_type', v_q.source_type, 'source_url', v_q.source_url,
      'source_timestamp', v_q.source_timestamp, 'archive_url', v_q.archive_url),
    'next', case when v_next is not null then public._round_json(v_next) end,
    'summary', case when v_next is null then jsonb_build_object('finished', true) || public._session_summary(v_s.id) end
  );
end $$;

revoke all on function public._round_json(uuid) from public, anon, authenticated;
