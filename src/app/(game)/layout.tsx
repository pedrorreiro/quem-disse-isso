import { Backdrop, MotionRoot } from "@/components/fx";

export default function GameLayout({ children }: { children: React.ReactNode }) {
  return (
    <MotionRoot>
      <Backdrop />
      <main className="mx-auto flex min-h-dvh w-full max-w-md flex-col px-4 md:max-w-3xl md:px-8">{children}</main>
    </MotionRoot>
  );
}
