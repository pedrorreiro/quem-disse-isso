import Hero from "@/components/Hero";

export default function Home() {
  return (
    <div className="flex flex-1 flex-col justify-center gap-10 py-10">
      <Hero />

      <p className="text-center text-xs text-white/40">Toda frase tem fonte. Confira no fim de cada rodada.</p>
    </div>
  );
}
