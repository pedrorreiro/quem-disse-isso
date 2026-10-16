import { ImageResponse } from "next/og";
import { Brand, C, Frame, QuoteMark, fonts } from "@/lib/card";
import { getQuotePreview } from "@/lib/preview";

// Imagem de uma frase para compartilhar no meio da partida: mostra a frase, nunca o autor.
export async function GET(_req: Request, ctx: RouteContext<"/api/card/frase/[id]">) {
  const { id } = await ctx.params;
  const preview = await getQuotePreview(id);
  if (!preview) return new Response("not found", { status: 404 });
  const text = preview.text;
  const fontSize = text.length > 200 ? 58 : text.length > 120 ? 70 : text.length > 60 ? 86 : 104;

  return new ImageResponse(
    (
      <Frame padding={90}>
        <Brand size={60} />
        <div style={{ display: "flex", flex: 1, alignItems: "center" }}>
          <div
            style={{
              display: "flex",
              position: "relative",
              padding: "90px 70px 70px",
              borderRadius: 64,
              background: "rgba(255,255,255,0.09)",
              border: "2px solid rgba(255,255,255,0.14)",
            }}
          >
            <div style={{ display: "flex", position: "absolute", left: -24, top: -44 }}>
              <QuoteMark size={120} />
            </div>
            <div style={{ display: "flex", fontSize, fontWeight: 800, lineHeight: 1.12, letterSpacing: -1.5 }}>{text}</div>
          </div>
        </div>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <div style={{ display: "flex", fontSize: 44, fontWeight: 800 }}>Você sabe quem disse?</div>
          <div
            style={{
              display: "flex",
              fontSize: 40,
              fontWeight: 800,
              color: C.ink,
              background: C.lime,
              padding: "18px 34px",
              borderRadius: 24,
              boxShadow: "0 8px 0 0 rgba(0,0,0,0.5)",
            }}
          >
            Jogar
          </div>
        </div>
      </Frame>
    ),
    { width: 1080, height: 1350, fonts, headers: { "cache-control": "public, max-age=86400" } },
  );
}
