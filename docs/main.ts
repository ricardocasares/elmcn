import "../src/UI/elmcn-dialog";
import { Elm, type Flags } from "./DocsMain.elm";

//-- FLAGS

const media = window.matchMedia("(prefers-color-scheme: dark)");
const getStoredTheme = () => {
  try {
    return (localStorage.getItem("theme") as Flags["theme"]) ?? null;
  } catch {
    return null;
  }
};

//-- INIT
// @ts-ignore
const app = Elm.DocsMain.init({
  node: document.getElementById("app"),
  flags: {
    theme: getStoredTheme(),
    systemDark: media.matches,
  },
});

//-- PORTS:SEND

media.addEventListener("change", (event) =>
  app.ports.interopToElm.send({
    tag: "SystemThemeChanged",
    dark: event.matches,
  }),
);

//-- PORTS:SUBSCRIBE

app.ports.interopFromElm.subscribe((fromElm) => {
  switch (fromElm.tag) {
    case "CopyToClipboard":
      return navigator.clipboard.writeText(fromElm.data).catch((error) =>
        app.ports.interopToElm.send({
          tag: "ClipboardError",
          message: String(error),
        }),
      );

    case "ReadFromLocalStorage":
      try {
        return localStorage.getItem(fromElm.data);
      } catch (error) {
        return app.ports.interopToElm.send({
          tag: "LocalStorageError",
          key: fromElm.data,
          message: String(error),
        });
      }

    case "WriteToLocalStorage":
      try {
        return localStorage.setItem(fromElm.data.key, fromElm.data.value);
      } catch (error) {
        return app.ports.interopToElm.send({
          tag: "LocalStorageError",
          key: fromElm.data.key,
          message: String(error),
        });
      }
  }
});
