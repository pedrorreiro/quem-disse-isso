import { Backdrop, MotionRoot } from "@/components/fx";
import { KindTheme } from "@/components/KindSwitch";

export default function GameLayout({ children }: { children: React.ReactNode }) {
  return (
    <MotionRoot>
      <KindTheme />
      <Backdrop />
      <main className="mx-auto flex min-h-dvh w-full max-w-md flex-col px-4 md:max-w-3xl md:px-8">{children}</main>
    </MotionRoot>
  );
}
