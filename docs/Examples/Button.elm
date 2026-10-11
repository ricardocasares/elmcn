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
        [ Button.new
            |> Button.text "Button"
            |> Button.outline
            |> Button.toHtml []
        , Button.new
            |> Button.icon (Phosphor.arrowUp Regular |> Phosphor.toHtml [])
            |> Button.label "Submit"
            |> Button.outline
            |> Button.toHtml []
        ]


size : Html msg
size =
    div [ class "flex flex-col items-start gap-8 sm:flex-row" ]
        [ div [ class "flex items-start gap-2" ]
            [ Button.new
                |> Button.text "Extra Small"
                |> Button.extraSmall
                |> Button.outline
                |> Button.toHtml []
            , Button.new
                |> Button.icon (Phosphor.arrowUpRight Regular |> Phosphor.toHtml [])
                |> Button.label "Submit"
                |> Button.extraSmall
                |> Button.outline
                |> Button.toHtml []
            ]
        , div [ class "flex items-start gap-2" ]
            [ Button.new
                |> Button.text "Small"
                |> Button.small
                |> Button.outline
                |> Button.toHtml []
            , Button.new |> Button.icon (Phosphor.arrowUpRight Regular |> Phosphor.toHtml []) |> Button.label "Submit" |> Button.small |> Button.outline |> Button.toHtml []
            ]
        , div [ class "flex items-start gap-2" ]
            [ Button.new
                |> Button.text "Default"
                |> Button.outline
                |> Button.toHtml []
            , Button.new
                |> Button.icon (Phosphor.arrowUpRight Regular |> Phosphor.toHtml [])
                |> Button.label "Submit"
                |> Button.outline
                |> Button.toHtml []
            ]
        , div [ class "flex items-start gap-2" ]
            [ Button.new
                |> Button.text "Large"
                |> Button.outline
                |> Button.large
                |> Button.toHtml []
            , Button.new
                |> Button.icon (Phosphor.arrowUpRight Regular |> Phosphor.toHtml [])
                |> Button.label "Submit"
                |> Button.outline
                |> Button.large
                |> Button.toHtml []
            ]
        ]


default : Html msg
default =
    Button.new
        |> Button.text "Button"
        |> Button.toHtml []


outline : Html msg
outline =
    Button.new
        |> Button.text "Outline"
        |> Button.outline
        |> Button.toHtml []


secondary : Html msg
secondary =
    Button.new
        |> Button.text "Secondary"
        |> Button.secondary
        |> Button.toHtml []


ghost : Html msg
ghost =
    Button.new
        |> Button.text "Ghost"
        |> Button.ghost
        |> Button.toHtml []


destructive : Html msg
destructive =
    Button.new
        |> Button.text "Destructive"
        |> Button.destructive
        |> Button.toHtml []


link : Html msg
link =
    Button.new
        |> Button.text "Link"
        |> Button.link
        |> Button.toHtml []


{-| An icon-only button needs its icon and an accessible label.
-}
icon : Html msg
icon =
    Button.new
        |> Button.icon (Phosphor.arrowCircleUp Regular |> Phosphor.toHtml [])
        |> Button.label "Upgrade"
        |> Button.outline
        |> Button.toHtml []


{-| `startIcon` and `endIcon` adjust the padding for the icon.
-}
withIcon : Html msg
withIcon =
    div [ class "flex gap-2" ]
        [ Button.new
            |> Button.text "New Branch"
            |> Button.outline
            |> Button.startIcon (Phosphor.gitBranch Regular |> Phosphor.toHtml [])
            |> Button.toHtml []
        , Button.new
            |> Button.text "Fork"
            |> Button.outline
            |> Button.endIcon (Phosphor.gitFork Regular |> Phosphor.toHtml [])
            |> Button.toHtml []
        ]


{-| `rounded` makes a pill of any size.
-}
rounded : Html msg
rounded =
    div [ class "flex gap-2" ]
        [ Button.new
            |> Button.text "Get Started"
            |> Button.rounded
            |> Button.toHtml []
        , Button.new
            |> Button.icon (Phosphor.arrowUp Regular |> Phosphor.toHtml [])
            |> Button.label "Submit"
            |> Button.outline
            |> Button.rounded
            |> Button.toHtml []
        ]


spinner : Html msg
spinner =
    div [ class "flex gap-2" ]
        [ Button.new
            |> Button.text "Generating"
            |> Button.outline
            |> Button.startIcon (Spinner.view [])
            |> Button.toHtml [ disabled True ]
        , Button.new
            |> Button.text "Downloading"
            |> Button.secondary
            |> Button.endIcon (Spinner.view [])
            |> Button.toHtml [ disabled True ]
        ]


{-| Use `toAttributes` to give another element the button styles.
-}
asLink : Html msg
asLink =
    a
        (href "#"
            :: Button.toAttributes
                (Button.new
                    |> Button.secondary
                    |> Button.small
                )
        )
        [ text "Login" ]


rtl : Html msg
rtl =
    div [ class "flex flex-wrap items-center gap-2 md:flex-row", dir "rtl" ]
        [ Button.new
            |> Button.text "زر"
            |> Button.outline
            |> Button.toHtml []
        , Button.new
            |> Button.text "حذف"
            |> Button.destructive
            |> Button.toHtml []
        , Button.new
            |> Button.text "إرسال "
            |> Button.outline
            |> Button.endIcon (Phosphor.arrowRight Regular |> Phosphor.toHtml [ Svg.Attributes.class "rtl:rotate-180" ])
            |> Button.toHtml []
        , Button.new
            |> Button.icon (Phosphor.plus Regular |> Phosphor.toHtml [])
            |> Button.label "Add"
            |> Button.outline
            |> Button.toHtml []
        , Button.new
            |> Button.text "جاري التحميل"
            |> Button.secondary
            |> Button.startIcon (Spinner.view [])
            |> Button.toHtml [ disabled True ]
        ]
