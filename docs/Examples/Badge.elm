module Examples.Badge exposing (..)

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, href)
import UI.Badge as Badge
import UI.Icon as Icon


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
    Badge.view [ Badge.secondary ] [] [ Icon.check [], text "Verified" ]


{-| Use `attributes` to style a link as a badge; links also get a hover state.
-}
asLink : Html msg
asLink =
    a (href "#" :: Badge.attributes [ Badge.outline ]) [ text "Link" ]
