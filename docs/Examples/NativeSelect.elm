module Examples.NativeSelect exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (attribute, value)
import UI.NativeSelect as NativeSelect


demo : Html msg
demo =
    NativeSelect.view []
        []
        [ NativeSelect.option [ value "" ] [ text "Select status" ]
        , NativeSelect.option [ value "todo" ] [ text "Todo" ]
        , NativeSelect.option [ value "in-progress" ] [ text "In Progress" ]
        , NativeSelect.option [ value "done" ] [ text "Done" ]
        ]


small : Html msg
small =
    NativeSelect.view [ NativeSelect.small ]
        []
        [ NativeSelect.option [] [ text "Small" ]
        , NativeSelect.option [] [ text "Select" ]
        ]


groups : Html msg
groups =
    NativeSelect.view []
        []
        [ NativeSelect.optionGroup [ attribute "label" "Engineering" ]
            [ NativeSelect.option [] [ text "Frontend" ]
            , NativeSelect.option [] [ text "Backend" ]
            ]
        , NativeSelect.optionGroup [ attribute "label" "Design" ]
            [ NativeSelect.option [] [ text "Product" ]
            , NativeSelect.option [] [ text "Brand" ]
            ]
        ]
