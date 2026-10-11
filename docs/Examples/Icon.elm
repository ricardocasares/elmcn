module Examples.Icon exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Svg.Attributes
import UI.Icon as Icon


demo : Html msg
demo =
    div [ class "flex items-center gap-4" ]
        [ Icon.check []
        , Icon.chevronDown []
        , Icon.chevronRight []
        , Icon.ellipsis []
        , Icon.loader []
        ]


{-| Icons are SVG, so style them with `Svg.Attributes.class`, not `Html.Attributes.class`.
-}
styled : Html msg
styled =
    div [ class "flex items-center gap-4" ]
        [ Icon.check [ Svg.Attributes.class "size-4 text-green-600" ]
        , Icon.check [ Svg.Attributes.class "size-6" ]
        , Icon.loader [ Svg.Attributes.class "size-8 animate-spin text-muted-foreground" ]
        ]
