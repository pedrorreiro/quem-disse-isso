import { supabaseAs } from "./server/supabase";
import type { Challenge } from "./types";

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** RPC pública chamada no servidor, sem sessão de jogador (metadados, imagens). */
async function publicRpc<T>(fn: string, args: Record<string, unknown>): Promise<T | null> {
  try {
    const { data, error } = await supabaseAs().rpc(fn, args);
    if (error || !data) return null;
    return data as T;
  } catch {
    return null;
  }
}

/** Texto público de uma frase (nunca o autor). Usado em metadados e imagem OG, no servidor. */
export async function getQuotePreview(id: string): Promise<{ text: string } | null> {
  if (!UUID.test(id)) return null;
  return publicRpc<{ text: string }>("get_quote_preview", { p_quote_id: id });
}

/** Nome e resultado de quem desafiou (nunca as frases). */
export async function getChallengePublic(id: string): Promise<Challenge | null> {
  if (!UUID.test(id)) return null;
  return publicRpc<Challenge>("get_challenge", { p_challenge_id: id });
}
