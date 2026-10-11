module Examples.ToggleGroup exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.ToggleGroup as ToggleGroup


demo : State -> Html State.Msg
demo state =
    ToggleGroup.new
        |> ToggleGroup.onToggle (toggleIn "toggle-group-format" (listAt "toggle-group-format" [] state))
        |> ToggleGroup.pressed (listAt "toggle-group-format" [] state)
        |> ToggleGroup.outline
        |> ToggleGroup.items
            [ ToggleGroup.item "bold" [ Phosphor.textB Regular |> Phosphor.toHtml [] ]
                |> ToggleGroup.label "Toggle bold"
            , ToggleGroup.item "italic" [ Phosphor.textItalic Regular |> Phosphor.toHtml [] ]
                |> ToggleGroup.label "Toggle italic"
            , ToggleGroup.item "underline" [ Phosphor.textUnderline Regular |> Phosphor.toHtml [] ]
                |> ToggleGroup.label "Toggle underline"
            ]
        |> ToggleGroup.toHtml []


{-| One pressed item at a time: the handler stores the clicked value and `pressed` gets it as a list.
-}
outline : State -> Html State.Msg
outline state =
    ToggleGroup.new
        |> ToggleGroup.onToggle (State.set "toggle-group-calls")
        |> ToggleGroup.pressed [ State.get "toggle-group-calls" state |> Maybe.withDefault "all" ]
        |> ToggleGroup.outline
        |> ToggleGroup.items
            [ ToggleGroup.item "all" [ text "All" ]
            , ToggleGroup.item "missed" [ text "Missed" ]
            ]
        |> ToggleGroup.toHtml []


sizes : State -> Html State.Msg
sizes state =
    let
        sides key =
            ToggleGroup.new
                |> ToggleGroup.onToggle (State.set key)
                |> ToggleGroup.pressed [ State.get key state |> Maybe.withDefault "top" ]
                |> ToggleGroup.outline
                |> ToggleGroup.items
                    [ ToggleGroup.item "top" [ text "Top" ]
                    , ToggleGroup.item "bottom" [ text "Bottom" ]
                    , ToggleGroup.item "left" [ text "Left" ]
                    , ToggleGroup.item "right" [ text "Right" ]
                    ]
    in
    div [ class "flex flex-col gap-4" ]
        [ sides "toggle-group-sides-sm"
            |> ToggleGroup.small
            |> ToggleGroup.toHtml []
        , sides "toggle-group-sides"
            |> ToggleGroup.toHtml []
        , sides "toggle-group-sides-lg"
            |> ToggleGroup.large
            |> ToggleGroup.toHtml []
        ]


{-| `spacing 0` joins the items into one bar. The default spacing is 2.
-}
joined : State -> Html State.Msg
joined state =
    ToggleGroup.new
        |> ToggleGroup.onToggle (State.set "toggle-group-joined")
        |> ToggleGroup.pressed [ State.get "toggle-group-joined" state |> Maybe.withDefault "top" ]
        |> ToggleGroup.outline
        |> ToggleGroup.small
        |> ToggleGroup.spacing 0
        |> ToggleGroup.items
            [ ToggleGroup.item "top" [ text "Top" ]
            , ToggleGroup.item "bottom" [ text "Bottom" ]
            , ToggleGroup.item "left" [ text "Left" ]
            , ToggleGroup.item "right" [ text "Right" ]
            ]
        |> ToggleGroup.toHtml []


vertical : State -> Html State.Msg
vertical state =
    let
        formats =
            listAt "toggle-group-vertical" [ "bold", "italic" ] state
    in
    ToggleGroup.new
        |> ToggleGroup.onToggle (toggleIn "toggle-group-vertical" formats)
        |> ToggleGroup.pressed formats
        |> ToggleGroup.vertical
        |> ToggleGroup.spacing 1
        |> ToggleGroup.items
            [ ToggleGroup.item "bold" [ Phosphor.textB Regular |> Phosphor.toHtml [] ]
                |> ToggleGroup.label "Toggle bold"
            , ToggleGroup.item "italic" [ Phosphor.textItalic Regular |> Phosphor.toHtml [] ]
                |> ToggleGroup.label "Toggle italic"
            , ToggleGroup.item "underline" [ Phosphor.textUnderline Regular |> Phosphor.toHtml [] ]
                |> ToggleGroup.label "Toggle underline"
            ]
        |> ToggleGroup.toHtml []


{-| `disabled` dims an item and makes it unclickable.
-}
disabled : State -> Html State.Msg
disabled state =
    ToggleGroup.new
        |> ToggleGroup.onToggle (State.set "toggle-group-disabled")
        |> ToggleGroup.pressed [ State.get "toggle-group-disabled" state |> Maybe.withDefault "bold" ]
        |> ToggleGroup.items
            [ ToggleGroup.item "bold" [ Phosphor.textB Regular |> Phosphor.toHtml [] ]
                |> ToggleGroup.label "Toggle bold"
            , ToggleGroup.item "italic" [ Phosphor.textItalic Regular |> Phosphor.toHtml [] ]
                |> ToggleGroup.label "Toggle italic"
                |> ToggleGroup.disabled
            , ToggleGroup.item "underline" [ Phosphor.textUnderline Regular |> Phosphor.toHtml [] ]
                |> ToggleGroup.label "Toggle underline"
                |> ToggleGroup.disabled
            ]
        |> ToggleGroup.toHtml []


{-| The pressed values are kept as a comma-separated string in the example state.
-}
listAt : String -> List String -> State -> List String
listAt key default state =
    State.get key state
        |> Maybe.map (String.split "," >> List.filter ((/=) ""))
        |> Maybe.withDefault default


toggleIn : String -> List String -> String -> State.Msg
toggleIn key current value =
    State.set key
        (String.join ","
            (if List.member value current then
                List.filter ((/=) value) current

             else
                current ++ [ value ]
            )
        )
