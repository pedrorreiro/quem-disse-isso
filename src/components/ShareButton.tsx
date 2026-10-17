"use client";

import { useEffect, useRef, useState } from "react";
import { Share2 } from "lucide-react";
import { fetchImage, share } from "@/lib/share";

type Props = {
  label: string;
  getData: () => { title: string; text: string; url: string };
  /** Imagem gerada no servidor que vai junto no compartilhamento. */
  image?: { url: string; name: string };
  className?: string;
  /** No celular mostra só o ícone (o texto fica para leitores de tela). */
  compact?: boolean;
  /** Espera (ms) antes de pré-carregar a imagem. */
  prefetchDelay?: number;
};

const NOTES = {
  copied: "Link copiado!",
  downloaded: "Imagem baixada e link copiado!",
  failed: "Não consegui compartilhar.",
} as const;

export default function ShareButton({ label, getData, image, className = "", compact = false, prefetchDelay = 0 }: Props) {
  const [note, setNote] = useState<string | null>(null);
  const [file, setFile] = useState<File | null>(null);
  const pending = useRef<Promise<File | null>>(Promise.resolve(null));
  const imageUrl = image?.url;
  const imageName = image?.name;

  // inicia o download agora, se o atraso ainda não venceu (o toque não espera o timer)
  const kick = useRef<() => void>(() => {});

  // pré-carrega a imagem: o navegador só libera a folha de compartilhamento logo após o toque.
  // Com prefetchDelay, espera antes de baixar (a imagem tem ~500 KB e leva ~1 s para ser gerada),
  // para não disputar rede e processador com o jogo; sair da tela cancela o download.
  useEffect(() => {
    if (!imageUrl || !imageName) return;
    const ctrl = new AbortController();
    let resolve: (f: File | null) => void = () => {};
    pending.current = new Promise((r) => (resolve = r));
    void pending.current.then((f) => !ctrl.signal.aborted && setFile(f));
    let started = false;
    const start = () => {
      if (started) return;
      started = true;
      void fetchImage(imageUrl, imageName, ctrl.signal).then(resolve);
    };
    kick.current = start;
    const timer = setTimeout(start, prefetchDelay);
    return () => {
      clearTimeout(timer);
      ctrl.abort();
      resolve(null);
    };
  }, [imageUrl, imageName, prefetchDelay]);

  async function onClick() {
    kick.current();
    // toque antes de a imagem chegar: espera o download em vez de mandar só o link
    const outcome = await share(getData(), file ?? (await pending.current));
    if (outcome === "shared") return;
    setNote(NOTES[outcome]);
    setTimeout(() => setNote(null), 2400);
  }

  return (
    <button
      type="button"
      onClick={onClick}
      aria-label={compact ? label : undefined}
      className={`inline-flex items-center justify-center gap-2 ${className}`}
    >
      <Share2 className="size-4 shrink-0" aria-hidden />
      {note ? (
        <span className={compact ? "sr-only sm:not-sr-only" : ""} role="status">
          {note}
        </span>
      ) : (
        <span className={compact ? "hidden sm:inline" : ""}>{label}</span>
      )}
    </button>
  );
}
