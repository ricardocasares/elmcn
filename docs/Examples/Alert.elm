module Examples.Alert exposing (..)

import Html exposing (Html, p, text)
import Html.Attributes exposing (class)
import Phosphor exposing (IconWeight(..))
import UI.Alert as Alert
import UI.Button as Button


demo : Html msg
demo =
    Alert.new
        |> Alert.icon (Phosphor.check Regular |> Phosphor.toHtml [])
        |> Alert.title [ text "Success! Your changes have been saved" ]
        |> Alert.description [ text "This is an alert with icon, title and description." ]
        |> Alert.toHtml [ class "max-w-md" ]


destructive : Html msg
destructive =
    Alert.new
        |> Alert.destructive
        |> Alert.title [ text "Unable to process your payment." ]
        |> Alert.description [ p [] [ text "Please verify your billing information and try again." ] ]
        |> Alert.toHtml [ class "max-w-md" ]


withAction : Html msg
withAction =
    Alert.new
        |> Alert.title [ text "Dark mode is now available" ]
        |> Alert.description [ text "Enable it under your profile settings." ]
        |> Alert.action (Button.view "Enable" |> Button.extraSmall |> Button.toHtml [])
        |> Alert.toHtml [ class "max-w-md" ]
