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

export type QuotePublic = {
  id: string;
  text: string;
  said_on: string | null;
  context: string | null;
  source_type: string | null;
  source_url: string | null;
  source_timestamp: string | null;
  archive_url: string | null;
  person: {
    name: string;
    image_url: string | null;
    image_credit: string | null;
    image_license: string | null;
    image_source_url: string | null;
  };
};

/** Frase compartilhada, já revelada: texto, quem disse e fonte. Só frases que estão no jogo. */
export async function getQuotePublic(id: string): Promise<QuotePublic | null> {
  if (!UUID.test(id)) return null;
  return publicRpc<QuotePublic>("get_quote_public", { p_quote_id: id });
}

/** Nome e resultado de quem desafiou (nunca as frases). */
export async function getChallengePublic(id: string): Promise<Challenge | null> {
  if (!UUID.test(id)) return null;
  return publicRpc<Challenge>("get_challenge", { p_challenge_id: id });
}
