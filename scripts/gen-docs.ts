// Generates docs/Generated.elm, the data behind the docs site, so that what the site
// shows is always what the repository contains:
//
// - the component list, titles, descriptions and install packages come from registry.json
// - usage and the API table come from the `src/UI/*.elm` module docs and signatures
// - every `name : Html msg` in `docs/Examples/<Module>.elm` becomes an example, rendered
//   from the real function and shown with its own source as the code. An example that
//   needs state is `name : State -> Html State.Msg` instead (see docs/State.elm)
//
// Usage: bun scripts/gen-docs.ts

import { $ } from "bun";

type Item = {
  name: string;
  title: string;
  description: string;
  files: { path: string }[];
  meta?: { elmDependencies?: string[] };
};
type Registry = { items: Item[] };
type Import = { module: string; alias?: string; exposing: string[] };
type Example = { id: string; stateful: boolean; title: string; description: string; code: string };
type Entry = { name: string; signature: string; description: string };
type Component = {
  slug: string;
  title: string;
  description: string;
  name: string;
  path: string;
  packages: string[];
  examples: Example[];
  usage: string;
  api: Entry[];
};

const OUTPUT = "docs/Generated.elm";
const ACRONYMS: Record<string, string> = { rtl: "RTL" };

const registry: Registry = await Bun.file("registry.json").json();
const errors: string[] = [];

const str = (s: string): string =>
  '"' +
  s.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n").replace(/\t/g, "\\t") +
  '"';

const list = (items: string[]): string => (items.length === 0 ? "[]" : `[ ${items.join(", ")} ]`);

const escapeRegExp = (s: string): string => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

// A `{-| ... -}` comment directly above a declaration, without crossing into another comment.
const DOC = "(?:\\{-\\|((?:(?!-\\})[\\s\\S])*)-\\}\\n)?";

const firstParagraph = (doc: string | undefined): string => {
  const paragraph = (doc ?? "")
    .trim()
    .split(/\n\s*\n/)
    .find((p) => !/^ {4}/.test(p));
  return (paragraph ?? "").replace(/\s+/g, " ").trim();
};

const dedent = (lines: string[], n: number): string => lines.map((l) => l.slice(n)).join("\n");

// ---- examples ---------------------------------------------------------------------

const sentenceCase = (name: string): string => {
  if (ACRONYMS[name]) return ACRONYMS[name];
  const words = name.replace(/([A-Z])/g, " $1").toLowerCase().trim();
  return words[0].toUpperCase() + words.slice(1);
};

const parseImports = (source: string): Import[] =>
  [...source.matchAll(/^import (\S+)(?: as (\w+))?(?: exposing \((.*)\))?$/gm)].map((m) => ({
    module: m[1],
    alias: m[2],
    exposing: m[3] ? m[3].split(",").map((s) => s.trim()) : [],
  }));

// Only the imports the snippet uses, so the code shown is what you would paste.
const importsFor = (imports: Import[], body: string): string[] =>
  imports.flatMap(({ module, alias, exposing }) => {
    const qualified = new RegExp(`(?<![\\w.])${escapeRegExp(alias ?? module)}\\.`).test(body);
    const used = exposing.filter((name) => new RegExp(`(?<![\\w.])${escapeRegExp(name)}(?![\\w])`).test(body));
    if (!qualified && used.length === 0) return [];
    return [
      `import ${module}` + (alias ? ` as ${alias}` : "") + (used.length > 0 ? ` exposing (${used.join(", ")})` : ""),
    ];
  });

const parseExamples = (source: string): Example[] => {
  const imports = parseImports(source);
  const pattern = new RegExp(
    `${DOC}^([a-z]\\w*) : (Html msg|State -> Html State\\.Msg)\\n\\2(?: \\w+)? =\\n((?:(?: {4}[^\\n]*)?\\n)+)`,
    "gm"
  );
  return [...source.matchAll(pattern)].map((m) => {
    const lines = m[4].replace(/\n+$/, "").split("\n");
    const body = dedent(lines, 4);
    return {
      id: m[2],
      stateful: m[3] !== "Html msg",
      title: sentenceCase(m[2]),
      description: firstParagraph(m[1]),
      code: [...importsFor(imports, body), "", body].join("\n"),
    };
  });
};

// ---- API --------------------------------------------------------------------------

