module UI.Progress exposing (view)

{-| Displays an indicator showing the completion progress of a task.

    Progress.view 60 [ class "w-[60%]" ]

@docs view

-}

import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (attribute, class, style)


{-| Takes the progress as a percentage, from 0 to 100.
-}
view : Float -> List (Attribute msg) -> Html msg
view value attrs =
    let
        percentage =
            clamp 0 100 value
    in
    div
        ([ attribute "data-slot" "progress"
         , attribute "role" "progressbar"
         , attribute "aria-valuemin" "0"
         , attribute "aria-valuemax" "100"
         , attribute "aria-valuenow" (String.fromFloat percentage)
         , class "relative h-2 w-full overflow-hidden rounded-full bg-primary/20"
         ]
            ++ attrs
        )
        [ div
            [ attribute "data-slot" "progress-indicator"
            , class "h-full w-full flex-1 bg-primary transition-all"
            , style "transform" ("translateX(-" ++ String.fromFloat (100 - percentage) ++ "%)")
            ]
            []
        ]
