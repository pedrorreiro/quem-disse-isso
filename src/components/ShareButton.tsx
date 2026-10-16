"use client";

import { useState } from "react";
import { share } from "@/lib/share";

type Props = {
  label: string;
  getData: () => { title: string; text: string; url: string };
  className?: string;
};

export default function ShareButton({ label, getData, className = "" }: Props) {
  const [note, setNote] = useState<string | null>(null);

  async function onClick() {
    const outcome = await share(getData());
    if (outcome === "copied") setNote("Link copiado!");
    else if (outcome === "failed") setNote("Não consegui compartilhar.");
    else return;
    setTimeout(() => setNote(null), 2200);
  }

  return (
    <button type="button" onClick={onClick} className={className}>
      {note ?? label}
    </button>
  );
}
