module Examples.Badge exposing (..)

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, href)
import Phosphor exposing (IconWeight(..))
import UI.Badge as Badge


demo : Html msg
demo =
    Badge.view [] [] [ text "Badge" ]


variants : Html msg
variants =
    div [ class "flex flex-wrap items-center gap-2" ]
        [ Badge.view [] [] [ text "Default" ]
        , Badge.view [ Badge.secondary ] [] [ text "Secondary" ]
        , Badge.view [ Badge.destructive ] [] [ text "Destructive" ]
        , Badge.view [ Badge.outline ] [] [ text "Outline" ]
        ]


withIcon : Html msg
withIcon =
    Badge.view [ Badge.secondary ] [] [ Phosphor.check Regular |> Phosphor.toHtml [], text "Verified" ]


{-| Use `attributes` to style a link as a badge; links also get a hover state.
-}
asLink : Html msg
asLink =
    a (href "#" :: Badge.attributes [ Badge.outline ]) [ text "Link" ]
