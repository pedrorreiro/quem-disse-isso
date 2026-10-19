import type { Metadata } from "next";
import Game from "@/components/Game";
import { asKind } from "@/lib/kind";
import { ogDefault } from "@/lib/site";

const title = "Jogar: adivinhe quem disse a frase";
const description = "Aparece uma frase de famoso, político ou influenciador e você tem segundos para adivinhar quem disse. Grátis e sem cadastro.";

// ?cat e ?tipo mudam só o sorteio: todas as variações apontam para /jogar
export const metadata: Metadata = {
  title,
  description,
  alternates: { canonical: "/jogar" },
  openGraph: { ...ogDefault, title, description, url: "/jogar" },
};

export default async function Jogar({ searchParams }: PageProps<"/jogar">) {
  const { cat, tipo } = await searchParams;
  const category = typeof cat === "string" && cat ? cat : undefined;
  // sem ?tipo, vale o que o jogador escolheu na home (Icônicas por padrão)
  const kind = asKind(tipo);
  return <Game key={`${category ?? "all"}:${kind ?? ""}`} mode="solo" category={category} kind={kind} />;
}
