import type { Metadata } from "next";
import Game from "@/components/Game";
import { getQuotePreview } from "@/lib/preview";

export async function generateMetadata({ params }: PageProps<"/q/[id]">): Promise<Metadata> {
  const { id } = await params;
  const preview = await getQuotePreview(id);
  const title = "Quem disse isso?";
  return {
    title,
    description: preview ? `“${preview.text}”` : "Adivinhe quem disse.",
    openGraph: { title, description: preview ? `“${preview.text}”` : undefined },
    twitter: { card: "summary_large_image" },
  };
}

export default async function SharedQuote({ params }: PageProps<"/q/[id]">) {
  const { id } = await params;
  return <Game mode="shared" quoteId={id} />;
}
