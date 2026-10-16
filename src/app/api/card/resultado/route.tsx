import { ImageResponse } from "next/og";
import { Brand, C, Frame, QuoteMark, fonts } from "@/lib/card";

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

  return new ImageResponse(
    (
      <Frame padding={90}>
        <div style={{ display: "flex", alignItems: "center", gap: 28 }}>
          <QuoteMark size={100} />
          <Brand size={64} />
        </div>

        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", marginTop: 70 }}>
          <div
            style={{
              display: "flex",
              fontSize: 34,
              fontWeight: 800,
              textTransform: "uppercase",
              letterSpacing: 4,
              padding: "10px 26px",
              borderRadius: 16,
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
              fontSize: 260,
              alignItems: "flex-end",
              fontWeight: 800,
              color: C.lime,
              lineHeight: 1,
              marginTop: 30,
              letterSpacing: -8,
              textShadow: "0 14px 0 rgba(0,0,0,0.5)",
            }}
          >
            {correct}
            <span style={{ fontSize: 150, color: "rgba(255,255,255,0.4)", letterSpacing: -4 }}>/{total}</span>
          </div>
          <div style={{ display: "flex", fontSize: 48, color: "rgba(255,255,255,0.7)", marginTop: 10 }}>acertos</div>
        </div>

        <div style={{ display: "flex", flexWrap: "wrap", justifyContent: "center", gap: 14, marginTop: 60 }}>
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

        <div style={{ display: "flex", gap: 30, marginTop: 60 }}>
          {[
            ["Aproveitamento", `${total ? Math.round((100 * correct) / total) : 0}%`],
            ["Maior sequência", String(best)],
          ].map(([label, value]) => (
            <div
              key={label}
              style={{
                flex: 1,
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                padding: "28px 0",
                borderRadius: 36,
                background: "rgba(255,255,255,0.09)",
                border: "2px solid rgba(255,255,255,0.12)",
              }}
            >
              <div style={{ display: "flex", fontSize: 30, color: "rgba(255,255,255,0.6)", textTransform: "uppercase", letterSpacing: 2 }}>
                {label}
              </div>
              <div style={{ display: "flex", fontSize: 76, fontWeight: 800 }}>{value}</div>
            </div>
          ))}
        </div>

        <div style={{ display: "flex", flex: 1 }} />
        <div style={{ display: "flex", justifyContent: "center", fontSize: 40, fontWeight: 800 }}>
          Duvido você acertar mais.
        </div>
      </Frame>
    ),
    { width: 1080, height: 1350, fonts, headers: { "cache-control": "public, max-age=31536000, immutable" } },
  );
}
