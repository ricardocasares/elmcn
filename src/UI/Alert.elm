module UI.Alert exposing
    ( view, title, description, action
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

Use `action` for a control pinned to the top-right corner:

    Alert.view []
        []
        [ Alert.title [] [ text "Update available" ]
        , Alert.action [] [ Button.view "Update" |> Button.outline |> Button.toHtml [] ]
        ]

@docs view, title, description, action


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
         , class "group/alert relative grid w-full gap-0.5 rounded-lg border px-2.5 py-2 text-left text-sm has-data-[slot=alert-action]:pr-18 has-[>svg]:grid-cols-[auto_1fr] has-[>svg]:gap-x-2 *:[svg]:row-span-2 *:[svg]:translate-y-0.5 *:[svg]:text-current *:[svg:not([class*='size-'])]:size-4"
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
            :: class "font-medium group-has-[>svg]/alert:col-start-2 [&_a]:underline [&_a]:underline-offset-3 [&_a]:hover:text-foreground"
            :: attrs
        )
        children


{-| -}
description : List (Attribute msg) -> List (Html msg) -> Html msg
description attrs children =
    div
        (attribute "data-slot" "alert-description"
            :: class "text-sm text-balance text-muted-foreground group-has-[>svg]/alert:col-start-2 md:text-pretty [&_a]:underline [&_a]:underline-offset-3 [&_a]:hover:text-foreground [&_p:not(:last-child)]:mb-4"
            :: attrs
        )
        children


{-| A control, such as a button, positioned in the top-right corner.
-}
action : List (Attribute msg) -> List (Html msg) -> Html msg
action attrs children =
    div
        (attribute "data-slot" "alert-action"
            :: class "absolute top-2 right-2"
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
            "bg-card text-destructive *:data-[slot=alert-description]:text-destructive/90 *:[svg]:text-current"
