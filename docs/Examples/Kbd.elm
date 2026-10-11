module Examples.Kbd exposing (..)

import Html exposing (Html)
import UI.Kbd as Kbd


demo : Html msg
demo =
    Kbd.new
        |> Kbd.key "⌘"
        |> Kbd.key "⇧"
        |> Kbd.key "⌥"
        |> Kbd.key "⌃"
        |> Kbd.toHtml []


single : Html msg
single =
    Kbd.new
        |> Kbd.key "Cmd"
        |> Kbd.toHtml []


combination : Html msg
combination =
    Kbd.new
        |> Kbd.key "Ctrl"
        |> Kbd.separator "+"
        |> Kbd.key "B"
        |> Kbd.toHtml []
