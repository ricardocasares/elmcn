module UI.Breadcrumb exposing (view, list, item, link, page, separator, ellipsis)

{-| Displays the path to the current resource using a hierarchy of links.

    Breadcrumb.view []
        [ Breadcrumb.list []
            [ Breadcrumb.item [] [ Breadcrumb.link [ href "/" ] [ text "Home" ] ]
            , Breadcrumb.separator [] []
            , Breadcrumb.item [] [ Breadcrumb.ellipsis [] ]
            , Breadcrumb.separator [] []
            , Breadcrumb.item [] [ Breadcrumb.page [] [ text "Breadcrumb" ] ]
            ]
        ]

@docs view, list, item, link, page, separator, ellipsis

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)
import Svg.Attributes
import UI.Icon as Icon


{-| Renders a `<nav>`.
-}
view : List (Attribute msg) -> List (Html msg) -> Html msg
view attrs children =
    Html.nav (attribute "aria-label" "breadcrumb" :: attribute "data-slot" "breadcrumb" :: attrs) children


{-| Renders an `<ol>` of items and separators.
-}
list : List (Attribute msg) -> List (Html msg) -> Html msg
list attrs children =
    Html.ol
        (attribute "data-slot" "breadcrumb-list"
            :: class "flex flex-wrap items-center gap-1.5 text-sm break-words text-muted-foreground sm:gap-2.5"
            :: attrs
        )
        children


{-| -}
item : List (Attribute msg) -> List (Html msg) -> Html msg
item attrs children =
    Html.li (attribute "data-slot" "breadcrumb-item" :: class "inline-flex items-center gap-1.5" :: attrs) children


{-| Renders an `<a>`.
-}
link : List (Attribute msg) -> List (Html msg) -> Html msg
link attrs children =
    Html.a (attribute "data-slot" "breadcrumb-link" :: class "transition-colors hover:text-foreground" :: attrs) children


{-| The current page. Not a link.
-}
page : List (Attribute msg) -> List (Html msg) -> Html msg
page attrs children =
    Html.span
        ([ attribute "data-slot" "breadcrumb-page"
         , attribute "role" "link"
         , attribute "aria-disabled" "true"
         , attribute "aria-current" "page"
         , class "font-normal text-foreground"
         ]
            ++ attrs
        )
        children


{-| Shows a chevron, unless you pass your own children.
-}
separator : List (Attribute msg) -> List (Html msg) -> Html msg
separator attrs children =
    Html.li
        ([ attribute "data-slot" "breadcrumb-separator"
         , attribute "role" "presentation"
         , attribute "aria-hidden" "true"
         , class "[&>svg]:size-3.5"
         ]
            ++ attrs
        )
        (if List.isEmpty children then
            [ Icon.chevronRight [] ]

         else
            children
        )


{-| Stands in for collapsed items.
-}
ellipsis : List (Attribute msg) -> Html msg
ellipsis attrs =
    Html.span
        ([ attribute "data-slot" "breadcrumb-ellipsis"
         , attribute "role" "presentation"
         , attribute "aria-hidden" "true"
         , class "flex size-9 items-center justify-center"
         ]
            ++ attrs
        )
        [ Icon.ellipsis [ Svg.Attributes.class "size-4" ]
        , Html.span [ class "sr-only" ] [ Html.text "More" ]
        ]
