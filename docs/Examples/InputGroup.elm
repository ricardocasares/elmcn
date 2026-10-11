module Examples.InputGroup exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (attribute, class, dir, for, id, placeholder, readonly, type_)
import Html.Events exposing (onClick)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import Svg.Attributes
import UI.Button as Button
import UI.Field as Field
import UI.InputGroup as InputGroup
import UI.Kbd as Kbd
import UI.Spinner as Spinner


demo : Html msg
demo =
    InputGroup.view [ class "max-w-xs" ]
        [ InputGroup.input [ placeholder "Search..." ]
        , InputGroup.start [] [ Phosphor.magnifyingGlass Regular |> Phosphor.toHtml [] ]
        , InputGroup.end [] [ text "12 results" ]
        ]


{-| `start` places the addon at the start of the input.
-}
inlineStart : Html msg
inlineStart =
    Field.view [ class "max-w-sm" ]
        [ Field.label [ for "inline-start-input" ] [ text "Input" ]
        , InputGroup.view []
            [ InputGroup.input [ id "inline-start-input", placeholder "Search..." ]
            , InputGroup.start [] [ Phosphor.magnifyingGlass Regular |> Phosphor.toHtml [] ]
            ]
        , Field.description [] [ text "Icon positioned at the start." ]
        ]


{-| `end` places the addon at the end of the input.
-}
inlineEnd : Html msg
inlineEnd =
    Field.view [ class "max-w-sm" ]
        [ Field.label [ for "inline-end-input" ] [ text "Input" ]
        , InputGroup.view []
            [ InputGroup.input [ id "inline-end-input", type_ "password", placeholder "Enter password" ]
            , InputGroup.end [] [ Phosphor.eyeSlash Regular |> Phosphor.toHtml [] ]
            ]
        , Field.description [] [ text "Icon positioned at the end." ]
        ]


{-| `top` places the addon above the control.
-}
blockStart : Html msg
blockStart =
    Field.group [ class "max-w-sm" ]
        [ Field.view []
            [ Field.label [ for "block-start-input" ] [ text "Input" ]
            , InputGroup.view []
                [ InputGroup.input [ id "block-start-input", placeholder "Enter your name" ]
                , InputGroup.top [] [ InputGroup.text [] [ text "Full Name" ] ]
                ]
            , Field.description [] [ text "Header positioned above the input." ]
            ]
        , Field.view []
            [ Field.label [ for "block-start-textarea" ] [ text "Textarea" ]
            , InputGroup.view []
                [ InputGroup.textarea [ id "block-start-textarea", placeholder "console.log('Hello, world!');", class "font-mono text-sm" ]
                , InputGroup.top []
                    [ Phosphor.fileCode Regular |> Phosphor.toHtml []
                    , InputGroup.text [ class "font-mono" ] [ text "script.js" ]
                    , InputGroup.button
                        |> Button.icon (Phosphor.copy Regular |> Phosphor.toHtml [])
                        |> Button.label "Copy"
                        |> Button.toHtml [ class "ms-auto" ]
                    ]
                ]
            , Field.description [] [ text "Header positioned above the textarea." ]
            ]
        ]


{-| `bottom` places the addon below the control.
-}
blockEnd : Html msg
blockEnd =
    Field.group [ class "max-w-sm" ]
        [ Field.view []
            [ Field.label [ for "block-end-input" ] [ text "Input" ]
            , InputGroup.view []
                [ InputGroup.input [ id "block-end-input", placeholder "Enter amount" ]
                , InputGroup.bottom [] [ InputGroup.text [] [ text "USD" ] ]
                ]
            , Field.description [] [ text "Footer positioned below the input." ]
            ]
        , Field.view []
            [ Field.label [ for "block-end-textarea" ] [ text "Textarea" ]
            , InputGroup.view []
                [ InputGroup.textarea [ id "block-end-textarea", placeholder "Write a comment..." ]
                , InputGroup.bottom []
                    [ InputGroup.text [] [ text "0/280" ]
                    , Button.new
                        |> Button.text "Post"
                        |> Button.small
                        |> Button.toHtml [ class "ms-auto" ]
                    ]
                ]
            , Field.description [] [ text "Footer positioned below the textarea." ]
            ]
        ]


