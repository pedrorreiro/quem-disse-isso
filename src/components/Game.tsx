"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import Link from "next/link";
import { AnimatePresence, motion } from "motion/react";
import OptionCard, { type CardState } from "./OptionCard";
import Results from "./Results";
import ShareButton from "./ShareButton";
import { Confetti, CountUp, buzz } from "./fx";
import {
  answerRound,
  eliminateOption,
  friendlyError,
  nextRound,
  playJoker,
  startGame,
} from "@/lib/api";
import type { GameMode, JokerName, Jokers, Reveal, Round, Summary } from "@/lib/types";

type Phase = "loading" | "question" | "answering" | "reveal" | "finished" | "error";

type Props = { mode: GameMode; category?: string; quoteId?: string };

const btnPrimary = "btn-pop bg-lime text-ink";
const btnGhost = "btn-pop bg-white/10 font-bold backdrop-blur";

const JOKERS: { name: JokerName; label: string; icon: string }[] = [
  { name: "fifty", label: "50/50", icon: "🌓" },
  { name: "time", label: "+5s", icon: "⏱️" },
  { name: "skip", label: "Pular", icon: "⏭️" },
];

// frases longas ganham fonte menor para caber sem rolar
function quoteSize(text: string) {
  if (text.length > 160) return "text-xl md:text-3xl";
  if (text.length > 90) return "text-2xl md:text-4xl";
  return "text-3xl md:text-5xl";
}

function storage(key: string, value?: string | null): string | null {
  try {
    if (value === undefined) return sessionStorage.getItem(key);
    if (value === null) sessionStorage.removeItem(key);
    else sessionStorage.setItem(key, value);
  } catch {
    /* modo privado / storage bloqueado: o jogo funciona sem retomar */
  }
  return null;
}

