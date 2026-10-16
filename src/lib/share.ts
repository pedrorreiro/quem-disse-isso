import type { RoundResult } from "./types";

export type ShareOutcome = "shared" | "copied" | "failed";

/** Folha de compartilhamento nativa no celular; copia o texto no desktop. */
export async function share(data: { title: string; text: string; url: string }): Promise<ShareOutcome> {
  try {
    if (typeof navigator.share === "function") {
      await navigator.share(data);
      return "shared";
    }
    await navigator.clipboard.writeText(`${data.text}\n${data.url}`);
    return "copied";
  } catch (e) {
    if (e instanceof DOMException && e.name === "AbortError") return "shared"; // usuário fechou a folha
    return "failed";
  }
}

const EMOJI: Record<RoundResult, string> = { correct: "🟩", wrong: "🟥", skipped: "⬜", pending: "⬜" };

export const resultEmojis = (results: RoundResult[]) => results.map((r) => EMOJI[r]).join("");

export const CATEGORY_LABELS: Record<string, string> = {
  futebol: "Futebol",
  musica: "Música",
  tv: "TV e Novela",
  internet: "Internet",
  politica: "Política",
  cinema: "Cinema",
  esportes: "Esportes",
  gringos: "Celebridades gringas",
};

export const categoryLabel = (c: string) => CATEGORY_LABELS[c] ?? c.charAt(0).toUpperCase() + c.slice(1);
