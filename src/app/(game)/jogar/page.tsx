import Game from "@/components/Game";

export default async function Jogar({ searchParams }: PageProps<"/jogar">) {
  const { cat } = await searchParams;
  const category = typeof cat === "string" && cat ? cat : undefined;
  return <Game key={category ?? "all"} mode="solo" category={category} />;
}
