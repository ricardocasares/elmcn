module Examples.Alert exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, dir)
import Phosphor exposing (IconWeight(..))
import UI.Alert as Alert
import UI.Button as Button


demo : Html msg
demo =
    div [ class "grid w-full max-w-md items-start gap-4" ]
        [ Alert.new
            |> Alert.icon (Phosphor.checkCircle Regular |> Phosphor.toHtml [])
            |> Alert.title [ text "Payment successful" ]
            |> Alert.description [ text "Your payment of $29.99 has been processed. A receipt has been sent to your email address." ]
            |> Alert.toHtml []
        , Alert.new
            |> Alert.icon (Phosphor.info Regular |> Phosphor.toHtml [])
            |> Alert.title [ text "New feature available" ]
            |> Alert.description [ text "We've added dark mode support. You can enable it in your account settings." ]
            |> Alert.toHtml []
        ]


{-| A basic alert with an icon, title and description.
-}
basic : Html msg
basic =
    Alert.new
        |> Alert.icon (Phosphor.checkCircle Regular |> Phosphor.toHtml [])
        |> Alert.title [ text "Account updated successfully" ]
        |> Alert.description [ text "Your profile information has been saved. Changes will be reflected immediately." ]
        |> Alert.toHtml [ class "max-w-md" ]


{-| Use `destructive` to create a destructive alert.
-}
destructive : Html msg
destructive =
    Alert.new
        |> Alert.destructive
        |> Alert.icon (Phosphor.warningCircle Regular |> Phosphor.toHtml [])
        |> Alert.title [ text "Payment failed" ]
        |> Alert.description [ text "Your payment could not be processed. Please check your payment method and try again." ]
        |> Alert.toHtml [ class "max-w-md" ]


{-| Use `action` to add a button or other action element to the alert.
-}
action : Html msg
action =
    Alert.new
        |> Alert.title [ text "Dark mode is now available" ]
        |> Alert.description [ text "Enable it under your profile settings to get started." ]
        |> Alert.action
            (Button.new
                |> Button.text "Enable"
                |> Button.extraSmall
                |> Button.toHtml []
            )
        |> Alert.toHtml [ class "max-w-md" ]


{-| Use `colors` to replace the default colors with your own classes, such as `bg-amber-50 dark:bg-amber-950`.
-}
customColors : Html msg
customColors =
    Alert.new
        |> Alert.colors "border-amber-200 bg-amber-50 text-amber-900 dark:border-amber-900 dark:bg-amber-950 dark:text-amber-50"
        |> Alert.icon (Phosphor.warning Regular |> Phosphor.toHtml [])
        |> Alert.title [ text "Your subscription will expire in 3 days." ]
        |> Alert.description [ text "Renew now to avoid service interruption or upgrade to a paid plan to continue using the service." ]
        |> Alert.toHtml [ class "max-w-md" ]


{-| Set `dir="rtl"` on a parent element for right-to-left languages.
-}
rtl : Html msg
rtl =
    div [ dir "rtl", class "grid w-full max-w-md items-start gap-4" ]
        [ Alert.new
            |> Alert.icon (Phosphor.checkCircle Regular |> Phosphor.toHtml [])
            |> Alert.title [ text "تم الدفع بنجاح" ]
            |> Alert.description [ text "تمت معالجة دفعتك البالغة 29.99 دولارًا. تم إرسال إيصال إلى عنوان بريدك الإلكتروني." ]
            |> Alert.toHtml []
        , Alert.new
            |> Alert.icon (Phosphor.info Regular |> Phosphor.toHtml [])
            |> Alert.title [ text "ميزة جديدة متاحة" ]
            |> Alert.description [ text "لقد أضفنا دعم الوضع الداكن. يمكنك تفعيله في إعدادات حسابك." ]
            |> Alert.toHtml []
        ]
