"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { motion } from "motion/react";
import { Flame, Swords } from "lucide-react";
import ShareButton from "./ShareButton";
import ResultTiles from "./ResultTiles";
import ChallengeSheet from "./ChallengeSheet";
import { Confetti, CountUp } from "./fx";
import { createChallenge, getChallenge } from "@/lib/api";
import { resultCode } from "@/lib/share";
import type { Challenge, Summary } from "@/lib/types";

const btnPrimary = "btn-pop bg-lime text-ink text-lg";
const btnGhost = "btn-pop bg-white/10 font-bold backdrop-blur";

const pop = (delay: number) => ({
  initial: { opacity: 0, y: 24, scale: 0.9 },
  animate: { opacity: 1, y: 0, scale: 1 },
  transition: { type: "spring" as const, stiffness: 320, damping: 22, delay },
});

function ddmm(day: string) {
  const [, m, d] = day.split("-");
  return `${d}/${m}`;
}

function storedName() {
  try {
    return localStorage.getItem("qdi:name") || null;
  } catch {
    return null;
  }
}

/** Placar "você x quem desafiou", só nas partidas de desafio. */
function Versus({ summary, rival }: { summary: Summary; rival: Challenge }) {
  const who = rival.name || "Quem te desafiou";
  const verdict =
    summary.correct > rival.correct ? "Você venceu" : summary.correct < rival.correct ? `${who} venceu` : "Empate";
  return (
    <motion.div {...pop(0.4)} className="rounded-3xl bg-white/[0.07] p-4 ring-1 ring-white/10 backdrop-blur md:mx-auto md:w-full md:max-w-md">
      <p className="text-center text-xs font-bold uppercase tracking-widest text-white/50">{verdict}</p>
      <div className="mt-2 flex items-center justify-center gap-4 font-display font-black">
        <div className="flex flex-col items-center">
          <span className="text-4xl text-lime">{summary.correct}</span>
          <span className="text-xs font-bold text-white/60">Você</span>
        </div>
        <Swords className="size-6 text-white/40" aria-hidden />
        <div className="flex flex-col items-center">
          <span className="text-4xl">{rival.correct}</span>
          <span className="max-w-32 truncate text-xs font-bold text-white/60">{who}</span>
        </div>
      </div>
      <ResultTiles results={rival.results} size="sm" delay={0.8} className="mt-3" />
    </motion.div>
  );
}

export default function Results({ summary, onReplay }: { summary: Summary; onReplay?: () => void }) {
  const isDaily = summary.mode === "daily";
  const canChallenge = summary.mode !== "shared";
  const [challengeId, setChallengeId] = useState<string | null>(null);
  const [sheet, setSheet] = useState(false);
  const [rival, setRival] = useState<Challenge | null>(null);

  // o desafio já fica criado ao terminar, para o link sair na hora do toque
  useEffect(() => {
    if (!canChallenge) return;
    createChallenge(summary.session_id, storedName())
      .then(setChallengeId)
      .catch(() => {});
  }, [canChallenge, summary.session_id]);

  useEffect(() => {
    if (summary.mode !== "challenge" || !summary.challenge_id) return;
    getChallenge(summary.challenge_id)
      .then(setRival)
      .catch(() => {});
  }, [summary.mode, summary.challenge_id]);

  const getData = () => {
    const origin = window.location.origin;
    const head = isDaily && summary.daily_day ? `Quem Disse Isso? — Desafio do dia ${ddmm(summary.daily_day)}` : "Quem Disse Isso?";
    return {
      title: "Quem Disse Isso?",
      text: `${head}\nAcertei ${summary.correct} de ${summary.total_rounds}. Duvido você acertar mais:`,
      url: `${origin}${challengeId ? `/desafio/${challengeId}` : isDaily ? "/diario" : "/"}`,
    };
  };

  const pct = summary.total_rounds > 0 ? Math.round((100 * summary.correct) / summary.total_rounds) : 0;
  const won = rival ? summary.correct > rival.correct : pct >= 60;

  return (
    <div className="flex flex-1 flex-col gap-6 py-6">
      {won && <Confetti count={40} />}
      <motion.div {...pop(0)} className="text-center">
        <p className="inline-block -rotate-2 rounded-lg bg-white/10 px-3 py-1 font-display text-xs font-bold uppercase tracking-widest text-white/70">
          {isDaily ? "Desafio do dia" : summary.mode === "challenge" ? "Desafio" : "Resultado"}
        </p>
        <p className="mt-3 font-display text-8xl font-black text-lime drop-shadow-[0_6px_0_rgb(0_0_0/0.5)] md:text-9xl">
          <CountUp value={summary.correct} />
          <span className="text-5xl text-white/40 md:text-6xl">/{summary.total_rounds}</span>
        </p>
        <p className="font-display font-bold text-white/60">acertos</p>
      </motion.div>

      <ResultTiles results={summary.results} />

      {rival ? (
        <Versus summary={summary} rival={rival} />
      ) : (
        <dl className="grid grid-cols-2 gap-3 text-center md:mx-auto md:w-full md:max-w-md">
          <motion.div {...pop(0.5)} className="-rotate-1 rounded-3xl bg-white/[0.07] p-4 ring-1 ring-white/10 backdrop-blur">
            <dt className="text-xs font-bold uppercase tracking-wide text-white/50">Aproveitamento</dt>
            <dd className="font-display text-3xl font-black">{pct}%</dd>
          </motion.div>
          <motion.div {...pop(0.6)} className="rotate-1 rounded-3xl bg-white/[0.07] p-4 ring-1 ring-white/10 backdrop-blur">
            <dt className="text-xs font-bold uppercase tracking-wide text-white/50">Maior sequência</dt>
            <dd className="flex items-center justify-center gap-1 font-display text-3xl font-black">
              <Flame className="size-7 fill-pink text-pink" aria-hidden />
              {summary.best_streak}
            </dd>
          </motion.div>
        </dl>
      )}

      <motion.div {...pop(0.75)} className="mt-auto flex flex-col gap-3 md:mx-auto md:w-full md:max-w-md">
        {canChallenge && (
          <button type="button" onClick={() => setSheet(true)} className={`${btnPrimary} flex items-center justify-center gap-2`}>
            <Swords className="size-5" aria-hidden />
            Desafiar um amigo
          </button>
        )}
        <ShareButton
          label="Compartilhar resultado"
          getData={getData}
          image={{
            url: `/api/card/resultado?${new URLSearchParams({
              c: String(summary.correct),
              t: String(summary.total_rounds),
              b: String(summary.best_streak),
              r: resultCode(summary.results),
              ...(isDaily && summary.daily_day ? { d: summary.daily_day } : {}),
            })}`,
            name: "quem-disse-isso-resultado.png",
          }}
          className={canChallenge ? btnGhost : btnPrimary}
        />
        <div className="grid grid-cols-2 gap-3">
          {summary.mode === "solo" && onReplay ? (
            <button type="button" onClick={onReplay} className={btnGhost}>
              Jogar de novo
            </button>
          ) : (
            <Link href="/jogar" className={btnGhost}>
              {summary.mode === "daily" ? "Partida livre" : "Jogar"}
            </Link>
          )}
          <Link href="/" className={btnGhost}>
            Início
          </Link>
        </div>
      </motion.div>

      {canChallenge && (
        <ChallengeSheet
          open={sheet}
          onClose={() => setSheet(false)}
          sessionId={summary.session_id}
          challengeId={challengeId}
          correct={summary.correct}
          total={summary.total_rounds}
        />
      )}
    </div>
  );
}
