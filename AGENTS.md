# AGENTS.md

Conventions for this repo that you cannot read off the code. For the layout, scripts and
install flow, read `README.md`, `package.json` and the header comments in `scripts/*.ts`.

## What a component is a port of

- Port shadcn/ui's **Base UI** variant in the **nova** style, not the Radix one. The docs
  pages at `ui.shadcn.com/docs/components/base/<name>` truncate code, and the shadcn MCP
  server returns the older Radix item. Fetch the raw sources from
  `github.com/shadcn-ui/ui` instead:
  - markup and structure: `apps/v4/registry/bases/base/ui/<name>.tsx`
  - concrete Tailwind classes: `apps/v4/registry/styles/style-nova.css` (grep `.cn-<name>`)
  - examples: `apps/v4/registry/bases/base/examples/<name>-*.tsx`
- Mirror the classes exactly. When a variant or size would clash with a base class under
  tailwind-merge, move the base class into the variant/size branches instead of relying on
  `!important`.
- The docs examples must match shadcn's examples, same set and same order. When improving
  an existing component, diff it against upstream and add any missing examples.

## API style

- Every component is a phantom-typed builder that is correct by construction: `X.new`,
  then content setters, then variant/size setters, then `toHtml []` (plus `toAnchor` and
  `toAttributes` where it makes sense). Required content is enforced by the type, so
  `toHtml` rejects an incomplete value. Last variant wins. See `UI.Button` and `UI.Badge`
  for the reference shape, and the `elm-patterns` skill for the reasoning.
- Anything users would otherwise reach for `!` classes to override gets a setter
  (`Button.rounded` is the precedent).
- For a new component or an API change,
  propose the pipeline as a short code sketch first, then build the agreed version.
  When a builder becomes awkward (pagination), prefer a simpler API over a clever one.
- Behaviour stays in Elm. No JS, no ports, no new Elm packages for component logic.
  Positioning, keyboard navigation and open/close state are done with Elm and CSS.
  Avoid adding `elm/svg` or other packages to a component when CSS can do the job.
- The exception is Dialog, which wraps its `<dialog>` in `<elmcn-dialog>` (`src/UI/elmcn-dialog.ts`),
  a thin custom element for the imperative `showModal`/`close` and for waiting on
  `transitionend`. Keep it thin: attributes in, DOM events out, no rendering.

## Formatting

- Break the line after `X.new` and put each `|>` on its own line, always, including in
  doc comments, `README.md` and the example modules. elm-format does not enforce this in
  strings or markdown, so check by hand.

## Workflow

- Run the dev server through `.claude/launch.json` (`docs`), then compare the rendered
  component against the live shadcn page side by side. Popover-style components (select,
  dropdown, dialog) had positioning glitches that only showed in Safari, Firefox or
  mobile Safari, so check more than Chrome when touching them.
- `docs/Generated.elm` is generated. Add `docs/Examples/<Name>.elm` and the registry
  item, then regenerate. Stateful examples go through `docs/State.elm`.
- Before reporting done: `bun run check` and `bun run test:install`. The pre-commit hook
  runs elm-review fixes and elm-format on staged files.
- Scripts are TypeScript run with Bun, using Bun's file APIs. Don't add Node-only code.
- When asked to add several components, spawn one agent per component in parallel and
  review their examples against upstream afterwards.
- Commit and push only when asked.
