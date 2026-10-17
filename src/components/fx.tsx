"use client";

import { useEffect } from "react";
import { MotionConfig, animate, motion, useMotionValue, useTransform } from "motion/react";

/** Respeita "reduzir movimento" do sistema em todo o jogo. */
export function MotionRoot({ children }: { children: React.ReactNode }) {
  return <MotionConfig reducedMotion="user">{children}</MotionConfig>;
}

/** Fundo com manchas de cor em movimento (CSS puro, fica atrás de tudo). */
export function Backdrop() {
  return (
    <div aria-hidden className="pointer-events-none fixed inset-0 -z-10 overflow-hidden">
      <div className="blob left-[-15%] top-[-10%] size-[60vmax] bg-grape" />
      <div className="blob right-[-20%] top-[20%] size-[50vmax] bg-pink [animation-delay:-7s]" />
      <div className="blob bottom-[-25%] left-[10%] size-[45vmax] bg-cyan/60 [animation-delay:-14s]" />
      <div className="grain" />
    </div>
  );
}

/** Número que "conta" até o valor novo. */
export function CountUp({ value, className }: { value: number; className?: string }) {
  const mv = useMotionValue(value);
  const text = useTransform(mv, (v) => Math.round(v).toLocaleString("pt-BR"));
  useEffect(() => {
    const controls = animate(mv, value, { duration: 0.8, ease: "easeOut" });
    return () => controls.stop();
  }, [mv, value]);
  return <motion.span className={className}>{text}</motion.span>;
}

const CONFETTI_COLORS = ["#c8ff2e", "#ff4fb8", "#3ee6ff", "#ffd43b", "#a78bfa"];

/** Explosão de confete (posições determinísticas, sem dependência externa). */
export function Confetti({ count = 28 }: { count?: number }) {
  return (
    <div aria-hidden className="pointer-events-none fixed inset-0 z-50 flex items-center justify-center overflow-hidden">
      {Array.from({ length: count }, (_, i) => {
        const angle = (i * 137.5 * Math.PI) / 180;
        const dist = 140 + ((i * 53) % 160);
        const x = Math.cos(angle) * dist;
        const y = Math.sin(angle) * dist - 80;
        const wide = i % 3 === 0;
        return (
          <motion.span
            key={i}
            className="absolute rounded-sm"
            style={{
              width: wide ? 14 : 8,
              height: wide ? 6 : 12,
              background: CONFETTI_COLORS[i % CONFETTI_COLORS.length],
            }}
            initial={{ x: 0, y: 0, opacity: 1, rotate: 0, scale: 0.4 }}
            animate={{ x, y: [y, y + 260], opacity: [1, 1, 0], rotate: (i % 2 ? 1 : -1) * (180 + i * 20), scale: 1 }}
            transition={{ duration: 1.3, ease: [0.15, 0.6, 0.35, 1], times: [0, 0.7, 1] }}
          />
        );
      })}
    </div>
  );
}

/** Vibração curta no celular (ignorada onde não existe). */
export function buzz(pattern: number | number[]) {
  try {
    navigator.vibrate?.(pattern);
  } catch {
    /* sem suporte */
  }
}

// ── Sons ──────────────────────────────────────────────────────────────────────
// Poucos e curtos, sintetizados na hora (sem arquivos): acerto, erro e fim da partida.
// O jogador pode desligar; a escolha fica neste navegador.

const MUTE_KEY = "qdi:som";
let audio: AudioContext | null = null;

export function soundOn() {
  try {
    return localStorage.getItem(MUTE_KEY) !== "off";
  } catch {
    return true;
  }
}

export function setSoundOn(on: boolean) {
  try {
    localStorage.setItem(MUTE_KEY, on ? "on" : "off");
  } catch {
    /* storage bloqueado: vale só nesta visita */
  }
}

/** Notas: [frequência em Hz, início em s, duração em s]. */
type Note = [number, number, number];

const SOUNDS: Record<"acerto" | "erro" | "fim", { wave: OscillatorType; volume: number; notes: Note[] }> = {
  acerto: { wave: "triangle", volume: 0.18, notes: [[784, 0, 0.09], [1175, 0.08, 0.16]] },
  erro: { wave: "sawtooth", volume: 0.07, notes: [[220, 0, 0.12], [165, 0.11, 0.22]] },
  fim: { wave: "triangle", volume: 0.16, notes: [[523, 0, 0.1], [659, 0.1, 0.1], [784, 0.2, 0.1], [1047, 0.3, 0.3]] },
};

export function sfx(name: keyof typeof SOUNDS) {
  if (!soundOn()) return;
  try {
    audio ??= new AudioContext();
    if (audio.state === "suspended") void audio.resume();
    const { wave, volume, notes } = SOUNDS[name];
    const t0 = audio.currentTime + 0.01;
    for (const [freq, start, dur] of notes) {
      const osc = audio.createOscillator();
      const gain = audio.createGain();
      osc.type = wave;
      osc.frequency.value = freq;
      // ataque rápido e queda suave, para não estalar
      gain.gain.setValueAtTime(0.0001, t0 + start);
      gain.gain.exponentialRampToValueAtTime(volume, t0 + start + 0.012);
      gain.gain.exponentialRampToValueAtTime(0.0001, t0 + start + dur);
      osc.connect(gain).connect(audio.destination);
      osc.start(t0 + start);
      osc.stop(t0 + start + dur + 0.02);
    }
  } catch {
    /* sem Web Audio: segue sem som */
  }
}
