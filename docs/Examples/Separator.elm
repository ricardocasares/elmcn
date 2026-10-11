module Examples.Separator exposing (..)

import Html exposing (Html, div, p, text)
import Html.Attributes exposing (class)
import UI.Separator as Separator


demo : Html msg
demo =
    div []
        [ div [ class "space-y-1" ]
            [ p [ class "text-sm leading-none font-medium" ] [ text "Radix Primitives" ]
            , p [ class "text-sm text-muted-foreground" ] [ text "An open-source UI component library." ]
            ]
        , Separator.new
            |> Separator.toHtml [ class "my-4" ]
        , div [ class "flex h-5 items-center space-x-4 text-sm" ]
            [ div [] [ text "Blog" ]
            , Separator.new
                |> Separator.vertical
                |> Separator.toHtml []
            , div [] [ text "Docs" ]
            , Separator.new
                |> Separator.vertical
                |> Separator.toHtml []
            , div [] [ text "Source" ]
            ]
        ]
