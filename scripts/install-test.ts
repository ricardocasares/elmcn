// Installs every registry item into its own fresh Elm app with the shadcn CLI,
// then compiles the installed modules. Catches missing registryDependencies
// and Elm packages that an item forgets to declare.
//
// Dependencies point at GitHub (ricardocasares/elmcn/<name>), so the registry is
// rebuilt into a temp folder with those rewritten to local files. Nothing is fetched
// from GitHub, so this tests the working tree, not what is pushed.
//
// Usage: bun scripts/install-test.ts [item ...]

import { $ } from "bun";
import { mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

type Item = {
  name: string;
  files: { target: string }[];
  registryDependencies?: string[];
  meta?: { elmDependencies?: string[] };
};
type Registry = { items: Item[] };
type ElmJson = {
  "elm-version": string;
  dependencies: { direct: Record<string, string>; indirect: Record<string, string> };
};

const REPO = "ricardocasares/elmcn/";
const root = resolve(".");
const bin = (name: string): string => join(root, "node_modules", ".bin", name);

const temp = mkdtempSync(join(tmpdir(), "elmcn-install-"));
const output = join(temp, "r");

const registry: Registry = await Bun.file("registry.json").json();
for (const item of registry.items) {
  item.registryDependencies = item.registryDependencies?.map((dependency) =>
    join(output, `${dependency.replace(REPO, "")}.json`)
  );
}
await Bun.write(join(temp, "registry.json"), JSON.stringify(registry));
await $`${bin("shadcn")} build ${join(temp, "registry.json")} --output ${output} --cwd ${root}`.cwd(root).quiet();

const project: ElmJson = await Bun.file("elm.json").json();
const versions = { ...project.dependencies.direct, ...project.dependencies.indirect };
const pick = (names: string[]): Record<string, string> => Object.fromEntries(names.map((name) => [name, versions[name]]));

// elm occasionally dies after a successful compile while it updates elm-stuff/d.dat
// ("resource busy (file is locked)" then "thread blocked indefinitely in an MVar
// operation"). It is a race inside the compiler, so retry it rather than fail the item.
const elmMake = async (file: string, cwd: string, attempts = 3): Promise<void> => {
  for (let attempt = 1; ; attempt++) {
    try {
      await $`${bin("elm")} make ${file} --output=/dev/null`.cwd(cwd).quiet();
      return;
    } catch (error) {
      const stderr = (error as { stderr?: Buffer }).stderr?.toString() ?? "";
      if (attempt >= attempts || !stderr.includes("file is locked")) throw error;
      rmSync(join(cwd, "elm-stuff"), { recursive: true, force: true });
    }
  }
};

const only = Bun.argv.slice(2);
const items = registry.items.filter((item) => only.length === 0 || only.includes(item.name));
let failures = 0;

for (const item of items) {
  const app = join(temp, "apps", item.name);
  mkdirSync(join(app, "src"), { recursive: true });
  const packages = new Set(["elm/browser", "elm/core", "elm/html", ...(item.meta?.elmDependencies ?? [])]);
  await Bun.write(
    join(app, "elm.json"),
    JSON.stringify({
      type: "application",
      "source-directories": ["src"],
      "elm-version": project["elm-version"],
      dependencies: {
        direct: pick([...packages].sort()),
        indirect: pick(["elm/json", "elm/time", "elm/url", "elm/virtual-dom"].filter((name) => !packages.has(name))),
      },
      "test-dependencies": { direct: {}, indirect: {} },
    })
  );

  try {
    await $`${bin("shadcn")} add ${join(output, `${item.name}.json`)} --yes --silent --cwd ${app}`.cwd(app).quiet();
    for (const file of item.files) {
      const installed = join(app, file.target.replace("~/", ""));
      if (!(await Bun.file(installed).exists())) throw new Error(`${file.target} was not installed`);
      if (installed.endsWith(".elm")) await elmMake(installed, app);
    }
    console.log(`✔ ${item.name}`);
  } catch (error) {
    failures += 1;
    const shell = error as { stdout?: Buffer; stderr?: Buffer; message?: string };
    console.error(`✗ ${item.name}\n${shell.stdout?.toString() ?? ""}${shell.stderr?.toString() ?? shell.message}`);
  }
}

if (failures > 0) process.exit(1);
console.log(`✔ ${items.length} items install and compile in a fresh Elm app.`);
