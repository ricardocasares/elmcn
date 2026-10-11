module UI.Breadcrumb exposing
    ( Breadcrumb
    , new
    , link, page, ellipsis, item
    , separator
    , toHtml
    )

{-| Displays the path to the current resource using a hierarchy of links.

A breadcrumb is built with `new`, given its items in order, and rendered with `toHtml`.
A separator is placed between every two items:

    Breadcrumb.new
        |> Breadcrumb.link [ href "/" ] [ text "Home" ]
        |> Breadcrumb.ellipsis
        |> Breadcrumb.link [ href "/components" ] [ text "Components" ]
        |> Breadcrumb.page [ text "Breadcrumb" ]
        |> Breadcrumb.toHtml []

The default separator is a chevron. Pass your own with `separator`:

    Breadcrumb.new
        |> Breadcrumb.separator (text "/")
        |> Breadcrumb.link [ href "/" ] [ text "Home" ]
        |> Breadcrumb.page [ text "Docs" ]
        |> Breadcrumb.toHtml []

@docs Breadcrumb


# Constructor

@docs new


# Items

@docs link, page, ellipsis, item


# Separator

@docs separator


# Rendering

@docs toHtml

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)


{-| A breadcrumb being built.
-}
type Breadcrumb msg
    = Breadcrumb
        { items : List (Html msg)
        , separator : Maybe (Html msg)
        }



-- CONSTRUCTOR


{-| An empty breadcrumb.
-}
new : Breadcrumb msg
new =
    Breadcrumb { items = [], separator = Nothing }



-- ITEMS


{-| A link to an ancestor, rendered as an `<a>`. The attributes go on the `<a>`, so pass `href`.
-}
link : List (Attribute msg) -> List (Html msg) -> Breadcrumb msg -> Breadcrumb msg
link attrs children =
    item []
        [ Html.a (attribute "data-slot" "breadcrumb-link" :: class "transition-colors hover:text-foreground" :: attrs) children ]


{-| The current page. Not a link.
-}
page : List (Html msg) -> Breadcrumb msg -> Breadcrumb msg
page children =
    item []
        [ Html.span
            [ attribute "data-slot" "breadcrumb-page"
            , attribute "role" "link"
            , attribute "aria-disabled" "true"
            , attribute "aria-current" "page"
            , class "font-normal text-foreground"
            ]
            children
        ]


{-| Stands in for collapsed items.
-}
ellipsis : Breadcrumb msg -> Breadcrumb msg
ellipsis =
    item []
        [ Html.span
            [ attribute "data-slot" "breadcrumb-ellipsis"
            , attribute "role" "presentation"
            , attribute "aria-hidden" "true"
            , class "flex size-5 items-center justify-center gap-0.5"
            ]
            [ Html.span [ class "size-[2.5px] rounded-full bg-current" ] []
            , Html.span [ class "size-[2.5px] rounded-full bg-current" ] []
            , Html.span [ class "size-[2.5px] rounded-full bg-current" ] []
            , Html.span [ class "sr-only" ] [ Html.text "More" ]
            ]
        ]


{-| An item with your own content, such as a dropdown trigger. The attributes go on the `<li>`.
-}
item : List (Attribute msg) -> List (Html msg) -> Breadcrumb msg -> Breadcrumb msg
item attrs children (Breadcrumb config) =
    Breadcrumb
        { config
            | items =
                config.items
                    ++ [ Html.li (attribute "data-slot" "breadcrumb-item" :: class "inline-flex items-center gap-1" :: attrs) children ]
        }



-- SEPARATOR


{-| Replaces the chevron placed between items.
-}
separator : Html msg -> Breadcrumb msg -> Breadcrumb msg
separator child (Breadcrumb config) =
    Breadcrumb { config | separator = Just child }



-- RENDERING


{-| Renders a `<nav>` with an `<ol>` of the items. The attributes go on the `<nav>`.
-}
toHtml : List (Attribute msg) -> Breadcrumb msg -> Html msg
toHtml attrs (Breadcrumb config) =
    Html.nav
        (attribute "aria-label" "breadcrumb" :: attribute "data-slot" "breadcrumb" :: attrs)
        [ Html.ol
            [ attribute "data-slot" "breadcrumb-list"
            , class "flex flex-wrap items-center gap-1.5 text-sm wrap-break-word text-muted-foreground"
            ]
            (List.intersperse (viewSeparator config.separator) config.items)
        ]


viewSeparator : Maybe (Html msg) -> Html msg
viewSeparator custom =
    Html.li
        [ attribute "data-slot" "breadcrumb-separator"
        , attribute "role" "presentation"
        , attribute "aria-hidden" "true"
        , class "flex items-center"
        ]
        [ Maybe.withDefault
            (Html.span [ class "size-1.5 rotate-45 border-t-[1.5px] border-r-[1.5px] border-current rtl:-rotate-135" ] [])
            custom
        ]
