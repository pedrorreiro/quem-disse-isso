import type { MetadataRoute } from "next";
import { supabaseAs } from "@/lib/server/supabase";
import { siteUrl } from "@/lib/site";

// lista de frases muda pouco; o Next refaz o sitemap a cada hora
export const revalidate = 3600;

const PAGES = ["", "/jogar", "/diario", "/categorias", "/creditos"];

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const pages: MetadataRoute.Sitemap = PAGES.map((path) => ({ url: `${siteUrl}${path}`, changeFrequency: "daily" }));

  let quotes: { id: string; verified_at: string | null }[] = [];
  try {
    const { data, error } = await supabaseAs().rpc("sitemap_quotes");
    if (!error && data) quotes = data;
  } catch {
    // sem o banco, o sitemap sai só com as páginas fixas
  }

  return [
    ...pages,
    ...quotes.map((q) => ({
      url: `${siteUrl}/q/${q.id}`,
      lastModified: q.verified_at ? new Date(q.verified_at) : undefined,
    })),
  ];
}
