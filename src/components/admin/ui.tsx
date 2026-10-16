import type { ReactNode } from "react";
import type { PhotoStatus } from "@/lib/admin";

export const input =
  "w-full rounded-lg bg-white/5 px-3 py-2 text-sm ring-1 ring-white/10 outline-none focus:ring-2 focus:ring-amber-400";
export const btn = "rounded-lg px-4 py-2 text-sm font-semibold transition active:scale-[0.98] disabled:opacity-40";
export const btnPrimary = `${btn} bg-amber-400 text-neutral-950`;
export const btnGhost = `${btn} bg-white/10 hover:bg-white/15`;
export const btnDanger = `${btn} bg-rose-500/15 text-rose-300 hover:bg-rose-500/25`;
export const btnOk = `${btn} bg-emerald-500 text-neutral-950`;

export function Field({ label, children, hint }: { label: string; children: ReactNode; hint?: string }) {
  return (
    <label className="flex flex-col gap-1">
      <span className="text-xs font-semibold uppercase tracking-wide text-white/50">{label}</span>
      {children}
      {hint && <span className="text-xs text-white/40">{hint}</span>}
    </label>
  );
}

const STATUS: Record<PhotoStatus, [string, string]> = {
  approved: ["Foto aprovada", "bg-emerald-500/15 text-emerald-300"],
  pending: ["Foto pendente", "bg-amber-400/15 text-amber-300"],
  rejected: ["Foto rejeitada", "bg-rose-500/15 text-rose-300"],
};

export function PhotoBadge({ status, hasImage = true }: { status: PhotoStatus; hasImage?: boolean }) {
  const [label, cls] = hasImage ? STATUS[status] : ["Sem foto", "bg-white/10 text-white/60"];
  return <span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${cls}`}>{label}</span>;
}

export function Avatar({ url, name, className = "" }: { url: string | null; name: string; className?: string }) {
  if (!url) {
    return (
      <div className={`flex items-center justify-center bg-white/5 text-white/30 ${className}`} aria-label={name}>
        sem foto
      </div>
    );
  }
  // eslint-disable-next-line @next/next/no-img-element
  return <img src={url} alt={name} className={`object-cover ${className}`} />;
}

export function ExternalLink({ href, children }: { href?: string | null; children: ReactNode }) {
  if (!href) return null;
  return (
    <a href={href} target="_blank" rel="noopener noreferrer" className="text-sm text-amber-300 underline underline-offset-2">
      {children} ↗
    </a>
  );
}
