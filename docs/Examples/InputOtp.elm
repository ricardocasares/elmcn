module Examples.InputOtp exposing (..)

import Html exposing (Html, a, div, span, text)
import Html.Attributes exposing (class, dir, for, href, id, required, type_)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.Button as Button
import UI.Card as Card
import UI.Field as Field
import UI.InputOtp as InputOtp


demo : State -> Html State.Msg
demo state =
    InputOtp.new
        |> InputOtp.value (State.get "demo" state |> Maybe.withDefault "123456")
        |> InputOtp.onChange (State.set "demo")
        |> InputOtp.group [] 6
        |> InputOtp.toHtml []


{-| Use `digits`, `letters` or `alphanumeric` to restrict the characters the input accepts.
-}
pattern : State -> Html State.Msg
pattern state =
    Field.view [ class "w-fit" ]
        [ Field.label [ for "digits-only" ] [ text "Digits Only" ]
        , InputOtp.new
            |> InputOtp.value (State.get "pattern" state |> Maybe.withDefault "")
            |> InputOtp.onChange (State.set "pattern")
            |> InputOtp.group [] 6
            |> InputOtp.digits
            |> InputOtp.toHtml [ id "digits-only" ]
        ]


{-| Use `separator` to add a separator between groups.
-}
separator : State -> Html State.Msg
separator state =
    InputOtp.new
        |> InputOtp.value (State.get "separator" state |> Maybe.withDefault "")
        |> InputOtp.onChange (State.set "separator")
        |> InputOtp.group [] 2
        |> InputOtp.separator []
        |> InputOtp.group [] 2
        |> InputOtp.separator []
        |> InputOtp.group [] 2
        |> InputOtp.toHtml []


{-| Use `disabled` to disable the input.
-}
disabled : State -> Html State.Msg
disabled state =
    InputOtp.new
        |> InputOtp.value (State.get "disabled" state |> Maybe.withDefault "123456")
        |> InputOtp.onChange (State.set "disabled")
        |> InputOtp.group [] 3
        |> InputOtp.separator []
        |> InputOtp.group [] 3
        |> InputOtp.disabled
        |> InputOtp.toHtml [ id "disabled" ]


{-| The value lives in your model, so anything can show it.
-}
controlled : State -> Html State.Msg
controlled state =
    let
        code =
            State.get "controlled" state |> Maybe.withDefault ""
    in
    div [ class "space-y-2" ]
        [ InputOtp.new
            |> InputOtp.value code
            |> InputOtp.onChange (State.set "controlled")
            |> InputOtp.group [] 6
            |> InputOtp.toHtml []
        , div [ class "text-center text-sm" ]
            [ if code == "" then
                text "Enter your one-time password."

              else
                text ("You entered: " ++ code)
            ]
        ]


{-| Use `invalid` to show an error state.
-}
invalid : State -> Html State.Msg
invalid state =
    InputOtp.new
        |> InputOtp.value (State.get "invalid" state |> Maybe.withDefault "000000")
        |> InputOtp.onChange (State.set "invalid")
        |> InputOtp.group [] 2
        |> InputOtp.separator []
        |> InputOtp.group [] 2
        |> InputOtp.separator []
        |> InputOtp.group [] 2
        |> InputOtp.invalid
        |> InputOtp.toHtml []


{-| A common pattern for PIN codes. This uses `digits`.
-}
fourDigits : State -> Html State.Msg
fourDigits state =
    InputOtp.new
        |> InputOtp.value (State.get "four-digits" state |> Maybe.withDefault "")
        |> InputOtp.onChange (State.set "four-digits")
        |> InputOtp.group [] 4
        |> InputOtp.digits
        |> InputOtp.toHtml []


{-| Use `alphanumeric` to accept both letters and numbers.
-}
alphanumeric : State -> Html State.Msg
alphanumeric state =
    InputOtp.new
        |> InputOtp.value (State.get "alphanumeric" state |> Maybe.withDefault "")
        |> InputOtp.onChange (State.set "alphanumeric")
        |> InputOtp.group [] 3
        |> InputOtp.separator []
        |> InputOtp.group [] 3
        |> InputOtp.alphanumeric
        |> InputOtp.toHtml []


form : State -> Html State.Msg
form state =
    let
        large =
            class "*:data-[slot=input-otp-slot]:h-12 *:data-[slot=input-otp-slot]:w-11 *:data-[slot=input-otp-slot]:text-xl"
    in
    Card.new
        |> Card.title [ text "Verify your login" ]
        |> Card.description
            [ text "Enter the verification code we sent to your email address: "
            , span [ class "font-medium" ] [ text "m@example.com" ]
            , text "."
            ]
        |> Card.content []
            [ Field.view []
                [ div [ class "flex items-center justify-between" ]
                    [ Field.label [ for "otp-verification" ] [ text "Verification code" ]
                    , Button.new
                        |> Button.text "Resend Code"
                        |> Button.startIcon (Phosphor.arrowClockwise Regular |> Phosphor.toHtml [])
                        |> Button.outline
                        |> Button.extraSmall
                        |> Button.toHtml []
                    ]
                , InputOtp.new
                    |> InputOtp.value (State.get "form" state |> Maybe.withDefault "")
                    |> InputOtp.onChange (State.set "form")
                    |> InputOtp.group [ large ] 3
                    |> InputOtp.separator [ class "mx-2" ]
                    |> InputOtp.group [ large ] 3
                    |> InputOtp.toHtml [ id "otp-verification", required True ]
                , Field.description []
                    [ a [ href "#" ] [ text "I no longer have access to this email address." ] ]
                ]
            ]
        |> Card.footer []
            [ Field.view []
                [ Button.new
                    |> Button.text "Verify"
                    |> Button.toHtml [ type_ "submit", class "w-full" ]
                , div [ class "text-sm text-muted-foreground" ]
                    [ text "Having trouble signing in? "
                    , a [ href "#", class "underline underline-offset-4 transition-colors hover:text-primary" ]
                        [ text "Contact support" ]
                    ]
                ]
            ]
        |> Card.toHtml [ class "mx-auto max-w-md" ]


{-| Set `dir "rtl"` on a parent element for right-to-left languages.
-}
rtl : State -> Html State.Msg
rtl state =
    Field.view [ class "mx-auto max-w-xs", dir "rtl" ]
        [ Field.label [ for "input-otp-rtl" ] [ text "رمز التحقق" ]
        , InputOtp.new
            |> InputOtp.value (State.get "rtl" state |> Maybe.withDefault "123456")
            |> InputOtp.onChange (State.set "rtl")
            |> InputOtp.group [] 6
            |> InputOtp.toHtml [ id "input-otp-rtl" ]
        ]
