import { getChallengePublic } from "@/lib/preview";
import { resultStory } from "@/lib/result-story";

// Imagem do desafio: o resultado vem do banco (não dá para inventar placar pela URL).
export async function GET(req: Request, ctx: RouteContext<"/api/card/desafio/[id]">) {
  const { id } = await ctx.params;
  const c = await getChallengePublic(id);
  if (!c) return new Response("not found", { status: 404 });
  return resultStory({
    correct: c.correct,
    total: c.total_rounds,
    best: c.best_streak,
    results: c.results,
    label: c.name ? `${c.name} te desafia` : "Desafio",
    cta: "Consegue bater?",
    host: new URL(req.url).host.replace(/^www\./, ""),
    // o nome pode mudar logo após criar o desafio; o link de compartilhamento já muda junto (?n=)
    cacheControl: "public, max-age=300",
  });
}
