-- Páginas por pessoa (/famoso/<slug>): frases de quem está no jogo, já reveladas, para o Google.
-- Usa people.slug (único, gerado pelo admin na criação e não muda ao editar o nome).
-- Mesmo critério de get_quote_public: só playable_quotes e sem source_url para Reality.

create or replace function public.person_quotes_public(p_slug text) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'slug',             p.slug,
    'name',             p.name,
    'category',         p.category,
    'bio_short',        p.bio_short,
    'image_url',        p.image_url,
    'image_credit',     p.image_credit,
    'image_license',    p.image_license,
    'image_source_url', p.image_source_url,
    'quotes', (
      select jsonb_agg(jsonb_build_object(
               'id',          q.id,
               'text',        q.text,
               'said_on',     q.said_on,
               'context',     q.context,
               'kind',        q.kind,
               'source_url',  case when p.category <> 'reality' then q.source_url end
             ) order by q.said_on desc nulls last, q.verified_at desc nulls last)
        from playable_quotes q
       where q.person_id = p.id
    ),
    -- outras pessoas da mesma categoria, para ligar as páginas entre si
    'related', coalesce((
      select jsonb_agg(jsonb_build_object('slug', o.slug, 'name', o.name) order by o.n desc, o.name)
        from (
          select o.slug, o.name, count(*) as n
            from playable_quotes q join people o on o.id = q.person_id
           where o.category = p.category and o.id <> p.id
           group by o.id
           order by n desc, o.name
           limit 8
        ) o
    ), '[]'::jsonb)
  )
    from people p
   where p.slug = p_slug
     and exists (select 1 from playable_quotes q where q.person_id = p.id)
$$;

grant execute on function public.person_quotes_public(text) to anon, authenticated;

-- Para o sitemap.xml: quem tem frase no jogo e quando a última foi verificada.
create or replace function public.sitemap_people()
returns table (slug text, verified_at timestamptz)
language sql stable security definer set search_path = public as $$
  select p.slug, max(q.verified_at)
    from playable_quotes q join people p on p.id = q.person_id
   group by p.slug
   order by p.slug;
$$;

grant execute on function public.sitemap_people() to anon, authenticated;

-- Frase compartilhada passa a trazer o slug, para o nome linkar para a página da pessoa.
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
      'slug', p.slug,
      'name', p.name, 'image_url', p.image_url, 'image_credit', p.image_credit,
      'image_license', p.image_license, 'image_source_url', p.image_source_url))
    from playable_quotes q join people p on p.id = q.person_id
   where q.id = p_quote_id
$$;