icon : Html msg
icon =
    div [ class "grid w-full max-w-sm gap-6" ]
        [ InputGroup.view []
            [ InputGroup.input [ placeholder "Search..." ]
            , InputGroup.start [] [ Phosphor.magnifyingGlass Regular |> Phosphor.toHtml [] ]
            ]
        , InputGroup.view []
            [ InputGroup.input [ type_ "email", placeholder "Enter your email" ]
            , InputGroup.start [] [ Phosphor.envelope Regular |> Phosphor.toHtml [] ]
            ]
        , InputGroup.view []
            [ InputGroup.input [ placeholder "Card number" ]
            , InputGroup.start [] [ Phosphor.creditCard Regular |> Phosphor.toHtml [] ]
            , InputGroup.end [] [ Phosphor.check Regular |> Phosphor.toHtml [] ]
            ]
        , InputGroup.view []
            [ InputGroup.input [ placeholder "Card number" ]
            , InputGroup.end []
                [ Phosphor.star Regular |> Phosphor.toHtml []
                , Phosphor.info Regular |> Phosphor.toHtml []
                ]
            ]
        ]


textAddon : Html msg
textAddon =
    div [ class "grid w-full max-w-sm gap-6" ]
        [ InputGroup.view []
            [ InputGroup.start [] [ InputGroup.text [] [ text "$" ] ]
            , InputGroup.input [ placeholder "0.00" ]
            , InputGroup.end [] [ InputGroup.text [] [ text "USD" ] ]
            ]
        , InputGroup.view []
            [ InputGroup.start [] [ InputGroup.text [] [ text "https://" ] ]
            , InputGroup.input [ placeholder "example.com", class "ps-0.5!" ]
            , InputGroup.end [] [ InputGroup.text [] [ text ".com" ] ]
            ]
        , InputGroup.view []
            [ InputGroup.input [ placeholder "Enter your username" ]
            , InputGroup.end [] [ InputGroup.text [] [ text "@company.com" ] ]
            ]
        , InputGroup.view []
            [ InputGroup.textarea [ placeholder "Enter your message" ]
            , InputGroup.bottom [] [ InputGroup.text [ class "text-xs text-muted-foreground" ] [ text "120 characters left" ] ]
            ]
        ]


{-| `InputGroup.button` is a ghost, extra small button. Give it an `icon` for a square one, or any other `Button` variant. The copy and favorite buttons here toggle through the example's state.
-}
button : State -> Html State.Msg
button state =
    let
        copied =
            State.get "input-group-copied" state == Just "true"

        favorite =
            State.get "input-group-favorite" state == Just "true"

        toggle key on =
            State.set key
                (if on then
                    "false"

                 else
                    "true"
                )
    in
    div [ class "grid w-full max-w-sm gap-6" ]
        [ InputGroup.view []
            [ InputGroup.input [ placeholder "https://x.com/shadcn", readonly True ]
            , InputGroup.end []
                [ InputGroup.button
                    |> Button.icon
                        (if copied then
                            Phosphor.check Regular |> Phosphor.toHtml []

                         else
                            Phosphor.copy Regular |> Phosphor.toHtml []
                        )
                    |> Button.label "Copy"
                    |> Button.toHtml [ onClick (toggle "input-group-copied" copied) ]
                ]
            ]
        , InputGroup.view [ class "[--radius:9999px]" ]
            [ InputGroup.start []
                [ InputGroup.button
                    |> Button.icon (Phosphor.info Regular |> Phosphor.toHtml [])
                    |> Button.label "Your connection is not secure"
                    |> Button.secondary
                    |> Button.rounded
                    |> Button.toHtml []
                ]
            , InputGroup.start [ class "ps-1.5 text-muted-foreground" ] [ text "https://" ]
            , InputGroup.input [ attribute "aria-label" "URL" ]
            , InputGroup.end []
                [ InputGroup.button
                    |> Button.icon
                        (Phosphor.star
                            (if favorite then
                                Fill

                             else
                                Regular
                            )
                            |> Phosphor.toHtml
                                [ Svg.Attributes.class
                                    (if favorite then
                                        "text-blue-600"

                                     else
                                        ""
                                    )
                                ]
                        )
                    |> Button.label "Favorite"
                    |> Button.toHtml [ onClick (toggle "input-group-favorite" favorite) ]
                ]
            ]
        , InputGroup.view []
            [ InputGroup.input [ placeholder "Type to search..." ]
            , InputGroup.end []
                [ InputGroup.button
                    |> Button.text "Search"
                    |> Button.secondary
                    |> Button.toHtml []
                ]
            ]
        ]


kbd : Html msg
kbd =
    InputGroup.view [ class "max-w-sm" ]
        [ InputGroup.input [ placeholder "Search..." ]
        , InputGroup.start [] [ Phosphor.magnifyingGlass Regular |> Phosphor.toHtml [] ]
        , InputGroup.end []
            [ Kbd.new
                |> Kbd.key "⌘K"
                |> Kbd.toHtml []
            ]
        ]


