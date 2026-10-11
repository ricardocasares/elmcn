module Examples.Textarea exposing (..)

import Html exposing (Html)
import Html.Attributes exposing (class, disabled, placeholder)
import UI.Textarea as Textarea


demo : Html msg
demo =
    Textarea.view [ class "max-w-sm", placeholder "Type your message here." ]


disabledTextarea : Html msg
disabledTextarea =
    Textarea.view [ class "max-w-sm", disabled True, placeholder "Disabled" ]
