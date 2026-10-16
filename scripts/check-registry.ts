// Checks that registry.json agrees with the Elm sources:
//
// - every src/UI module belongs to exactly one item
// - every file installs to the same path it has in this repo
// - every `import UI.X` is covered by a registryDependency
// - meta.elmDependencies lists every Elm package the item (and its dependencies) import
// - the docs of an item that ships a script tell users to import it
//
// Usage: bun scripts/check-registry.ts

import { readdirSync } from "node:fs";

type File = { path: string; target: string };
type Item = {
  name: string;
  files: File[];
  docs?: string;
  registryDependencies?: string[];
  meta?: { elmDependencies?: string[] };
};
type Registry = { items: Item[] };

const REPO = "ricardocasares/elmcn/";
const PACKAGES: Record<string, string> = {
  Html: "elm/html",
  Svg: "elm/svg",
  Json: "elm/json",
  Browser: "elm/browser",
  TsJson: "dillonkearns/elm-ts-json"
};

// Templates kept in src/ in this repo, because the root copies belong to the docs site, that install to the project root.
const ROOT_FILES = new Set(["src/index.html", "src/vite.config.ts", "src/elm.json", "src/package.json", "src/.gitignore"]);

const registry: Registry = await Bun.file("registry.json").json();
const items = new Map(registry.items.map((item) => [item.name, item]));
const errors: string[] = [];

const moduleOwner = new Map<string, string>();
for (const item of registry.items) {
  for (const file of item.files) {
    const expected = ROOT_FILES.has(file.path) ? `~/${file.path.replace(/^src\//, "")}` : `~/${file.path}`;
    if (file.target !== expected) {
      errors.push(`${item.name}: ${file.path} installs to ${file.target}, expected ${expected}`);
    }
    const match = file.path.match(/^src\/(UI\/.+)\.elm$/);
    if (match) {
      const module = match[1].replaceAll("/", ".");
      if (moduleOwner.has(module)) {
        errors.push(`${module} is in both ${moduleOwner.get(module)} and ${item.name}`);
      }
      moduleOwner.set(module, item.name);
    }
  }
}

for (const file of readdirSync("src/UI").filter((f) => f.endsWith(".elm"))) {
  const module = `UI.${file.replace(/\.elm$/, "")}`;
  if (!moduleOwner.has(module)) errors.push(`${module} is not in any registry item`);
}

const dependencyNames = (item: Item): string[] =>
  (item.registryDependencies ?? []).map((dependency) => {
    const name = dependency.replace(REPO, "");
    if (!items.has(name)) errors.push(`${item.name}: unknown registryDependency ${dependency}`);
    return name;
  });

const sources = new Map<string, string>();
await Promise.all(
  registry.items
    .flatMap((item) => item.files)
    .filter((file) => file.path.endsWith(".elm"))
    .map(async (file) => sources.set(file.path, await Bun.file(file.path).text()))
);

const imports = (item: Item): string[] =>
  item.files
    .filter((file) => file.path.endsWith(".elm"))
    .flatMap((file) => [...sources.get(file.path)!.matchAll(/^import\s+([\w.]+)/gm)].map((m) => m[1]));

const packagesOf = (name: string, seen = new Set<string>()): Set<string> => {
  const item = items.get(name);
  if (seen.has(name) || !item) return new Set();
  seen.add(name);
  const packages = new Set(
    imports(item)
      .map((module) => PACKAGES[module.split(".")[0]])
      .filter(Boolean)
  );
  for (const dependency of dependencyNames(item)) {
    for (const p of packagesOf(dependency, seen)) packages.add(p);
  }
  return packages;
};

for (const item of registry.items) {
  const dependencies = dependencyNames(item);

  for (const module of imports(item).filter((m) => m.startsWith("UI."))) {
    const owner = moduleOwner.get(module);
    if (!owner) errors.push(`${item.name}: imports ${module}, which no item provides`);
    else if (owner !== item.name && !dependencies.includes(owner)) {
      errors.push(`${item.name}: imports ${module} but does not depend on ${REPO}${owner}`);
    }
  }

  const declared = new Set(item.meta?.elmDependencies ?? []);
  for (const p of packagesOf(item.name)) {
    if (!declared.has(p)) errors.push(`${item.name}: needs ${p}, missing from meta.elmDependencies`);
  }
  for (const p of declared) {
    if (p !== "elm/html" && p !== "elm/core" && !(item.docs ?? "").includes(p)) {
      errors.push(`${item.name}: needs ${p}, but its docs don't tell users to install it`);
    }
  }
  for (const file of item.files.filter((f) => f.path.startsWith("src/UI/") && f.path.endsWith(".ts"))) {
    const specifier = file.target.replace(/^~\/src\//, "./").replace(/\.ts$/, "");
    if (!(item.docs ?? "").includes(`import "${specifier}";`)) {
      errors.push(`${item.name}: ships ${file.path}, but its docs don't tell users to import "${specifier}"`);
    }
  }
}

if (errors.length > 0) {
  console.error(errors.map((e) => `✗ ${e}`).join("\n"));
  process.exit(1);
}
console.log(`✔ ${registry.items.length} registry items match the Elm sources.`);
