module Examples.NativeSelect exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (value)
import UI.NativeSelect as NativeSelect


demo : Html msg
demo =
    NativeSelect.new
        |> NativeSelect.options
            [ NativeSelect.option [ value "" ] [ text "Select status" ]
            , NativeSelect.option [ value "todo" ] [ text "Todo" ]
            , NativeSelect.option [ value "in-progress" ] [ text "In Progress" ]
            , NativeSelect.option [ value "done" ] [ text "Done" ]
            ]
        |> NativeSelect.toHtml []


small : Html msg
small =
    NativeSelect.new
        |> NativeSelect.small
        |> NativeSelect.options
            [ NativeSelect.option [] [ text "Small" ]
            , NativeSelect.option [] [ text "Select" ]
            ]
        |> NativeSelect.toHtml []


groups : Html msg
groups =
    NativeSelect.new
        |> NativeSelect.options
            [ NativeSelect.optionGroup "Engineering"
                [ NativeSelect.option [] [ text "Frontend" ]
                , NativeSelect.option [] [ text "Backend" ]
                ]
            , NativeSelect.optionGroup "Design"
                [ NativeSelect.option [] [ text "Product" ]
                , NativeSelect.option [] [ text "Brand" ]
                ]
            ]
        |> NativeSelect.toHtml []
