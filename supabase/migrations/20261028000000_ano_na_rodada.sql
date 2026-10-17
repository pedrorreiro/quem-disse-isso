-- A rodada passa a trazer o ano em que a frase foi dita (`year`), para o jogo mostrar um emblema junto da frase.
-- Nulo quando a frase não tem data. Pode rodar mais de uma vez.

create or replace function public._round_json(p_round_id uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'finished',      false,
    'round_id',      r.id,
    'position',      r.position,
    'total_rounds',  s.total_rounds,
    'quote_text',    q.text,
    'year',          extract(year from q.said_on)::int,
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
