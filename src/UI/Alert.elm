module UI.Alert exposing
    ( view, title, description
    , Option, destructive
    )

{-| Displays a callout for user attention.

    Alert.view []
        []
        [ Alert.title [] [ text "Heads up!" ]
        , Alert.description [] [ text "You can add components to your app using the CLI." ]
        ]

An optional icon can go first; it is placed in its own column:

    Alert.view [ Alert.destructive ]
        []
        [ someIcon
        , Alert.title [] [ text "Something went wrong" ]
        ]

@docs view, title, description


# Variants

@docs Option, destructive

-}

import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (attribute, class)


{-| -}
view : List Option -> List (Attribute msg) -> List (Html msg) -> Html msg
view options attrs children =
    let
        variant =
            List.foldl (\(Variant v) _ -> v) Default options
    in
    div
        ([ attribute "data-slot" "alert"
         , attribute "role" "alert"
         , class "relative grid w-full grid-cols-[0_1fr] items-start gap-y-0.5 rounded-lg border px-4 py-3 text-sm has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr] has-[>svg]:gap-x-3 [&>svg]:size-4 [&>svg]:translate-y-0.5 [&>svg]:text-current"
         , class (variantClass variant)
         ]
            ++ attrs
        )
        children


{-| -}
title : List (Attribute msg) -> List (Html msg) -> Html msg
title attrs children =
    div
        (attribute "data-slot" "alert-title"
            :: class "col-start-2 line-clamp-1 min-h-4 font-medium tracking-tight"
            :: attrs
        )
        children


{-| -}
description : List (Attribute msg) -> List (Html msg) -> Html msg
description attrs children =
    div
        (attribute "data-slot" "alert-description"
            :: class "col-start-2 grid justify-items-start gap-1 text-sm text-muted-foreground [&_p]:leading-relaxed"
            :: attrs
        )
        children


{-| An alert variant. When several are given, the last one wins.
-}
type Option
    = Variant Variant


type Variant
    = Default
    | Destructive


{-| -}
destructive : Option
destructive =
    Variant Destructive


variantClass : Variant -> String
variantClass variant =
    case variant of
        Default ->
            "bg-card text-card-foreground"

        Destructive ->
            "bg-card text-destructive *:data-[slot=alert-description]:text-destructive/90 [&>svg]:text-current"
