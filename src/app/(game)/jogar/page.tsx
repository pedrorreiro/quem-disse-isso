import Game from "@/components/Game";
import { asKind } from "@/lib/kind";

export default async function Jogar({ searchParams }: PageProps<"/jogar">) {
  const { cat, tipo } = await searchParams;
  const category = typeof cat === "string" && cat ? cat : undefined;
  // sem ?tipo, vale o que o jogador escolheu na home (Icônicas por padrão)
  const kind = asKind(tipo);
  return <Game key={`${category ?? "all"}:${kind ?? ""}`} mode="solo" category={category} kind={kind} />;
}
