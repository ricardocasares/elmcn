import "./app.css";
import "../src/UI/elmcn-dialog";
import { Elm } from "./Main.elm";

const media = window.matchMedia("(prefers-color-scheme: dark)");
let theme: "light" | "dark" | "system" | null = null;
try {
  const stored = localStorage.getItem("theme");
  if (stored === "light" || stored === "dark" || stored === "system") {
    theme = stored;
  }
} catch (_) {}

// The `dark` class goes on <html> as well as on Elm's root, so <body> has the
// right background, and the theme color follows it: browsers tint their bars
// from these. The colors are `--background` in src/elmcn.css.
const applyTheme = () => {
  const dark = theme === "dark" || (theme !== "light" && media.matches);
  document.documentElement.classList.toggle("dark", dark);
  document
    .querySelector('meta[name="theme-color"]')!
    .setAttribute("content", dark ? "#0a0a0a" : "#ffffff");
};
applyTheme();

const app = Elm.Main.init({
  node: document.getElementById("app"),
  flags: { base: import.meta.env.BASE_URL, theme, systemDark: media.matches },
});

app.ports.interopFromElm.subscribe((fromElm) => {
  switch (fromElm.tag) {
    case "saveTheme":
      theme = fromElm.data;
      applyTheme();
      try {
        localStorage.setItem("theme", theme);
      } catch (_) {}
      break;
    case "copyToClipboard":
      navigator.clipboard.writeText(fromElm.data).catch(() => {});
      break;
  }
});

media.addEventListener("change", (event) => {
  applyTheme();
  app.ports.interopToElm.send({
    tag: "systemThemeChanged",
    dark: event.matches,
  });
});
