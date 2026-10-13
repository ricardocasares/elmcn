module Examples.Breadcrumb exposing (..)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, dir, href)
import Phosphor exposing (IconWeight(..))
import UI.Breadcrumb as Breadcrumb
import UI.Button as Button
import UI.DropdownMenu as DropdownMenu


demo : Html msg
demo =
    Breadcrumb.new
        |> Breadcrumb.link [ href "#" ] [ text "Home" ]
        |> Breadcrumb.item []
            [ DropdownMenu.new
                |> DropdownMenu.id "breadcrumb-demo"
                |> DropdownMenu.trigger
                    (Button.new
                        |> Button.icon Breadcrumb.ellipsisIcon
                        |> Button.ghost
                        |> Button.small
                        |> Button.toAttributes
                    )
                    [ Breadcrumb.ellipsisIcon
                    , span [ class "sr-only" ] [ text "Toggle menu" ]
                    ]
                |> DropdownMenu.content
                    [ DropdownMenu.group
                        [ DropdownMenu.item [] [ text "Documentation" ]
                        , DropdownMenu.item [] [ text "Themes" ]
                        , DropdownMenu.item [] [ text "GitHub" ]
                        ]
                    ]
                |> DropdownMenu.toHtml []
            ]
        |> Breadcrumb.link [ href "#" ] [ text "Components" ]
        |> Breadcrumb.page [ text "Breadcrumb" ]
        |> Breadcrumb.separator (Phosphor.caretRight Regular |> Phosphor.toHtml [])
        |> Breadcrumb.toHtml []


{-| A home link, a components link and the current page.
-}
basic : Html msg
basic =
    Breadcrumb.new
        |> Breadcrumb.link [ href "#" ] [ text "Home" ]
        |> Breadcrumb.link [ href "#" ] [ text "Components" ]
        |> Breadcrumb.page [ text "Breadcrumb" ]
        |> Breadcrumb.separator (Phosphor.caretRight Regular |> Phosphor.toHtml [])
        |> Breadcrumb.toHtml []


{-| Any content can be the separator, such as a dot icon.
-}
customSeparator : Html msg
customSeparator =
    Breadcrumb.new
        |> Breadcrumb.link [ href "/" ] [ text "Home" ]
        |> Breadcrumb.link [ href "/components" ] [ text "Components" ]
        |> Breadcrumb.page [ text "Breadcrumb" ]
        |> Breadcrumb.separator (Phosphor.dot Regular |> Phosphor.toHtml [])
        |> Breadcrumb.toHtml []


{-| `item` takes your own content, such as a `DropdownMenu` whose trigger is the item.
-}
dropdown : Html msg
dropdown =
    Breadcrumb.new
        |> Breadcrumb.link [ href "/" ] [ text "Home" ]
        |> Breadcrumb.item []
            [ DropdownMenu.new
                |> DropdownMenu.id "breadcrumb-dropdown"
                |> DropdownMenu.trigger [ class "flex items-center gap-1 [&>svg]:size-3.5" ]
                    [ text "Components"
                    , Phosphor.caretDown Regular |> Phosphor.toHtml []
                    ]
                |> DropdownMenu.content
                    [ DropdownMenu.group
                        [ DropdownMenu.item [] [ text "Documentation" ]
                        , DropdownMenu.item [] [ text "Themes" ]
                        , DropdownMenu.item [] [ text "GitHub" ]
                        ]
                    ]
                |> DropdownMenu.toHtml []
            ]
        |> Breadcrumb.page [ text "Breadcrumb" ]
        |> Breadcrumb.separator (Phosphor.dot Regular |> Phosphor.toHtml [])
        |> Breadcrumb.toHtml []


{-| `ellipsis` stands in for the items left out when the path is too long.
-}
collapsed : Html msg
collapsed =
    Breadcrumb.new
        |> Breadcrumb.link [ href "/" ] [ text "Home" ]
        |> Breadcrumb.ellipsis
        |> Breadcrumb.link [ href "/docs/components" ] [ text "Components" ]
        |> Breadcrumb.page [ text "Breadcrumb" ]
        |> Breadcrumb.separator (Phosphor.caretRight Regular |> Phosphor.toHtml [])
        |> Breadcrumb.toHtml []


{-| `link` renders an `<a>` and puts the attributes on it, so pass the `href` and events your router uses.
-}
linkComponent : Html msg
linkComponent =
    Breadcrumb.new
        |> Breadcrumb.link [ href "#link-component" ] [ text "Home" ]
        |> Breadcrumb.link [ href "#link-component" ] [ text "Components" ]
        |> Breadcrumb.page [ text "Breadcrumb" ]
        |> Breadcrumb.separator (Phosphor.caretRight Regular |> Phosphor.toHtml [])
        |> Breadcrumb.toHtml []


{-| The menu is aligned to the end so it opens under its trigger.
-}
rtl : Html msg
rtl =
    div [ dir "rtl" ]
        [ Breadcrumb.new
            |> Breadcrumb.link [ href "/" ] [ text "الرئيسية" ]
            |> Breadcrumb.item []
                [ DropdownMenu.new
                    |> DropdownMenu.id "breadcrumb-rtl"
                    |> DropdownMenu.trigger [ class "flex items-center gap-1 [&>svg]:size-3.5" ]
                        [ text "المكونات"
                        , Phosphor.caretDown Regular |> Phosphor.toHtml []
                        ]
                    |> DropdownMenu.content
                        [ DropdownMenu.group
                            [ DropdownMenu.item [] [ text "التوثيق" ]
                            , DropdownMenu.item [] [ text "السمات" ]
                            , DropdownMenu.item [] [ text "جيت هاب" ]
                            ]
                        ]
                    |> DropdownMenu.alignEnd
                    |> DropdownMenu.toHtml []
                ]
            |> Breadcrumb.page [ text "مسار التنقل" ]
            |> Breadcrumb.separator (Phosphor.dot Regular |> Phosphor.toHtml [])
            |> Breadcrumb.toHtml []
        ]
