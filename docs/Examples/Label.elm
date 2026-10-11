module Examples.Label exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, for, id, placeholder)
import UI.Checkbox as Checkbox
import UI.Input as Input
import UI.Label as Label


demo : Html msg
demo =
    Label.view [] [ Checkbox.view [ id "label-terms" ], text "Accept terms and conditions" ]


{-| Point `for` at the input's `id` to link them.
-}
forInput : Html msg
forInput =
    div [ class "grid w-full max-w-sm gap-2" ]
        [ Label.view [ for "label-email" ] [ text "Email" ]
        , Input.view [ id "label-email", placeholder "m@example.com" ]
        ]
