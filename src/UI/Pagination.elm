module UI.Pagination exposing
    ( view
    , Item, previous, next, link, activeLink, ellipsis
    )

{-| Pagination with page navigation, next and previous links.

    Pagination.view []
        [ Pagination.previous [ href "?page=1" ] []
        , Pagination.link [ href "?page=1" ] [ text "1" ]
        , Pagination.activeLink [ href "?page=2" ] [ text "2" ]
        , Pagination.link [ href "?page=3" ] [ text "3" ]
        , Pagination.ellipsis
        , Pagination.next [ href "?page=3" ] []
        ]

Links render as `<a>`, so pass `href` for a page URL, or `onClick` with `preventDefault`
when the page is kept in your model.

@docs view


# Items

@docs Item, previous, next, link, activeLink, ellipsis

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)
import UI.Button as Button


{-| Renders a `<nav>` with a `<ul>` of the items. The attributes go on the `<nav>`.
-}
view : List (Attribute msg) -> List (Item msg) -> Html msg
view attrs items =
    Html.nav
        ([ attribute "role" "navigation"
         , attribute "aria-label" "pagination"
         , attribute "data-slot" "pagination"
         , class "mx-auto flex w-full justify-center"
         ]
            ++ attrs
        )
        [ Html.ul
            [ attribute "data-slot" "pagination-content"
            , class "flex items-center gap-0.5"
            ]
            (List.map (\(Item child) -> Html.li [ attribute "data-slot" "pagination-item" ] [ child ]) items)
        ]



-- ITEMS


{-| An item of the list, made with one of the functions below.
-}
type Item msg
    = Item (Html msg)


{-| A link to the previous page, with a chevron and the text "Previous". The text is hidden on small screens. Pass your own children to replace it.
-}
previous : List (Attribute msg) -> List (Html msg) -> Item msg
previous attrs children =
    Item
        (anchor False
            textButton
            (attribute "aria-label" "Go to previous page" :: class "pl-1.5!" :: attrs)
            [ chevron "inline-start" "border-b-[1.5px] border-l-[1.5px] rtl:-rotate-135"
            , Html.span [ class "hidden sm:block" ] (withDefault "Previous" children)
            ]
        )


{-| A link to the next page, with the text "Next" and a chevron. The text is hidden on small screens. Pass your own children to replace it.
-}
next : List (Attribute msg) -> List (Html msg) -> Item msg
next attrs children =
    Item
        (anchor False
            textButton
            (attribute "aria-label" "Go to next page" :: class "pr-1.5!" :: attrs)
            [ Html.span [ class "hidden sm:block" ] (withDefault "Next" children)
            , chevron "inline-end" "border-t-[1.5px] border-r-[1.5px] rtl:-rotate-135"
            ]
        )


{-| A page link, rendered as a square ghost button.
-}
link : List (Attribute msg) -> List (Html msg) -> Item msg
link attrs children =
    Item (anchor False iconButton attrs children)


{-| The current page. The link gets the outline variant and `aria-current="page"`.
-}
activeLink : List (Attribute msg) -> List (Html msg) -> Item msg
activeLink attrs children =
    Item (anchor True iconButton attrs children)


{-| Stands in for skipped pages.
-}
ellipsis : Item msg
ellipsis =
    Item
        (Html.span
            [ attribute "aria-hidden" "true"
            , attribute "data-slot" "pagination-ellipsis"
            , class "flex size-8 items-center justify-center gap-0.5"
            ]
            [ Html.span [ class "size-[2.5px] rounded-full bg-current" ] []
            , Html.span [ class "size-[2.5px] rounded-full bg-current" ] []
            , Html.span [ class "size-[2.5px] rounded-full bg-current" ] []
            , Html.span [ class "sr-only" ] [ Html.text "More pages" ]
            ]
        )



-- INTERNALS


type alias Styles msg =
    Bool -> List (Attribute msg)


anchor : Bool -> Styles msg -> List (Attribute msg) -> List (Html msg) -> Html msg
anchor current styles attrs children =
    Html.a
        ([ attribute "data-slot" "pagination-link"
         , attribute "data-active"
            (if current then
                "true"

             else
                "false"
            )
         ]
            ++ (if current then
                    [ attribute "aria-current" "page" ]

                else
                    []
               )
            ++ styles current
            ++ attrs
        )
        children


{-| The styles of a square icon button. The empty icon and label only pick the square size, `toAttributes` renders neither.
-}
iconButton : Styles msg
iconButton current =
    Button.new
        |> Button.icon (Html.text "")
        |> Button.label ""
        |> variant current
        |> Button.toAttributes


textButton : Styles msg
textButton current =
    Button.new
        |> variant current
        |> Button.toAttributes


variant : Bool -> Button.Button shape status msg -> Button.Button shape status msg
variant current =
    if current then
        Button.outline

    else
        Button.ghost


chevron : String -> String -> Html msg
chevron position borders =
    Html.span
        [ attribute "data-icon" position
        , class "flex size-4 shrink-0 items-center justify-center"
        ]
        [ Html.span [ class ("size-2 rotate-45 border-current " ++ borders) ] [] ]


withDefault : String -> List (Html msg) -> List (Html msg)
withDefault fallback children =
    if List.isEmpty children then
        [ Html.text fallback ]

    else
        children
