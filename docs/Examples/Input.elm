module Examples.Input exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (attribute, class, disabled, for, id, placeholder, value)
import UI.Input as Input
import UI.Label as Label


demo : Html msg
demo =
    Input.view [ class "max-w-sm", placeholder "Email" ]


withLabel : Html msg
withLabel =
    div [ class "grid w-full max-w-sm gap-2" ]
        [ Label.view [ for "input-name" ] [ text "Name" ]
        , Input.view [ id "input-name", placeholder "Ada Lovelace" ]
        ]


{-| Set `aria-invalid` to show the error state.
-}
invalid : Html msg
invalid =
    div [ class "grid w-full max-w-sm gap-2" ]
        [ Label.view [ for "input-invalid" ] [ text "Email" ]
        , Input.view [ id "input-invalid", value "not-an-email", attribute "aria-invalid" "true" ]
        ]


disabledInput : Html msg
disabledInput =
    Input.view [ class "max-w-sm", disabled True, placeholder "Disabled" ]
