import { ImageResponse } from "next/og";
import { Brand, C, Frame, QuoteMark, fonts } from "@/lib/card";
import { getChallengePublic } from "@/lib/preview";

export const alt = "Desafio no Quem disse isso?";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default async function Image({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const c = await getChallengePublic(id);

  return new ImageResponse(
    (
      <Frame padding={64}>
        <div style={{ display: "flex", alignItems: "center", gap: 22 }}>
          <QuoteMark size={72} />
          <Brand size={44} />
        </div>
        <div style={{ display: "flex", flex: 1, flexDirection: "column", justifyContent: "center" }}>
          {c ? (
            <>
              <div style={{ display: "flex", fontSize: 64, fontWeight: 800 }}>{`${c.name ?? "Alguém"} acertou`}</div>
              <div style={{ display: "flex", alignItems: "flex-end", fontSize: 150, fontWeight: 800, color: C.lime, lineHeight: 1 }}>
                {c.correct}
                <span style={{ fontSize: 90, color: "rgba(255,255,255,0.4)" }}>/{c.total_rounds}</span>
              </div>
            </>
          ) : (
            <div style={{ display: "flex", fontSize: 64, fontWeight: 800 }}>Desafio</div>
          )}
        </div>
        <div style={{ display: "flex", fontSize: 40, fontWeight: 800 }}>Consegue bater?</div>
      </Frame>
    ),
    { ...size, fonts },
  );
}
