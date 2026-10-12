module Examples.Popover exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, dir, for, id, value)
import UI.Button as Button
import UI.Field as Field
import UI.Input as Input
import UI.Label as Label
import UI.Popover as Popover


demo : Html msg
demo =
    let
        field key label default =
            div [ class "grid grid-cols-3 items-center gap-4" ]
                [ Label.view [ for key ] [ text label ]
                , Input.view [ id key, value default, class "col-span-2 h-8" ]
                ]
    in
    Popover.new
        |> Popover.id "dimensions"
        |> Popover.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Open popover" ]
        |> Popover.title [ text "Dimensions" ]
        |> Popover.description [ text "Set the dimensions for the layer." ]
        |> Popover.content
            [ div [ class "grid gap-2" ]
                [ field "width" "Width" "100%"
                , field "max-width" "Max. width" "300px"
                , field "height" "Height" "25px"
                , field "max-height" "Max. height" "none"
                ]
            ]
        |> Popover.toHtml [ class "w-80" ]


{-| A simple popover with a header, title, and description.
-}
basic : Html msg
basic =
    Popover.new
        |> Popover.id "basic"
        |> Popover.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Open Popover" ]
        |> Popover.title [ text "Dimensions" ]
        |> Popover.description [ text "Set the dimensions for the layer." ]
        |> Popover.alignStart
        |> Popover.toHtml []


{-| Use `alignStart` and `alignEnd` on the popover to control the horizontal alignment.
-}
align : Html msg
align =
    let
        popover key label place =
            Popover.new
                |> Popover.id ("align-" ++ key)
                |> Popover.trigger
                    (Button.new
                        |> Button.outline
                        |> Button.small
                        |> Button.toAttributes
                    )
                    [ text label ]
                |> Popover.content [ text ("Aligned to " ++ key) ]
                |> place
                |> Popover.toHtml [ class "w-40" ]
    in
    div [ class "flex gap-6" ]
        [ popover "start" "Start" Popover.alignStart
        , popover "center" "Center" identity
        , popover "end" "End" Popover.alignEnd
        ]


{-| A popover with form fields inside.
-}
withForm : Html msg
withForm =
    let
        field key label default =
            Field.horizontal []
                [ Field.label [ for key, class "w-1/2" ] [ text label ]
                , Input.view [ id key, value default ]
                ]
    in
    Popover.new
        |> Popover.id "form"
        |> Popover.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Open Popover" ]
        |> Popover.title [ text "Dimensions" ]
        |> Popover.description [ text "Set the dimensions for the layer." ]
        |> Popover.content
            [ Field.group [ class "gap-4" ]
                [ field "form-width" "Width" "100%"
                , field "form-height" "Height" "25px"
                ]
            ]
        |> Popover.alignStart
        |> Popover.toHtml [ class "w-64" ]


{-| `left` and `right` are physical sides and stay put in right-to-left text, while `inlineStart` and `inlineEnd` follow the text direction.
-}
rtl : Html msg
rtl =
    let
        popover key label place =
            Popover.new
                |> Popover.id ("rtl-" ++ key)
                |> Popover.trigger
                    (Button.new
                        |> Button.outline
                        |> Button.toAttributes
                    )
                    [ text label ]
                |> Popover.title [ text "الأبعاد" ]
                |> Popover.description [ text "تعيين الأبعاد للطبقة." ]
                |> place
                |> Popover.toHtml []
    in
    div [ class "grid gap-4", dir "rtl" ]
        [ div [ class "flex flex-wrap justify-center gap-2" ]
            [ popover "left" "يسار" Popover.left
            , popover "top" "أعلى" Popover.top
            , popover "bottom" "أسفل" identity
            , popover "right" "يمين" Popover.right
            ]
        , div [ class "flex flex-wrap justify-center gap-2" ]
            [ popover "inline-start" "بداية السطر" Popover.inlineStart
            , popover "inline-end" "نهاية السطر" Popover.inlineEnd
            ]
        ]
