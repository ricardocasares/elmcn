module UI.Button exposing
    ( Button, Text, Icon, Ready, NeedsLabel
    , view, icon, label
    , toHtml, toAttributes
    , startIcon, endIcon
    , destructive, outline, secondary, ghost, link
    , extraSmall, small, large
    )

{-| Displays a button or a component that looks like a button.

A button is built with a constructor, adjusted with setters, and rendered with `toHtml`:

    Button.view "Save"
        |> Button.toHtml [ onClick Save ]

    Button.view "Cancel"
        |> Button.outline
        |> Button.small
        |> Button.toHtml []

An icon-only button is built from an icon and must then be given an accessible label. `toHtml` won't accept it until it has one:

    Button.icon (Phosphor.cube Bold |> Phosphor.toHtml [])
        |> Button.label "A cube"
        |> Button.outline
        |> Button.toHtml []

The button has `type="button"`, so it doesn't submit forms unless you pass `type_ "submit"` to `toHtml`.

@docs Button, Text, Icon, Ready, NeedsLabel


# Constructors

@docs view, icon, label


# Rendering

@docs toHtml, toAttributes

Use `toAttributes` to make another element look like a button, for example a link:

    a (href "/login" :: Button.toAttributes (Button.view "" |> Button.secondary |> Button.small)) [ text "Login" ]


# Setters

@docs startIcon, endIcon


## Variants

The default variant is a solid primary button. When several variants are given, the last one wins.

@docs destructive, outline, secondary, ghost, link


## Sizes

Icon-only buttons are square versions of the same sizes. When several sizes are given, the last one wins.

@docs extraSmall, small, large

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, type_)


