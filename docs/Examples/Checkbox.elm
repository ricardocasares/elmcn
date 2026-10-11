module Examples.Checkbox exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (checked, disabled)
import UI.Checkbox as Checkbox
import UI.Label as Label


demo : Html msg
demo =
    Label.view []
        [ Checkbox.view [ checked True ]
        , text "Accept terms and conditions"
        ]


disabledCheckbox : Html msg
disabledCheckbox =
    Label.view [] [ Checkbox.view [ disabled True ], text "Disabled" ]
