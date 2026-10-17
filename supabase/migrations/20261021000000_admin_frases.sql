-- Painel: lista de todas as frases (no jogo, rascunho, rejeitadas) para buscar, editar ou tirar do jogo.
-- Traz quantas vezes cada frase foi respondida e a taxa de acerto. Pode rodar mais de uma vez.

create or replace function public.admin_quotes() returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  perform public._require_admin();
  return coalesce((
    select jsonb_agg(
             to_jsonb(q) || jsonb_build_object(
               'playable', q.status = 'verified' and p.photo_status = 'approved',
               'plays',    coalesce(s.plays, 0),
               'hits',     coalesce(s.hits, 0),
               'person',   jsonb_build_object('id', p.id, 'name', p.name, 'category', p.category,
                                              'image_url', p.image_url, 'photo_status', p.photo_status))
             order by q.status = 'verified' desc, q.status = 'draft' desc, p.name, q.created_at)
      from quotes q
      join people p on p.id = q.person_id
      left join (
        select quote_id,
               count(*) filter (where not skipped)              as plays,
               count(*) filter (where correct and not skipped)  as hits
          from game_rounds where answered_at is not null
         group by quote_id) s on s.quote_id = q.id), '[]');
end $$;

revoke all on function public.admin_quotes() from public, anon, authenticated;
grant execute on function public.admin_quotes() to authenticated;
