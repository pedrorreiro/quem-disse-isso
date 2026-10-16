import { ImageResponse } from "next/og";
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
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          background: "#0a0a0f",
          color: "#f5f5f4",
          padding: 72,
        }}
      >
        <div style={{ display: "flex", fontSize: 40, fontWeight: 800, color: "#fbbf24" }}>Quem disse isso?</div>
        <div style={{ display: "flex", fontSize, fontWeight: 700, lineHeight: 1.2 }}>{`“${text}”`}</div>
        <div style={{ display: "flex", fontSize: 32, color: "#a1a1aa" }}>Toque para adivinhar quem foi.</div>
      </div>
    ),
    size,
  );
}
