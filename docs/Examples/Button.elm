module Examples.Button exposing (..)

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (attribute, class, dir, disabled, href)
import Icons
import Svg.Attributes
import UI.Button as Button
import UI.Spinner as Spinner


demo : Html msg
demo =
    div [ class "flex flex-wrap items-center gap-2 md:flex-row" ]
        [ Button.view [ Button.outline ] [] [ text "Button" ]
        , Button.view [ Button.outline, Button.icon ] [ attribute "aria-label" "Submit" ] [ Icons.arrowUp [] ]
        ]


size : Html msg
size =
    div [ class "flex flex-col items-start gap-8 sm:flex-row" ]
        [ div [ class "flex items-start gap-2" ]
            [ Button.view [ Button.extraSmall, Button.outline ] [] [ text "Extra Small" ]
            , Button.view [ Button.iconExtraSmall, Button.outline ] [ attribute "aria-label" "Submit" ] [ Icons.arrowUpRight [] ]
            ]
        , div [ class "flex items-start gap-2" ]
            [ Button.view [ Button.small, Button.outline ] [] [ text "Small" ]
            , Button.view [ Button.iconSmall, Button.outline ] [ attribute "aria-label" "Submit" ] [ Icons.arrowUpRight [] ]
            ]
        , div [ class "flex items-start gap-2" ]
            [ Button.view [ Button.outline ] [] [ text "Default" ]
            , Button.view [ Button.icon, Button.outline ] [ attribute "aria-label" "Submit" ] [ Icons.arrowUpRight [] ]
            ]
        , div [ class "flex items-start gap-2" ]
            [ Button.view [ Button.outline, Button.large ] [] [ text "Large" ]
            , Button.view [ Button.iconLarge, Button.outline ] [ attribute "aria-label" "Submit" ] [ Icons.arrowUpRight [] ]
            ]
        ]


default : Html msg
default =
    Button.view [] [] [ text "Button" ]


outline : Html msg
outline =
    Button.view [ Button.outline ] [] [ text "Outline" ]


secondary : Html msg
secondary =
    Button.view [ Button.secondary ] [] [ text "Secondary" ]


ghost : Html msg
ghost =
    Button.view [ Button.ghost ] [] [ text "Ghost" ]


destructive : Html msg
destructive =
    Button.view [ Button.destructive ] [] [ text "Destructive" ]


link : Html msg
link =
    Button.view [ Button.link ] [] [ text "Link" ]


icon : Html msg
icon =
    Button.view [ Button.outline, Button.icon ]
        [ attribute "aria-label" "Upgrade" ]
        [ Icons.circleFadingArrowUp [] ]


{-| Mark an icon next to the label with `data-icon` so the padding is adjusted for it.
-}
withIcon : Html msg
withIcon =
    div [ class "flex gap-2" ]
        [ Button.view [ Button.outline ]
            []
            [ Icons.gitBranch [ attribute "data-icon" "inline-start" ], text " New Branch" ]
        , Button.view [ Button.outline ]
            []
            [ text "Fork", Icons.gitFork [ attribute "data-icon" "inline-end" ] ]
        ]


{-| Elm keeps every class, so override one the component already sets with Tailwind's important modifier.
-}
rounded : Html msg
rounded =
    div [ class "flex gap-2" ]
        [ Button.view [] [ class "rounded-full!" ] [ text "Get Started" ]
        , Button.view [ Button.outline, Button.icon ] [ class "rounded-full!" ] [ Icons.arrowUp [] ]
        ]


spinner : Html msg
spinner =
    div [ class "flex gap-2" ]
        [ Button.view [ Button.outline ]
            [ disabled True ]
            [ Spinner.view [ attribute "data-icon" "inline-start" ], text "Generating" ]
        , Button.view [ Button.secondary ]
            [ disabled True ]
            [ text "Downloading", Spinner.view [ attribute "data-icon" "inline-start" ] ]
        ]


{-| Use `attributes` to give another element the button styles.
-}
asLink : Html msg
asLink =
    a (href "#" :: Button.attributes [ Button.secondary, Button.small ]) [ text "Login" ]


rtl : Html msg
rtl =
    div [ class "flex flex-wrap items-center gap-2 md:flex-row", dir "rtl" ]
        [ Button.view [ Button.outline ] [] [ text "زر" ]
        , Button.view [ Button.destructive ] [] [ text "حذف" ]
        , Button.view [ Button.outline ]
            []
            [ text "إرسال "
            , Icons.arrowRight [ Svg.Attributes.class "rtl:rotate-180", attribute "data-icon" "inline-end" ]
            ]
        , Button.view [ Button.outline, Button.icon ] [ attribute "aria-label" "Add" ] [ Icons.plus [] ]
        , Button.view [ Button.secondary ]
            [ disabled True ]
            [ Spinner.view [ attribute "data-icon" "inline-start" ], text " جاري التحميل" ]
        ]
