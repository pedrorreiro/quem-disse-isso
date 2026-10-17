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
};

const NOTES = {
  copied: "Link copiado!",
  downloaded: "Imagem baixada e link copiado!",
  failed: "Não consegui compartilhar.",
} as const;

export default function ShareButton({ label, getData, image, className = "", compact = false }: Props) {
  const [note, setNote] = useState<string | null>(null);
  const [file, setFile] = useState<File | null>(null);
  const pending = useRef<Promise<File | null>>(Promise.resolve(null));
  const imageUrl = image?.url;
  const imageName = image?.name;

  // pré-carrega a imagem: o navegador só libera a folha de compartilhamento logo após o toque
  useEffect(() => {
    if (!imageUrl || !imageName) return;
    let live = true;
    pending.current = fetchImage(imageUrl, imageName);
    void pending.current.then((f) => live && setFile(f));
    return () => {
      live = false;
    };
  }, [imageUrl, imageName]);

  async function onClick() {
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
