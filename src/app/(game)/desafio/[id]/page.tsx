import type { Metadata } from "next";
import ChallengeIntro from "@/components/ChallengeIntro";
import { getChallengePublic } from "@/lib/preview";

const who = (name: string | null) => name ?? "Alguém";

export async function generateMetadata({ params }: PageProps<"/desafio/[id]">): Promise<Metadata> {
  const { id } = await params;
  const c = await getChallengePublic(id);
  const title = c ? `${who(c.name)} acertou ${c.correct}/${c.total_rounds}. Consegue bater?` : "Quem disse isso?";
  const description = "Mesmas frases, mesmo tempo. Descubra quem disse cada uma.";
  return {
    title,
    description,
    openGraph: { title, description },
    twitter: { card: "summary_large_image" },
  };
}

export default async function Desafio({ params }: PageProps<"/desafio/[id]">) {
  const { id } = await params;
  const challenge = await getChallengePublic(id);
  return <ChallengeIntro id={id} challenge={challenge} />;
}
