module UI.Card exposing (view, header, title, description, action, content, footer)

{-| Displays a card with header, content, and footer.

    Card.view []
        [ Card.header []
            [ Card.title [] [ text "Notifications" ]
            , Card.description [] [ text "You have 3 unread messages." ]
            , Card.action [] [ Button.view [ Button.link ] [] [ text "Mark all read" ] ]
            ]
        , Card.content [] [ text "…" ]
        , Card.footer [] [ Button.view [] [ class "w-full" ] [ text "Done" ] ]
        ]

@docs view, header, title, description, action, content, footer

-}

import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (attribute, class)


{-| -}
view : List (Attribute msg) -> List (Html msg) -> Html msg
view attrs children =
    div
        (attribute "data-slot" "card"
            :: class "flex flex-col gap-6 rounded-xl border bg-card py-6 text-card-foreground shadow-sm"
            :: attrs
        )
        children


{-| Holds the title, description and an optional `action`.
-}
header : List (Attribute msg) -> List (Html msg) -> Html msg
header attrs children =
    div
        (attribute "data-slot" "card-header"
            :: class "@container/card-header grid auto-rows-min grid-rows-[auto_auto] items-start gap-2 px-6 has-data-[slot=card-action]:grid-cols-[1fr_auto] [.border-b]:pb-6"
            :: attrs
        )
        children


{-| -}
title : List (Attribute msg) -> List (Html msg) -> Html msg
title attrs children =
    div (attribute "data-slot" "card-title" :: class "leading-none font-semibold" :: attrs) children


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
    div (attribute "data-slot" "card-content" :: class "px-6" :: attrs) children


{-| -}
footer : List (Attribute msg) -> List (Html msg) -> Html msg
footer attrs children =
    div (attribute "data-slot" "card-footer" :: class "flex items-center px-6 [.border-t]:pt-6" :: attrs) children
