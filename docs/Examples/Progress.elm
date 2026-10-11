module Examples.Progress exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, dir)
import UI.Progress as Progress


demo : Html msg
demo =
    Progress.new 56
        |> Progress.label [ text "Upload progress" ]
        |> Progress.value
        |> Progress.toHtml [ class "w-full max-w-sm" ]


{-| A bare track and indicator. Size it with width classes.
-}
basic : Html msg
basic =
    Progress.new 33
        |> Progress.toHtml [ class "w-full max-w-sm" ]


{-| `label` and `value` sit above the track. `formatValue` replaces the default percentage text.
-}
withLabel : Html msg
withLabel =
    div [ class "flex w-full max-w-sm flex-col gap-6" ]
        [ Progress.new 25
            |> Progress.label [ text "Downloading" ]
            |> Progress.value
            |> Progress.toHtml []
        , Progress.new 70
            |> Progress.label [ text "Files" ]
            |> Progress.formatValue (\p -> String.fromFloat p ++ " of 100")
            |> Progress.toHtml []
        ]


{-| The indicator width comes from `--progress-value`, so classes on the root can restyle the slots.
-}
customColors : Html msg
customColors =
    div [ class "flex w-full max-w-sm flex-col gap-6" ]
        [ Progress.new 80
            |> Progress.toHtml [ class "[&_[data-slot=progress-indicator]]:bg-green-600" ]
        , Progress.new 45
            |> Progress.toHtml [ class "[&_[data-slot=progress-track]]:h-3 [&_[data-slot=progress-indicator]]:bg-amber-500" ]
        ]


rtl : Html msg
rtl =
    Progress.new 56
        |> Progress.label [ text "تقدم الرفع" ]
        |> Progress.value
        |> Progress.toHtml [ class "w-full max-w-sm", dir "rtl" ]