{-| A button being built.

`shape` is [`Text`](#Text) or [`Icon`](#Icon). `status` is [`Ready`](#Ready) once the button can be rendered, or [`NeedsLabel`](#NeedsLabel) while an icon button still lacks its label.

-}
type Button shape status msg
    = Button
        { variant : Variant
        , size : Size
        , content : Content msg
        }


{-| A button with a text label, made with [`view`](#view).
-}
type Text
    = Text


{-| A square button with a single icon, made with [`icon`](#icon).
-}
type Icon
    = Icon


{-| The button can be rendered.
-}
type Ready
    = Ready


{-| An icon button that still needs [`label`](#label) before it can be rendered.
-}
type NeedsLabel
    = NeedsLabel


type Content msg
    = Words
        { text : String
        , start : Maybe (Html msg)
        , end : Maybe (Html msg)
        }
    | Glyph
        { name : String
        , icon : Html msg
        }


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



-- CONSTRUCTORS


{-| A button with a text label.
-}
view : String -> Button Text Ready msg
view text =
    init (Words { text = text, start = Nothing, end = Nothing })


{-| A square button with only an icon. Give it an accessible name with [`label`](#label).
-}
icon : Html msg -> Button Icon NeedsLabel msg
icon child =
    init (Glyph { name = "", icon = child })


{-| The accessible name of an icon button, set as `aria-label`.
-}
label : String -> Button Icon NeedsLabel msg -> Button Icon Ready msg
label name (Button config) =
    case config.content of
        Glyph glyph ->
            Button { config | content = Glyph { glyph | name = name } }

        Words _ ->
            Button config


init : Content msg -> Button shape status msg
init content =
    Button { variant = Default, size = Medium, content = content }



-- RENDERING


{-| Renders a `<button type="button">` with the given attributes after the styles, so they can override them.
-}
toHtml : List (Attribute msg) -> Button shape Ready msg -> Html msg
toHtml attrs ((Button config) as button) =
    Html.button
        (type_ "button" :: attribute "data-slot" "button" :: toAttributes button ++ ariaLabel config.content ++ attrs)
        (children config.content)


ariaLabel : Content msg -> List (Attribute msg)
ariaLabel content =
    case content of
        Words _ ->
            []

        Glyph { name } ->
            [ attribute "aria-label" name ]


children : Content msg -> List (Html msg)
children content =
    case content of
        Words { text, start, end } ->
            List.filterMap identity
                [ Maybe.map (iconSlot "inline-start") start
                , Just (Html.text text)
                , Maybe.map (iconSlot "inline-end") end
                ]

        Glyph config ->
            [ config.icon ]


iconSlot : String -> Html msg -> Html msg
iconSlot position child =
    Html.span [ attribute "data-icon" position, class "contents" ] [ child ]


{-| The button styles, for elements other than `<button>`.
-}
toAttributes : Button shape status msg -> List (Attribute msg)
toAttributes (Button config) =
    [ class "group/button inline-flex shrink-0 items-center justify-center border bg-clip-padding font-medium whitespace-nowrap transition-all outline-none select-none focus-visible:ring-3 active:not-aria-[haspopup]:translate-y-px disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20 dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0"
    , class (variantClass config.variant)
    , class (sizeClass config.content config.size)
    ]



-- SETTERS


{-| An icon before the label. The padding is adjusted for it.
-}
startIcon : Html msg -> Button Text status msg -> Button Text status msg
startIcon child =
    mapText (\words -> { words | start = Just child })


{-| An icon after the label. The padding is adjusted for it.
-}
endIcon : Html msg -> Button Text status msg -> Button Text status msg
endIcon child =
    mapText (\words -> { words | end = Just child })


mapText :
    ({ text : String, start : Maybe (Html msg), end : Maybe (Html msg) } -> { text : String, start : Maybe (Html msg), end : Maybe (Html msg) })
    -> Button Text status msg
    -> Button Text status msg
mapText f (Button config) =
    case config.content of
        Words words ->
            Button { config | content = Words (f words) }

        Glyph _ ->
            Button config


variant : Variant -> Button shape status msg -> Button shape status msg
variant v (Button config) =
    Button { config | variant = v }


size : Size -> Button shape status msg -> Button shape status msg
size s (Button config) =
    Button { config | size = s }


{-| -}
destructive : Button shape status msg -> Button shape status msg
destructive =
    variant Destructive


{-| -}
outline : Button shape status msg -> Button shape status msg
outline =
    variant Outline


{-| -}
secondary : Button shape status msg -> Button shape status msg
secondary =
    variant Secondary


{-| -}
ghost : Button shape status msg -> Button shape status msg
ghost =
    variant Ghost


{-| Looks like a text link.
-}
link : Button shape status msg -> Button shape status msg
link =
    variant Link


{-| -}
extraSmall : Button shape status msg -> Button shape status msg
extraSmall =
    size ExtraSmall


{-| -}
small : Button shape status msg -> Button shape status msg
small =
    size Small


{-| -}
large : Button shape status msg -> Button shape status msg
large =
    size Large



-- shadcn merges its base, variant and size classes with tailwind-merge, which drops
-- the base classes a variant or size overrides. Elm keeps every class, so classes
-- that differ by variant or size live only in `variantClass` and `sizeClass`.


variantClass : Variant -> String
variantClass v =
    case v of
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


sizeClass : Content msg -> Size -> String
sizeClass content size_ =
    case content of
        Words _ ->
            labeledSizeClass size_

        Glyph _ ->
            iconSizeClass size_


labeledSizeClass : Size -> String
labeledSizeClass size_ =
    case size_ of
        Medium ->
            "h-8 gap-1.5 rounded-lg px-2.5 text-sm has-data-[icon=inline-end]:pe-2 has-data-[icon=inline-start]:ps-2 [&_svg:not([class*='size-'])]:size-4"

        ExtraSmall ->
            "h-6 gap-1 rounded-[min(var(--radius-md),10px)] px-2 text-xs in-data-[slot=button-group]:rounded-lg has-data-[icon=inline-end]:pe-1.5 has-data-[icon=inline-start]:ps-1.5 [&_svg:not([class*='size-'])]:size-3"

        Small ->
            "h-7 gap-1 rounded-[min(var(--radius-md),12px)] px-2.5 text-[0.8rem] in-data-[slot=button-group]:rounded-lg has-data-[icon=inline-end]:pe-1.5 has-data-[icon=inline-start]:ps-1.5 [&_svg:not([class*='size-'])]:size-3.5"

        Large ->
            "h-9 gap-1.5 rounded-lg px-2.5 text-sm has-data-[icon=inline-end]:pe-2 has-data-[icon=inline-start]:ps-2 [&_svg:not([class*='size-'])]:size-4"


iconSizeClass : Size -> String
iconSizeClass size_ =
    case size_ of
        Medium ->
            "size-8 rounded-lg text-sm [&_svg:not([class*='size-'])]:size-4"

        ExtraSmall ->
            "size-6 rounded-[min(var(--radius-md),10px)] text-sm in-data-[slot=button-group]:rounded-lg [&_svg:not([class*='size-'])]:size-3"

        Small ->
            "size-7 rounded-[min(var(--radius-md),12px)] text-sm in-data-[slot=button-group]:rounded-lg [&_svg:not([class*='size-'])]:size-4"

        Large ->
            "size-9 rounded-lg text-sm [&_svg:not([class*='size-'])]:size-4"
