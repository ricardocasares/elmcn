module Examples.Input exposing (..)

import Html exposing (Html, div, p, text)
import Html.Attributes exposing (attribute, class, disabled, for, id, placeholder, type_, value)
import State exposing (State)
import UI.Button as Button
import UI.Input as Input
import UI.Label as Label
import UI.NativeSelect as NativeSelect
import UI.Select as Select


demo : Html msg
demo =
    Input.view [ class "max-w-sm", type_ "email", placeholder "Email" ]


{-| Set `aria-invalid` to show the error state.
-}
invalid : Html msg
invalid =
    Input.view [ class "max-w-sm", placeholder "Error", attribute "aria-invalid" "true" ]


{-| Point the label's `for` at the input's `id` to link them.
-}
withLabel : Html msg
withLabel =
    div [ class "grid w-full max-w-sm gap-2" ]
        [ Label.view [ for "input-email" ] [ text "Email" ]
        , Input.view [ id "input-email", type_ "email", placeholder "name@example.com" ]
        ]


withDescription : Html msg
withDescription =
    div [ class "grid w-full max-w-sm gap-2" ]
        [ Label.view [ for "input-username" ] [ text "Username" ]
        , Input.view [ id "input-username", placeholder "Enter your username" ]
        , p [ class "text-sm text-muted-foreground" ] [ text "Choose a unique username for your account." ]
        ]


disabledInput : Html msg
disabledInput =
    div [ class "grid w-full max-w-sm gap-2" ]
        [ Label.view [ for "input-disabled" ] [ text "Email" ]
        , Input.view [ id "input-disabled", type_ "email", placeholder "Email", disabled True ]
        ]


{-| The input styles every native `type_`, including `file`, `date` and `time`.
-}
inputTypes : Html msg
inputTypes =
    let
        field key label attrs =
            div [ class "grid gap-2" ]
                [ Label.view [ for ("input-" ++ key) ] [ text label ]
                , Input.view (id ("input-" ++ key) :: attrs)
                ]
    in
    div [ class "grid w-full max-w-sm gap-6" ]
        [ field "password" "Password" [ type_ "password", placeholder "Password" ]
        , field "tel" "Phone" [ type_ "tel", placeholder "+1 (555) 123-4567" ]
        , field "url" "URL" [ type_ "url", placeholder "https://example.com" ]
        , field "search" "Search" [ type_ "search", placeholder "Search" ]
        , field "number" "Number" [ type_ "number", placeholder "123" ]
        , field "date" "Date" [ type_ "date" ]
        , field "time" "Time" [ type_ "time" ]
        , field "file" "File" [ type_ "file" ]
        ]


withSelect : State -> Html State.Msg
withSelect state =
    div [ class "flex w-full max-w-sm gap-2" ]
        [ Input.view [ class "flex-1", placeholder "Enter amount" ]
        , Select.new
            |> Select.id "input-currency"
            |> Select.onSelect (State.set "input-currency")
            |> Select.value (Just (State.get "input-currency" state |> Maybe.withDefault "usd"))
            |> Select.items
                [ Select.item "usd" [ text "USD" ]
                , Select.item "eur" [ text "EUR" ]
                , Select.item "gbp" [ text "GBP" ]
                ]
            |> Select.toHtml [ class "w-32" ]
        ]


withButton : Html msg
withButton =
    div [ class "flex w-full max-w-sm gap-2" ]
        [ Input.view [ class "flex-1", type_ "search", placeholder "Search..." ]
        , Button.new
            |> Button.text "Search"
            |> Button.toHtml []
        ]


withNativeSelect : Html msg
withNativeSelect =
    div [ class "flex w-full max-w-sm gap-2" ]
        [ Input.view [ class "flex-1", type_ "tel", placeholder "(555) 123-4567" ]
        , NativeSelect.new
            |> NativeSelect.options
                [ NativeSelect.option [ value "+1" ] [ text "+1" ]
                , NativeSelect.option [ value "+44" ] [ text "+44" ]
                , NativeSelect.option [ value "+46" ] [ text "+46" ]
                ]
            |> NativeSelect.toHtml []
        ]


form : State -> Html State.Msg
form state =
    let
        field key label attrs =
            div [ class "grid gap-2" ]
                [ Label.view [ for ("form-" ++ key) ] [ text label ]
                , Input.view (id ("form-" ++ key) :: attrs)
                ]
    in
    Html.form [ class "grid w-full max-w-sm gap-6" ]
        [ field "name" "Name" [ placeholder "John Doe" ]
        , div [ class "grid gap-2" ]
            [ Label.view [ for "form-email" ] [ text "Email" ]
            , Input.view [ id "form-email", type_ "email", placeholder "john@example.com" ]
            , p [ class "text-sm text-muted-foreground" ] [ text "We'll never share your email with anyone." ]
            ]
        , div [ class "grid grid-cols-2 gap-4" ]
            [ field "phone" "Phone" [ type_ "tel", placeholder "+1 (555) 123-4567" ]
            , div [ class "grid gap-2" ]
                [ Label.view [ for "form-country" ] [ text "Country" ]
                , Select.new
                    |> Select.id "form-country"
                    |> Select.onSelect (State.set "form-country")
                    |> Select.value (Just (State.get "form-country" state |> Maybe.withDefault "us"))
                    |> Select.items
                        [ Select.item "us" [ text "United States" ]
                        , Select.item "uk" [ text "United Kingdom" ]
                        , Select.item "ca" [ text "Canada" ]
                        ]
                    |> Select.toHtml [ class "w-full" ]
                ]
            ]
        , field "address" "Address" [ placeholder "123 Main St" ]
        , div [ class "flex gap-2" ]
            [ Button.new
                |> Button.text "Cancel"
                |> Button.outline
                |> Button.toHtml [ type_ "button" ]
            , Button.new
                |> Button.text "Submit"
                |> Button.toHtml [ type_ "submit" ]
            ]
        ]
