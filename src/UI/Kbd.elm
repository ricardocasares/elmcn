module UI.Kbd exposing (view, group)

{-| Displays textual user input from a keyboard.

    Kbd.group []
        [ Kbd.view [] [ text "Ctrl" ]
        , span [] [ text "+" ]
        , Kbd.view [] [ text "B" ]
        ]

@docs view, group

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)


{-| Renders a `<kbd>`.
-}
view : List (Attribute msg) -> List (Html msg) -> Html msg
view attrs children =
    Html.kbd
        ([ attribute "data-slot" "kbd"
         , class "pointer-events-none inline-flex h-5 w-fit min-w-5 items-center justify-center gap-1 rounded-sm bg-muted px-1 font-sans text-xs font-medium text-muted-foreground select-none"
         , class "[&_svg:not([class*='size-'])]:size-3"
         , class "[[data-slot=tooltip-content]_&]:bg-background/20 [[data-slot=tooltip-content]_&]:text-background dark:[[data-slot=tooltip-content]_&]:bg-background/10"
         ]
            ++ attrs
        )
        children


{-| Groups keys of a shortcut.
-}
group : List (Attribute msg) -> List (Html msg) -> Html msg
group attrs children =
    Html.kbd (attribute "data-slot" "kbd-group" :: class "inline-flex items-center gap-1" :: attrs) children
