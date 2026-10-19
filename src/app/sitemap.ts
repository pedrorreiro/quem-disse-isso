import type { MetadataRoute } from "next";
import { supabaseAs } from "@/lib/server/supabase";
import { siteUrl } from "@/lib/site";

// lista de frases muda pouco; o Next refaz o sitemap a cada hora
export const revalidate = 3600;

const PAGES = ["", "/jogar", "/diario", "/categorias", "/creditos"];

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const pages: MetadataRoute.Sitemap = PAGES.map((path) => ({ url: `${siteUrl}${path}`, changeFrequency: "daily" }));

  let quotes: { id: string; verified_at: string | null }[] = [];
  let people: { slug: string; verified_at: string | null }[] = [];
  try {
    const db = supabaseAs();
    const [q, p] = await Promise.all([db.rpc("sitemap_quotes"), db.rpc("sitemap_people")]);
    if (!q.error && q.data) quotes = q.data;
    if (!p.error && p.data) people = p.data;
  } catch {
    // sem o banco, o sitemap sai só com as páginas fixas
  }

  return [
    ...pages,
    ...people.map((p) => ({
      url: `${siteUrl}/famoso/${p.slug}`,
      lastModified: p.verified_at ? new Date(p.verified_at) : undefined,
    })),
    ...quotes.map((q) => ({
      url: `${siteUrl}/q/${q.id}`,
      lastModified: q.verified_at ? new Date(q.verified_at) : undefined,
    })),
  ];
}
