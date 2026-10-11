module UI.NativeSelect exposing
    ( view, option, optionGroup
    , Option, small
    )

{-| A styled native HTML select element.

    NativeSelect.view []
        [ onInput StatusChosen ]
        [ NativeSelect.option [ value "" ] [ text "Select status" ]
        , NativeSelect.option [ value "todo" ] [ text "Todo" ]
        , NativeSelect.option [ value "done" ] [ text "Done" ]
        ]

@docs view, option, optionGroup


# Sizes

@docs Option, small

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)
import Svg.Attributes
import UI.Icon as Icon


{-| The attributes go on the `<select>`.
-}
view : List Option -> List (Attribute msg) -> List (Html msg) -> Html msg
view options attrs children =
    let
        size =
            List.foldl (\(Size s) _ -> s) Medium options
    in
    Html.div
        [ attribute "data-slot" "native-select-wrapper"
        , class "group/native-select relative w-fit has-[select:disabled]:opacity-50"
        ]
        [ Html.select
            ([ attribute "data-slot" "native-select"
             , attribute "data-size" (sizeName size)
             , class "h-8 w-full min-w-0 appearance-none rounded-lg border border-input bg-transparent py-1 pr-8 pl-2.5 text-sm transition-colors outline-none select-none selection:bg-primary selection:text-primary-foreground placeholder:text-muted-foreground disabled:pointer-events-none disabled:cursor-not-allowed data-[size=sm]:h-7 data-[size=sm]:rounded-[min(var(--radius-md),10px)] data-[size=sm]:py-0.5 dark:bg-input/30 dark:hover:bg-input/50"
             , class "focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50"
             , class "aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20 dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40"
             ]
                ++ attrs
            )
            children
        , Icon.chevronDown
            [ attribute "data-slot" "native-select-icon"
            , Svg.Attributes.class "pointer-events-none absolute top-1/2 right-2.5 size-4 -translate-y-1/2 text-muted-foreground select-none"
            ]
        ]


{-| Renders an `<option>`.
-}
option : List (Attribute msg) -> List (Html msg) -> Html msg
option attrs children =
    Html.option (attribute "data-slot" "native-select-option" :: class "bg-[Canvas] text-[CanvasText]" :: attrs) children


{-| Renders an `<optgroup>`. Pass its `label` as `attribute "label" "…"`.
-}
optionGroup : List (Attribute msg) -> List (Html msg) -> Html msg
optionGroup attrs children =
    Html.optgroup (attribute "data-slot" "native-select-optgroup" :: class "bg-[Canvas] text-[CanvasText]" :: attrs) children


{-| The select size. When several are given, the last one wins.
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
