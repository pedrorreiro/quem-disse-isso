import type { RoundResult } from "./types";

export type ShareOutcome = "shared" | "copied" | "downloaded" | "failed";

type ShareData = { title: string; text: string; url: string };

/**
 * Celular: folha de compartilhamento nativa com a imagem (quando houver) + texto.
 * Desktop: baixa a imagem e copia o texto com o link.
 */
export async function share(data: ShareData, image?: File | null): Promise<ShareOutcome> {
  try {
    if (image && navigator.canShare?.({ files: [image] })) {
      await navigator.share({ files: [image], title: data.title, text: `${data.text}\n${data.url}` });
      return "shared";
    }
    if (!image && typeof navigator.share === "function") {
      await navigator.share(data);
      return "shared";
    }
    if (image) {
      const a = document.createElement("a");
      a.href = URL.createObjectURL(image);
      a.download = image.name;
      a.click();
      setTimeout(() => URL.revokeObjectURL(a.href), 5000);
    }
    await navigator.clipboard.writeText(`${data.text}\n${data.url}`).catch(() => {});
    return image ? "downloaded" : "copied";
  } catch (e) {
    if (e instanceof DOMException && e.name === "AbortError") return "shared"; // usuário fechou a folha
    return "failed";
  }
}

/** Baixa a imagem antes do clique: o navegador só abre a folha de compartilhamento logo após o toque. */
export async function fetchImage(url: string, name: string): Promise<File | null> {
  try {
    const res = await fetch(url);
    if (!res.ok) return null;
    return new File([await res.blob()], name, { type: "image/png" });
  } catch {
    return null;
  }
}

const CODE: Record<RoundResult, string> = { correct: "c", wrong: "w", skipped: "s", pending: "s" };

export const resultCode = (results: RoundResult[]) => results.map((r) => CODE[r]).join("");

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
