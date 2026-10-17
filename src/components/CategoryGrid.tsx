"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { motion } from "motion/react";
import {
  ArrowLeft,
  Cctv,
  Check,
  Clapperboard,
  Landmark,
  Medal,
  MonitorPlay,
  Music,
  Shuffle,
  Smartphone,
  Sparkles,
  Star,
  Trophy,
  Tv,
  type LucideIcon,
} from "lucide-react";
import { listCategories, myProgress } from "@/lib/api";
import { categoryLabel } from "@/lib/share";
import type { CategoryInfo, CategoryProgress } from "@/lib/types";

const ICON: Record<string, LucideIcon> = {
  futebol: Trophy,
  musica: Music,
  tv: Tv,
  internet: Smartphone,
  youtubers: MonitorPlay,
  politica: Landmark,
  cinema: Clapperboard,
  esportes: Medal,
  gringos: Star,
  reality: Cctv,
};

// cores das capas, em rodízio; a primeira (lime) fica para "Tudo misturado"
const TILE = ["bg-pink text-white", "bg-cyan text-ink", "bg-grape text-white", "bg-white/10 text-white backdrop-blur"];

function Tile({
  href,
  icon: Icon,
  title,
  subtitle,
  faces,
  color,
  index,
  wide,
  progress,
}: {
  href: string;
  icon: LucideIcon;
  title: string;
  subtitle: string;
  faces: string[];
  color: string;
  index: number;
  wide?: boolean;
  progress?: { seen: number; total: number };
}) {
  const done = !!progress && progress.total > 0 && progress.seen >= progress.total;
  return (
    <motion.div
      initial={{ opacity: 0, y: 24, scale: 0.94 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      transition={{ type: "spring", stiffness: 340, damping: 24, delay: 0.1 + index * 0.05 }}
      className={wide ? "col-span-2 md:col-span-3" : ""}
    >
      <Link
        href={href}
        className={`btn-pop relative flex h-full min-h-32 flex-col justify-between gap-3 overflow-hidden rounded-3xl p-4 md:min-h-40 md:p-5 ${color}`}
      >
        <span className="grid size-10 place-items-center rounded-2xl bg-black/15" aria-hidden>
          <Icon className="size-5" strokeWidth={2.5} />
        </span>
        <span>
          <span className="block font-display text-xl font-black leading-tight md:text-2xl">{title}</span>
          <span className="block text-xs font-semibold opacity-70">{subtitle}</span>
          {progress && progress.total > 0 && (
            <span className="mt-2 flex items-center gap-2 text-xs font-bold">
              <span className="h-1.5 flex-1 overflow-hidden rounded-full bg-black/20" aria-hidden>
                <span
                  className="block h-full rounded-full bg-current"
                  style={{ width: `${Math.min(100, (100 * progress.seen) / progress.total)}%` }}
                />
              </span>
              {done ? (
                <span className="flex items-center gap-0.5">
                  <Check className="size-3.5" strokeWidth={3} aria-hidden />
                  Completa
                </span>
              ) : (
                <span>
                  {progress.seen}/{progress.total}
                  <span className="sr-only"> frases descobertas</span>
                </span>
              )}
            </span>
          )}
        </span>
        {faces.length > 0 && (
          <span className="absolute right-3 top-3 flex -space-x-3" aria-hidden>
            {faces.map((src) => (
              // eslint-disable-next-line @next/next/no-img-element
              <img key={src} src={src} alt="" className="size-9 rounded-full object-cover ring-2 ring-ink/40" />
            ))}
          </span>
        )}
      </Link>
    </motion.div>
  );
}

/** Tela de escolha de categoria: uma capa grande por categoria, mais "Tudo misturado". */
export default function CategoryGrid() {
  const [categories, setCategories] = useState<CategoryInfo[] | null>(null);
  const [failed, setFailed] = useState(false);
  const [progress, setProgress] = useState<Map<string, CategoryProgress>>(new Map());

  useEffect(() => {
    listCategories()
      .then(setCategories)
      .catch(() => setFailed(true));
    myProgress()
      .then((list) => setProgress(new Map(list.map((p) => [p.category, p]))))
      .catch(() => {});
  }, []);

  const all = [...progress.values()].reduce((a, p) => ({ seen: a.seen + p.seen, total: a.total + p.total }), { seen: 0, total: 0 });

  const total = categories?.reduce((n, c) => n + c.people, 0) ?? 0;
  const mixFaces = categories?.flatMap((c) => c.faces.slice(0, 1)).slice(0, 4) ?? [];

  return (
    <div className="flex flex-1 flex-col gap-6 py-6 md:py-10">
      <header className="flex items-center gap-3">
        <Link href="/" className="btn-pop grid size-11 shrink-0 place-items-center rounded-2xl p-0! bg-white/10 backdrop-blur" aria-label="Voltar ao início">
          <ArrowLeft className="size-5" aria-hidden />
        </Link>
        <div>
          <h1 className="font-display text-3xl font-black leading-none md:text-4xl">Categorias</h1>
          <p className="mt-1 text-sm text-white/60">Escolha de quem vão ser as frases.</p>
        </div>
      </header>

      {failed && <p className="text-center text-white/70">Não deu para carregar as categorias. Tente de novo.</p>}

      {!categories && !failed && (
        <div className="grid grid-cols-2 gap-3 md:grid-cols-3" aria-hidden>
          {Array.from({ length: 7 }, (_, i) => (
            <div key={i} className={`min-h-32 animate-pulse rounded-3xl bg-white/[0.07] md:min-h-40 ${i === 0 ? "col-span-2 md:col-span-3" : ""}`} />
          ))}
        </div>
      )}

      {categories && (
        <div className="grid grid-cols-2 gap-3 md:grid-cols-3">
          <Tile
            href="/jogar"
            icon={Shuffle}
            title="Tudo misturado"
            subtitle={`${total} famosos de todas as categorias`}
            faces={mixFaces}
            color="bg-lime text-ink"
            index={0}
            wide
            progress={all.total > 0 ? all : undefined}
          />
          {categories.map((c, i) => (
            <Tile
              key={c.id}
              href={`/jogar?cat=${encodeURIComponent(c.id)}`}
              icon={ICON[c.id] ?? Sparkles}
              title={categoryLabel(c.id)}
              subtitle={`${c.people} ${c.people === 1 ? "famoso" : "famosos"}`}
              faces={c.faces.slice(0, 3)}
              color={TILE[i % TILE.length]}
              index={i + 1}
              progress={progress.get(c.id)}
            />
          ))}
        </div>
      )}
    </div>
  );
}
