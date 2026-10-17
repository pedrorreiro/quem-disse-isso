import { ImageResponse } from "next/og";
import { headers } from "next/headers";
import { Brand, C, Frame, QuoteMark, fonts, photoSrc } from "@/lib/card";
import { getQuotePublic } from "@/lib/preview";

export const alt = "Quem disse isso?";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default async function Image({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const quote = await getQuotePublic(id);
  const text = quote?.text ?? "Adivinhe quem disse.";
  const fontSize = text.length > 140 ? 40 : text.length > 80 ? 50 : 60;
  const h = await headers();
  const origin = `${h.get("x-forwarded-proto") ?? "https"}://${h.get("host")}`;
  const photo = quote ? await photoSrc(quote.person.image_url, origin) : null;

  return new ImageResponse(
    (
      <Frame padding={64}>
        <div style={{ display: "flex", alignItems: "center", gap: 22 }}>
          <QuoteMark size={72} />
          <Brand size={44} />
        </div>
        <div style={{ display: "flex", flex: 1, alignItems: "center", fontSize, fontWeight: 800, lineHeight: 1.15 }}>
          {text}
        </div>
        {quote && (
          <div style={{ display: "flex", alignItems: "center", gap: 24 }}>
            {photo && (
              <img src={photo} alt="" width={96} height={96} style={{ borderRadius: 26, objectFit: "cover", border: `5px solid ${C.lime}` }} />
            )}
            <div style={{ display: "flex", flexDirection: "column" }}>
              <div style={{ display: "flex", fontSize: 22, letterSpacing: 4, color: "rgba(255,255,255,0.55)" }}>QUEM DISSE</div>
              <div style={{ display: "flex", fontSize: 44, fontWeight: 800, color: C.lime }}>{quote.person.name}</div>
            </div>
          </div>
        )}
      </Frame>
    ),
    { ...size, fonts },
  );
}
