import { sendOtp } from "@/lib/server/supabase";

// Envia o e-mail de acesso do painel (link mágico + código).
export async function POST(req: Request) {
  const { email } = (await req.json().catch(() => ({}))) as { email?: unknown };
  if (typeof email !== "string" || !email.includes("@")) return Response.json({ error: "E-mail inválido" }, { status: 400 });
  try {
    await sendOtp(email.trim(), `${new URL(req.url).origin}/admin`);
    return Response.json({ ok: true });
  } catch (e) {
    return Response.json({ error: e instanceof Error ? e.message : String(e) }, { status: 400 });
  }
}
