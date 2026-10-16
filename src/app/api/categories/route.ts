import { supabaseAs } from "@/lib/server/supabase";

// Categorias da tela inicial. Pública e igual para todos: pode ficar em cache um pouco.
export async function GET() {
  try {
    const { data, error } = await supabaseAs().from("people").select("category");
    if (error) return Response.json({ error: error.message }, { status: 400 });
    const categories = [...new Set((data ?? []).map((r) => r.category as string))].sort();
    return Response.json({ data: categories }, { headers: { "Cache-Control": "public, s-maxage=300, stale-while-revalidate=3600" } });
  } catch (e) {
    return Response.json({ error: e instanceof Error ? e.message : String(e) }, { status: 500 });
  }
}
