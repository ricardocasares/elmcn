module Examples.Spinner exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Svg.Attributes
import UI.Spinner as Spinner


demo : Html msg
demo =
    Spinner.view []


{-| Spinners are SVG, so size them with `Svg.Attributes.class`.
-}
size : Html msg
size =
    div [ class "flex items-center gap-4" ]
        [ Spinner.view []
        , Spinner.view [ Svg.Attributes.class "size-6" ]
        , Spinner.view [ Svg.Attributes.class "size-8" ]
        ]
