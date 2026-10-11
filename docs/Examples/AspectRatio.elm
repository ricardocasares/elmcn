module Examples.AspectRatio exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import UI.AspectRatio as AspectRatio


demo : Html msg
demo =
    AspectRatio.view (16 / 9)
        [ class "w-full max-w-md rounded-lg bg-muted" ]
        [ div [ class "flex size-full items-center justify-center text-muted-foreground" ] [ text "16 / 9" ] ]


square : Html msg
square =
    AspectRatio.view 1
        [ class "w-48 rounded-lg bg-muted" ]
        [ div [ class "flex size-full items-center justify-center text-muted-foreground" ] [ text "1 / 1" ] ]
