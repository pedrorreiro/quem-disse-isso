import { ImageResponse } from "next/og";
import { Brand, C, Frame, PlayCta, QuoteMark, STORY, fonts } from "@/lib/card";

// Imagem do resultado da partida para compartilhar (stories / WhatsApp). Tudo vem da URL:
// não há nada secreto aqui, é só o placar que o próprio jogador vê.
const TILE: Record<string, { bg: string; fg: string }> = {
  c: { bg: C.lime, fg: C.ink },
  w: { bg: C.pink, fg: "#fff" },
  s: { bg: "rgba(255,255,255,0.18)", fg: "rgba(255,255,255,0.7)" },
};

function TileIcon({ kind, color }: { kind: string; color: string }) {
  const common = { fill: "none", stroke: color, strokeWidth: 3.5, strokeLinecap: "round" as const, strokeLinejoin: "round" as const };
  return (
    <svg width="40" height="40" viewBox="0 0 24 24">
      {kind === "c" ? (
        <path d="M20 6 9 17l-5-5" {...common} />
      ) : kind === "w" ? (
        <path d="M18 6 6 18M6 6l12 12" {...common} />
      ) : (
        <path d="M5 12h14" {...common} />
      )}
    </svg>
  );
}

const int = (v: string | null, max: number) => Math.min(max, Math.max(0, Number.parseInt(v ?? "", 10) || 0));

export function GET(req: Request) {
  const q = new URL(req.url).searchParams;
  const total = int(q.get("t"), 30);
  const correct = Math.min(int(q.get("c"), 30), total);
  const best = int(q.get("b"), 30);
  const results = (q.get("r") ?? "").replace(/[^cws]/g, "").slice(0, 30).split("").filter(Boolean);
  const day = /^\d{4}-\d{2}-\d{2}$/.test(q.get("d") ?? "") ? q.get("d")!.split("-").reverse().slice(0, 2).join("/") : null;

  const host = new URL(req.url).host.replace(/^www\./, "");
  const pct = total ? Math.round((100 * correct) / total) : 0;

  return new ImageResponse(
    (
      <Frame padding={96}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 28, marginTop: 40 }}>
          <QuoteMark size={110} />
          <Brand size={70} />
        </div>

        <div style={{ display: "flex", flex: 1 }} />

        <div style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
          <div
            style={{
              display: "flex",
              fontSize: 38,
              fontWeight: 800,
              textTransform: "uppercase",
              letterSpacing: 5,
              padding: "12px 30px",
              borderRadius: 18,
              background: "rgba(255,255,255,0.12)",
              color: "rgba(255,255,255,0.8)",
              transform: "rotate(-2deg)",
            }}
          >
            {day ? `Desafio do dia ${day}` : "Meu resultado"}
          </div>
          <div
            style={{
              display: "flex",
              alignItems: "flex-end",
              fontSize: 340,
              fontWeight: 800,
              color: C.lime,
              lineHeight: 1,
              marginTop: 40,
              letterSpacing: -10,
              textShadow: "0 16px 0 rgba(0,0,0,0.5)",
            }}
          >
            {correct}
            <span style={{ fontSize: 180, color: "rgba(255,255,255,0.4)", letterSpacing: -4, marginBottom: 20 }}>/{total}</span>
          </div>
          <div style={{ display: "flex", fontSize: 56, color: "rgba(255,255,255,0.7)", marginTop: 6 }}>acertos</div>
        </div>

        <div style={{ display: "flex", flexWrap: "wrap", justifyContent: "center", gap: 14, marginTop: 80 }}>
          {results.map((r, i) => (
            <div
              key={i}
              style={{
                width: 72,
                height: 72,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                borderRadius: 22,
                background: TILE[r].bg,
                boxShadow: "0 8px 0 0 rgba(0,0,0,0.5)",
              }}
            >
              <TileIcon kind={r} color={TILE[r].fg} />
            </div>
          ))}
        </div>

        <div style={{ display: "flex", gap: 30, marginTop: 80 }}>
          {[
            ["Aproveitamento", `${pct}%`],
            ["Maior sequência", String(best)],
          ].map(([label, value]) => (
            <div
              key={label}
              style={{
                flex: 1,
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                padding: "34px 0",
                borderRadius: 40,
                background: "rgba(255,255,255,0.09)",
                border: "2px solid rgba(255,255,255,0.12)",
              }}
            >
              <div style={{ display: "flex", fontSize: 32, color: "rgba(255,255,255,0.6)", textTransform: "uppercase", letterSpacing: 2 }}>
                {label}
              </div>
              <div style={{ display: "flex", fontSize: 88, fontWeight: 800 }}>{value}</div>
            </div>
          ))}
        </div>

        <div style={{ display: "flex", flex: 1 }} />
        <PlayCta host={host} title="Duvido você acertar mais." />
        <div style={{ display: "flex", height: 60 }} />
      </Frame>
    ),
    { ...STORY, fonts, headers: { "cache-control": "public, max-age=31536000, immutable" } },
  );
}
