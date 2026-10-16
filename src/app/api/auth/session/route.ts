import { adoptSession } from "@/lib/server/supabase";

// Quem entra pelo link mágico chega com os tokens no #hash; o painel manda para cá e limpa a URL.
export async function POST(req: Request) {
  const { access_token, refresh_token } = (await req.json().catch(() => ({}))) as Record<string, unknown>;
  if (typeof access_token !== "string" || typeof refresh_token !== "string") {
    return Response.json({ error: "Dados inválidos" }, { status: 400 });
  }
  try {
    await adoptSession(access_token, refresh_token);
    return Response.json({ ok: true });
  } catch (e) {
    return Response.json({ error: e instanceof Error ? e.message : String(e) }, { status: 400 });
  }
}
