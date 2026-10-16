import type { Option } from "@/lib/types";

export type CardState = "idle" | "eliminated" | "correct" | "wrong" | "dimmed";

const RING: Record<CardState, string> = {
  idle: "ring-white/10 hover:ring-amber-400 active:scale-[0.98]",
  eliminated: "ring-white/5 opacity-30",
  correct: "ring-4 ring-emerald-400",
  wrong: "ring-4 ring-rose-500",
  dimmed: "ring-white/5 opacity-40",
};

type Props = {
  option: Option;
  hotkey?: number;
  state: CardState;
  disabled: boolean;
  onPick: (id: string) => void;
};

export default function OptionCard({ option, hotkey, state, disabled, onPick }: Props) {
  return (
    <button
      type="button"
      disabled={disabled}
      onClick={() => onPick(option.id)}
      className={`flex flex-col overflow-hidden rounded-2xl bg-neutral-900 text-left ring-2 transition ${RING[state]}`}
    >
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        src={option.image_url}
        alt=""
        className="aspect-[4/3] w-full object-cover"
        draggable={false}
      />
      <span
        className={`flex flex-1 items-center justify-between gap-2 px-3 py-2 text-sm font-semibold leading-tight md:text-base ${
          state === "eliminated" ? "line-through" : ""
        }`}
      >
        {option.name}
        {hotkey && (
          <kbd className="hidden rounded bg-white/10 px-1.5 text-xs font-normal text-white/50 md:inline">{hotkey}</kbd>
        )}
      </span>
    </button>
  );
}
