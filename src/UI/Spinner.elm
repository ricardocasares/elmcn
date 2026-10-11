module UI.Spinner exposing (view)

{-| An indicator that shows a loading state.

    Spinner.view []

The spinner is an SVG, so size it with `Svg.Attributes.class`:

    Spinner.view [ Svg.Attributes.class "size-8" ]

@docs view

-}

import Html.Attributes exposing (attribute)
import Svg exposing (Attribute, Svg)
import Svg.Attributes
import UI.Icon as Icon


{-| -}
view : List (Attribute msg) -> Svg msg
view attrs =
    Icon.loader
        ([ attribute "role" "status"
         , attribute "aria-label" "Loading"
         , attribute "aria-hidden" "false"
         , Svg.Attributes.class "size-4 animate-spin"
         ]
            ++ attrs
        )
