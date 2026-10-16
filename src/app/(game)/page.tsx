import Link from "next/link";
import CategoryPicker from "@/components/CategoryPicker";

export default function Home() {
  return (
    <div className="flex flex-1 flex-col justify-center gap-10 py-10">
      <header className="text-center">
        <h1 className="text-5xl font-black leading-none tracking-tight md:text-7xl">
          Quem
          <br />
          <span className="text-amber-400">disse isso?</span>
        </h1>
        <p className="mt-4 text-white/60">Aparece a frase. Você descobre quem soltou essa pérola.</p>
      </header>

      <div className="flex flex-col gap-3 md:mx-auto md:w-full md:max-w-md">
        <Link
          href="/jogar"
          className="rounded-2xl bg-amber-400 px-5 py-4 text-center text-lg font-black text-neutral-950 active:scale-[0.98]"
        >
          Jogar
        </Link>
        <Link
          href="/diario"
          className="rounded-2xl bg-white/10 px-5 py-4 text-center text-lg font-bold active:scale-[0.98]"
        >
          Desafio do dia
        </Link>
      </div>

      <CategoryPicker />

      <p className="text-center text-xs text-white/40">
        Toda frase tem fonte. Confira no fim de cada rodada. ·{" "}
        <Link href="/creditos" className="underline">
          Créditos das fotos
        </Link>
      </p>
    </div>
  );
}
