import type { Kind } from "./kind";
import type { CategoryInfo, CategoryProgress, Challenge, GameMode, Reveal, Round, Summary } from "./types";

/** Tudo passa pelo servidor do Next (/api/*): o navegador não fala com o Supabase. */
async function call<T>(path: string, init?: RequestInit): Promise<T> {
  let res: Response;
  try {
    res = await fetch(path, { ...init, headers: { "Content-Type": "application/json" }, cache: "no-store" });
  } catch {
    throw new Error("Sem conexão. Tente de novo.");
  }
  const body = (await res.json().catch(() => ({}))) as { data?: T; error?: string };
  if (!res.ok || body.error) throw new Error(body.error ?? `Erro ${res.status}`);
  return body.data as T;
}

export const rpc = <T>(fn: string, args?: Record<string, unknown>) =>
  call<T>(`/api/rpc/${fn}`, { method: "POST", body: JSON.stringify(args ?? {}) });

export async function startGame(
  mode: GameMode,
  opts: { category?: string; quoteId?: string; challengeId?: string; kind?: Kind; replay?: boolean } = {},
) {
  if (mode === "challenge") return rpc<string>("start_challenge", { p_challenge_id: opts.challengeId });
  return rpc<string>("start_game", {
    p_mode: mode,
    ...(opts.category ? { p_category: opts.category } : {}),
    ...(opts.quoteId ? { p_quote_id: opts.quoteId } : {}),
    ...(opts.kind ? { p_kind: opts.kind } : {}),
    // sem replay, o solo só traz frases ainda não respondidas (e dá "all_seen" se não sobrou nenhuma)
    ...(opts.replay ? { p_replay: true } : {}),
  });
}

export const nextRound = (sessionId: string) =>
  rpc<Round | Summary>("next_round", { p_session_id: sessionId });

export const answerRound = (roundId: string, personId: string | null) =>
  rpc<Reveal>("answer_round", { p_round_id: roundId, p_person_id: personId });

export const createChallenge = (sessionId: string, name?: string | null) =>
  rpc<string>("create_challenge", { p_session_id: sessionId, p_name: name ?? null });

export const getChallenge = (id: string) => rpc<Challenge | null>("get_challenge", { p_challenge_id: id });

export const listCategories = () => call<CategoryInfo[]>("/api/categories");

const ERRORS: Record<string, string> = {
  all_seen: "Você já respondeu todas as frases daqui.",
  no_quotes: "Ainda não há frases suficientes para jogar.",
  quote_not_found: "Essa frase não existe mais.",
  not_enough_people: "O banco ainda precisa de mais pessoas cadastradas.",
  session_not_found: "Partida não encontrada. Comece uma nova.",
  challenge_not_found: "Esse desafio não existe.",
  quote_not_rejected: "Só dá para apagar frases que estão fora do jogo.",
};

export function friendlyError(e: unknown): string {
  const msg = e instanceof Error ? e.message : String(e);
  return ERRORS[msg] ?? msg;
}

/** Quantas frases de cada categoria o jogador já respondeu (sem sessão, tudo zero). */
export const myProgress = () => rpc<CategoryProgress[]>("my_progress");
