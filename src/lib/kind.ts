/** Tipo da frase: "iconica" (bordão, meme) ou "polemica" (deu repercussão). O padrão do app é Icônicas. */
export type Kind = "iconica" | "polemica";

export const KINDS: Kind[] = ["iconica", "polemica"];
export const KIND_LABELS: Record<Kind, string> = { iconica: "Icônicas", polemica: "Polêmicas" };
/** "frases icônicas", "frases polêmicas" */
export const KIND_ADJ: Record<Kind, string> = { iconica: "icônicas", polemica: "polêmicas" };

export const asKind = (v: unknown): Kind | undefined => (v === "iconica" || v === "polemica" ? v : undefined);

const KEY = "qdi:tipo";
// com o storage bloqueado, a escolha vale só nesta visita
let memory: Kind | undefined;
const listeners = new Set<() => void>();

export function storedKind(): Kind {
  try {
    return asKind(localStorage.getItem(KEY)) ?? memory ?? "iconica";
  } catch {
    return memory ?? "iconica";
  }
}

export function setStoredKind(k: Kind) {
  memory = k;
  try {
    localStorage.setItem(KEY, k);
  } catch {
    /* storage bloqueado */
  }
  listeners.forEach((l) => l());
}

export function subscribeKind(cb: () => void) {
  listeners.add(cb);
  window.addEventListener("storage", cb);
  return () => {
    listeners.delete(cb);
    window.removeEventListener("storage", cb);
  };
}
