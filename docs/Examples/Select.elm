module Examples.Select exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (attribute, class, disabled, for)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.Label as Label
import UI.Select as Select


demo : State -> Html State.Msg
demo state =
    Select.new
        |> Select.id "fruit"
        |> Select.onSelect (State.set "fruit")
        |> Select.placeholder "Select a fruit"
        |> Select.value (State.get "fruit" state)
        |> Select.items
            [ Select.item "apple" [ text "Apple" ]
            , Select.item "banana" [ text "Banana" ]
            , Select.item "blueberry" [ text "Blueberry" ]
            , Select.item "grapes" [ text "Grapes" ]
            , Select.item "pineapple" [ text "Pineapple" ]
            ]
        |> Select.toHtml [ class "w-45" ]


groups : State -> Html State.Msg
groups state =
    Select.new
        |> Select.id "food"
        |> Select.onSelect (State.set "food")
        |> Select.placeholder "Select a food"
        |> Select.value (State.get "food" state)
        |> Select.group "Fruits"
            [ Select.item "apple" [ text "Apple" ]
            , Select.item "banana" [ text "Banana" ]
            , Select.item "blueberry" [ text "Blueberry" ]
            ]
        |> Select.group "Vegetables"
            [ Select.item "carrot" [ text "Carrot" ]
            , Select.item "broccoli" [ text "Broccoli" ]
            , Select.item "spinach" [ text "Spinach" ]
            ]
        |> Select.toHtml [ class "w-45" ]


withIcons : State -> Html State.Msg
withIcons state =
    Select.new
        |> Select.id "chart"
        |> Select.onSelect (State.set "chart")
        |> Select.placeholder "Chart type"
        |> Select.value (State.get "chart" state)
        |> Select.items
            [ Select.item "line" [ Phosphor.chartLine Regular |> Phosphor.toHtml [], text "Line" ]
            , Select.item "bar" [ Phosphor.chartBar Regular |> Phosphor.toHtml [], text "Bar" ]
            , Select.item "pie" [ Phosphor.chartPie Regular |> Phosphor.toHtml [], text "Pie" ]
            ]
        |> Select.toHtml [ class "w-45" ]


scrollable : State -> Html State.Msg
scrollable state =
    Select.new
        |> Select.id "item"
        |> Select.onSelect (State.set "item")
        |> Select.placeholder "Select an item"
        |> Select.value (State.get "item" state)
        |> Select.items
            (List.range 0 99
                |> List.map (\n -> Select.item (String.fromInt n) [ text ("Item " ++ String.fromInt n) ])
            )
        |> Select.toHtml [ class "w-45" ]


small : State -> Html State.Msg
small state =
    Select.new
        |> Select.id "fruit-small"
        |> Select.onSelect (State.set "fruit-small")
        |> Select.placeholder "Select a fruit"
        |> Select.value (State.get "fruit-small" state)
        |> Select.small
        |> Select.items
            [ Select.item "apple" [ text "Apple" ]
            , Select.item "banana" [ text "Banana" ]
            , Select.item "blueberry" [ text "Blueberry" ]
            ]
        |> Select.toHtml [ class "w-45" ]


withLabel : State -> Html State.Msg
withLabel state =
    div [ class "grid w-full max-w-sm gap-2" ]
        [ Label.view [ for "favorite" ] [ text "Favorite fruit" ]
        , Select.new
            |> Select.id "favorite"
            |> Select.onSelect (State.set "favorite")
            |> Select.placeholder "Select a fruit"
            |> Select.value (State.get "favorite" state)
            |> Select.items
                [ Select.item "apple" [ text "Apple" ]
                , Select.item "banana" [ text "Banana" ]
                , Select.item "grapes" [ text "Grapes" ] |> Select.disabled
                ]
            |> Select.toHtml [ class "w-full" ]
        ]


invalid : State -> Html State.Msg
invalid state =
    Select.new
        |> Select.id "fruit-invalid"
        |> Select.onSelect (State.set "fruit-invalid")
        |> Select.placeholder "Select a fruit"
        |> Select.value (State.get "fruit-invalid" state)
        |> Select.items
            [ Select.item "apple" [ text "Apple" ]
            , Select.item "banana" [ text "Banana" ]
            ]
        |> Select.toHtml [ class "w-45", attribute "aria-invalid" "true" ]


disabledSelect : State -> Html State.Msg
disabledSelect _ =
    Select.new
        |> Select.id "fruit-disabled"
        |> Select.onSelect (State.set "fruit-disabled")
        |> Select.placeholder "Select a fruit"
        |> Select.items [ Select.item "apple" [ text "Apple" ] ]
        |> Select.toHtml [ class "w-45", disabled True ]
