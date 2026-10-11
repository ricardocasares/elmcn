module UI.Separator exposing
    ( view
    , Option, vertical
    )

{-| Visually separates content.

    Separator.view [] []

    Separator.view [ Separator.vertical ] []

The separator is decorative and hidden from assistive technology. For a meaningful
separator, pass `attribute "role" "separator"`.

@docs view


# Options

@docs Option, vertical

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)


{-| -}
view : List Option -> List (Attribute msg) -> Html msg
view options attrs =
    let
        orientation =
            List.foldl (\(Orientation o) _ -> o) Horizontal options
    in
    Html.div
        ([ attribute "data-slot" "separator"
         , attribute "role" "none"
         , attribute "data-orientation" (orientationName orientation)
         , class "shrink-0 bg-border data-[orientation=horizontal]:h-px data-[orientation=horizontal]:w-full data-[orientation=vertical]:w-px data-[orientation=vertical]:self-stretch"
         ]
            ++ attrs
        )
        []


{-| The separator orientation. It is horizontal unless `vertical` is given.
-}
type Option
    = Orientation Orientation


type Orientation
    = Horizontal
    | Vertical


{-| -}
vertical : Option
vertical =
    Orientation Vertical


orientationName : Orientation -> String
orientationName orientation =
    case orientation of
        Horizontal ->
            "horizontal"

        Vertical ->
            "vertical"
