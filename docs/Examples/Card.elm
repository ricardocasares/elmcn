module Examples.Card exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, for, id, placeholder)
import UI.Button as Button
import UI.Card as Card
import UI.Input as Input
import UI.Label as Label


demo : Html msg
demo =
    Card.view []
        [ class "w-full max-w-sm" ]
        [ Card.header []
            [ Card.title [] [ text "Login to your account" ]
            , Card.description [] [ text "Enter your email below to login to your account" ]
            , Card.action []
                [ Button.new
                    |> Button.text "Sign Up"
                    |> Button.link
                    |> Button.toHtml []
                ]
            ]
        , Card.content []
            [ div [ class "flex flex-col gap-6" ]
                [ div [ class "grid gap-2" ]
                    [ Label.view [ for "card-email" ] [ text "Email" ]
                    , Input.view [ id "card-email", Html.Attributes.type_ "email", placeholder "m@example.com" ]
                    ]
                , div [ class "grid gap-2" ]
                    [ Label.view [ for "card-password" ] [ text "Password" ]
                    , Input.view [ id "card-password", Html.Attributes.type_ "password" ]
                    ]
                ]
            ]
        , Card.footer [ class "flex-col gap-2" ]
            [ Button.new
                |> Button.text "Login"
                |> Button.toHtml [ class "w-full" ]
            , Button.new
                |> Button.text "Login with Google"
                |> Button.outline
                |> Button.toHtml [ class "w-full" ]
            ]
        ]


simple : Html msg
simple =
    Card.view []
        [ class "w-full max-w-sm" ]
        [ Card.header []
            [ Card.title [] [ text "Notifications" ]
            , Card.description [] [ text "You have 3 unread messages." ]
            ]
        , Card.content [] [ text "Your inbox is waiting." ]
        , Card.footer []
            [ Button.new
                |> Button.text "Mark all as read"
                |> Button.toHtml [ class "w-full" ]
            ]
        ]
