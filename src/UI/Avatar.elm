module UI.Avatar exposing
    ( view, image, fallback, badge
    , group, groupCount
    , Option, small, large
    )

{-| An image element with a fallback for representing the user.

    Avatar.view []
        []
        [ Avatar.fallback [] [ text "CN" ]
        , Avatar.image [ src "https://github.com/shadcn.png", alt "@shadcn" ]
        ]

The image covers the fallback once it loads, so list the fallback first. There is no
load-error handling: if the image URL may be missing, render only the fallback.

@docs view, image, fallback, badge


# Groups

    Avatar.group []
        [ Avatar.view [] [] [ Avatar.fallback [] [ text "AB" ] ]
        , Avatar.view [] [] [ Avatar.fallback [] [ text "CD" ] ]
        , Avatar.groupCount [] [ text "+3" ]
        ]

@docs group, groupCount


# Sizes

@docs Option, small, large

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)


{-| -}
view : List Option -> List (Attribute msg) -> List (Html msg) -> Html msg
view options attrs children =
    let
        size =
            List.foldl (\(Size s) _ -> s) Medium options
    in
    Html.span
        ([ attribute "data-slot" "avatar"
         , attribute "data-size" (sizeName size)
         , class "group/avatar relative flex size-8 shrink-0 rounded-full select-none after:absolute after:inset-0 after:rounded-full after:border after:border-border after:mix-blend-darken data-[size=lg]:size-10 data-[size=sm]:size-6 dark:after:mix-blend-lighten"
         ]
            ++ attrs
        )
        children


{-| Renders an `<img>`. Pass `src` and `alt`.
-}
image : List (Attribute msg) -> Html msg
image attrs =
    Html.img (attribute "data-slot" "avatar-image" :: class "absolute inset-0 aspect-square size-full rounded-full object-cover" :: attrs) []


{-| Shown while the image loads, or when there is no image.
-}
fallback : List (Attribute msg) -> List (Html msg) -> Html msg
fallback attrs children =
    Html.span
        (attribute "data-slot" "avatar-fallback"
            :: class "flex size-full items-center justify-center rounded-full bg-muted text-sm text-muted-foreground group-data-[size=sm]/avatar:text-xs"
            :: attrs
        )
        children


{-| A small status dot in the bottom-right corner. Place it inside `view`.
-}
badge : List (Attribute msg) -> List (Html msg) -> Html msg
badge attrs children =
    Html.span
        ([ attribute "data-slot" "avatar-badge"
         , class "absolute right-0 bottom-0 z-10 inline-flex items-center justify-center rounded-full bg-primary text-primary-foreground bg-blend-color ring-2 ring-background select-none"
         , class "group-data-[size=sm]/avatar:size-2 group-data-[size=sm]/avatar:[&>svg]:hidden"
         , class "group-data-[size=default]/avatar:size-2.5 group-data-[size=default]/avatar:[&>svg]:size-2"
         , class "group-data-[size=lg]/avatar:size-3 group-data-[size=lg]/avatar:[&>svg]:size-2"
         ]
            ++ attrs
        )
        children


{-| Stacks avatars so they overlap.
-}
group : List (Attribute msg) -> List (Html msg) -> Html msg
group attrs children =
    Html.div
        (attribute "data-slot" "avatar-group"
            :: class "group/avatar-group flex -space-x-2 *:data-[slot=avatar]:ring-2 *:data-[slot=avatar]:ring-background"
            :: attrs
        )
        children


{-| Shows how many more avatars there are, at the end of a `group`.
-}
groupCount : List (Attribute msg) -> List (Html msg) -> Html msg
groupCount attrs children =
    Html.div
        (attribute "data-slot" "avatar-group-count"
            :: class "relative flex size-8 shrink-0 items-center justify-center rounded-full bg-muted text-sm text-muted-foreground ring-2 ring-background group-has-data-[size=lg]/avatar-group:size-10 group-has-data-[size=sm]/avatar-group:size-6 [&>svg]:size-4 group-has-data-[size=lg]/avatar-group:[&>svg]:size-5 group-has-data-[size=sm]/avatar-group:[&>svg]:size-3"
            :: attrs
        )
        children


{-| The avatar size. When several are given, the last one wins.
-}
type Option
    = Size Size


type Size
    = Medium
    | Small
    | Large


{-| -}
small : Option
small =
    Size Small


{-| -}
large : Option
large =
    Size Large


sizeName : Size -> String
sizeName size =
    case size of
        Medium ->
            "default"

        Small ->
            "sm"

        Large ->
            "lg"
