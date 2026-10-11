module Examples.Input exposing (..)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (attribute, class, dir, disabled, for, id, placeholder, required, type_)
import State exposing (State)
import UI.Badge as Badge
import UI.Button as Button
import UI.Field as Field
import UI.Input as Input
import UI.Select as Select


demo : Html msg
demo =
    Field.view [ class "max-w-sm" ]
        [ Field.label [ for "input-api-key" ] [ text "API Key" ]
        , Input.view [ id "input-api-key", type_ "password", placeholder "sk-..." ]
        , Field.description [] [ text "Your API key is encrypted and stored securely." ]
        ]


basic : Html msg
basic =
    Input.view [ class "max-w-sm", placeholder "Enter text" ]


{-| Put the input in a `Field` with a label and a description. Point the label's `for` at the input's `id`.
-}
field : Html msg
field =
    Field.view [ class "max-w-sm" ]
        [ Field.label [ for "input-username" ] [ text "Username" ]
        , Input.view [ id "input-username", placeholder "Enter your username" ]
        , Field.description [] [ text "Choose a unique username for your account." ]
        ]


{-| A `Field.group` spaces out several fields.
-}
fieldGroup : Html msg
fieldGroup =
    Field.group [ class "max-w-sm" ]
        [ Field.view []
            [ Field.label [ for "input-group-name" ] [ text "Name" ]
            , Input.view [ id "input-group-name", placeholder "Jordan Lee" ]
            ]
        , Field.view []
            [ Field.label [ for "input-group-email" ] [ text "Email" ]
            , Input.view [ id "input-group-email", type_ "email", placeholder "name@example.com" ]
            , Field.description [] [ text "We'll send updates to this address." ]
            ]
        , Field.horizontal []
            [ Button.new
                |> Button.text "Reset"
                |> Button.outline
                |> Button.toHtml [ type_ "reset" ]
            , Button.new
                |> Button.text "Submit"
                |> Button.toHtml [ type_ "submit" ]
            ]
        ]


{-| `Field.disabled` dims the label to match the disabled input.
-}
disabledInput : Html msg
disabledInput =
    Field.view [ Field.disabled, class "max-w-sm" ]
        [ Field.label [ for "input-disabled" ] [ text "Email" ]
        , Input.view [ id "input-disabled", type_ "email", placeholder "Email", disabled True ]
        , Field.description [] [ text "This field is currently disabled." ]
        ]


{-| Set `aria-invalid` on the input and `Field.invalid` on the field to show the error state.
-}
invalid : Html msg
invalid =
    Field.view [ Field.invalid, class "max-w-sm" ]
        [ Field.label [ for "input-invalid" ] [ text "Invalid Input" ]
        , Input.view [ id "input-invalid", placeholder "Error", attribute "aria-invalid" "true" ]
        , Field.description [] [ text "This field contains validation errors." ]
        ]


file : Html msg
file =
    Field.view [ class "max-w-sm" ]
        [ Field.label [ for "input-picture" ] [ text "Picture" ]
        , Input.view [ id "input-picture", type_ "file" ]
        , Field.description [] [ text "Select a picture to upload." ]
        ]


{-| A `Field.horizontal` puts the input and a button on one line.
-}
inline : Html msg
inline =
    Field.horizontal [ class "max-w-sm" ]
        [ Input.view [ type_ "search", placeholder "Search..." ]
        , Button.new
            |> Button.text "Search"
            |> Button.toHtml []
        ]


{-| A `Field.group` can be a grid.
-}
grid : Html msg
grid =
    Field.group [ class "grid max-w-sm grid-cols-2" ]
        [ Field.view []
            [ Field.label [ for "input-first-name" ] [ text "First Name" ]
            , Input.view [ id "input-first-name", placeholder "Jordan" ]
            ]
        , Field.view []
            [ Field.label [ for "input-last-name" ] [ text "Last Name" ]
            , Input.view [ id "input-last-name", placeholder "Lee" ]
            ]
        ]


requiredInput : Html msg
requiredInput =
    Field.view [ class "max-w-sm" ]
        [ Field.label [ for "input-required" ]
            [ text "Required Field "
            , span [ class "text-destructive" ] [ text "*" ]
            ]
        , Input.view [ id "input-required", placeholder "This field is required", required True ]
        , Field.description [] [ text "This field must be filled out." ]
        ]


{-| The label is a flex row, so `ml-auto` pushes a badge to its end.
-}
badge : Html msg
badge =
    Field.view [ class "max-w-sm" ]
        [ Field.label [ for "input-webhook" ]
            [ text "Webhook URL"
            , Badge.new
                |> Badge.text "Beta"
                |> Badge.secondary
                |> Badge.toHtml [ class "ml-auto" ]
            ]
        , Input.view [ id "input-webhook", type_ "url", placeholder "https://api.example.com/webhook" ]
        ]


form : State -> Html State.Msg
form state =
    Html.form [ class "w-full max-w-sm" ]
        [ Field.group []
            [ Field.view []
                [ Field.label [ for "input-form-name" ] [ text "Name" ]
                , Input.view [ id "input-form-name", placeholder "Evil Rabbit", required True ]
                ]
            , Field.view []
                [ Field.label [ for "input-form-email" ] [ text "Email" ]
                , Input.view [ id "input-form-email", type_ "email", placeholder "john@example.com" ]
                , Field.description [] [ text "We'll never share your email with anyone." ]
                ]
            , div [ class "grid grid-cols-2 gap-4" ]
                [ Field.view []
                    [ Field.label [ for "input-form-phone" ] [ text "Phone" ]
                    , Input.view [ id "input-form-phone", type_ "tel", placeholder "+1 (555) 123-4567" ]
                    ]
                , Field.view []
                    [ Field.label [ for "input-form-country" ] [ text "Country" ]
                    , Select.new
                        |> Select.id "input-form-country"
                        |> Select.onSelect (State.set "input-form-country")
                        |> Select.value (Just (State.get "input-form-country" state |> Maybe.withDefault "us"))
                        |> Select.items
                            [ Select.item "us" [ text "United States" ]
                            , Select.item "uk" [ text "United Kingdom" ]
                            , Select.item "ca" [ text "Canada" ]
                            ]
                        |> Select.toHtml []
                    ]
                ]
            , Field.view []
                [ Field.label [ for "input-form-address" ] [ text "Address" ]
                , Input.view [ id "input-form-address", placeholder "123 Main St" ]
                ]
            , Field.horizontal []
                [ Button.new
                    |> Button.text "Cancel"
                    |> Button.outline
                    |> Button.toHtml [ type_ "button" ]
                , Button.new
                    |> Button.text "Submit"
                    |> Button.toHtml [ type_ "submit" ]
                ]
            ]
        ]


{-| Set `dir` on the field and the input.
-}
rtl : Html msg
rtl =
    Field.view [ dir "rtl", class "max-w-sm" ]
        [ Field.label [ for "input-rtl-api-key" ] [ text "مفتاح API" ]
        , Input.view [ id "input-rtl-api-key", type_ "password", placeholder "sk-...", dir "rtl" ]
        , Field.description [] [ text "مفتاح API الخاص بك مشفر ومخزن بأمان." ]
        ]
