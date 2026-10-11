module Examples.Spinner exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import UI.Spinner as Spinner


demo : Html msg
demo =
    Spinner.view []


{-| Size spinners with a `size-*` class.
-}
size : Html msg
size =
    div [ class "flex items-center gap-4" ]
        [ Spinner.view []
        , Spinner.view [ class "size-6" ]
        , Spinner.view [ class "size-8" ]
        ]
