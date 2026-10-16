"use client";

import { useState } from "react";
import Link from "next/link";
import { motion } from "motion/react";
import { Swords } from "lucide-react";
import Game from "./Game";
import ResultTiles from "./ResultTiles";
import type { Challenge } from "@/lib/types";

/** Tela de entrada do link de desafio: mostra o placar de quem desafiou e começa a partida. */
export default function ChallengeIntro({ id, challenge }: { id: string; challenge: Challenge | null }) {
  const [started, setStarted] = useState(false);

  if (started) return <Game mode="challenge" challengeId={id} />;

  if (!challenge) {
    return (
      <div className="m-auto flex max-w-xs flex-col gap-4 text-center">
        <p className="text-white/80">Esse desafio não existe (ou o link veio cortado).</p>
        <Link href="/jogar" className="btn-pop bg-lime text-ink">
          Jogar uma partida
        </Link>
      </div>
    );
  }

  const who = challenge.name ?? "Alguém";
  return (
    <div className="flex flex-1 flex-col justify-center gap-8 py-10 text-center">
      <motion.div
        initial={{ scale: 0, rotate: -30 }}
        animate={{ scale: 1, rotate: -8 }}
        transition={{ type: "spring", stiffness: 400, damping: 12 }}
        className="mx-auto grid size-16 place-items-center rounded-2xl bg-pink text-white shadow-[0_5px_0_0_rgb(0_0_0/0.5)]"
        aria-hidden
      >
        <Swords className="size-8" />
      </motion.div>

      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.15 }}>
        <p className="font-display text-sm font-bold uppercase tracking-widest text-white/60">Desafio</p>
        <h1 className="mt-2 font-display text-4xl font-black leading-tight md:text-6xl">
          <span className="text-lime">{who}</span> te desafiou
        </h1>
        <p className="mt-3 text-white/70">
          Acertou <strong className="text-white">{challenge.correct} de {challenge.total_rounds}</strong> frases. Você
          joga as mesmas, na mesma ordem.
        </p>
      </motion.div>

      <ResultTiles results={challenge.results} delay={0.4} />

      <motion.div
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ type: "spring", stiffness: 260, damping: 22, delay: 0.7 }}
        className="flex flex-col gap-3 md:mx-auto md:w-full md:max-w-md"
      >
        <button
          type="button"
          onClick={() => setStarted(true)}
          className="btn-pop flex items-center justify-center gap-2 bg-lime py-5 font-display text-2xl font-black text-ink"
        >
          <Swords className="size-6" aria-hidden />
          Aceitar desafio
        </button>
        <Link href="/" className="text-sm text-white/50 underline">
          O que é isso?
        </Link>
      </motion.div>
    </div>
  );
}
