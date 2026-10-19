import { ImageResponse } from "next/og";
import { Brand, C, Frame, QuoteMark, fonts } from "@/lib/card";

// Prévia padrão dos links do site (home, categorias, diário...); /q e /desafio têm opengraph-image próprio.
// Rota fixa, e não opengraph-image: página que define `openGraph` perde a imagem herdada do segmento pai.
const size = { width: 1200, height: 630 };

export function GET() {
  return new ImageResponse(
    (
      <Frame padding={72}>
        <div style={{ display: "flex", alignItems: "center", gap: 24 }}>
          <QuoteMark size={80} />
          <Brand size={48} />
        </div>
        <div style={{ display: "flex", flexDirection: "column", flex: 1, justifyContent: "center", gap: 20 }}>
          <div style={{ display: "flex", fontSize: 76, fontWeight: 800, lineHeight: 1.05 }}>Aparece a frase.</div>
          <div style={{ display: "flex", fontSize: 76, fontWeight: 800, lineHeight: 1.05, color: C.lime }}>Você adivinha quem disse.</div>
        </div>
        <div style={{ display: "flex", fontSize: 30, color: "rgba(255,255,255,0.7)" }}>
          Frases icônicas e polêmicas de famosos, políticos e influenciadores. Toda frase tem fonte.
        </div>
      </Frame>
    ),
    { ...size, fonts, headers: { "Cache-Control": "public, max-age=86400, s-maxage=604800" } },
  );
}
