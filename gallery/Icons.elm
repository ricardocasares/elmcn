module Icons exposing (arrowLeft, arrowRight, arrowUp, arrowUpRight, circleFadingArrowUp, gitBranch, gitFork, plus)

{-| Icons used only by the gallery examples, from Lucide and Tabler.
-}

import Html.Attributes
import Svg exposing (Attribute, Svg)
import Svg.Attributes as Attr


arrowUp : List (Attribute msg) -> Svg msg
arrowUp =
    icon [ "m5 12 7-7 7 7", "M12 19V5" ]


arrowUpRight : List (Attribute msg) -> Svg msg
arrowUpRight =
    icon [ "M7 7h10v10", "M7 17 17 7" ]


arrowLeft : List (Attribute msg) -> Svg msg
arrowLeft =
    icon [ "m12 19-7-7 7-7", "M19 12H5" ]


arrowRight : List (Attribute msg) -> Svg msg
arrowRight =
    icon [ "M5 12h14", "m12 5 7 7-7 7" ]


plus : List (Attribute msg) -> Svg msg
plus =
    icon [ "M5 12h14", "M12 5v14" ]


circleFadingArrowUp : List (Attribute msg) -> Svg msg
circleFadingArrowUp =
    icon
        [ "M12 2a10 10 0 0 1 7.38 16.75"
        , "m16 12-4-4-4 4"
        , "M12 16V8"
        , "M2.5 8.875a10 10 0 0 0-.5 3"
        , "M2.83 16a10 10 0 0 0 2.43 3.4"
        , "M4.636 5.235a10 10 0 0 1 .891-.857"
        , "M8.644 21.42a10 10 0 0 0 7.631-.38"
        ]


gitBranch : List (Attribute msg) -> Svg msg
gitBranch =
    icon
        [ "M7 18m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0"
        , "M7 6m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0"
        , "M17 6m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0"
        , "M7 8l0 8"
        , "M9 18h6a2 2 0 0 0 2 -2v-5"
        , "M14 14l3 -3l3 3"
        ]


gitFork : List (Attribute msg) -> Svg msg
gitFork =
    icon
        [ "M12 18m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0"
        , "M7 6m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0"
        , "M17 6m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0"
        , "M7 8v2a2 2 0 0 0 2 2h6a2 2 0 0 0 2 -2v-2"
        , "M12 12l0 4"
        ]


icon : List String -> List (Attribute msg) -> Svg msg
icon paths attributes =
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
        (List.map (\d -> Svg.path [ Attr.d d ] []) paths)
