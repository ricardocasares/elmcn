module Examples.Toggle exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (attribute, class)
import Html.Events exposing (onClick)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.Toggle as Toggle


demo : State -> Html State.Msg
demo state =
    let
        bookmarked =
            isOn "toggle-bookmark" state
    in
    Toggle.new
        |> Toggle.pressed bookmarked
        |> Toggle.small
        |> Toggle.outline
        |> Toggle.toHtml
            [ attribute "aria-label" "Toggle bookmark", onClick (flip "toggle-bookmark" bookmarked) ]
            [ Phosphor.bookmarkSimple (weight bookmarked) |> Phosphor.toHtml []
            , text "Bookmark"
            ]


outline : State -> Html State.Msg
outline state =
    div [ class "flex flex-wrap items-center gap-2" ]
        [ Toggle.new
            |> Toggle.pressed (isOn "toggle-outline-italic" state)
            |> Toggle.outline
            |> Toggle.toHtml
                [ attribute "aria-label" "Toggle italic", onClick (flip "toggle-outline-italic" (isOn "toggle-outline-italic" state)) ]
                [ Phosphor.textItalic Regular |> Phosphor.toHtml [], text "Italic" ]
        , Toggle.new
            |> Toggle.pressed (isOn "toggle-outline-bold" state)
            |> Toggle.outline
            |> Toggle.toHtml
                [ attribute "aria-label" "Toggle bold", onClick (flip "toggle-outline-bold" (isOn "toggle-outline-bold" state)) ]
                [ Phosphor.textB Regular |> Phosphor.toHtml [], text "Bold" ]
        ]


sizes : State -> Html State.Msg
sizes state =
    div [ class "flex flex-wrap items-center gap-2" ]
        [ Toggle.new
            |> Toggle.pressed (isOn "toggle-size-sm" state)
            |> Toggle.outline
            |> Toggle.small
            |> Toggle.toHtml
                [ attribute "aria-label" "Toggle small", onClick (flip "toggle-size-sm" (isOn "toggle-size-sm" state)) ]
                [ text "Small" ]
        , Toggle.new
            |> Toggle.pressed (isOn "toggle-size-default" state)
            |> Toggle.outline
            |> Toggle.toHtml
                [ attribute "aria-label" "Toggle default", onClick (flip "toggle-size-default" (isOn "toggle-size-default" state)) ]
                [ text "Default" ]
        , Toggle.new
            |> Toggle.pressed (isOn "toggle-size-lg" state)
            |> Toggle.outline
            |> Toggle.large
            |> Toggle.toHtml
                [ attribute "aria-label" "Toggle large", onClick (flip "toggle-size-lg" (isOn "toggle-size-lg" state)) ]
                [ text "Large" ]
        ]


{-| The content can be an icon, text, or both.
-}
withText : State -> Html State.Msg
withText state =
    Toggle.new
        |> Toggle.pressed (isOn "toggle-text" state)
        |> Toggle.toHtml
            [ attribute "aria-label" "Toggle italic", onClick (flip "toggle-text" (isOn "toggle-text" state)) ]
            [ Phosphor.textItalic Regular |> Phosphor.toHtml [], text "Italic" ]


disabled : Html msg
disabled =
    div [ class "flex flex-wrap items-center gap-2" ]
        [ Toggle.new
            |> Toggle.toHtml
                [ attribute "aria-label" "Toggle disabled", Html.Attributes.disabled True ]
                [ text "Disabled" ]
        , Toggle.new
            |> Toggle.outline
            |> Toggle.toHtml
                [ attribute "aria-label" "Toggle disabled outline", Html.Attributes.disabled True ]
                [ text "Disabled" ]
        ]


isOn : String -> State -> Bool
isOn key state =
    State.get key state == Just "true"


flip : String -> Bool -> State.Msg
flip key on =
    State.set key
        (if on then
            "false"

         else
            "true"
        )


weight : Bool -> IconWeight
weight on =
    if on then
        Fill

    else
        Regular
