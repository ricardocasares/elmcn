// Installs every registry item into its own fresh Elm app with the shadcn CLI,
// then compiles the installed modules. Catches missing registryDependencies
// and Elm packages that an item forgets to declare.
//
// Dependencies point at GitHub (ricardocasares/elmcn/<name>), so the registry is
// rebuilt into a temp folder with those rewritten to local files. Nothing is fetched
// from GitHub, so this tests the working tree, not what is pushed.
//
// Usage: node scripts/install-test.mjs [item ...]

import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

const REPO = "ricardocasares/elmcn/";
const root = resolve(".");
const bin = (name) => join(root, "node_modules", ".bin", name);
const run = (command, args, cwd) => execFileSync(command, args, { cwd, stdio: "pipe", encoding: "utf8" });

const temp = mkdtempSync(join(tmpdir(), "elmcn-install-"));
const output = join(temp, "r");

const registry = JSON.parse(readFileSync("registry.json", "utf8"));
for (const item of registry.items) {
  item.registryDependencies = item.registryDependencies?.map((dependency) =>
    join(output, `${dependency.replace(REPO, "")}.json`)
  );
}
writeFileSync(join(temp, "registry.json"), JSON.stringify(registry));
run(bin("shadcn"), ["build", join(temp, "registry.json"), "--output", output, "--cwd", root], root);

const project = JSON.parse(readFileSync("elm.json", "utf8"));
const versions = { ...project.dependencies.direct, ...project.dependencies.indirect };
const pick = (names) => Object.fromEntries(names.map((name) => [name, versions[name]]));

const only = process.argv.slice(2);
const items = registry.items.filter((item) => only.length === 0 || only.includes(item.name));
let failures = 0;

for (const item of items) {
  const app = join(temp, "apps", item.name);
  mkdirSync(join(app, "src"), { recursive: true });
  const packages = new Set(["elm/browser", "elm/core", "elm/html", ...(item.meta?.elmDependencies ?? [])]);
  writeFileSync(
    join(app, "elm.json"),
    JSON.stringify({
      type: "application",
      "source-directories": ["src"],
      "elm-version": project["elm-version"],
      dependencies: {
        direct: pick([...packages].sort()),
        indirect: pick(["elm/json", "elm/time", "elm/url", "elm/virtual-dom"]),
      },
      "test-dependencies": { direct: {}, indirect: {} },
    })
  );

  try {
    run(bin("shadcn"), ["add", join(output, `${item.name}.json`), "--yes", "--silent", "--cwd", app], app);
    for (const file of item.files) {
      const installed = join(app, file.target.replace("~/", ""));
      if (!existsSync(installed)) throw new Error(`${file.target} was not installed`);
      if (installed.endsWith(".elm")) run(bin("elm"), ["make", installed, "--output=/dev/null"], app);
    }
    console.log(`✔ ${item.name}`);
  } catch (error) {
    failures += 1;
    console.error(`✗ ${item.name}\n${error.stdout ?? ""}${error.stderr ?? error.message}`);
  }
}

if (failures > 0) process.exit(1);
console.log(`✔ ${items.length} items install and compile in a fresh Elm app.`);
