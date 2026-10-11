module UI.Card exposing
    ( view, header, title, description, action, content, footer
    , Option, small
    )

{-| Displays a card with header, content, and footer.

    Card.view []
        []
        [ Card.header []
            [ Card.title [] [ text "Notifications" ]
            , Card.description [] [ text "You have 3 unread messages." ]
            , Card.action [] [ Button.view "Mark all read" |> Button.link |> Button.toHtml [] ]
            ]
        , Card.content [] [ text "…" ]
        , Card.footer [] [ Button.view "Done" |> Button.toHtml [ class "w-full" ] ]
        ]

An image placed first or last in the card runs edge to edge, with rounded outer corners.

@docs view, header, title, description, action, content, footer


# Sizes

The default card has roomier spacing. Use `small` for a denser one.

@docs Option, small

-}

import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (attribute, class)


{-| -}
view : List Option -> List (Attribute msg) -> List (Html msg) -> Html msg
view options attrs children =
    let
        size =
            List.foldl (\(Size s) _ -> s) Default options
    in
    div
        ([ attribute "data-slot" "card"
         , attribute "data-size" (sizeName size)
         , class "group/card flex flex-col gap-(--card-spacing) overflow-hidden rounded-xl bg-card py-(--card-spacing) text-sm text-card-foreground ring-1 ring-foreground/10 [--card-spacing:--spacing(4)] has-data-[slot=card-footer]:pb-0 has-[>img:first-child]:pt-0 data-[size=sm]:[--card-spacing:--spacing(3)] *:[img:first-child]:rounded-t-xl *:[img:last-child]:rounded-b-xl"
         ]
            ++ attrs
        )
        children


{-| Holds the title, description and an optional `action`.
-}
header : List (Attribute msg) -> List (Html msg) -> Html msg
header attrs children =
    div
        (attribute "data-slot" "card-header"
            :: class "group/card-header @container/card-header grid auto-rows-min items-start gap-1 rounded-t-xl px-(--card-spacing) has-data-[slot=card-action]:grid-cols-[1fr_auto] has-data-[slot=card-description]:grid-rows-[auto_auto] [.border-b]:pb-(--card-spacing)"
            :: attrs
        )
        children


{-| -}
title : List (Attribute msg) -> List (Html msg) -> Html msg
title attrs children =
    div (attribute "data-slot" "card-title" :: class "text-base leading-snug font-medium group-data-[size=sm]/card:text-sm" :: attrs) children


{-| -}
description : List (Attribute msg) -> List (Html msg) -> Html msg
description attrs children =
    div (attribute "data-slot" "card-description" :: class "text-sm text-muted-foreground" :: attrs) children


{-| Placed in the top-right corner of the `header`.
-}
action : List (Attribute msg) -> List (Html msg) -> Html msg
action attrs children =
    div
        (attribute "data-slot" "card-action"
            :: class "col-start-2 row-span-2 row-start-1 self-start justify-self-end"
            :: attrs
        )
        children


{-| -}
content : List (Attribute msg) -> List (Html msg) -> Html msg
content attrs children =
    div (attribute "data-slot" "card-content" :: class "px-(--card-spacing)" :: attrs) children


{-| -}
footer : List (Attribute msg) -> List (Html msg) -> Html msg
footer attrs children =
    div (attribute "data-slot" "card-footer" :: class "flex items-center rounded-b-xl border-t bg-muted/50 p-(--card-spacing)" :: attrs) children


{-| A card size. When several are given, the last one wins.
-}
type Option
    = Size Size


type Size
    = Default
    | Small


{-| -}
small : Option
small =
    Size Small


sizeName : Size -> String
sizeName size =
    case size of
        Default ->
            "default"

        Small ->
            "sm"
