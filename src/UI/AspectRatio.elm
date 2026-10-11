module UI.AspectRatio exposing (view)

{-| Displays content within a desired ratio.

    AspectRatio.view (16 / 9)
        [ class "rounded-lg bg-muted" ]
        [ img [ src "/photo.jpg", alt "Photo", class "size-full rounded-lg object-cover" ] [] ]

Use `1 / 1` for square and `9 / 16` for portrait content.

@docs view

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, style)


{-| Takes the ratio of width to height. The container is `relative`, so
children can be positioned absolutely inside it.
-}
view : Float -> List (Attribute msg) -> List (Html msg) -> Html msg
view ratio attrs children =
    Html.div
        (attribute "data-slot" "aspect-ratio"
            :: class "relative"
            :: style "aspect-ratio" (String.fromFloat ratio)
            :: attrs
        )
        children
