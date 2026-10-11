module Examples.Badge exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class, dir, href)
import Phosphor exposing (IconWeight(..))
import UI.Badge as Badge
import UI.Spinner as Spinner


demo : Html msg
demo =
    div [ class "flex w-full flex-wrap justify-center gap-2" ]
        [ Badge.new
            |> Badge.text "Badge"
            |> Badge.toHtml []
        , Badge.new
            |> Badge.text "Secondary"
            |> Badge.secondary
            |> Badge.toHtml []
        , Badge.new
            |> Badge.text "Destructive"
            |> Badge.destructive
            |> Badge.toHtml []
        , Badge.new
            |> Badge.text "Outline"
            |> Badge.outline
            |> Badge.toHtml []
        ]


{-| The default variant is a solid primary badge.
-}
variants : Html msg
variants =
    div [ class "flex flex-wrap gap-2" ]
        [ Badge.new
            |> Badge.text "Default"
            |> Badge.toHtml []
        , Badge.new
            |> Badge.text "Secondary"
            |> Badge.secondary
            |> Badge.toHtml []
        , Badge.new
            |> Badge.text "Destructive"
            |> Badge.destructive
            |> Badge.toHtml []
        , Badge.new
            |> Badge.text "Outline"
            |> Badge.outline
            |> Badge.toHtml []
        , Badge.new
            |> Badge.text "Ghost"
            |> Badge.ghost
            |> Badge.toHtml []
        ]


{-| `startIcon` and `endIcon` adjust the padding for the icon.
-}
withIcon : Html msg
withIcon =
    div [ class "flex flex-wrap gap-2" ]
        [ Badge.new
            |> Badge.text "Verified"
            |> Badge.secondary
            |> Badge.startIcon (Phosphor.sealCheck Regular |> Phosphor.toHtml [])
            |> Badge.toHtml []
        , Badge.new
            |> Badge.text "Bookmark"
            |> Badge.outline
            |> Badge.endIcon (Phosphor.bookmarkSimple Regular |> Phosphor.toHtml [])
            |> Badge.toHtml []
        ]


{-| `toAnchor` renders an `<a>` instead of a `<span>`. Links get a hover state.
-}
asLink : Html msg
asLink =
    Badge.new
        |> Badge.text "Open Link"
        |> Badge.endIcon (Phosphor.arrowUpRight Regular |> Phosphor.toHtml [])
        |> Badge.toAnchor [ href "#link" ]


withSpinner : Html msg
withSpinner =
    div [ class "flex flex-wrap gap-2" ]
        [ Badge.new
            |> Badge.text "Deleting"
            |> Badge.destructive
            |> Badge.startIcon (Spinner.view [])
            |> Badge.toHtml []
        , Badge.new
            |> Badge.text "Generating"
            |> Badge.secondary
            |> Badge.endIcon (Spinner.view [])
            |> Badge.toHtml []
        ]


{-| The attributes come after the styles, so classes can override the colors.
-}
customColors : Html msg
customColors =
    div [ class "flex flex-wrap gap-2" ]
        [ Badge.new
            |> Badge.text "Blue"
            |> Badge.toHtml [ class "bg-blue-50 text-blue-700 dark:bg-blue-950 dark:text-blue-300" ]
        , Badge.new
            |> Badge.text "Green"
            |> Badge.toHtml [ class "bg-green-50 text-green-700 dark:bg-green-950 dark:text-green-300" ]
        , Badge.new
            |> Badge.text "Sky"
            |> Badge.toHtml [ class "bg-sky-50 text-sky-700 dark:bg-sky-950 dark:text-sky-300" ]
        , Badge.new
            |> Badge.text "Purple"
            |> Badge.toHtml [ class "bg-purple-50 text-purple-700 dark:bg-purple-950 dark:text-purple-300" ]
        , Badge.new
            |> Badge.text "Red"
            |> Badge.toHtml [ class "bg-red-50 text-red-700 dark:bg-red-950 dark:text-red-300" ]
        ]


rtl : Html msg
rtl =
    div [ class "flex w-full flex-wrap justify-center gap-2", dir "rtl" ]
        [ Badge.new
            |> Badge.text "شارة"
            |> Badge.toHtml []
        , Badge.new
            |> Badge.text "ثانوي"
            |> Badge.secondary
            |> Badge.toHtml []
        , Badge.new
            |> Badge.text "مدمر"
            |> Badge.destructive
            |> Badge.toHtml []
        , Badge.new
            |> Badge.text "مخطط"
            |> Badge.outline
            |> Badge.toHtml []
        , Badge.new
            |> Badge.text "متحقق"
            |> Badge.secondary
            |> Badge.startIcon (Phosphor.sealCheck Regular |> Phosphor.toHtml [])
            |> Badge.toHtml []
        , Badge.new
            |> Badge.text "إشارة مرجعية"
            |> Badge.outline
            |> Badge.endIcon (Phosphor.bookmarkSimple Regular |> Phosphor.toHtml [])
            |> Badge.toHtml []
        ]
