import { supabaseAs } from "@/lib/server/supabase";
import type { CategoryInfo } from "@/lib/types";

// Categorias da tela de escolha, com quantos famosos cada uma tem e algumas fotos para a capa.
// Só entram pessoas com foto aprovada (é o que a política de leitura de people libera).
// Pública e igual para todos: pode ficar em cache um pouco.
export async function GET() {
  try {
    const { data, error } = await supabaseAs().from("people").select("category, image_url");
    if (error) return Response.json({ error: error.message }, { status: 400 });

    const byCat = new Map<string, CategoryInfo>();
    for (const r of data ?? []) {
      const c = r.category as string;
      const info = byCat.get(c) ?? { id: c, people: 0, faces: [] };
      info.people += 1;
      if (r.image_url && info.faces.length < 4) info.faces.push(r.image_url as string);
      byCat.set(c, info);
    }
    const categories = [...byCat.values()].sort((a, b) => b.people - a.people || a.id.localeCompare(b.id));
    return Response.json({ data: categories }, { headers: { "Cache-Control": "public, s-maxage=300, stale-while-revalidate=3600" } });
  } catch (e) {
    return Response.json({ error: e instanceof Error ? e.message : String(e) }, { status: 500 });
  }
}
