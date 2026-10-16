import { verifyOtp } from "@/lib/server/supabase";

// Confere o código do e-mail e grava a sessão em cookie httpOnly.
export async function POST(req: Request) {
  const { email, code } = (await req.json().catch(() => ({}))) as { email?: unknown; code?: unknown };
  if (typeof email !== "string" || typeof code !== "string") return Response.json({ error: "Dados inválidos" }, { status: 400 });
  try {
    await verifyOtp(email.trim(), code.trim());
    return Response.json({ ok: true });
  } catch (e) {
    return Response.json({ error: e instanceof Error ? e.message : String(e) }, { status: 400 });
  }
}
