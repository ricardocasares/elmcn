module Examples.Select exposing (..)

import Html exposing (Html, div, p, text)
import Html.Attributes exposing (attribute, class, dir, disabled, for)
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


{-| By default the list opens with the selected item over the trigger. `alignToEdge` opens it below the trigger instead, or above when it doesn't fit below.
-}
alignToEdge : State -> Html State.Msg
alignToEdge state =
    Select.new
        |> Select.id "fruit-edge"
        |> Select.onSelect (State.set "fruit-edge")
        |> Select.placeholder "Select a fruit"
        |> Select.value (Just (State.get "fruit-edge" state |> Maybe.withDefault "banana"))
        |> Select.alignToEdge
        |> Select.items
            [ Select.item "apple" [ text "Apple" ]
            , Select.item "banana" [ text "Banana" ]
            , Select.item "blueberry" [ text "Blueberry" ]
            , Select.item "grapes" [ text "Grapes" ]
            , Select.item "pineapple" [ text "Pineapple" ]
            ]
        |> Select.toHtml [ class "w-45" ]


{-| `group` adds a heading, and `separator` a line between groups.
-}
groups : State -> Html State.Msg
groups state =
    Select.new
        |> Select.id "food"
        |> Select.onSelect (State.set "food")
        |> Select.placeholder "Select a fruit"
        |> Select.value (State.get "food" state)
        |> Select.group "Fruits"
            [ Select.item "apple" [ text "Apple" ]
            , Select.item "banana" [ text "Banana" ]
            , Select.item "blueberry" [ text "Blueberry" ]
            ]
        |> Select.separator
        |> Select.group "Vegetables"
            [ Select.item "carrot" [ text "Carrot" ]
            , Select.item "broccoli" [ text "Broccoli" ]
            , Select.item "spinach" [ text "Spinach" ]
            ]
        |> Select.toHtml [ class "w-45" ]


{-| A select with many items that scrolls.
-}
scrollable : State -> Html State.Msg
scrollable state =
    Select.new
        |> Select.id "timezone"
        |> Select.onSelect (State.set "timezone")
        |> Select.placeholder "Select a timezone"
        |> Select.value (State.get "timezone" state)
        |> Select.group "North America"
            [ Select.item "est" [ text "Eastern Standard Time" ]
            , Select.item "cst" [ text "Central Standard Time" ]
            , Select.item "mst" [ text "Mountain Standard Time" ]
            , Select.item "pst" [ text "Pacific Standard Time" ]
            , Select.item "akst" [ text "Alaska Standard Time" ]
            , Select.item "hst" [ text "Hawaii Standard Time" ]
            ]
        |> Select.group "Europe & Africa"
            [ Select.item "gmt" [ text "Greenwich Mean Time" ]
            , Select.item "cet" [ text "Central European Time" ]
            , Select.item "eet" [ text "Eastern European Time" ]
            , Select.item "west" [ text "Western European Summer Time" ]
            , Select.item "cat" [ text "Central Africa Time" ]
            , Select.item "eat" [ text "East Africa Time" ]
            ]
        |> Select.group "Asia"
            [ Select.item "msk" [ text "Moscow Time" ]
            , Select.item "ist" [ text "India Standard Time" ]
            , Select.item "cst_china" [ text "China Standard Time" ]
            , Select.item "jst" [ text "Japan Standard Time" ]
            , Select.item "kst" [ text "Korea Standard Time" ]
            , Select.item "ist_indonesia" [ text "Indonesia Central Standard Time" ]
            ]
        |> Select.group "Australia & Pacific"
            [ Select.item "awst" [ text "Australian Western Standard Time" ]
            , Select.item "acst" [ text "Australian Central Standard Time" ]
            , Select.item "aest" [ text "Australian Eastern Standard Time" ]
            , Select.item "nzst" [ text "New Zealand Standard Time" ]
            , Select.item "fjt" [ text "Fiji Time" ]
            ]
        |> Select.group "South America"
            [ Select.item "art" [ text "Argentina Time" ]
            , Select.item "bot" [ text "Bolivia Time" ]
            , Select.item "brt" [ text "Brasilia Time" ]
            , Select.item "clt" [ text "Chile Standard Time" ]
            ]
        |> Select.toHtml [ class "w-full max-w-64" ]


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


disabledSelect : State -> Html State.Msg
disabledSelect _ =
    Select.new
        |> Select.id "fruit-disabled"
        |> Select.onSelect (State.set "fruit-disabled")
        |> Select.placeholder "Select a fruit"
        |> Select.items [ Select.item "apple" [ text "Apple" ] ]
        |> Select.toHtml [ class "w-45", disabled True ]


{-| Pass `aria-invalid` to the trigger to show the error state.
-}
invalid : State -> Html State.Msg
invalid state =
    div [ class "grid w-full max-w-sm gap-2" ]
        [ Label.view [ for "fruit-invalid" ] [ text "Fruit" ]
        , Select.new
            |> Select.id "fruit-invalid"
            |> Select.onSelect (State.set "fruit-invalid")
            |> Select.placeholder "Select a fruit"
            |> Select.value (State.get "fruit-invalid" state)
            |> Select.items
                [ Select.item "apple" [ text "Apple" ]
                , Select.item "banana" [ text "Banana" ]
                , Select.item "blueberry" [ text "Blueberry" ]
                ]
            |> Select.toHtml [ class "w-full", attribute "aria-invalid" "true" ]
        , p [ class "text-sm text-destructive" ] [ text "Please select a fruit." ]
        ]


rtl : State -> Html State.Msg
rtl state =
    div [ dir "rtl" ]
        [ Select.new
            |> Select.id "fruit-rtl"
            |> Select.onSelect (State.set "fruit-rtl")
            |> Select.placeholder "اختر فاكهة"
            |> Select.value (State.get "fruit-rtl" state)
            |> Select.group "الفواكه"
                [ Select.item "apple" [ text "تفاح" ]
                , Select.item "banana" [ text "موز" ]
                , Select.item "blueberry" [ text "توت أزرق" ]
                , Select.item "grapes" [ text "عنب" ]
                , Select.item "pineapple" [ text "أناناس" ]
                ]
            |> Select.separator
            |> Select.group "الخضروات"
                [ Select.item "carrot" [ text "جزر" ]
                , Select.item "broccoli" [ text "بروكلي" ]
                , Select.item "spinach" [ text "سبانخ" ]
                ]
            |> Select.toHtml [ class "w-45" ]
        ]
