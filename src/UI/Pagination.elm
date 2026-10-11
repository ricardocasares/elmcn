module UI.Pagination exposing
    ( view, content, item, link, previous, next, ellipsis
    , Option, active
    )

{-| Pagination with page navigation, next and previous links.

    Pagination.view []
        [ Pagination.content []
            [ Pagination.item [] [ Pagination.previous [ href "#" ] [] ]
            , Pagination.item [] [ Pagination.link [] [ href "#" ] [ text "1" ] ]
            , Pagination.item [] [ Pagination.link [ Pagination.active ] [ href "#" ] [ text "2" ] ]
            , Pagination.item [] [ Pagination.link [] [ href "#" ] [ text "3" ] ]
            , Pagination.item [] [ Pagination.ellipsis [] ]
            , Pagination.item [] [ Pagination.next [ href "#" ] [] ]
            ]
        ]

Links render as `<a>`, so pass `href` for a page URL, or `onClick` with `preventDefault` when the page is kept in your model.

@docs view, content, item, link, previous, next, ellipsis


# Options

@docs Option, active

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)
import UI.Button as Button


{-| Renders a `<nav>`.
-}
view : List (Attribute msg) -> List (Html msg) -> Html msg
view attrs children =
    Html.nav
        ([ attribute "role" "navigation"
         , attribute "aria-label" "pagination"
         , attribute "data-slot" "pagination"
         , class "mx-auto flex w-full justify-center"
         ]
            ++ attrs
        )
        children


{-| Renders a `<ul>` of items.
-}
content : List (Attribute msg) -> List (Html msg) -> Html msg
content attrs children =
    Html.ul
        (attribute "data-slot" "pagination-content"
            :: class "flex items-center gap-0.5"
            :: attrs
        )
        children


{-| -}
item : List (Attribute msg) -> List (Html msg) -> Html msg
item attrs children =
    Html.li (attribute "data-slot" "pagination-item" :: attrs) children


{-| A page link, rendered as a square ghost button. The [`active`](#active) option marks the current page.
-}
link : List Option -> List (Attribute msg) -> List (Html msg) -> Html msg
link options attrs children =
    anchor (isActive options) iconButton attrs children


{-| A link to the previous page, with a chevron and the text "Previous". The text is hidden on small screens. Pass your own children to replace it.
-}
previous : List (Attribute msg) -> List (Html msg) -> Html msg
previous attrs children =
    anchor False
        textButton
        (attribute "aria-label" "Go to previous page" :: class "pl-1.5!" :: attrs)
        [ chevron "inline-start" "border-b-[1.5px] border-l-[1.5px] rtl:-rotate-135"
        , Html.span [ class "hidden sm:block" ] (withDefault "Previous" children)
        ]


{-| A link to the next page, with the text "Next" and a chevron. The text is hidden on small screens. Pass your own children to replace it.
-}
next : List (Attribute msg) -> List (Html msg) -> Html msg
next attrs children =
    anchor False
        textButton
        (attribute "aria-label" "Go to next page" :: class "pr-1.5!" :: attrs)
        [ Html.span [ class "hidden sm:block" ] (withDefault "Next" children)
        , chevron "inline-end" "border-t-[1.5px] border-r-[1.5px] rtl:-rotate-135"
        ]


{-| Stands in for skipped pages.
-}
ellipsis : List (Attribute msg) -> Html msg
ellipsis attrs =
    Html.span
        ([ attribute "aria-hidden" "true"
         , attribute "data-slot" "pagination-ellipsis"
         , class "flex size-8 items-center justify-center gap-0.5"
         ]
            ++ attrs
        )
        [ Html.span [ class "size-1 rounded-full bg-current" ] []
        , Html.span [ class "size-1 rounded-full bg-current" ] []
        , Html.span [ class "size-1 rounded-full bg-current" ] []
        , Html.span [ class "sr-only" ] [ Html.text "More pages" ]
        ]



-- OPTIONS


{-| Whether a link is the current page.
-}
type Option
    = Active


{-| The current page. The link gets the outline variant and `aria-current="page"`.
-}
active : Option
active =
    Active


isActive : List Option -> Bool
isActive =
    List.any (\Active -> True)



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
