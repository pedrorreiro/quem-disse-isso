// Acesso ao Supabase feito só no servidor. O navegador fala com /api/* e nunca vê
// a URL nem a chave do projeto; a sessão do jogador fica em cookies httpOnly.
import { createClient, type Session, type SupabaseClient } from "@supabase/supabase-js";
import { cookies, headers } from "next/headers";

const AT = "qdi_at";
const RT = "qdi_rt";
const YEAR = 60 * 60 * 24 * 365;

function env() {
  // aceita os nomes antigos (NEXT_PUBLIC_*) para o deploy não quebrar enquanto as variáveis são renomeadas
  const url = process.env.SUPABASE_URL ?? process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.SUPABASE_ANON_KEY ?? process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !key) throw new Error("Defina SUPABASE_URL e SUPABASE_ANON_KEY (veja .env.example).");
  return { url, key };
}

/** IP de quem jogou, repassado ao Supabase para o limite de cadastros anônimos não somar todo mundo. */
async function clientIp() {
  const h = await headers();
  return h.get("x-forwarded-for")?.split(",")[0]?.trim() || h.get("x-real-ip") || null;
}

export function supabaseAs(accessToken?: string | null): SupabaseClient {
  const { url, key } = env();
  return createClient(url, key, {
    auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false },
    global: accessToken ? { headers: { Authorization: `Bearer ${accessToken}` } } : undefined,
  });
}

async function authClient() {
  const { url, key } = env();
  const ip = await clientIp();
  return createClient(url, key, {
    auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false },
    global: ip ? { headers: { "Sb-Forwarded-For": ip } } : undefined,
  });
}

function expiresAt(token: string): number {
  try {
    return JSON.parse(Buffer.from(token.split(".")[1], "base64url").toString()).exp ?? 0;
  } catch {
    return 0;
  }
}

export async function saveSession(s: Pick<Session, "access_token" | "refresh_token">) {
  const jar = await cookies();
  const base = { httpOnly: true, sameSite: "lax" as const, secure: process.env.NODE_ENV === "production", path: "/" };
  jar.set(AT, s.access_token, { ...base, maxAge: Math.max(60, expiresAt(s.access_token) - Math.floor(Date.now() / 1000)) });
  jar.set(RT, s.refresh_token, { ...base, maxAge: YEAR });
}

export async function clearSession() {
  const jar = await cookies();
  jar.delete(AT);
  jar.delete(RT);
}

/**
 * Token de acesso válido do visitante: usa o do cookie, renova se estiver vencendo
 * e, com `create`, abre uma sessão anônima nova quando não há nenhuma.
 */
export async function accessToken({ create }: { create: boolean }): Promise<string | null> {
  const jar = await cookies();
  const at = jar.get(AT)?.value;
  if (at && expiresAt(at) - Date.now() / 1000 > 60) return at;

  const rt = jar.get(RT)?.value;
  const auth = (await authClient()).auth;
  if (rt) {
    const { data } = await auth.refreshSession({ refresh_token: rt });
    if (data.session) {
      await saveSession(data.session);
      return data.session.access_token;
    }
  }
  if (!create) return null;

  const { data, error } = await auth.signInAnonymously();
  if (error || !data.session) throw new Error(`Não foi possível iniciar a sessão: ${error?.message ?? "sem sessão"}`);
  await saveSession(data.session);
  return data.session.access_token;
}

export async function currentUser() {
  const token = await accessToken({ create: false });
  if (!token) return null;
  const { data } = await supabaseAs(token).auth.getUser(token);
  return data.user ? { id: data.user.id, is_anonymous: !!data.user.is_anonymous } : null;
}

export async function sendOtp(email: string, redirectTo: string) {
  const { error } = await (await authClient()).auth.signInWithOtp({ email, options: { emailRedirectTo: redirectTo } });
  if (error) throw new Error(error.message);
}

export async function verifyOtp(email: string, token: string) {
  const { data, error } = await (await authClient()).auth.verifyOtp({ email, token, type: "email" });
  if (error || !data.session) throw new Error(error?.message ?? "Código inválido");
  await saveSession(data.session);
}

/** Sessão vinda do link mágico (tokens no #hash): confere com o Supabase antes de gravar. */
export async function adoptSession(access_token: string, refresh_token: string) {
  const { data } = await supabaseAs(access_token).auth.getUser(access_token);
  if (!data.user) throw new Error("Link inválido ou expirado");
  await saveSession({ access_token, refresh_token });
}
