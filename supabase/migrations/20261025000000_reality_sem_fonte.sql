-- Reality Show não mostra fonte para o jogador: as frases são bordões e memes, e o link não acrescenta nada.
-- A URL continua salva em quotes.source_url para a revisão em /admin; só a revelação (answer_round) e a
-- página da frase compartilhada (get_quote_public) passam a devolver source_url nulo nessa categoria.
-- Pode rodar mais de uma vez.

create or replace function public.get_quote_public(p_quote_id uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'id',               q.id,
    'text',             q.text,
    'said_on',          q.said_on,
    'context',          q.context,
    'source_type',      q.source_type,
    'source_url',       case when p.category <> 'reality' then q.source_url end,
    'source_timestamp', q.source_timestamp,
    'archive_url',      q.archive_url,
    'person', jsonb_build_object(
      'name', p.name, 'image_url', p.image_url, 'image_credit', p.image_credit,
      'image_license', p.image_license, 'image_source_url', p.image_source_url))
    from playable_quotes q join people p on p.id = q.person_id
   where q.id = p_quote_id
$$;

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
      'source_type', v_q.source_type,
      'source_url', case when v_p.category <> 'reality' then v_q.source_url end,
      'source_timestamp', v_q.source_timestamp, 'archive_url', v_q.archive_url),
    'next', case when v_next is not null then public._round_json(v_next) end,
    'summary', case when v_next is null then jsonb_build_object('finished', true) || public._session_summary(v_s.id) end
  );
end $$;
