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

1. Add the theme. It writes `src/elmcn.css`:

   ```sh
   npx shadcn@latest add ricardocasares/elmcn/theme
   ```

   Then import it after Tailwind in your main stylesheet:

   ```css
   @import "tailwindcss";
   @import "./elmcn.css"; /* path relative to this file */
   ```

2. Add components. Each one is written to `src/UI/<Name>.elm`, along with any
   components it uses:

   ```sh
   npx shadcn@latest add ricardocasares/elmcn/button ricardocasares/elmcn/card
   ```

To pin a version, add a tag: `ricardocasares/elmcn/button#v0.1.0`. Pins apply only to
the item you name, not to the items it depends on.

## Components

| Item | Module |
| --- | --- |
| `alert` | `UI.Alert` |
| `aspect-ratio` | `UI.AspectRatio` |
| `avatar` | `UI.Avatar` |
| `badge` | `UI.Badge` |
| `breadcrumb` | `UI.Breadcrumb` |
| `button` | `UI.Button` |
| `card` | `UI.Card` |
| `checkbox` | `UI.Checkbox` |
| `empty` | `UI.Empty` |
| `input` | `UI.Input` |
| `kbd` | `UI.Kbd` |
| `label` | `UI.Label` |
| `native-select` | `UI.NativeSelect` |
| `progress` | `UI.Progress` |
| `radio-group` | `UI.RadioGroup` |
| `select` | `UI.Select` |
| `separator` | `UI.Separator` |
| `skeleton` | `UI.Skeleton` |
| `spinner` | `UI.Spinner` |
| `switch` | `UI.Switch` |
| `table` | `UI.Table` |
| `textarea` | `UI.Textarea` |

None of the components need ports or their own `Model`/`update`. Checkbox, Switch,
Radio Group and Native Select are styled native inputs, so `checked`, `onCheck`,
`onInput` and forms work as usual. Select keeps its value in your model and opens as a
native popover, positioned with CSS anchor positioning.

## Conventions

**Attributes, then children.** Every component takes `List (Attribute msg)` like
`elm/html`. Attributes you pass come after the component's own, so they override them
(`type_`, `role`, …). Parts of compound components are functions in the same module:
`Breadcrumb.item`, `Table.row`, and so on.

**Options come first.** Simple components with variants take a list of options before
the attributes. An empty list gives the defaults, and the last option of a kind wins:

```elm
Separator.view [] []
Separator.view [ Separator.vertical ] []
```

**Components with content are builders.** Button, Badge, Alert, Avatar, Card, Empty, Kbd and Select start
with `new`, add content, pipe through setters, and render at the end. The compiler won't
let you render until the required content is there: a button needs `text`, or `icon` and
an accessible `label`; a badge needs `text`; an alert needs `title`; an avatar needs
`fallback`; a shortcut needs a `key`; a select needs an `id` and an `onSelect` handler. Variants, sizes, `rounded`, `startIcon` and
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

**No icons included.** The checkbox tick, select chevron, breadcrumb separators and spinner
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
