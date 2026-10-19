import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Quem Disse Isso?",
    short_name: "Quem Disse?",
    description: "Jogo de adivinhar quem disse a frase: famosos, políticos, jogadores e influenciadores. Toda frase tem fonte.",
    start_url: "/",
    display: "standalone",
    background_color: "#0a0a0f",
    theme_color: "#0a0a0f",
    lang: "pt-BR",
    categories: ["games", "entertainment", "trivia"],
    icons: [{ src: "/icon.svg", sizes: "any", type: "image/svg+xml" }],
  };
}
