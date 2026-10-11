module UI.Kbd exposing
    ( Kbd, Ready, NeedsKey
    , new
    , key, separator
    , toHtml
    )

{-| Displays textual user input from a keyboard.

A shortcut is built with `new`, given its keys, and rendered with `toHtml`.
A single key renders as one `<kbd>`:

    Kbd.new
        |> Kbd.key "Cmd"
        |> Kbd.toHtml []

Several keys are rendered as a group:

    Kbd.new
        |> Kbd.key "Cmd"
        |> Kbd.key "S"
        |> Kbd.toHtml []

An optional separator can be placed between keys:

    Kbd.new
        |> Kbd.key "Ctrl"
        |> Kbd.separator "+"
        |> Kbd.key "B"
        |> Kbd.toHtml []

A shortcut needs at least one key, and a separator must be followed by a key.
`toHtml` won't accept it otherwise:

    Kbd.new
        |> Kbd.key "Ctrl"
        |> Kbd.separator "+"
        |> Kbd.toHtml []
        -- compile error: the shortcut is still `NeedsKey`

@docs Kbd, Ready, NeedsKey


# Constructor

@docs new


# Keys

@docs key, separator


# Rendering

@docs toHtml

-}

import Html exposing (Attribute, Html, span, text)
import Html.Attributes exposing (attribute, class)


{-| A shortcut being built.

`status` is [`Ready`](#Ready) once the shortcut can be rendered, or [`NeedsKey`](#NeedsKey) while it still lacks a key.

-}
type Kbd status msg
    = Kbd (List Part)


type Part
    = Key String
    | Separator String


{-| The shortcut can be rendered.
-}
type Ready
    = Ready


{-| A shortcut that still needs a [`key`](#key) before it can be rendered.
-}
type NeedsKey
    = NeedsKey



-- CONSTRUCTOR


{-| An empty shortcut. Give it a [`key`](#key) to make it renderable.
-}
new : Kbd NeedsKey msg
new =
    Kbd []



-- KEYS


{-| Appends a key.
-}
key : String -> Kbd status msg -> Kbd Ready msg
key label (Kbd parts) =
    Kbd (Key label :: parts)


{-| Appends a separator, such as `+`, shown between the previous key and the next one.
-}
separator : String -> Kbd Ready msg -> Kbd NeedsKey msg
separator label (Kbd parts) =
    Kbd (Separator label :: parts)



-- RENDERING


{-| Renders the shortcut with the given attributes after the styles, so they can override them.

A single key renders as a `<kbd>`, and several keys as a group of them.

-}
toHtml : List (Attribute msg) -> Kbd Ready msg -> Html msg
toHtml attrs (Kbd parts) =
    case List.reverse parts of
        [ Key label ] ->
            viewKey attrs label

        ordered ->
            Html.kbd (attribute "data-slot" "kbd-group" :: class "inline-flex items-center gap-1" :: attrs)
                (List.map viewPart ordered)


viewPart : Part -> Html msg
viewPart part =
    case part of
        Key label ->
            viewKey [] label

        Separator label ->
            span [] [ text label ]


viewKey : List (Attribute msg) -> String -> Html msg
viewKey attrs label =
    Html.kbd
        ([ attribute "data-slot" "kbd"
         , class "pointer-events-none inline-flex h-5 w-fit min-w-5 items-center justify-center gap-1 rounded-sm bg-muted px-1 font-sans text-xs font-medium text-muted-foreground select-none"
         , class "[&_svg:not([class*='size-'])]:size-3"
         , class "[[data-slot=tooltip-content]_&]:bg-background/20 [[data-slot=tooltip-content]_&]:text-background dark:[[data-slot=tooltip-content]_&]:bg-background/10"
         ]
            ++ attrs
        )
        [ text label ]
