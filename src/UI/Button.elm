module UI.Button exposing
    ( view, attributes
    , Option
    , destructive, outline, secondary, ghost, link
    , extraSmall, small, large, icon, iconExtraSmall, iconSmall, iconLarge
    )

{-| Displays a button or a component that looks like a button.

    Button.view [] [ onClick Save ] [ text "Save" ]

    Button.view [ Button.outline, Button.small ] [ onClick Cancel ] [ text "Cancel" ]

The button has `type="button"`, so it doesn't submit forms unless you pass `type_ "submit"`.

Mark an icon next to the label with `data-icon` so the padding is adjusted for it:

    Button.view [ Button.outline ]
        []
        [ someIcon [ attribute "data-icon" "inline-start" ], text "New Branch" ]

Use `attributes` to make another element look like a button, for example a link:

    a (href "/login" :: Button.attributes [ Button.secondary, Button.small ]) [ text "Login" ]

@docs view, attributes


# Options

@docs Option


## Variants

The default variant is a solid primary button.

@docs destructive, outline, secondary, ghost, link


## Sizes

@docs extraSmall, small, large, icon, iconExtraSmall, iconSmall, iconLarge

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, type_)


{-| Renders a `<button type="button">`.
-}
view : List Option -> List (Attribute msg) -> List (Html msg) -> Html msg
view options attrs children =
    Html.button (type_ "button" :: attribute "data-slot" "button" :: attributes options ++ attrs) children


{-| The button styles as attributes, for elements other than `<button>`.
-}
attributes : List Option -> List (Attribute msg)
attributes options =
    let
        config =
            List.foldl apply { variant = Default, size = Medium } options
    in
    [ class "group/button inline-flex shrink-0 items-center justify-center border bg-clip-padding font-medium whitespace-nowrap transition-all outline-none select-none focus-visible:ring-3 active:not-aria-[haspopup]:translate-y-px disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20 dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0"
    , class (variantClass config.variant)
    , class (sizeClass config.size)
    ]



-- OPTIONS


{-| A variant or size. When several of the same kind are given, the last one wins.
-}
type Option
    = Variant Variant
    | Size Size


type Variant
    = Default
    | Destructive
    | Outline
    | Secondary
    | Ghost
    | Link


type Size
    = Medium
    | ExtraSmall
    | Small
    | Large
    | Icon
    | IconExtraSmall
    | IconSmall
    | IconLarge


{-| -}
destructive : Option
destructive =
    Variant Destructive


{-| -}
outline : Option
outline =
    Variant Outline


{-| -}
secondary : Option
secondary =
    Variant Secondary


{-| -}
ghost : Option
ghost =
    Variant Ghost


{-| Looks like a text link.
-}
link : Option
link =
    Variant Link


{-| -}
extraSmall : Option
extraSmall =
    Size ExtraSmall


{-| -}
small : Option
small =
    Size Small


{-| -}
large : Option
large =
    Size Large


{-| A square button for a single icon.
-}
icon : Option
icon =
    Size Icon


{-| -}
iconExtraSmall : Option
iconExtraSmall =
    Size IconExtraSmall


{-| -}
iconSmall : Option
iconSmall =
    Size IconSmall


{-| -}
iconLarge : Option
iconLarge =
    Size IconLarge


apply : Option -> { variant : Variant, size : Size } -> { variant : Variant, size : Size }
apply option config =
    case option of
        Variant variant ->
            { config | variant = variant }

        Size size ->
            { config | size = size }



-- shadcn merges its base, variant and size classes with tailwind-merge, which drops
-- the base classes a variant or size overrides. Elm keeps every class, so classes
-- that differ by variant or size live only in `variantClass` and `sizeClass`.


variantClass : Variant -> String
variantClass variant =
    case variant of
        Default ->
            "border-transparent bg-primary text-primary-foreground hover:bg-primary/80 focus-visible:border-ring focus-visible:ring-ring/50"

        Destructive ->
            "border-transparent bg-destructive/10 text-destructive hover:bg-destructive/20 focus-visible:border-destructive/40 focus-visible:ring-destructive/20 dark:bg-destructive/20 dark:hover:bg-destructive/30 dark:focus-visible:ring-destructive/40"

        Outline ->
            "border-border bg-background hover:bg-muted hover:text-foreground focus-visible:border-ring focus-visible:ring-ring/50 aria-expanded:bg-muted aria-expanded:text-foreground dark:border-input dark:bg-input/30 dark:hover:bg-input/50"

        Secondary ->
            "border-transparent bg-secondary text-secondary-foreground hover:bg-[color-mix(in_oklch,var(--secondary),var(--foreground)_5%)] focus-visible:border-ring focus-visible:ring-ring/50 aria-expanded:bg-secondary aria-expanded:text-secondary-foreground"

        Ghost ->
            "border-transparent hover:bg-muted hover:text-foreground focus-visible:border-ring focus-visible:ring-ring/50 aria-expanded:bg-muted aria-expanded:text-foreground dark:hover:bg-muted/50"

        Link ->
            "border-transparent text-primary underline-offset-4 hover:underline focus-visible:border-ring focus-visible:ring-ring/50"


sizeClass : Size -> String
sizeClass size =
    case size of
        Medium ->
            "h-8 gap-1.5 rounded-lg px-2.5 text-sm has-data-[icon=inline-end]:pe-2 has-data-[icon=inline-start]:ps-2 [&_svg:not([class*='size-'])]:size-4"

        ExtraSmall ->
            "h-6 gap-1 rounded-[min(var(--radius-md),10px)] px-2 text-xs in-data-[slot=button-group]:rounded-lg has-data-[icon=inline-end]:pe-1.5 has-data-[icon=inline-start]:ps-1.5 [&_svg:not([class*='size-'])]:size-3"

        Small ->
            "h-7 gap-1 rounded-[min(var(--radius-md),12px)] px-2.5 text-[0.8rem] in-data-[slot=button-group]:rounded-lg has-data-[icon=inline-end]:pe-1.5 has-data-[icon=inline-start]:ps-1.5 [&_svg:not([class*='size-'])]:size-3.5"

        Large ->
            "h-9 gap-1.5 rounded-lg px-2.5 text-sm has-data-[icon=inline-end]:pe-2 has-data-[icon=inline-start]:ps-2 [&_svg:not([class*='size-'])]:size-4"

        Icon ->
            "size-8 rounded-lg text-sm [&_svg:not([class*='size-'])]:size-4"

        IconExtraSmall ->
            "size-6 rounded-[min(var(--radius-md),10px)] text-sm in-data-[slot=button-group]:rounded-lg [&_svg:not([class*='size-'])]:size-3"

        IconSmall ->
            "size-7 rounded-[min(var(--radius-md),12px)] text-sm in-data-[slot=button-group]:rounded-lg [&_svg:not([class*='size-'])]:size-4"

        IconLarge ->
            "size-9 rounded-lg text-sm [&_svg:not([class*='size-'])]:size-4"
