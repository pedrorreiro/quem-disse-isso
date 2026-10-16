import { ImageResponse } from "next/og";
import { Brand, Frame, QuoteMark, fonts } from "@/lib/card";
import { getQuotePreview } from "@/lib/preview";

export const alt = "Quem disse isso?";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default async function Image({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const preview = await getQuotePreview(id);
  const text = preview?.text ?? "Adivinhe quem disse.";
  const fontSize = text.length > 140 ? 44 : text.length > 80 ? 56 : 68;

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
        <div style={{ display: "flex", fontSize: 32, color: "rgba(255,255,255,0.65)" }}>Toque para adivinhar quem foi.</div>
      </Frame>
    ),
    { ...size, fonts },
  );
}
