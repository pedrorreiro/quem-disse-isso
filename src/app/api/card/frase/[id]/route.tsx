import { ImageResponse } from "next/og";
import { Brand, C, Frame, PlayCta, QuoteMark, STORY, fonts, photoCredit, photoSrc } from "@/lib/card";
import { getQuotePublic } from "@/lib/preview";
import { quoteDetail } from "@/lib/share";

// Imagem de uma frase para compartilhar depois de responder: a frase e quem disse.
export async function GET(req: Request, ctx: RouteContext<"/api/card/frase/[id]">) {
  const { id } = await ctx.params;
  const quote = await getQuotePublic(id);
  if (!quote) return new Response("not found", { status: 404 });
  const url = new URL(req.url);
  const host = url.host.replace(/^www\./, "");
  const photo = await photoSrc(quote.person.image_url, url.origin);
  const credit = photoCredit(quote.person.image_credit, quote.person.image_license);
  const detail = quoteDetail(quote.context, quote.said_on);
  const text = quote.text;
  const fontSize = text.length > 220 ? 58 : text.length > 140 ? 68 : text.length > 70 ? 82 : 100;

  return new ImageResponse(
    (
      <Frame padding={96}>
        <div style={{ display: "flex", justifyContent: "center", marginTop: 40 }}>
          <Brand size={70} />
        </div>
        <div style={{ display: "flex", flex: 1, flexDirection: "column", justifyContent: "center", gap: 64 }}>
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
          <div style={{ display: "flex", alignItems: "center", gap: 40, padding: "0 20px" }}>
            {photo && (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                src={photo}
                alt=""
                width={220}
                height={220}
                style={{ borderRadius: 56, objectFit: "cover", border: `10px solid ${C.lime}` }}
              />
            )}
            <div style={{ display: "flex", flexDirection: "column", flex: 1, gap: 6 }}>
              <div style={{ display: "flex", fontSize: 32, letterSpacing: 6, color: "rgba(255,255,255,0.55)" }}>QUEM DISSE</div>
              <div style={{ display: "flex", fontSize: 76, fontWeight: 800, lineHeight: 1.05, color: C.lime }}>{quote.person.name}</div>
              {detail && (
                <div style={{ display: "flex", fontSize: 34, color: "rgba(255,255,255,0.65)", lineHeight: 1.25 }}>{detail}</div>
              )}
            </div>
          </div>
        </div>
        <PlayCta host={host} title="Você acertaria as outras?" />
        <div style={{ display: "flex", justifyContent: "center", height: 60, alignItems: "flex-end", fontSize: 24, color: "rgba(255,255,255,0.4)" }}>
          {credit ?? ""}
        </div>
      </Frame>
    ),
    { ...STORY, fonts, headers: { "cache-control": "public, max-age=86400" } },
  );
}
