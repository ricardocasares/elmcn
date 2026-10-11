// Checks that registry.json agrees with the Elm sources:
//
// - every src/UI module belongs to exactly one item
// - every file installs to the same path it has in this repo
// - every `import UI.X` is covered by a registryDependency
// - meta.elmDependencies lists every Elm package the item (and its dependencies) import
//
// Usage: node scripts/check-registry.mjs

import { readFileSync, readdirSync } from "node:fs";

const REPO = "ricardocasares/elmcn/";
const PACKAGES = { Html: "elm/html", Svg: "elm/svg", Json: "elm/json", Browser: "elm/browser" };

const registry = JSON.parse(readFileSync("registry.json", "utf8"));
const items = new Map(registry.items.map((item) => [item.name, item]));
const errors = [];

const moduleOwner = new Map();
for (const item of registry.items) {
  for (const file of item.files) {
    if (file.target !== `~/${file.path}`) {
      errors.push(`${item.name}: ${file.path} installs to ${file.target}, expected ~/${file.path}`);
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

for (const file of readdirSync("src/UI")) {
  const module = `UI.${file.replace(/\.elm$/, "")}`;
  if (!moduleOwner.has(module)) errors.push(`${module} is not in any registry item`);
}

const dependencyNames = (item) =>
  (item.registryDependencies ?? []).map((dependency) => {
    const name = dependency.replace(REPO, "");
    if (!items.has(name)) errors.push(`${item.name}: unknown registryDependency ${dependency}`);
    return name;
  });

const imports = (item) =>
  item.files
    .filter((file) => file.path.endsWith(".elm"))
    .flatMap((file) => [...readFileSync(file.path, "utf8").matchAll(/^import\s+([\w.]+)/gm)].map((m) => m[1]));

const packagesOf = (name, seen = new Set()) => {
  if (seen.has(name) || !items.has(name)) return new Set();
  seen.add(name);
  const item = items.get(name);
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
}

if (errors.length > 0) {
  console.error(errors.map((e) => `✗ ${e}`).join("\n"));
  process.exit(1);
}
console.log(`✔ ${registry.items.length} registry items match the Elm sources.`);
