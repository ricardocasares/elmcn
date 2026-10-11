module Examples.Alert exposing (..)

import Html exposing (Html, div, p, text)
import Html.Attributes exposing (class)
import Phosphor exposing (IconWeight(..))
import UI.Alert as Alert
import UI.Button as Button


demo : Html msg
demo =
    Alert.view []
        [ class "max-w-md" ]
        [ Phosphor.check Regular |> Phosphor.toHtml []
        , Alert.title [] [ text "Success! Your changes have been saved" ]
        , Alert.description [] [ text "This is an alert with icon, title and description." ]
        ]


destructive : Html msg
destructive =
    Alert.view [ Alert.destructive ]
        [ class "max-w-md" ]
        [ Alert.title [] [ text "Unable to process your payment." ]
        , Alert.description [] [ p [] [ text "Please verify your billing information and try again." ] ]
        ]


withAction : Html msg
withAction =
    Alert.view []
        [ class "max-w-md" ]
        [ Alert.title [] [ text "Dark mode is now available" ]
        , Alert.description [] [ text "Enable it under your profile settings." ]
        , Alert.action [] [ Button.view "Enable" |> Button.extraSmall |> Button.toHtml [] ]
        ]