spinner : Html msg
spinner =
    div [ class "grid w-full max-w-sm gap-4" ]
        [ InputGroup.view []
            [ InputGroup.input [ placeholder "Searching..." ]
            , InputGroup.end [] [ Spinner.view [] ]
            ]
        , InputGroup.view []
            [ InputGroup.input [ placeholder "Processing..." ]
            , InputGroup.start [] [ Spinner.view [] ]
            ]
        , InputGroup.view []
            [ InputGroup.input [ placeholder "Saving changes..." ]
            , InputGroup.end []
                [ InputGroup.text [] [ text "Saving..." ]
                , Spinner.view []
                ]
            ]
        , InputGroup.view []
            [ InputGroup.input [ placeholder "Refreshing data..." ]
            , InputGroup.start [] [ Phosphor.circleNotch Regular |> Phosphor.toHtml [ Svg.Attributes.class "animate-spin" ] ]
            , InputGroup.end [] [ InputGroup.text [ class "text-muted-foreground" ] [ text "Please wait..." ] ]
            ]
        ]


{-| A `top` addon with `border-b` and a `bottom` addon with `border-t` make a header and a footer.
-}
textarea : Html msg
textarea =
    div [ class "grid w-full max-w-md gap-4" ]
        [ InputGroup.view []
            [ InputGroup.textarea [ id "textarea-code-32", placeholder "console.log('Hello, world!');", class "min-h-[200px]" ]
            , InputGroup.bottom [ class "border-t" ]
                [ InputGroup.text [] [ text "Line 1, Column 1" ]
                , Button.new
                    |> Button.text "Run"
                    |> Button.endIcon (Phosphor.arrowElbowDownLeft Regular |> Phosphor.toHtml [])
                    |> Button.small
                    |> Button.toHtml [ class "ms-auto" ]
                ]
            , InputGroup.top [ class "border-b" ]
                [ InputGroup.text [ class "font-mono font-medium" ]
                    [ Phosphor.fileJs Regular |> Phosphor.toHtml []
                    , text "script.js"
                    ]
                , InputGroup.button
                    |> Button.icon (Phosphor.arrowClockwise Regular |> Phosphor.toHtml [])
                    |> Button.label "Refresh"
                    |> Button.toHtml [ class "ms-auto" ]
                , InputGroup.button
                    |> Button.icon (Phosphor.copy Regular |> Phosphor.toHtml [])
                    |> Button.label "Copy"
                    |> Button.toHtml []
                ]
            ]
        ]


{-| Any element with `data-slot="input-group-control"` gets the group's focus and error handling, so a control of your own fits in.
-}
customInput : Html msg
customInput =
    div [ class "grid w-full max-w-sm gap-6" ]
        [ InputGroup.view []
            [ Html.textarea
                [ attribute "data-slot" "input-group-control"
                , class "flex field-sizing-content min-h-16 w-full resize-none rounded-md bg-transparent px-3 py-2.5 text-base transition-[color,box-shadow] outline-none md:text-sm"
                , placeholder "Autoresize textarea..."
                ]
                []
            , InputGroup.bottom []
                [ Button.new
                    |> Button.text "Submit"
                    |> Button.small
                    |> Button.toHtml [ class "ms-auto" ]
                ]
            ]
        ]


rtl : Html msg
rtl =
    div [ class "grid w-full max-w-sm gap-6", dir "rtl" ]
        [ InputGroup.view [ class "max-w-xs" ]
            [ InputGroup.input [ placeholder "بحث..." ]
            , InputGroup.start [] [ Phosphor.magnifyingGlass Regular |> Phosphor.toHtml [] ]
            , InputGroup.end [] [ text "١٢ نتيجة" ]
            ]
        , InputGroup.view []
            [ InputGroup.input [ placeholder "جاري البحث..." ]
            , InputGroup.end [] [ Spinner.view [] ]
            ]
        , InputGroup.view []
            [ InputGroup.input [ placeholder "جاري حفظ التغييرات..." ]
            , InputGroup.end []
                [ InputGroup.text [] [ text "جاري الحفظ..." ]
                , Spinner.view []
                ]
            ]
        , Field.group [ class "max-w-sm" ]
            [ Field.view []
                [ Field.label [ for "rtl-textarea" ] [ text "منطقة النص" ]
                , InputGroup.view []
                    [ InputGroup.textarea [ id "rtl-textarea", placeholder "اكتب تعليقًا..." ]
                    , InputGroup.bottom []
                        [ InputGroup.text [] [ text "٠/٢٨٠" ]
                        , Button.new
                            |> Button.text "نشر"
                            |> Button.small
                            |> Button.toHtml [ class "ms-auto" ]
                        ]
                    ]
                , Field.description [] [ text "تذييل موضع أسفل منطقة النص." ]
                ]
            ]
        ]
