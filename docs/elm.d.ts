/// <reference types="vite/client" />

declare module "*.elm" {
  export const Elm: {
    Main: {
      init(options: { node: HTMLElement | null; flags: unknown }): {
        ports: {
          saveTheme: { subscribe(fn: (value: string) => void): void };
          systemThemeChanged: { send(value: boolean): void };
        };
      };
    };
  };
}
