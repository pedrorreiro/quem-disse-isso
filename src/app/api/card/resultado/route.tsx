import { resultStory } from "@/lib/result-story";

// Imagem do resultado da partida para compartilhar. Tudo vem da URL:
// não há nada secreto aqui, é só o placar que o próprio jogador vê.
const int = (v: string | null, max: number) => Math.min(max, Math.max(0, Number.parseInt(v ?? "", 10) || 0));

export function GET(req: Request) {
  const q = new URL(req.url).searchParams;
  const total = int(q.get("t"), 30);
  const correct = Math.min(int(q.get("c"), 30), total);
  const best = int(q.get("b"), 30);
  const results = (q.get("r") ?? "").replace(/[^cws]/g, "").slice(0, 30).split("").filter(Boolean);
  const day = /^\d{4}-\d{2}-\d{2}$/.test(q.get("d") ?? "") ? q.get("d")!.split("-").reverse().slice(0, 2).join("/") : null;

  const host = new URL(req.url).host.replace(/^www\./, "");

  return resultStory({
    correct,
    total,
    best,
    results,
    label: day ? `Desafio do dia ${day}` : "Meu resultado",
    cta: "Duvido você acertar mais.",
    host,
    cacheControl: "public, max-age=31536000, immutable",
  });
}
