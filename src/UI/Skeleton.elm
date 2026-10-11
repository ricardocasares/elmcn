module UI.Skeleton exposing (view)

{-| Shows a placeholder while content is loading. Size it with classes:

    Skeleton.view [ class "h-4 w-[250px]" ]

@docs view

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)


{-| -}
view : List (Attribute msg) -> Html msg
view attrs =
    Html.div (attribute "data-slot" "skeleton" :: class "animate-pulse rounded-md bg-accent" :: attrs) []
