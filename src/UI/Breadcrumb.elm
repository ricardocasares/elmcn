module UI.Breadcrumb exposing
    ( Breadcrumb, Ready, NeedsSeparator
    , new
    , separator
    , link, page, ellipsis, ellipsisIcon, item
    , toHtml
    )

{-| Displays the path to the current resource using a hierarchy of links.

A breadcrumb is built with `new`, given its items in order and a `separator`, and rendered with `toHtml`.
The separator is placed between every two items:

    Breadcrumb.new
        |> Breadcrumb.link [ href "/" ] [ text "Home" ]
        |> Breadcrumb.ellipsis
        |> Breadcrumb.link [ href "/components" ] [ text "Components" ]
        |> Breadcrumb.page [ text "Breadcrumb" ]
        |> Breadcrumb.separator (Phosphor.caretRight Regular |> Phosphor.toHtml [])
        |> Breadcrumb.toHtml []

@docs Breadcrumb, Ready, NeedsSeparator


# Constructor

@docs new


# Required

`toHtml` won't accept a breadcrumb until it has a `separator`.

@docs separator


# Items

@docs link, page, ellipsis, ellipsisIcon, item


# Rendering

@docs toHtml

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)


{-| A breadcrumb being built. `status` is [`Ready`](#Ready) once it has a separator, or [`NeedsSeparator`](#NeedsSeparator) until then.
-}
type Breadcrumb status msg
    = Breadcrumb
        { items : List (Html msg)
        , separator : Html msg
        }


{-| The breadcrumb can be rendered.
-}
type Ready
    = Ready


{-| A breadcrumb that still needs a [`separator`](#separator) before it can be rendered.
-}
type NeedsSeparator
    = NeedsSeparator



-- CONSTRUCTOR


{-| An empty breadcrumb. Give it a [`separator`](#separator) to make it renderable.
-}
new : Breadcrumb NeedsSeparator msg
new =
    Breadcrumb { items = [], separator = Html.text "" }



-- REQUIRED


{-| What goes between the items, such as an icon. The breadcrumb becomes renderable. It is placed in a `<li>` that sizes an `svg` child to `size-3.5`.
-}
separator : Html msg -> Breadcrumb status msg -> Breadcrumb Ready msg
separator child (Breadcrumb config) =
    Breadcrumb { items = config.items, separator = child }



-- ITEMS


{-| A link to an ancestor, rendered as an `<a>`. The attributes go on the `<a>`, so pass `href`.
-}
link : List (Attribute msg) -> List (Html msg) -> Breadcrumb status msg -> Breadcrumb status msg
link attrs children =
    item []
        [ Html.a (attribute "data-slot" "breadcrumb-link" :: class "transition-colors hover:text-foreground" :: attrs) children ]


{-| The current page. Not a link.
-}
page : List (Html msg) -> Breadcrumb status msg -> Breadcrumb status msg
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
ellipsis : Breadcrumb status msg -> Breadcrumb status msg
ellipsis =
    item [] [ ellipsisIcon ]


{-| The ellipsis on its own, to put inside an `item`, such as in the trigger of a dropdown menu that lists the collapsed items.
-}
ellipsisIcon : Html msg
ellipsisIcon =
    Html.span
        [ attribute "data-slot" "breadcrumb-ellipsis"
        , attribute "role" "presentation"
        , attribute "aria-hidden" "true"
        , class "flex size-5 items-center justify-center gap-0.5"
        ]
        [ dot, dot, dot, Html.span [ class "sr-only" ] [ Html.text "More" ] ]


dot : Html msg
dot =
    Html.span [ class "size-[2.667px] rounded-full bg-current" ] []


{-| An item with your own content, such as a dropdown trigger. The attributes go on the `<li>`.
-}
item : List (Attribute msg) -> List (Html msg) -> Breadcrumb status msg -> Breadcrumb status msg
item attrs children (Breadcrumb config) =
    Breadcrumb
        { config
            | items =
                config.items
                    ++ [ Html.li (attribute "data-slot" "breadcrumb-item" :: class "inline-flex items-center gap-1" :: attrs) children ]
        }



-- RENDERING


{-| Renders a `<nav>` with an `<ol>` of the items. The attributes go on the `<nav>`.
-}
toHtml : List (Attribute msg) -> Breadcrumb Ready msg -> Html msg
toHtml attrs (Breadcrumb config) =
    Html.nav
        (attribute "aria-label" "breadcrumb" :: attribute "data-slot" "breadcrumb" :: attrs)
        [ Html.ol
            [ attribute "data-slot" "breadcrumb-list"
            , class "flex flex-wrap items-center gap-1.5 text-sm wrap-break-word text-muted-foreground"
            ]
            (List.intersperse (viewSeparator config.separator) config.items)
        ]


viewSeparator : Html msg -> Html msg
viewSeparator child =
    Html.li
        [ attribute "data-slot" "breadcrumb-separator"
        , attribute "role" "presentation"
        , attribute "aria-hidden" "true"
        , class "flex items-center [&>svg]:size-3.5"
        ]
        [ child ]
