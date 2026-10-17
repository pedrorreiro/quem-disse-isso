"use client";

import { useEffect, useState } from "react";
import { AnimatePresence, motion } from "motion/react";
import { Swords, X } from "lucide-react";
import ShareButton from "./ShareButton";
import { createChallenge } from "@/lib/api";

const NAME_KEY = "qdi:name";

function loadName() {
  try {
    return localStorage.getItem(NAME_KEY) ?? "";
  } catch {
    return "";
  }
}

function saveName(name: string) {
  try {
    localStorage.setItem(NAME_KEY, name);
  } catch {
    /* sem storage: só não lembra o nome da próxima vez */
  }
}

type Props = {
  open: boolean;
  onClose: () => void;
  sessionId: string;
  challengeId: string | null;
  correct: number;
  total: number;
};

/** Painel "Desafiar um amigo": pede o nome que o amigo vai ver e abre o compartilhamento. */
export default function ChallengeSheet({ open, onClose, sessionId, challengeId, correct, total }: Props) {
  const [name, setName] = useState(loadName);
  const [saved, setSaved] = useState<string | null>(null);

  // grava o nome no desafio pouco depois de parar de digitar (a imagem usa o nome do banco)
  useEffect(() => {
    if (!open || !challengeId) return;
    const clean = name.trim().slice(0, 30);
    if (clean === saved) return;
    const t = setTimeout(() => {
      saveName(clean);
      createChallenge(sessionId, clean || null)
        .then(() => setSaved(clean))
        .catch(() => setSaved(clean));
    }, 450);
    return () => clearTimeout(t);
  }, [open, challengeId, sessionId, name, saved]);

  const ready = !!challengeId && saved === name.trim().slice(0, 30);

  return (
    <AnimatePresence>
      {open && (
        <>
          <motion.div
            key="shade"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 z-40 bg-ink/60 md:backdrop-blur-sm"
            aria-hidden
          />
          <motion.section
            key="sheet"
            role="dialog"
            aria-modal="true"
            aria-labelledby="challenge-title"
            initial={{ y: "110%" }}
            animate={{ y: 0 }}
            exit={{ y: "110%" }}
            transition={{ type: "spring", stiffness: 320, damping: 30 }}
            className="fixed inset-x-0 bottom-0 z-50 px-2 md:px-8"
          >
            <div className="mx-auto flex max-w-md flex-col gap-4 rounded-t-[2rem] bg-[#1d1230]/95 p-5 pb-[max(1.25rem,env(safe-area-inset-bottom))] shadow-[0_-10px_40px_rgb(0_0_0/0.5)] ring-1 ring-white/10 md:backdrop-blur-xl md:p-6">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <h2 id="challenge-title" className="flex items-center gap-2 font-display text-2xl font-black">
                    <Swords className="size-6 text-lime" aria-hidden />
                    Desafiar um amigo
                  </h2>
                  <p className="mt-1 text-sm text-white/60">
                    Quem receber joga as mesmas {total} frases e, no fim, vê se bateu {correct === 1 ? "seu 1 acerto" : `seus ${correct} acertos`}.
                  </p>
                </div>
                <button
                  type="button"
                  onClick={onClose}
                  className="grid size-9 shrink-0 place-items-center rounded-full bg-white/10 text-white/70"
                  aria-label="Fechar"
                >
                  <X className="size-4" />
                </button>
              </div>

              <label className="flex flex-col gap-1.5">
                <span className="text-xs font-bold uppercase tracking-widest text-white/50">Seu nome</span>
                <input
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  maxLength={30}
                  autoComplete="given-name"
                  placeholder="Como seu amigo te conhece"
                  className="rounded-2xl bg-white/10 px-4 py-3 font-display text-lg font-bold outline-none ring-2 ring-transparent placeholder:font-sans placeholder:text-base placeholder:font-normal placeholder:text-white/30 focus:ring-lime"
                />
              </label>

              {challengeId ? (
                <ShareButton
                  label={ready ? "Enviar desafio" : "Preparando…"}
                  className={`btn-pop bg-lime text-lg text-ink ${ready ? "" : "pointer-events-none opacity-60"}`}
                  image={
                    ready
                      ? { url: `/api/card/desafio/${challengeId}?n=${encodeURIComponent(saved ?? "")}`, name: "desafio-quem-disse-isso.png" }
                      : undefined
                  }
                  getData={() => ({
                    title: "Quem Disse Isso?",
                    text: `Acertei ${correct} de ${total} no Quem disse isso? Duvido você bater:`,
                    url: `${window.location.origin}/desafio/${challengeId}`,
                  })}
                />
              ) : (
                <p className="text-center text-sm text-white/50">Criando o desafio…</p>
              )}
            </div>
          </motion.section>
        </>
      )}
    </AnimatePresence>
  );
}
