module UI.Switch exposing
    ( view
    , Option, small
    )

{-| A control that allows the user to toggle between checked and not checked.

It is a native `<input type="checkbox" role="switch">`, so it works in forms and with `onCheck`:

    label [ class "flex items-center gap-2" ]
        [ Switch.view [] [ checked model.airplaneMode, onCheck AirplaneModeToggled ]
        , text "Airplane mode"
        ]

@docs view


# Sizes

@docs Option, small

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, type_)


{-| The attributes go on the `<input>`.
-}
view : List Option -> List (Attribute msg) -> Html msg
view options attrs =
    let
        size =
            List.foldl (\(Size s) _ -> s) Medium options
    in
    Html.span
        [ attribute "data-size" (sizeName size)
        , class "relative inline-grid shrink-0 items-center *:col-start-1 *:row-start-1"
        ]
        [ Html.input
            ([ type_ "checkbox"
             , attribute "role" "switch"
             , attribute "data-slot" "switch"
             , class "peer inline-flex shrink-0 appearance-none rounded-full border border-transparent bg-input transition-all outline-none checked:bg-primary focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20 dark:bg-input/80 dark:checked:bg-primary dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40"
             , class (trackClass size)
             ]
                ++ attrs
            )
            []
        , Html.span
            [ attribute "data-slot" "switch-thumb"
            , class "pointer-events-none block translate-x-px rounded-full bg-background ring-0 transition-transform peer-checked:translate-x-[calc(100%-1px)] peer-disabled:opacity-50 dark:bg-foreground dark:peer-checked:bg-primary-foreground"
            , class (thumbClass size)
            ]
            []
        ]


{-| The switch size. When several are given, the last one wins.
-}
type Option
    = Size Size


type Size
    = Medium
    | Small


{-| -}
small : Option
small =
    Size Small


sizeName : Size -> String
sizeName size =
    case size of
        Medium ->
            "default"

        Small ->
            "sm"


trackClass : Size -> String
trackClass size =
    case size of
        Medium ->
            "h-[1.15rem] w-8"

        Small ->
            "h-3.5 w-6"


thumbClass : Size -> String
thumbClass size =
    case size of
        Medium ->
            "size-4"

        Small ->
            "size-3"
