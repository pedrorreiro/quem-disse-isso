-- Progresso do jogador: quantas frases jogáveis cada categoria tem e quantas ele já respondeu.
-- Sem sessão (auth.uid() nulo) devolve só os totais, com seen = 0.

create or replace function public.my_progress() returns jsonb
language sql stable security definer set search_path = public as $$
  with seen as (
    select distinct r.quote_id
      from game_rounds r join game_sessions s on s.id = r.session_id
     where s.user_id = auth.uid() and r.answered_at is not null
  )
  select coalesce(jsonb_agg(jsonb_build_object('category', category, 'total', total, 'seen', seen) order by category), '[]')
    from (
      select p.category, count(*)::int as total, count(seen.quote_id)::int as seen
        from playable_quotes q
        join people p on p.id = q.person_id
        left join seen on seen.quote_id = q.id
       group by p.category
    ) c
$$;

revoke all on function public.my_progress() from public, anon, authenticated;
grant execute on function public.my_progress() to anon, authenticated;
