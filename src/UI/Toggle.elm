module UI.Toggle exposing
    ( Toggle
    , new
    , pressed
    , outline
    , small, large
    , toHtml, toAttributes
    )

{-| A two-state button that can be either on or off.

A toggle is built with `new`, told whether it is `pressed`, and rendered with `toHtml`. Whether it is pressed lives in your model, and a click tells you to flip it:

    Toggle.new
        |> Toggle.pressed model.bold
        |> Toggle.toHtml
            [ attribute "aria-label" "Toggle bold", onClick BoldToggled ]
            [ Phosphor.textB Regular |> Phosphor.toHtml [] ]

The content can be an icon, text, or both. An icon-only toggle needs an `aria-label`.

`toHtml` renders a `<button type="button">` with `aria-pressed`, so the toggle doesn't submit forms and the styles key off the pressed state. Pass `disabled True` to disable it.

@docs Toggle


# Constructor

@docs new


# State

@docs pressed


# Variants

The default variant has no border. When several variants are given, the last one wins.

@docs outline


# Sizes

When several sizes are given, the last one wins.

@docs small, large


# Rendering

@docs toHtml, toAttributes

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, type_)


{-| A toggle being built.
-}
type Toggle
    = Toggle
        { variant : Variant
        , size : Size
        , pressed : Bool
        }


type Variant
    = Default
    | Outline


type Size
    = Medium
    | Small
    | Large



-- CONSTRUCTOR


{-| A toggle that is not pressed, at the default variant and size.
-}
new : Toggle
new =
    Toggle { variant = Default, size = Medium, pressed = False }



-- STATE


{-| Whether the toggle is on, usually from your model. A pressed toggle is filled and has `aria-pressed="true"`.
-}
pressed : Bool -> Toggle -> Toggle
pressed on (Toggle config) =
    Toggle { config | pressed = on }



-- VARIANTS


{-| A bordered toggle.
-}
outline : Toggle -> Toggle
outline (Toggle config) =
    Toggle { config | variant = Outline }



-- SIZES


{-| -}
small : Toggle -> Toggle
small (Toggle config) =
    Toggle { config | size = Small }


{-| -}
large : Toggle -> Toggle
large (Toggle config) =
    Toggle { config | size = Large }



-- RENDERING


{-| Renders a `<button type="button" aria-pressed>` with the given attributes after the styles, so they can override them, and the given content.
-}
toHtml : List (Attribute msg) -> List (Html msg) -> Toggle -> Html msg
toHtml attrs children toggle =
    Html.button
        (type_ "button" :: attribute "data-slot" "toggle" :: toAttributes toggle ++ attrs)
        children


{-| The toggle styles and `aria-pressed` alone, for another element or for building a group of toggles.
-}
toAttributes : Toggle -> List (Attribute msg)
toAttributes (Toggle config) =
    [ attribute "aria-pressed" (boolean config.pressed)
    , class "group/toggle inline-flex items-center justify-center gap-1 font-medium whitespace-nowrap transition-all outline-none hover:bg-muted hover:text-foreground focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 aria-pressed:bg-muted aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0"
    , class (variantClass config.variant)
    , class (sizeClass config.size)
    ]
        ++ (if config.pressed then
                [ attribute "data-pressed" "" ]

            else
                []
           )


boolean : Bool -> String
boolean b =
    if b then
        "true"

    else
        "false"



-- shadcn merges its base, variant and size classes with tailwind-merge, which drops
-- the base classes a size overrides. Elm keeps every class, so the radius, text size
-- and icon size that differ by size live only in `sizeClass`.


variantClass : Variant -> String
variantClass variant =
    case variant of
        Default ->
            "bg-transparent"

        Outline ->
            "border border-input bg-transparent"


sizeClass : Size -> String
sizeClass size =
    case size of
        Medium ->
            "h-8 min-w-8 rounded-lg px-2.5 text-sm has-data-[icon=inline-end]:pe-2 has-data-[icon=inline-start]:ps-2 [&_svg:not([class*='size-'])]:size-4"

        Small ->
            "h-7 min-w-7 rounded-[min(var(--radius-md),12px)] px-2.5 text-[0.8rem] has-data-[icon=inline-end]:pe-1.5 has-data-[icon=inline-start]:ps-1.5 [&_svg:not([class*='size-'])]:size-3.5"

        Large ->
            "h-9 min-w-9 rounded-lg px-2.5 text-sm has-data-[icon=inline-end]:pe-2 has-data-[icon=inline-start]:ps-2 [&_svg:not([class*='size-'])]:size-4"
