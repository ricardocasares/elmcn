# elmcn

[shadcn/ui](https://ui.shadcn.com) components for Elm, installed with the shadcn CLI.

Like shadcn/ui, this is not a package. The CLI copies the component source into your
project, and from then on the code is yours to read and change.

```elm
import UI.Button as Button

Button.new
    |> Button.text "Save"
    |> Button.outline
    |> Button.small
    |> Button.toHtml [ onClick Save ]
```

## Requirements

- Elm 0.19, with `src` as a source directory
- [Tailwind CSS v4](https://tailwindcss.com/docs/installation)
- Node.js, to run the shadcn CLI. No `components.json` is needed.

## Install

1. Add the theme. It writes `src/main.css`, which already imports Tailwind:

   ```sh
   npx shadcn@latest add ricardocasares/elmcn/theme
   ```

   Then link it from your `index.html`, instead of importing CSS from TypeScript:

   ```html
   <link rel="stylesheet" href="/src/main.css" />
   ```

2. Add components. Each one is written to `src/UI/<Name>.elm`, along with any
   components it uses:

   ```sh
   npx shadcn@latest add ricardocasares/elmcn/button ricardocasares/elmcn/card
   ```

### Starting a new app

The `starter` item sets up a Vite + Tailwind CSS v4 app around the theme and the
`button` component. It writes:

- `index.html`, `vite.config.ts`, `elm.json`, `package.json` and `AGENTS.md` in the project root,
  and `src/main.ts` and `src/main.css`
- `src/Main.elm`, a small app that saves the theme to `localStorage` and copies text to
  the clipboard
- `src/InteropDefinitions.elm` and `src/InteropPorts.elm`, the typed ports that
  `Main.elm` uses, and `src/Main.elm.d.ts`, their TypeScript types
- `public/favicon.svg`

```sh
npx shadcn@latest add ricardocasares/elmcn/starter --overwrite
npm install
npm run dev
```

`elm.json` and `package.json` list everything the starter needs, so in a new project
that is all there is to it (the CLI asks before replacing a `package.json` it has just
started, so pass `--overwrite`). In an existing project, decline overwriting them and add
the packages yourself: `elm install dillonkearns/elm-ts-json elm/browser elm/json`, and
`vite`, `vite-plugin-elm`, `@tailwindcss/vite`, `tailwindcss` and `elm-ts-interop` from
npm. `npm run dev` generates the TypeScript types and starts Vite.

After changing `InteropDefinitions.elm`, regenerate the types (`npm run dev` and `npm run build` do it for you):

```sh
npx elm-ts-interop --output src/Main.elm.d.ts
```

To pin a version, add a tag: `ricardocasares/elmcn/button#v0.1.0`. Pins apply only to
the item you name, not to the items it depends on.

## Components

| Item | Module |
| --- | --- |
| `accordion` | `UI.Accordion` |
| `alert` | `UI.Alert` |
| `alert-dialog` | `UI.AlertDialog` |
| `aspect-ratio` | `UI.AspectRatio` |
| `attachment` | `UI.Attachment` |
| `avatar` | `UI.Avatar` |
| `badge` | `UI.Badge` |
| `breadcrumb` | `UI.Breadcrumb` |
| `button` | `UI.Button` |
| `button-group` | `UI.ButtonGroup` |
| `card` | `UI.Card` |
| `checkbox` | `UI.Checkbox` |
| `dialog` | `UI.Dialog` |
| `drawer` | `UI.Drawer` |
| `dropdown-menu` | `UI.DropdownMenu` |
| `empty` | `UI.Empty` |
| `field` | `UI.Field` |
| `input` | `UI.Input` |
| `input-group` | `UI.InputGroup` |
| `input-otp` | `UI.InputOtp` |
| `item` | `UI.Item` |
| `kbd` | `UI.Kbd` |
| `label` | `UI.Label` |
| `message-scroller` | `UI.MessageScroller` |
| `native-select` | `UI.NativeSelect` |
| `pagination` | `UI.Pagination` |
| `popover` | `UI.Popover` |
| `progress` | `UI.Progress` |
| `radio-group` | `UI.RadioGroup` |
| `select` | `UI.Select` |
| `separator` | `UI.Separator` |
| `skeleton` | `UI.Skeleton` |
| `slider` | `UI.Slider` |
| `spinner` | `UI.Spinner` |
| `switch` | `UI.Switch` |
| `table` | `UI.Table` |
| `tabs` | `UI.Tabs` |
| `textarea` | `UI.Textarea` |
| `toggle` | `UI.Toggle` |
| `toggle-group` | `UI.ToggleGroup` |

None of the components need ports or their own `Model`/`update`. Dialog, Alert Dialog
and Drawer are the ones that come with a little TypeScript: `src/UI/elmcn-dialog.ts`
defines the `<elmcn-dialog>` element that opens and closes them and waits for their
transitions, so import it once from your JavaScript entry point
(`import "./UI/elmcn-dialog";`). Checkbox, Switch,
Radio Group and Native Select are styled native inputs, so `checked`, `onCheck`,
`onInput` and forms work as usual. Select keeps its value in your model and opens as a
native popover, positioned with CSS anchor positioning. Slider keeps its values in your
model too, with one native range input per thumb. Input OTP is one styled native text
input stretched over its slots, with the code in your model, so paste, SMS autofill and
forms work. Message Scroller is a transcript scroller whose scroll commands are
`Browser.Dom` tasks.

## Conventions

**Attributes, then children.** Every component takes `List (Attribute msg)` like
`elm/html`. Attributes you pass come after the component's own, so they override them
(`type_`, `role`, …). Parts of compound components are functions in the same module:
`Pagination.link`, `Table.row`, and so on.

**Components with options or content are builders.** Button, Badge, Alert, Attachment, Avatar, Breadcrumb, Card, Empty, Item, Kbd,
Input OTP, Message Scroller, Native Select, Progress, Select, Separator, Slider and Switch start
with `new`, add content, pipe through setters, and render at the end. The compiler won't
let you render until the required content is there: a button needs `text`, or `icon` and
an accessible `label`; a badge needs `text`; an alert or an attachment needs `title`; an avatar needs
`fallback`; a shortcut needs a `key`; a select needs an `id` and an `onSelect` handler; a message scroller needs an `id`; a slider needs a `value`, `range` or
`values` and then an `onChange` handler whose type follows from it; an input OTP needs a `value`, an `onChange` handler
and at least one `group`. Variants, sizes, `rounded`, `startIcon` and
`endIcon` are setters, and the renderer takes the attributes:

```elm
Button.new
    |> Button.text "Delete"
    |> Button.destructive
    |> Button.large
    |> Button.toHtml []

Button.new
    |> Button.icon trashIcon
    |> Button.label "Delete"
    |> Button.toHtml [ onClick Delete ]
```

**Buttons as links.** `Button.toAnchor` renders an `<a>` with the same content and setters
as `toHtml`, the equivalent of shadcn's `asChild` on an anchor:

```elm
Button.new
    |> Button.text "Login"
    |> Button.secondary
    |> Button.toAnchor [ href "/login" ]
```

**Styling other elements.** `Button.toAttributes` and `Badge.toAttributes` give you the
styles without the element, the equivalent of shadcn's `buttonVariants`:

```elm
span
    (Button.toAttributes
        (Button.new
            |> Button.outline
        )
    )
    [ text "Not a button" ]
```

**Buttons don't submit forms by default.** `Button.toHtml` renders `type="button"`, like
shadcn's Base UI button. Pass `type_ "submit"` for a submit button.

**Icons next to a label** go through `startIcon` or `endIcon`, which tighten the button's
padding on that side. They use logical properties, so they are also correct in
right-to-left layouts:

```elm
Button.new
    |> Button.text "Done"
    |> Button.outline
    |> Button.startIcon (Phosphor.check Regular |> Phosphor.toHtml [])
    |> Button.toHtml []
```

**Pointer cursor.** Tailwind v4 buttons use the default cursor. To get a pointer, add
this to your stylesheet:

```css
@layer base {
  button:not(:disabled),
  [role="button"]:not(:disabled) {
    cursor: pointer;
  }
}
```

**Overriding classes.** shadcn/ui merges classes with `tailwind-merge`, so a later
`rounded-full` replaces `rounded-md`. Elm has no equivalent: both classes end up on the
element, and Tailwind's own CSS order decides which one applies, not the order you
wrote them in. Adding classes that don't conflict works as you'd expect. To override a
class the component already sets, prefer a setter when there is one (`Button.rounded`);
otherwise use Tailwind's important modifier, or edit the component:

```elm
Skeleton.view [ class "size-12 rounded-full!" ]
```

**No icons included.** The checkbox tick, select chevron, breadcrumb separators, pagination chevrons and spinner
are plain CSS, so elmcn needs only `elm/html`. Bring your own icon library for `Button.startIcon`
and friends.

**Dark mode.** Add the `dark` class to `<html>` or any ancestor.

## Development

```sh
bun install
bun run build          # docs site → dist/ (open dist/index.html)
bun run check          # elm-format, registry schema, registry ↔ source consistency
bun run test:install   # install every item into a fresh Elm app and compile it
```

The registry is `registry.json` at the repository root. The shadcn CLI reads it, and
the files it lists, straight from GitHub, so there is nothing to build or host. When
you add a component:

1. Write `src/UI/<Name>.elm`, porting the classes from the shadcn/ui source.
2. Add an item to `registry.json`. Its target is the same path under `~/`. List the
   `registryDependencies` it imports and the `meta.elmDependencies` it needs.
3. Add `docs/Examples/<Name>.elm`: every `name : Html msg` in it becomes an example on
   the docs page, shown with its own source as the code. `demo` is the one at the top.
   An example that needs state, such as a select remembering its value, is
   `name : State -> Html State.Msg` instead; see `docs/State.elm`.
4. Run `bun run check && bun run test:install`.

## License

MIT. The component styles are adapted from [shadcn/ui](https://github.com/shadcn-ui/ui)
(MIT).
