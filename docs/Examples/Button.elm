module Examples.Button exposing (..)

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, dir, disabled, href)
import Phosphor exposing (IconWeight(..))
import Svg.Attributes
import UI.Button as Button
import UI.Spinner as Spinner


demo : Html msg
demo =
    div [ class "flex flex-wrap items-center gap-2 md:flex-row" ]
        [ Button.view "Button" |> Button.outline |> Button.toHtml []
        , Button.icon (Phosphor.arrowUp Regular |> Phosphor.toHtml []) |> Button.label "Submit" |> Button.outline |> Button.toHtml []
        ]


size : Html msg
size =
    div [ class "flex flex-col items-start gap-8 sm:flex-row" ]
        [ div [ class "flex items-start gap-2" ]
            [ Button.view "Extra Small" |> Button.extraSmall |> Button.outline |> Button.toHtml []
            , Button.icon (Phosphor.arrowUpRight Regular |> Phosphor.toHtml []) |> Button.label "Submit" |> Button.extraSmall |> Button.outline |> Button.toHtml []
            ]
        , div [ class "flex items-start gap-2" ]
            [ Button.view "Small" |> Button.small |> Button.outline |> Button.toHtml []
            , Button.icon (Phosphor.arrowUpRight Regular |> Phosphor.toHtml []) |> Button.label "Submit" |> Button.small |> Button.outline |> Button.toHtml []
            ]
        , div [ class "flex items-start gap-2" ]
            [ Button.view "Default" |> Button.outline |> Button.toHtml []
            , Button.icon (Phosphor.arrowUpRight Regular |> Phosphor.toHtml []) |> Button.label "Submit" |> Button.outline |> Button.toHtml []
            ]
        , div [ class "flex items-start gap-2" ]
            [ Button.view "Large" |> Button.outline |> Button.large |> Button.toHtml []
            , Button.icon (Phosphor.arrowUpRight Regular |> Phosphor.toHtml []) |> Button.label "Submit" |> Button.outline |> Button.large |> Button.toHtml []
            ]
        ]


default : Html msg
default =
    Button.view "Button" |> Button.toHtml []


outline : Html msg
outline =
    Button.view "Outline" |> Button.outline |> Button.toHtml []


secondary : Html msg
secondary =
    Button.view "Secondary" |> Button.secondary |> Button.toHtml []


ghost : Html msg
ghost =
    Button.view "Ghost" |> Button.ghost |> Button.toHtml []


destructive : Html msg
destructive =
    Button.view "Destructive" |> Button.destructive |> Button.toHtml []


link : Html msg
link =
    Button.view "Link" |> Button.link |> Button.toHtml []


{-| An icon-only button needs its icon and an accessible label.
-}
icon : Html msg
icon =
    Button.icon (Phosphor.arrowCircleUp Regular |> Phosphor.toHtml [])
        |> Button.label "Upgrade"
        |> Button.outline
        |> Button.toHtml []


{-| `startIcon` and `endIcon` adjust the padding for the icon.
-}
withIcon : Html msg
withIcon =
    div [ class "flex gap-2" ]
        [ Button.view "New Branch"
            |> Button.outline
            |> Button.startIcon (Phosphor.gitBranch Regular |> Phosphor.toHtml [])
            |> Button.toHtml []
        , Button.view "Fork"
            |> Button.outline
            |> Button.endIcon (Phosphor.gitFork Regular |> Phosphor.toHtml [])
            |> Button.toHtml []
        ]


{-| Elm keeps every class, so override one the component already sets with Tailwind's important modifier.
-}
rounded : Html msg
rounded =
    div [ class "flex gap-2" ]
        [ Button.view "Get Started" |> Button.toHtml [ class "rounded-full!" ]
        , Button.icon (Phosphor.arrowUp Regular |> Phosphor.toHtml [])
            |> Button.label "Submit"
            |> Button.outline
            |> Button.toHtml [ class "rounded-full!" ]
        ]


spinner : Html msg
spinner =
    div [ class "flex gap-2" ]
        [ Button.view "Generating"
            |> Button.outline
            |> Button.startIcon (Spinner.view [])
            |> Button.toHtml [ disabled True ]
        , Button.view "Downloading"
            |> Button.secondary
            |> Button.endIcon (Spinner.view [])
            |> Button.toHtml [ disabled True ]
        ]


{-| Use `toAttributes` to give another element the button styles.
-}
asLink : Html msg
asLink =
    a (href "#" :: Button.toAttributes (Button.view "" |> Button.secondary |> Button.small)) [ text "Login" ]


rtl : Html msg
rtl =
    div [ class "flex flex-wrap items-center gap-2 md:flex-row", dir "rtl" ]
        [ Button.view "زر" |> Button.outline |> Button.toHtml []
        , Button.view "حذف" |> Button.destructive |> Button.toHtml []
        , Button.view "إرسال "
            |> Button.outline
            |> Button.endIcon (Phosphor.arrowRight Regular |> Phosphor.toHtml [ Svg.Attributes.class "rtl:rotate-180" ])
            |> Button.toHtml []
        , Button.icon (Phosphor.plus Regular |> Phosphor.toHtml []) |> Button.label "Add" |> Button.outline |> Button.toHtml []
        , Button.view "جاري التحميل"
            |> Button.secondary
            |> Button.startIcon (Spinner.view [])
            |> Button.toHtml [ disabled True ]
        ]
