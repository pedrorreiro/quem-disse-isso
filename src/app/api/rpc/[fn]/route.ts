import { accessToken, supabaseAs } from "@/lib/server/supabase";

// Só estas funções passam pelo proxy. "session": cria sessão anônima se não houver;
// "user": exige sessão já existente (admin); "optional": usa a sessão se houver, sem criar;
// "public": roda sem sessão.
const FNS: Record<string, "session" | "user" | "optional" | "public"> = {
  start_game: "session",
  start_challenge: "session",
  next_round: "session",
  answer_round: "session",
  create_challenge: "session",
  my_progress: "optional",
  get_challenge: "public",
  photo_credits: "public",
  is_admin: "user",
  admin_overview: "user",
  admin_stats: "user",
  admin_people: "user",
  admin_quote_queue: "user",
  admin_quotes: "user",
  admin_delete_quote: "user",
  admin_review_quote: "user",
  admin_create_quote: "user",
  admin_upsert_person: "user",
  admin_review_photo: "user",
};

export async function POST(req: Request, ctx: RouteContext<"/api/rpc/[fn]">) {
  const { fn } = await ctx.params;
  const access = FNS[fn];
  if (!access) return Response.json({ error: "not_found" }, { status: 404 });

  let args: unknown;
  try {
    args = await req.json();
  } catch {
    args = {};
  }
  if (!args || typeof args !== "object" || Array.isArray(args)) return Response.json({ error: "bad_args" }, { status: 400 });

  try {
    const token = access === "public" ? null : await accessToken({ create: access === "session" });
    if (access === "user" && !token) return Response.json({ error: "not_authenticated" }, { status: 401 });
    const { data, error } = await supabaseAs(token).rpc(fn, args as Record<string, unknown>);
    if (error) return Response.json({ error: error.message }, { status: 400 });
    return Response.json({ data: data ?? null });
  } catch (e) {
    return Response.json({ error: e instanceof Error ? e.message : String(e) }, { status: 500 });
  }
}
