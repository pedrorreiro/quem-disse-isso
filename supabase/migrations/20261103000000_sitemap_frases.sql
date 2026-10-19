-- Lista para o sitemap.xml: frases que estão no jogo (mesmo critério de /q/<id>).
-- Anônima: não expõe texto nem resposta, só id e data de verificação.
create or replace function public.sitemap_quotes()
returns table (id uuid, verified_at timestamptz)
language sql
stable
security definer
set search_path to 'public'
as $function$
  select q.id, q.verified_at
    from playable_quotes q
   order by q.verified_at desc nulls last;
$function$;

grant execute on function public.sitemap_quotes() to anon, authenticated;