export default function Game({ mode, category, quoteId }: Props) {
  const [phase, setPhase] = useState<Phase>("loading");
  const [error, setError] = useState("");
  const [round, setRound] = useState<Round | null>(null);
  const [eliminated, setEliminated] = useState<string[]>([]);
  const [jokers, setJokers] = useState<Jokers>({});
  const [totalSeconds, setTotalSeconds] = useState(20);
  const [deadline, setDeadline] = useState(0);
  const [now, setNow] = useState(0);
  const [score, setScore] = useState(0);
  const [streak, setStreak] = useState(0);
  const [reveal, setReveal] = useState<Reveal | null>(null);
  const [summary, setSummary] = useState<Summary | null>(null);

  const sessionId = useRef<string | null>(null);
  const busy = useRef(false);
  const autoElim = useRef(0);
  const started = useRef(false);
  const storageKey = `qdi:sid:${mode}:${category ?? ""}:${quoteId ?? ""}`;

  const fail = useCallback((e: unknown) => {
    busy.current = false;
    setError(friendlyError(e));
    setPhase("error");
  }, []);

  const loadRound = useCallback(
    async (sid: string) => {
      const r = await nextRound(sid);
      busy.current = false;
      if (r.finished) {
        storage(storageKey, null);
        setSummary(r);
        setPhase("finished");
        return;
      }
      const t = Date.now();
      setRound(r);
      setEliminated(r.eliminated);
      setJokers(r.jokers);
      setTotalSeconds(r.total_seconds);
      setScore(r.score);
      setStreak(r.streak);
      setReveal(null);
      setNow(t);
      setDeadline(t + r.seconds_left * 1000);
      autoElim.current = 0;
      setPhase("question");
    },
    [storageKey],
  );

  const begin = useCallback(
    async (fresh: boolean) => {
      setPhase("loading");
      try {
        // No solo, recarregar a página retoma a partida em andamento (o relógio é do servidor).
        const saved = !fresh && mode === "solo" ? storage(storageKey) : null;
        if (saved) {
          try {
            sessionId.current = saved;
            await loadRound(saved);
            return;
          } catch {
            storage(storageKey, null);
          }
        }
        const sid = await startGame(mode, { category, quoteId });
        sessionId.current = sid;
        if (mode === "solo") storage(storageKey, sid);
        await loadRound(sid);
      } catch (e) {
        fail(e);
      }
    },
    [mode, category, quoteId, storageKey, loadRound, fail],
  );

  useEffect(() => {
    if (started.current) return;
    started.current = true;
    void begin(false);
  }, [begin]);

  // relógio de exibição (a validação do tempo é feita no servidor)
  useEffect(() => {
    if (phase !== "question") return;
    const id = setInterval(() => setNow(Date.now()), 100);
    return () => clearInterval(id);
  }, [phase]);

  const remaining = Math.max(0, (deadline - now) / 1000);

  const answer = useCallback(
    async (personId: string | null) => {
      if (!round || busy.current) return;
      busy.current = true;
      setPhase("answering");
      try {
        const r = await answerRound(round.round_id, personId);
        busy.current = false;
        setReveal(r);
        setScore(r.score);
        setStreak(r.streak);
        setPhase("reveal");
        buzz(r.correct ? 30 : [40, 40, 40]);
      } catch (e) {
        fail(e);
      }
    },
    [round, fail],
  );

  // tempo esgotado (reagendado se o curinga +5s mudar o prazo)
  useEffect(() => {
    if (phase !== "question") return;
    const id = setTimeout(() => void answer(null), Math.max(0, deadline - Date.now()));
    return () => clearTimeout(id);
  }, [phase, deadline, answer]);

  // eliminação automática: uma opção errada some a cada terço do tempo (custa pontos)
  useEffect(() => {
    if (phase !== "question" || !round || busy.current) return;
    const elapsed = 1 - remaining / totalSeconds;
    const target = elapsed >= 2 / 3 ? 2 : elapsed >= 1 / 3 ? 1 : 0;
    if (target <= autoElim.current) return;
    autoElim.current = target;
    if (eliminated.length >= 2) return;
    eliminateOption(round.round_id)
      .then(setEliminated)
      .catch(() => {});
  }, [phase, round, remaining, totalSeconds, eliminated.length]);

  // desktop: 1–4 escolhem a carta, Enter avança
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.metaKey || e.ctrlKey || e.altKey || (e.target as HTMLElement).closest("input, textarea")) return;
      if (phase === "question" && round && /^[1-4]$/.test(e.key)) {
        const o = round.options[Number(e.key) - 1];
        if (o && !eliminated.includes(o.id)) void answer(o.id);
      } else if (phase === "reveal" && e.key === "Enter") {
        e.preventDefault();
        void advanceRef.current();
      }
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [phase, round, eliminated, answer]);

  async function triggerJoker(name: JokerName) {
    if (!round || busy.current || (jokers[name] ?? 0) < 1) return;
    busy.current = true;
    try {
      const r = await playJoker(round.round_id, name);
      setJokers(r.jokers);
      if (name === "skip") {
        await loadRound(sessionId.current!);
        return;
      }
      setEliminated(r.eliminated);
      if (name === "time") {
        setTotalSeconds(r.total_seconds);
        setDeadline((d) => d + 5000);
      }
      busy.current = false;
    } catch (e) {
      fail(e);
    }
  }

  const advanceRef = useRef(advance);
  useEffect(() => {
    advanceRef.current = advance;
  });

  async function advance() {
    if (busy.current || !sessionId.current) return;
    busy.current = true;
    try {
      await loadRound(sessionId.current);
    } catch (e) {
      fail(e);
    }
  }


  if (phase === "loading") {
    return (
      <div className="m-auto flex flex-col items-center gap-4" role="status" aria-label="Carregando">
        <div className="flex gap-2">
          {["bg-lime", "bg-pink", "bg-cyan"].map((c, i) => (
            <motion.span
              key={c}
              className={`size-4 rounded-full ${c}`}
              animate={{ y: [0, -14, 0] }}
              transition={{ duration: 0.6, repeat: Infinity, delay: i * 0.12, ease: "easeInOut" }}
            />
          ))}
        </div>
        <p className="font-display text-sm font-bold text-white/60">Embaralhando as frases…</p>
      </div>
    );
  }

  if (phase === "error") {
    return (
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        className="m-auto flex max-w-xs flex-col gap-4 text-center"
      >
        <p className="text-white/80">{error}</p>
        <button type="button" className={btnPrimary} onClick={() => void begin(true)}>
          Tentar de novo
        </button>
        <Link href="/" className={btnGhost}>
          Início
        </Link>
      </motion.div>
    );
  }

  if (phase === "finished" && summary) {
    return <Results summary={summary} onReplay={() => void begin(true)} />;
  }

  if (!round) return null;

  const revealed = phase === "reveal" && reveal;
  const fraction = revealed ? 0 : remaining / totalSeconds;
  const lowTime = fraction < 0.25;
  const multiplier = 1 + Math.min(streak, 4) * 0.25;
  const words = round.quote_text.split(/\s+/);

  function cardState(id: string): CardState {
    if (revealed) {
      if (id === reveal.person.id) return "correct";
      if (id === reveal.chosen_person_id) return "wrong";
      return "dimmed";
    }
    return eliminated.includes(id) ? "eliminated" : "idle";
  }

  return (
    <div className="flex flex-1 flex-col gap-4 py-4 md:justify-center md:py-10">
      <header className="flex items-center justify-between gap-3">
        <Link
          href="/"
          className="grid size-10 place-items-center rounded-full bg-white/10 text-white/70 transition hover:bg-white/20"
          aria-label="Voltar ao início"
        >
          ✕
        </Link>

        {/* progresso: uma bolinha por rodada */}
        <div className="flex flex-1 justify-center gap-1.5" aria-label={`Rodada ${round.position} de ${round.total_rounds}`}>
          {Array.from({ length: round.total_rounds }, (_, i) => (
            <motion.span
              key={i}
              layout
              className={`h-2 rounded-full ${
                i + 1 < round.position ? "bg-white/60" : i + 1 === round.position ? "bg-lime" : "bg-white/15"
              }`}
              animate={{ width: i + 1 === round.position ? 22 : 8 }}
            />
          ))}
        </div>

        <div className="flex items-center gap-2">
          <AnimatePresence>
            {streak > 1 && (
              <motion.span
                key={streak}
                initial={{ scale: 0, rotate: -30 }}
                animate={{ scale: 1, rotate: -6 }}
                exit={{ scale: 0 }}
                transition={{ type: "spring", stiffness: 500, damping: 15 }}
                className="rounded-full bg-pink px-2.5 py-1 font-display text-xs font-black text-white shadow-[0_3px_0_0_rgb(0_0_0/0.5)]"
              >
                🔥 x{multiplier.toFixed(2).replace(/\.?0+$/, "")}
              </motion.span>
            )}
          </AnimatePresence>
          <span className="rounded-full bg-white/10 px-3 py-1 font-display text-lg font-black tabular-nums text-lime">
            <CountUp value={score} />
          </span>
        </div>
      </header>

      {/* barra de tempo */}
      <div className="flex items-center gap-3" aria-hidden>
        <div className="h-3 flex-1 overflow-hidden rounded-full bg-white/10">
          <motion.div
            className={`h-full rounded-full ${lowTime ? "bg-pink" : "bg-gradient-to-r from-cyan to-lime"}`}
            style={{ width: `${fraction * 100}%` }}
            animate={lowTime && !revealed ? { opacity: [1, 0.45, 1] } : { opacity: 1 }}
            transition={lowTime ? { duration: 0.6, repeat: Infinity } : undefined}
          />
        </div>
        <span
          className={`w-9 text-right font-display text-sm font-black tabular-nums ${lowTime && !revealed ? "text-pink" : "text-white/60"}`}
        >
          {Math.ceil(revealed ? 0 : remaining)}s
        </span>
      </div>

      <AnimatePresence mode="wait">
        <motion.div
          key={round.round_id}
          initial={{ opacity: 0, x: 60 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: -60, transition: { duration: 0.2 } }}
          transition={{ type: "spring", stiffness: 260, damping: 26 }}
          className="flex flex-col gap-4"
        >
          <blockquote className="relative rounded-[2rem] bg-white/[0.07] p-6 pt-8 ring-1 ring-white/10 backdrop-blur-md md:p-10">
            <motion.span
              aria-hidden
              initial={{ scale: 0, rotate: -40 }}
              animate={{ scale: 1, rotate: -10 }}
              transition={{ type: "spring", stiffness: 400, damping: 12, delay: 0.1 }}
              className="absolute -left-2 -top-4 grid size-12 place-items-center rounded-2xl bg-pink font-display text-4xl font-black leading-none text-white shadow-[0_4px_0_0_rgb(0_0_0/0.5)]"
            >
              “
            </motion.span>
            <p className={`font-display font-extrabold leading-[1.15] tracking-tight ${quoteSize(round.quote_text)}`}>
              <span className="sr-only">{round.quote_text}</span>
              <span aria-hidden>
                {words.map((w, i) => (
                  <motion.span
                    key={i}
                    className="inline-block"
                    initial={{ opacity: 0, y: 14, filter: "blur(6px)" }}
                    animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
                    transition={{ duration: 0.3, delay: Math.min(i * 0.035, 0.9) }}
                  >
                    {w}&nbsp;
                  </motion.span>
                ))}
              </span>
            </p>
          </blockquote>

          <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
            {round.options.map((o, idx) => (
              <OptionCard
                key={o.id}
                option={o}
                index={idx}
                state={cardState(o.id)}
                disabled={phase !== "question" || eliminated.includes(o.id)}
                onPick={(id) => void answer(id)}
              />
            ))}
          </div>
        </motion.div>
      </AnimatePresence>

      {phase !== "reveal" && (
        <div className="flex justify-center gap-2">
          {JOKERS.filter(({ name }) => name in jokers).map(({ name, label, icon }) => (
            <motion.button
              key={name}
              type="button"
              whileTap={{ scale: 0.9, rotate: -4 }}
              disabled={phase !== "question" || (jokers[name] ?? 0) < 1}
              onClick={() => void triggerJoker(name)}
              className="btn-pop flex items-center gap-1.5 rounded-full bg-white/10 px-4 py-2 text-sm backdrop-blur"
            >
              <span aria-hidden>{icon}</span>
              {label}
              <span className="grid size-5 place-items-center rounded-full bg-white/15 text-xs">{jokers[name] ?? 0}</span>
            </motion.button>
          ))}
        </div>
      )}

      {revealed && reveal.correct && <Confetti key={reveal.quote_id} />}

      <AnimatePresence>
        {revealed && (
          <motion.section
            key={reveal.quote_id}
            initial={{ y: 80, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ type: "spring", stiffness: 300, damping: 26 }}
            className={`mt-auto flex flex-col gap-3 rounded-[2rem] p-4 ring-2 backdrop-blur-md md:mt-2 md:p-6 ${
              reveal.correct ? "bg-lime/10 ring-lime/60" : "bg-pink/10 ring-pink/60"
            }`}
          >
            <div className="flex items-center justify-between">
              <motion.h2
                initial={{ scale: 0.6, rotate: -6 }}
                animate={{ scale: 1, rotate: -2 }}
                transition={{ type: "spring", stiffness: 500, damping: 14, delay: 0.1 }}
                className={`rounded-xl px-3 py-1 font-display text-xl font-black uppercase ${
                  reveal.correct ? "bg-lime text-ink" : "bg-pink text-white"
                }`}
              >
                {reveal.timed_out ? "Tempo esgotado" : reveal.correct ? "Correto" : "Errado"}
              </motion.h2>
              {reveal.correct && (
                <motion.span
                  initial={{ y: 20, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  transition={{ delay: 0.25 }}
                  className="font-display text-2xl font-black text-lime"
                >
                  +{reveal.points}
                  {reveal.multiplier > 1 && <span className="ml-1 text-sm">x{reveal.multiplier}</span>}
                </motion.span>
              )}
            </div>
            <p>
              <span className="font-display text-lg font-bold">{reveal.person.name}</span>
              {(reveal.quote.context || reveal.quote.said_on) && (
                <span className="text-sm text-white/60">
                  {" "}
                  — {[reveal.quote.context, reveal.quote.said_on?.slice(0, 4)].filter(Boolean).join(", ")}
                </span>
              )}
            </p>
            <div className="grid grid-cols-2 gap-2">
              <a href={reveal.quote.source_url} target="_blank" rel="noopener noreferrer" className={`${btnGhost} text-sm`}>
                Ver fonte{reveal.quote.source_timestamp ? ` (${reveal.quote.source_timestamp})` : ""} ↗
              </a>
              <ShareButton
                label="Compartilhar"
                className={`${btnGhost} text-sm`}
                getData={() => ({
                  title: "Quem Disse Isso?",
                  text: `Quem disse isso? “${reveal.quote.text}”`,
                  url: `${window.location.origin}/q/${reveal.quote_id}`,
                })}
              />
            </div>
            {reveal.person.image_credit && (
              <p className="text-center text-xs text-white/40">
                Foto: {reveal.person.image_credit}
                {reveal.person.image_license && ` · ${reveal.person.image_license}`}
              </p>
            )}
            {reveal.quote.archive_url && (
              <a
                href={reveal.quote.archive_url}
                target="_blank"
                rel="noopener noreferrer"
                className="text-center text-xs text-white/40 underline"
              >
                Fonte arquivada
              </a>
            )}
            <button type="button" onClick={() => void advance()} className={`${btnPrimary} text-lg`}>
              {reveal.finished ? "Ver resultado" : "Próxima →"}
              <kbd className="ml-2 hidden text-xs font-normal opacity-60 md:inline">Enter</kbd>
            </button>
          </motion.section>
        )}
      </AnimatePresence>
    </div>
  );
}
