import type { Metadata } from "next";
import CategoryGrid from "@/components/CategoryGrid";
import { ogDefault } from "@/lib/site";

const title = "Categorias: futebol, política, BBB, música e mais";
const description =
  "Escolha o tema e adivinhe quem disse cada frase: futebol, política, TV e novela, Reality Show, música, youtubers, internet e celebridades.";

export const metadata: Metadata = {
  title,
  description,
  alternates: { canonical: "/categorias" },
  openGraph: { ...ogDefault, title, description, url: "/categorias" },
};

export default function CategoriasPage() {
  return <CategoryGrid />;
}
