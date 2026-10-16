import { currentUser } from "@/lib/server/supabase";

export async function GET() {
  try {
    return Response.json({ user: await currentUser() });
  } catch (e) {
    return Response.json({ error: e instanceof Error ? e.message : String(e) }, { status: 500 });
  }
}
