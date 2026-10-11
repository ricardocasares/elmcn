module UI.Icon exposing (check, chevronDown, chevronRight, ellipsis, loader)

{-| The handful of [Lucide](https://lucide.dev) icons the elmcn components use.

Icons are SVG, so style them with `Svg.Attributes.class`, not `Html.Attributes.class`:

    Icon.check [ Svg.Attributes.class "size-4" ]

Lucide is licensed under the ISC license.

@docs check, chevronDown, chevronRight, ellipsis, loader

-}

import Html.Attributes
import Svg exposing (Attribute, Svg)
import Svg.Attributes as Attr


{-| -}
check : List (Attribute msg) -> Svg msg
check attributes =
    icon attributes [ Svg.path [ Attr.d "M20 6 9 17l-5-5" ] [] ]


{-| -}
chevronDown : List (Attribute msg) -> Svg msg
chevronDown attributes =
    icon attributes [ Svg.path [ Attr.d "m6 9 6 6 6-6" ] [] ]


{-| -}
chevronRight : List (Attribute msg) -> Svg msg
chevronRight attributes =
    icon attributes [ Svg.path [ Attr.d "m9 18 6-6-6-6" ] [] ]


{-| Three horizontal dots (Lucide's `ellipsis`, formerly `more-horizontal`).
-}
ellipsis : List (Attribute msg) -> Svg msg
ellipsis attributes =
    icon attributes
        [ Svg.circle [ Attr.cx "12", Attr.cy "12", Attr.r "1" ] []
        , Svg.circle [ Attr.cx "19", Attr.cy "12", Attr.r "1" ] []
        , Svg.circle [ Attr.cx "5", Attr.cy "12", Attr.r "1" ] []
        ]


{-| A partial circle; spin it with `animate-spin` (Lucide's `loader-circle`).
-}
loader : List (Attribute msg) -> Svg msg
loader attributes =
    icon attributes [ Svg.path [ Attr.d "M21 12a9 9 0 1 1-6.219-8.56" ] [] ]


icon : List (Attribute msg) -> List (Svg msg) -> Svg msg
icon attributes children =
    Svg.svg
        ([ Attr.width "24"
         , Attr.height "24"
         , Attr.viewBox "0 0 24 24"
         , Attr.fill "none"
         , Attr.stroke "currentColor"
         , Attr.strokeWidth "2"
         , Attr.strokeLinecap "round"
         , Attr.strokeLinejoin "round"
         , Html.Attributes.attribute "aria-hidden" "true"
         ]
            ++ attributes
        )
        children
