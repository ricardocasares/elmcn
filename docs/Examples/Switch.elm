module Examples.Switch exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (checked)
import UI.Label as Label
import UI.Switch as Switch


demo : Html msg
demo =
    Label.view []
        [ Switch.new
            |> Switch.toHtml [ checked False ]
        , text "Airplane mode"
        ]


small : Html msg
small =
    Label.view []
        [ Switch.new
            |> Switch.small
            |> Switch.toHtml [ checked True ]
        , text "Small switch"
        ]
