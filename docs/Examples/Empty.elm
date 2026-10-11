module Examples.Empty exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import UI.Button as Button
import UI.Empty as Empty
import UI.Icon as Icon


demo : Html msg
demo =
    Empty.view [ class "w-full border" ]
        [ Empty.header []
            [ Empty.media [ Empty.icon ] [] [ Icon.ellipsis [] ]
            , Empty.title [] [ text "No projects yet" ]
            , Empty.description [] [ text "You haven't created any projects yet. Get started by creating your first project." ]
            ]
        , Empty.content []
            [ div [ class "flex gap-2" ]
                [ Button.view "Create project" |> Button.toHtml []
                , Button.view "Import project" |> Button.outline |> Button.toHtml []
                ]
            ]
        ]
