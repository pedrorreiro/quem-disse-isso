import type { Metadata } from "next";
import QuoteShared from "@/components/QuoteShared";
import { getQuotePublic } from "@/lib/preview";

export async function generateMetadata({ params }: PageProps<"/q/[id]">): Promise<Metadata> {
  const { id } = await params;
  const quote = await getQuotePublic(id);
  const title = quote ? `${quote.person.name} disse isso` : "Quem disse isso?";
  const description = quote ? `“${quote.text}”` : "Adivinhe quem disse.";
  return {
    title,
    description,
    openGraph: { title, description },
    twitter: { card: "summary_large_image" },
  };
}

export default async function SharedQuote({ params }: PageProps<"/q/[id]">) {
  const { id } = await params;
  return <QuoteShared quote={await getQuotePublic(id)} />;
}
