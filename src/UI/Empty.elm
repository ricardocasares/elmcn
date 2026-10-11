module UI.Empty exposing
    ( view, header, media, title, description, content
    , MediaOption, icon
    )

{-| Displays an empty state.

    Empty.view [ class "border" ]
        [ Empty.header []
            [ Empty.media [ Empty.icon ] [] [ someIcon ]
            , Empty.title [] [ text "No projects yet" ]
            , Empty.description [] [ text "Get started by creating your first project." ]
            ]
        , Empty.content [] [ Button.view [] [] [ text "Create project" ] ]
        ]

@docs view, header, media, title, description, content


# Media options

@docs MediaOption, icon

-}

import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (attribute, class)


{-| -}
view : List (Attribute msg) -> List (Html msg) -> Html msg
view attrs children =
    div
        (attribute "data-slot" "empty"
            :: class "flex min-w-0 flex-1 flex-col items-center justify-center gap-6 rounded-lg border-dashed p-6 text-center text-balance md:p-12"
            :: attrs
        )
        children


{-| Holds the media, title and description.
-}
header : List (Attribute msg) -> List (Html msg) -> Html msg
header attrs children =
    div (attribute "data-slot" "empty-header" :: class "flex max-w-sm flex-col items-center gap-2 text-center" :: attrs) children


{-| An image, avatar or icon above the title.
-}
media : List MediaOption -> List (Attribute msg) -> List (Html msg) -> Html msg
media options attrs children =
    let
        variant =
            List.foldl (\(Variant v) _ -> v) Default options
    in
    div
        ([ attribute "data-slot" "empty-icon"
         , attribute "data-variant" (variantName variant)
         , class "mb-2 flex shrink-0 items-center justify-center [&_svg]:pointer-events-none [&_svg]:shrink-0"
         , class (variantClass variant)
         ]
            ++ attrs
        )
        children


{-| -}
title : List (Attribute msg) -> List (Html msg) -> Html msg
title attrs children =
    div (attribute "data-slot" "empty-title" :: class "text-lg font-medium tracking-tight" :: attrs) children


{-| -}
description : List (Attribute msg) -> List (Html msg) -> Html msg
description attrs children =
    div
        (attribute "data-slot" "empty-description"
            :: class "text-sm/relaxed text-muted-foreground [&>a]:underline [&>a]:underline-offset-4 [&>a:hover]:text-primary"
            :: attrs
        )
        children


{-| Actions such as buttons or inputs.
-}
content : List (Attribute msg) -> List (Html msg) -> Html msg
content attrs children =
    div
        (attribute "data-slot" "empty-content"
            :: class "flex w-full max-w-sm min-w-0 flex-col items-center gap-4 text-sm text-balance"
            :: attrs
        )
        children


{-| A `media` variant. When several are given, the last one wins.
-}
type MediaOption
    = Variant Variant


type Variant
    = Default
    | Icon


{-| Puts the media on a muted, rounded square, sized for an icon.
-}
icon : MediaOption
icon =
    Variant Icon


variantName : Variant -> String
variantName variant =
    case variant of
        Default ->
            "default"

        Icon ->
            "icon"


variantClass : Variant -> String
variantClass variant =
    case variant of
        Default ->
            "bg-transparent"

        Icon ->
            "flex size-10 shrink-0 items-center justify-center rounded-lg bg-muted text-foreground [&_svg:not([class*='size-'])]:size-6"
