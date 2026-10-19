import type { Metadata } from "next";
import Game from "@/components/Game";
import { ogDefault } from "@/lib/site";

const title = "Desafio do dia: as mesmas frases para todo mundo";
const description = "Todo dia um desafio novo no Quem Disse Isso? Mesmas frases para todos: jogue, compare o placar e desafie os amigos.";

export const metadata: Metadata = {
  title,
  description,
  alternates: { canonical: "/diario" },
  openGraph: { ...ogDefault, title, description, url: "/diario" },
};

export default function Diario() {
  return <Game mode="daily" />;
}
