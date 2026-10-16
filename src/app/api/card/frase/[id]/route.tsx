import { ImageResponse } from "next/og";
import { Brand, Frame, PlayCta, QuoteMark, STORY, fonts } from "@/lib/card";
import { getQuotePreview } from "@/lib/preview";

// Imagem de uma frase para compartilhar no meio da partida: mostra a frase, nunca o autor.
export async function GET(req: Request, ctx: RouteContext<"/api/card/frase/[id]">) {
  const { id } = await ctx.params;
  const preview = await getQuotePreview(id);
  if (!preview) return new Response("not found", { status: 404 });
  const host = new URL(req.url).host.replace(/^www\./, "");
  const text = preview.text;
  const fontSize = text.length > 220 ? 64 : text.length > 140 ? 76 : text.length > 70 ? 92 : 112;

  return new ImageResponse(
    (
      <Frame padding={96}>
        <div style={{ display: "flex", justifyContent: "center", marginTop: 40 }}>
          <Brand size={70} />
        </div>
        <div style={{ display: "flex", flex: 1, alignItems: "center" }}>
          <div
            style={{
              display: "flex",
              position: "relative",
              padding: "110px 76px 84px",
              borderRadius: 72,
              background: "rgba(255,255,255,0.09)",
              border: "2px solid rgba(255,255,255,0.14)",
            }}
          >
            <div style={{ display: "flex", position: "absolute", left: -26, top: -56 }}>
              <QuoteMark size={140} />
            </div>
            <div style={{ display: "flex", fontSize, fontWeight: 800, lineHeight: 1.12, letterSpacing: -1.5 }}>{text}</div>
          </div>
        </div>
        <PlayCta host={host} title="Você sabe quem disse?" />
        <div style={{ display: "flex", height: 60 }} />
      </Frame>
    ),
    { ...STORY, fonts, headers: { "cache-control": "public, max-age=86400" } },
  );
}
