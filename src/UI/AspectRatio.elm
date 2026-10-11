module UI.AspectRatio exposing (view)

{-| Displays content within a desired ratio.

    AspectRatio.view (16 / 9)
        [ class "rounded-lg bg-muted" ]
        [ img [ src "/photo.jpg", class "size-full rounded-lg object-cover" ] [] ]

@docs view

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, style)


{-| Takes the ratio of width to height.
-}
view : Float -> List (Attribute msg) -> List (Html msg) -> Html msg
view ratio attrs children =
    Html.div
        (attribute "data-slot" "aspect-ratio"
            :: style "aspect-ratio" (String.fromFloat ratio)
            :: attrs
        )
        children
