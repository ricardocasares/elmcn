module UI.Badge exposing
    ( view, attributes
    , Option, secondary, destructive, outline, ghost, link
    )

{-| Displays a badge or a component that looks like a badge.

    Badge.view [] [] [ text "New" ]

    Badge.view [ Badge.outline ] [] [ text "Draft" ]

Use `attributes` to style a link as a badge; links also get a hover state:

    a (href "/inbox" :: Badge.attributes [ Badge.secondary ]) [ text "12 unread" ]

@docs view, attributes


# Variants

The default variant is a solid primary badge.

@docs Option, secondary, destructive, outline, ghost, link

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)


{-| Renders a `<span>`.
-}
view : List Option -> List (Attribute msg) -> List (Html msg) -> Html msg
view options attrs children =
    Html.span (attributes options ++ attrs) children


{-| The badge styles as attributes, for elements other than `<span>`.
-}
attributes : List Option -> List (Attribute msg)
attributes options =
    let
        variant =
            List.foldl (\(Variant v) _ -> v) Default options
    in
    [ attribute "data-slot" "badge"
    , attribute "data-variant" (variantName variant)
    , class "group/badge inline-flex h-5 w-fit shrink-0 items-center justify-center gap-1 overflow-hidden rounded-4xl border border-transparent px-2 py-0.5 text-xs font-medium whitespace-nowrap transition-all focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 has-data-[icon=inline-end]:pr-1.5 has-data-[icon=inline-start]:pl-1.5 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 [&>svg]:pointer-events-none [&>svg]:size-3!"
    , class (variantClass variant)
    ]


{-| A badge variant. When several are given, the last one wins.
-}
type Option
    = Variant Variant


type Variant
    = Default
    | Secondary
    | Destructive
    | Outline
    | Ghost
    | Link


{-| -}
secondary : Option
secondary =
    Variant Secondary


{-| -}
destructive : Option
destructive =
    Variant Destructive


{-| -}
outline : Option
outline =
    Variant Outline


{-| -}
ghost : Option
ghost =
    Variant Ghost


{-| -}
link : Option
link =
    Variant Link


variantName : Variant -> String
variantName variant =
    case variant of
        Default ->
            "default"

        Secondary ->
            "secondary"

        Destructive ->
            "destructive"

        Outline ->
            "outline"

        Ghost ->
            "ghost"

        Link ->
            "link"


variantClass : Variant -> String
variantClass variant =
    case variant of
        Default ->
            "bg-primary text-primary-foreground [a&]:hover:bg-primary/80"

        Secondary ->
            "bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/80"

        Destructive ->
            "bg-destructive/10 text-destructive focus-visible:ring-destructive/20 dark:bg-destructive/20 dark:focus-visible:ring-destructive/40 [a&]:hover:bg-destructive/20"

        Outline ->
            "border-border text-foreground [a&]:hover:bg-muted [a&]:hover:text-muted-foreground"

        Ghost ->
            "hover:bg-muted hover:text-muted-foreground dark:hover:bg-muted/50"

        Link ->
            "text-primary underline-offset-4 hover:underline"
