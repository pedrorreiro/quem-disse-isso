import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Quem Disse Isso?",
    short_name: "Quem Disse?",
    description: "Adivinhe quem disse a frase. Toda frase tem fonte.",
    start_url: "/",
    display: "standalone",
    background_color: "#0a0a0f",
    theme_color: "#0a0a0f",
    lang: "pt-BR",
  };
}