const parseModule = (file: string, source: string): { usage: string; api: Entry[] } => {
  const moduleDoc = source.match(/\{-\|([\s\S]*?)\n-\}/)?.[1] ?? "";

  const lines = moduleDoc.split("\n");
  const start = lines.findIndex((l) => /^ {4}\S/.test(l));
  let usage = "";
  if (start !== -1) {
    let end = start;
    while (end + 1 < lines.length && /^( {4}.*|\s*)$/.test(lines[end + 1])) end++;
    usage = dedent(lines.slice(start, end + 1), 4).trim();
  }

  const names = [...moduleDoc.matchAll(/^@docs (.+)$/gm)].flatMap((m) => m[1].split(",").map((s) => s.trim()));

  const api = names.map((name): Entry => {
    const isType = /^[A-Z]/.test(name);
    const pattern = isType
      ? new RegExp(`${DOC}^(type (?:alias )?${name}\\b[^\\n]*)`, "m")
      : new RegExp(`${DOC}^(${name} : [^\\n]*(?:\\n {4}[^\\n]*)*)`, "m");
    const m = source.match(pattern);
    if (!m) {
      errors.push(`${file}: @docs ${name} has no declaration`);
      return { name, signature: "", description: "" };
    }
    const signature = isType ? m[2].trim() : m[2].replace(/^\w+ : /, "").replace(/\s+/g, " ");
    return { name, signature, description: firstParagraph(m[1]) };
  });

  return { usage, api };
};

// ---- components ---------------------------------------------------------------------

const component = async (item: Item): Promise<Component | null> => {
  const path = item.files.find((f) => f.path.startsWith("src/UI/"))!.path;
  const name = path.match(/UI\/(\w+)\.elm$/)![1];
  const examplesFile = Bun.file(`docs/Examples/${name}.elm`);
  if (!(await examplesFile.exists())) {
    errors.push(`${item.name}: missing ${examplesFile.name}`);
    return null;
  }
  const examples = parseExamples(await examplesFile.text());
  if (!examples.some((e) => e.id === "demo")) errors.push(`${examplesFile.name}: no \`demo : Html msg\``);
  return {
    slug: item.name,
    title: item.title,
    description: item.description,
    name,
    path,
    packages: (item.meta?.elmDependencies ?? []).filter((p) => p !== "elm/html"),
    examples,
    ...parseModule(path, await Bun.file(path).text()),
  };
};

const components = (
  await Promise.all(registry.items.filter((item) => item.files.some((f) => f.path.startsWith("src/UI/"))).map(component))
)
  .filter((c): c is Component => c !== null)
  .sort((a, b) => a.title.localeCompare(b.title));

if (errors.length > 0) {
  console.error(errors.map((e) => `✗ ${e}`).join("\n"));
  process.exit(1);
}

// ---- output -------------------------------------------------------------------------

const renderExample = (name: string, e: Example): string =>
  `{ id = ${str(e.id)}, title = ${str(e.title)}, description = ${str(e.description)}, view = ${
    e.stateful ? `Examples.${name}.${e.id}` : `\\_ -> Html.map never Examples.${name}.${e.id}`
  }, code = ${str(e.code)} }`;

const renderEntry = (e: Entry): string =>
  `{ name = ${str(e.name)}, signature = ${str(e.signature)}, description = ${str(e.description)} }`;

const renderComponent = (c: Component): string => `{ slug = ${str(c.slug)}
, title = ${str(c.title)}
, description = ${str(c.description)}
, module_ = ${str("UI." + c.name)}
, file = ${str(c.path)}
, packages = ${list(c.packages.map(str))}
, usage = ${str(c.usage)}
, examples = ${list(c.examples.map((e) => renderExample(c.name, e)))}
, api = ${list(c.api.map(renderEntry))}
}`;

const output = `module Generated exposing (components)

{-| Generated by scripts/gen-docs.ts. Do not edit.
-}

import Component exposing (Component)
import Html
${components.map((c) => `import Examples.${c.name}`).join("\n")}


components : List Component
components =
    ${list(components.map(renderComponent))}
`;

await Bun.write(OUTPUT, output);
await $`node_modules/.bin/elm-format ${OUTPUT} --yes`.quiet();
console.log(`${OUTPUT}: ${components.length} components, ${components.reduce((n, c) => n + c.examples.length, 0)} examples`);
