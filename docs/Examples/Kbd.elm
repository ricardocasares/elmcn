module Examples.Kbd exposing (..)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
import UI.Kbd as Kbd


demo : Html msg
demo =
    Kbd.group []
        [ Kbd.view [] [ text "⌘" ]
        , Kbd.view [] [ text "⇧" ]
        , Kbd.view [] [ text "⌥" ]
        , Kbd.view [] [ text "⌃" ]
        ]


combination : Html msg
combination =
    Kbd.group []
        [ Kbd.view [] [ text "Ctrl" ]
        , span [] [ text "+" ]
        , Kbd.view [] [ text "B" ]
        ]
