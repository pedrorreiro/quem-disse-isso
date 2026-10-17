-- Frase compartilhada já revelada: texto, quem disse e fonte. Só frases que estão no jogo.
-- O id da frase só aparece depois de responder, então isto não entrega resposta de rodada aberta.
-- Pode rodar mais de uma vez.

create or replace function public.get_quote_public(p_quote_id uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'id',               q.id,
    'text',             q.text,
    'said_on',          q.said_on,
    'context',          q.context,
    'source_type',      q.source_type,
    'source_url',       q.source_url,
    'source_timestamp', q.source_timestamp,
    'archive_url',      q.archive_url,
    'person', jsonb_build_object(
      'name', p.name, 'image_url', p.image_url, 'image_credit', p.image_credit,
      'image_license', p.image_license, 'image_source_url', p.image_source_url))
    from playable_quotes q join people p on p.id = q.person_id
   where q.id = p_quote_id
$$;

revoke all on function public.get_quote_public(uuid) from public, anon, authenticated;
grant execute on function public.get_quote_public(uuid) to anon, authenticated;
