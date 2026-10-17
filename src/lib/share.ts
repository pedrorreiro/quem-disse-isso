import type { RoundResult } from "./types";

export type ShareOutcome = "shared" | "copied" | "downloaded" | "failed";

type ShareData = { title: string; text: string; url: string };

/**
 * Computador = não é celular nem tablet. Pelo aparelho, e não por `(pointer: coarse)`: alguns
 * navegadores de Mac (o Dia, por exemplo) não respondem a essa consulta como deveriam, e aí a imagem
 * ia junto e o WhatsApp Desktop colava o caminho do arquivo no texto. O iPad se apresenta como Mac,
 * mas tem toque.
 */
const isDesktop = () => {
  if (typeof navigator === "undefined") return false;
  const ua = navigator.userAgent;
  const mobile =
    (navigator as Navigator & { userAgentData?: { mobile?: boolean } }).userAgentData?.mobile ||
    /Android|iPhone|iPad|iPod|Mobile/i.test(ua) ||
    (/Macintosh/.test(ua) && navigator.maxTouchPoints > 1);
  return !mobile;
};

/**
 * Texto com o link numa linha própria. O link vai dentro do texto (e não no campo `url`):
 * alguns apps colam `url` grudado no texto e ele deixa de ser clicável.
 */
const message = (data: ShareData) => `${data.text}\n\n${data.url}`;

/**
 * Celular: folha de compartilhamento nativa com a imagem (quando houver) + texto.
 * Computador: só texto e link. Na folha do macOS o WhatsApp Desktop cola o caminho
 * do arquivo como texto, e a prévia do link já mostra a imagem.
 */
export async function share(data: ShareData, image?: File | null): Promise<ShareOutcome> {
  const text = message(data);
  try {
    if (isDesktop()) {
      if (typeof navigator.share === "function") {
        await navigator.share({ title: data.title, text });
        return "shared";
      }
      await navigator.clipboard.writeText(text);
      return "copied";
    }
    if (image && navigator.canShare?.({ files: [image] })) {
      await navigator.share({ files: [image], title: data.title, text });
      return "shared";
    }
    if (!image && typeof navigator.share === "function") {
      await navigator.share({ title: data.title, text });
      return "shared";
    }
    if (image) {
      const a = document.createElement("a");
      a.href = URL.createObjectURL(image);
      a.download = image.name;
      a.click();
      setTimeout(() => URL.revokeObjectURL(a.href), 5000);
    }
    await navigator.clipboard.writeText(text).catch(() => {});
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
  youtubers: "Youtubers",
  politica: "Política",
  cinema: "Cinema",
  esportes: "Esportes",
  gringos: "Celebridades",
};

export const categoryLabel = (c: string) => CATEGORY_LABELS[c] ?? c.charAt(0).toUpperCase() + c.slice(1);

/** "Contexto, ano" sem repetir o ano quando o contexto já fala dele. */
export function quoteDetail(context: string | null, saidOn: string | null) {
  const year = saidOn?.slice(0, 4);
  return [context, year && !context?.includes(year) ? year : null].filter(Boolean).join(", ");
}
