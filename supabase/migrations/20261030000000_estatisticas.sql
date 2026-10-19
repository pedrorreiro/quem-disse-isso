-- Painel: estatísticas de acertos e erros. Por famoso (quem a galera acerta, com quem confunde),
-- por jogador, por categoria, por dia e as frases mais difíceis/fáceis.
-- p_days limita às respostas dos últimos N dias (nulo = desde sempre). Pode rodar mais de uma vez.

create or replace function public.admin_stats(p_days int default null) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  v_since timestamptz := case when p_days is null then '-infinity'::timestamptz else now() - make_interval(days => p_days) end;
  v_today date := (now() at time zone 'America/Sao_Paulo')::date;
  v_out   jsonb;
begin
  perform public._require_admin();

  with v as (
    select r.quote_id, r.chosen_person_id, coalesce(r.correct, false) as correct,
           r.chosen_person_id is null as timeout,
           extract(epoch from r.answered_at - r.served_at) as secs,
           r.answered_at, s.user_id, s.mode, q.person_id, q.kind, p.category
      from game_rounds r
      join game_sessions s on s.id = r.session_id
      join quotes q on q.id = r.quote_id
      join people p on p.id = q.person_id
     where r.answered_at is not null and r.answered_at >= v_since
  )
  select jsonb_build_object(
    'totals', (
      select jsonb_build_object(
        'players',       count(distinct user_id),
        'answers',       count(*),
        'hits',          count(*) filter (where correct),
        'timeouts',      count(*) filter (where timeout),
        'avg_secs',      round(avg(secs) filter (where not timeout)::numeric, 1),
        'players_today', count(distinct user_id) filter (where (answered_at at time zone 'America/Sao_Paulo')::date = v_today),
        'answers_today', count(*) filter (where (answered_at at time zone 'America/Sao_Paulo')::date = v_today),
        'games',         (select count(*) from game_sessions where created_at >= v_since),
        'finished',      (select count(*) from game_sessions where created_at >= v_since and status = 'finished'))
        from v),
    'by_day', coalesce((
      select jsonb_agg(jsonb_build_object('day', d, 'players', players, 'answers', answers, 'hits', hits) order by d)
        from (select (answered_at at time zone 'America/Sao_Paulo')::date as d,
                     count(distinct user_id) as players, count(*) as answers, count(*) filter (where correct) as hits
                from v group by 1) x), '[]'),
    'by_category', coalesce((
      select jsonb_agg(jsonb_build_object('category', category, 'answers', answers, 'hits', hits) order by answers desc)
        from (select category, count(*) as answers, count(*) filter (where correct) as hits from v group by 1) x), '[]'),
    'by_kind', coalesce((
      select jsonb_agg(jsonb_build_object('kind', kind, 'answers', answers, 'hits', hits) order by answers desc)
        from (select kind, count(*) as answers, count(*) filter (where correct) as hits from v group by 1) x), '[]'),
    'by_mode', coalesce((
      select jsonb_agg(jsonb_build_object('mode', mode, 'answers', answers, 'hits', hits) order by answers desc)
        from (select mode, count(*) as answers, count(*) filter (where correct) as hits from v group by 1) x), '[]'),
    'people', coalesce((
      select jsonb_agg(jsonb_build_object(
               'id', p.id, 'name', p.name, 'category', p.category, 'image_url', p.image_url,
               'quotes', x.quotes, 'answers', x.answers, 'hits', x.hits, 'timeouts', x.timeouts,
               'avg_secs', x.avg_secs,
               -- quantas vezes a galera chutou esta pessoa numa frase que era de outra
               'decoy', coalesce(d.n, 0),
               'confused_with', c.top)
             order by x.answers desc, p.name)
        from (select person_id, count(distinct quote_id) as quotes, count(*) as answers,
                     count(*) filter (where correct) as hits, count(*) filter (where timeout) as timeouts,
                     round(avg(secs) filter (where not timeout)::numeric, 1) as avg_secs
                from v group by person_id) x
        join people p on p.id = x.person_id
        left join (select chosen_person_id, count(*) as n from v where not correct and chosen_person_id is not null
                    group by 1) d on d.chosen_person_id = p.id
        left join lateral (
          select jsonb_agg(jsonb_build_object('name', cp.name, 'count', w.n) order by w.n desc, cp.name) as top
            from (select chosen_person_id, count(*) as n from v
                   where v.person_id = p.id and not correct and chosen_person_id is not null
                   group by 1 order by 2 desc limit 3) w
            join people cp on cp.id = w.chosen_person_id) c on true), '[]'),
    'confusions', coalesce((
      select jsonb_agg(jsonb_build_object('said_by', sp.name, 'guessed', cp.name, 'count', w.n) order by w.n desc, sp.name)
        from (select person_id, chosen_person_id, count(*) as n from v
               where not correct and chosen_person_id is not null
               group by 1, 2 order by 3 desc limit 15) w
        join people sp on sp.id = w.person_id
        join people cp on cp.id = w.chosen_person_id), '[]'),
    'quotes', coalesce((
      select jsonb_agg(jsonb_build_object('id', q.id, 'text', q.text, 'person', p.name, 'kind', q.kind,
                                          'answers', x.answers, 'hits', x.hits))
        from (select quote_id, count(*) as answers, count(*) filter (where correct) as hits
                from v group by quote_id having count(*) >= 3) x
        join quotes q on q.id = x.quote_id
        join people p on p.id = q.person_id), '[]'),
    'players', coalesce((
      select jsonb_agg(jsonb_build_object(
               'id', x.user_id, 'is_anonymous', coalesce(u.is_anonymous, true),
               'is_admin', exists (select 1 from admins ad where ad.user_id = x.user_id),
               'answers', x.answers, 'hits', x.hits, 'timeouts', x.timeouts, 'avg_secs', x.avg_secs,
               'games', g.games, 'best_score', g.best_score, 'best_streak', g.best_streak,
               'first_seen', x.first_seen, 'last_seen', x.last_seen,
               'favorite_category', fc.category)
             order by x.answers desc)
        from (select user_id, count(*) as answers, count(*) filter (where correct) as hits,
                     count(*) filter (where timeout) as timeouts,
                     round(avg(secs) filter (where not timeout)::numeric, 1) as avg_secs,
                     min(answered_at) as first_seen, max(answered_at) as last_seen
                from v group by user_id) x
        left join auth.users u on u.id = x.user_id
        left join lateral (
          select count(*) as games, max(score) as best_score, max(best_streak) as best_streak
            from game_sessions s where s.user_id = x.user_id and s.created_at >= v_since) g on true
        left join lateral (
          select category from v where v.user_id = x.user_id group by category order by count(*) desc limit 1) fc on true), '[]')
  ) into v_out;

  return v_out;
end $$;

revoke all on function public.admin_stats(int) from public, anon, authenticated;
grant execute on function public.admin_stats(int) to authenticated;
