import { ensureSession, getSupabase } from "./supabase";
import type { Challenge, GameMode, JokerName, Jokers, Reveal, Round, Summary } from "./types";

export async function rpc<T>(fn: string, args?: Record<string, unknown>): Promise<T> {
  const { data, error } = await getSupabase().rpc(fn, args);
  if (error) throw new Error(error.message);
  return data as T;
}

export async function startGame(
  mode: GameMode,
  opts: { category?: string; quoteId?: string; challengeId?: string } = {},
) {
  await ensureSession();
  if (mode === "challenge") return rpc<string>("start_challenge", { p_challenge_id: opts.challengeId });
  return rpc<string>("start_game", {
    p_mode: mode,
    ...(opts.category ? { p_category: opts.category } : {}),
    ...(opts.quoteId ? { p_quote_id: opts.quoteId } : {}),
  });
}

export const nextRound = (sessionId: string) =>
  rpc<Round | Summary>("next_round", { p_session_id: sessionId });

export const answerRound = (roundId: string, personId: string | null) =>
  rpc<Reveal>("answer_round", { p_round_id: roundId, p_person_id: personId });

export const playJoker = (roundId: string, joker: JokerName) =>
  rpc<{ jokers: Jokers; eliminated: string[]; total_seconds: number; skipped: boolean }>("use_joker", {
    p_round_id: roundId,
    p_joker: joker,
  });

export const createChallenge = (sessionId: string, name?: string | null) =>
  rpc<string>("create_challenge", { p_session_id: sessionId, p_name: name ?? null });

export const getChallenge = (id: string) => rpc<Challenge | null>("get_challenge", { p_challenge_id: id });

export async function listCategories(): Promise<string[]> {
  const { data, error } = await getSupabase().from("people").select("category");
  if (error) throw new Error(error.message);
  return [...new Set((data ?? []).map((r) => r.category as string))].sort();
}

const ERRORS: Record<string, string> = {
  no_quotes: "Ainda não há frases suficientes para jogar.",
  quote_not_found: "Essa frase não existe mais.",
  not_enough_people: "O banco ainda precisa de mais pessoas cadastradas.",
  session_not_found: "Partida não encontrada. Comece uma nova.",
  challenge_not_found: "Esse desafio não existe.",
};

export function friendlyError(e: unknown): string {
  const msg = e instanceof Error ? e.message : String(e);
  return ERRORS[msg] ?? msg;
}
