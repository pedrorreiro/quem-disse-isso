-- Painel: apagar de vez uma frase que já está fora do jogo (rejeitada).
-- As rodadas antigas que usaram a frase somem junto; o placar das partidas já jogadas não muda.
-- Pode rodar mais de uma vez.

create or replace function public.admin_delete_quote(p_quote_id uuid) returns void
language plpgsql volatile security definer set search_path = public as $$
declare
  v_status text;
begin
  perform public._require_admin();
  select status into v_status from quotes where id = p_quote_id for update;
  if not found then raise exception 'quote_not_found'; end if;
  if v_status <> 'rejected' then raise exception 'quote_not_rejected'; end if;

  delete from game_rounds where quote_id = p_quote_id;
  update daily_challenges set quote_ids = array_remove(quote_ids, p_quote_id) where p_quote_id = any (quote_ids);
  delete from quotes where id = p_quote_id;
end $$;

revoke all on function public.admin_delete_quote(uuid) from public, anon, authenticated;
grant execute on function public.admin_delete_quote(uuid) to authenticated;
