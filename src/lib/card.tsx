// Peças comuns das imagens geradas no servidor (compartilhamento e prévia de link).
import { readFile } from "node:fs/promises";
import { join } from "node:path";

export const C = { ink: "#0d0717", fg: "#f7f3ff", lime: "#c8ff2e", pink: "#ff4fb8", cyan: "#3ee6ff", grape: "#7c3aed" };

const dir = join(process.cwd(), "assets/fonts");
const [bold, regular] = await Promise.all([
  readFile(join(dir, "BricolageGrotesque-Bold.ttf")),
  readFile(join(dir, "BricolageGrotesque-Regular.ttf")),
]);

export const fonts = [
  { name: "Bricolage", data: bold, weight: 800 as const, style: "normal" as const },
  { name: "Bricolage", data: regular, weight: 400 as const, style: "normal" as const },
];

/** Fundo escuro com as manchas de cor do site. */
export function Frame({ children, padding = 80 }: { children: React.ReactNode; padding?: number }) {
  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        position: "relative",
        background: C.ink,
        backgroundImage: `radial-gradient(circle at 0% 0%, ${C.grape}cc 0%, transparent 55%), radial-gradient(circle at 100% 45%, ${C.pink}88 0%, transparent 50%), radial-gradient(circle at 20% 100%, ${C.cyan}55 0%, transparent 50%)`,
        color: C.fg,
        fontFamily: "Bricolage",
        padding,
      }}
    >
      {children}
    </div>
  );
}

/** Selo rosa de aspas, igual ao do jogo. */
export function QuoteMark({ size = 96 }: { size?: number }) {
  return (
    <div
      style={{
        width: size,
        height: size,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: C.pink,
        borderRadius: size * 0.28,
        transform: "rotate(-8deg)",
        boxShadow: `0 ${size * 0.07}px 0 0 rgba(0,0,0,0.5)`,
      }}
    >
      <svg width={size * 0.5} height={size * 0.5} viewBox="0 0 24 24" fill="#fff">
        <path d="M3 21c3 0 7-1 7-8V5c0-1.25-.756-2.017-2-2H4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2 1 0 1 0 1 1v1c0 1-1 2-2 2s-1 .008-1 1.031V20c0 1 0 1 1 1z" />
        <path d="M15 21c3 0 7-1 7-8V5c0-1.25-.757-2.017-2-2h-4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2h.75c0 2.25.25 4-2.75 4v3c0 1 0 1 1 1z" />
      </svg>
    </div>
  );
}

export function Brand({ size = 44 }: { size?: number }) {
  return (
    <div style={{ display: "flex", fontSize: size, fontWeight: 800, letterSpacing: -1 }}>
      Quem&nbsp;<span style={{ color: C.lime }}>disse isso?</span>
    </div>
  );
}

/** Rodapé com chamada para jogar e o endereço do site. */
export function PlayCta({ host, title }: { host: string; title: string }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 28 }}>
      <div style={{ display: "flex", fontSize: 52, fontWeight: 800, textAlign: "center" }}>{title}</div>
      <div
        style={{
          display: "flex",
          fontSize: 44,
          fontWeight: 800,
          color: C.ink,
          background: C.lime,
          padding: "22px 48px",
          borderRadius: 28,
          boxShadow: "0 10px 0 0 rgba(0,0,0,0.5)",
        }}
      >
        Jogue em {host}
      </div>
    </div>
  );
}

/** Tamanho de Stories / Status (9:16). */
export const STORY = { width: 1080, height: 1920 };
