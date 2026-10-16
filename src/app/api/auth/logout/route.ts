import { clearSession } from "@/lib/server/supabase";

export async function POST() {
  await clearSession();
  return Response.json({ ok: true });
}
