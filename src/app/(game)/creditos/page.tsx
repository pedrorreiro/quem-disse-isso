import type { Metadata } from "next";
import Credits from "@/components/Credits";

export const metadata: Metadata = {
  title: "Créditos das fotos",
  description: "Autores e licenças das fotos usadas no Quem Disse Isso?.",
  alternates: { canonical: "/creditos" },
};

export default function CreditosPage() {
  return <Credits />;
}
