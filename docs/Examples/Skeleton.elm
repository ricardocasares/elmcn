module Examples.Skeleton exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import UI.Skeleton as Skeleton


demo : Html msg
demo =
    div [ class "flex items-center gap-4" ]
        [ Skeleton.view [ class "size-12 rounded-full!" ]
        , div [ class "space-y-2" ]
            [ Skeleton.view [ class "h-4 w-[250px]" ]
            , Skeleton.view [ class "h-4 w-[200px]" ]
            ]
        ]
