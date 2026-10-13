module Examples.AlertDialog exposing (..)

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, dir, href)
import Phosphor exposing (IconWeight(..))
import UI.AlertDialog as AlertDialog
import UI.Button as Button


demo : Html msg
demo =
    AlertDialog.new
        |> AlertDialog.id "alert-demo"
        |> AlertDialog.trigger
            (Button.new
                |> Button.text "Show Dialog"
                |> Button.outline
            )
        |> AlertDialog.title [ text "Are you absolutely sure?" ]
        |> AlertDialog.description [ text "This action cannot be undone. This will permanently delete your account from our servers." ]
        |> AlertDialog.cancel
            (Button.new
                |> Button.text "Cancel"
                |> Button.outline
            )
        |> AlertDialog.action []
            (Button.new
                |> Button.text "Continue"
            )
        |> AlertDialog.toHtml []


{-| A basic alert dialog with a title, description, and cancel and continue buttons.
-}
basic : Html msg
basic =
    AlertDialog.new
        |> AlertDialog.id "alert-basic"
        |> AlertDialog.trigger
            (Button.new
                |> Button.text "Show Dialog"
                |> Button.outline
            )
        |> AlertDialog.title [ text "Are you absolutely sure?" ]
        |> AlertDialog.description [ text "This action cannot be undone. This will permanently delete your account and remove your data from our servers." ]
        |> AlertDialog.cancel
            (Button.new
                |> Button.text "Cancel"
                |> Button.outline
            )
        |> AlertDialog.action []
            (Button.new
                |> Button.text "Continue"
            )
        |> AlertDialog.toHtml []


{-| Use `small` to make the alert dialog smaller.
-}
small : Html msg
small =
    AlertDialog.new
        |> AlertDialog.id "alert-small"
        |> AlertDialog.trigger
            (Button.new
                |> Button.text "Show Dialog"
                |> Button.outline
            )
        |> AlertDialog.title [ text "Allow accessory to connect?" ]
        |> AlertDialog.description [ text "Do you want to allow the USB accessory to connect to this device?" ]
        |> AlertDialog.cancel
            (Button.new
                |> Button.text "Don't allow"
                |> Button.outline
            )
        |> AlertDialog.action []
            (Button.new
                |> Button.text "Allow"
            )
        |> AlertDialog.small
        |> AlertDialog.toHtml []


{-| Use `media` to add a media element such as an icon or image to the alert dialog.
-}
media : Html msg
media =
    AlertDialog.new
        |> AlertDialog.id "alert-media"
        |> AlertDialog.trigger
            (Button.new
                |> Button.text "Share Project"
                |> Button.outline
            )
        |> AlertDialog.media [] [ Phosphor.plusCircle Regular |> Phosphor.toHtml [] ]
        |> AlertDialog.title [ text "Share this project?" ]
        |> AlertDialog.description [ text "Anyone with the link will be able to view and edit this project." ]
        |> AlertDialog.cancel
            (Button.new
                |> Button.text "Cancel"
                |> Button.outline
            )
        |> AlertDialog.action []
            (Button.new
                |> Button.text "Share"
            )
        |> AlertDialog.toHtml []


{-| Use `small` to make the alert dialog smaller and `media` to add a media element such as an icon or image to the alert dialog.
-}
smallWithMedia : Html msg
smallWithMedia =
    AlertDialog.new
        |> AlertDialog.id "alert-small-media"
        |> AlertDialog.trigger
            (Button.new
                |> Button.text "Show Dialog"
                |> Button.outline
            )
        |> AlertDialog.media [] [ Phosphor.bluetooth Regular |> Phosphor.toHtml [] ]
        |> AlertDialog.title [ text "Allow accessory to connect?" ]
        |> AlertDialog.description [ text "Do you want to allow the USB accessory to connect to this device?" ]
        |> AlertDialog.cancel
            (Button.new
                |> Button.text "Don't allow"
                |> Button.outline
            )
        |> AlertDialog.action []
            (Button.new
                |> Button.text "Allow"
            )
        |> AlertDialog.small
        |> AlertDialog.toHtml []


{-| Make the `action` `destructive` to add a destructive action button to the alert dialog.
-}
destructive : Html msg
destructive =
    AlertDialog.new
        |> AlertDialog.id "alert-destructive"
        |> AlertDialog.trigger
            (Button.new
                |> Button.text "Delete Chat"
                |> Button.destructive
            )
        |> AlertDialog.media [ class "bg-destructive/10 text-destructive dark:bg-destructive/20 dark:text-destructive" ] [ Phosphor.trash Regular |> Phosphor.toHtml [] ]
        |> AlertDialog.title [ text "Delete chat?" ]
        |> AlertDialog.description
            [ text "This will permanently delete this chat conversation. View "
            , a [ href "#" ] [ text "Settings" ]
            , text " delete any memories saved during this chat."
            ]
        |> AlertDialog.cancel
            (Button.new
                |> Button.text "Cancel"
                |> Button.outline
            )
        |> AlertDialog.action []
            (Button.new
                |> Button.text "Delete"
                |> Button.destructive
            )
        |> AlertDialog.small
        |> AlertDialog.toHtml []


{-| Set `dir "rtl"` on the dialog to lay it out right to left.
-}
rtl : Html msg
rtl =
    div [ class "flex gap-4", dir "rtl" ]
        [ AlertDialog.new
            |> AlertDialog.id "alert-rtl"
            |> AlertDialog.trigger
                (Button.new
                    |> Button.text "إظهار الحوار"
                    |> Button.outline
                )
            |> AlertDialog.title [ text "هل أنت متأكد تمامًا؟" ]
            |> AlertDialog.description [ text "لا يمكن التراجع عن هذا الإجراء. سيؤدي هذا إلى حذف حسابك نهائيًا من خوادمنا." ]
            |> AlertDialog.cancel
                (Button.new
                    |> Button.text "إلغاء"
                    |> Button.outline
                )
            |> AlertDialog.action []
                (Button.new
                    |> Button.text "متابعة"
                )
            |> AlertDialog.toHtml [ dir "rtl" ]
        , AlertDialog.new
            |> AlertDialog.id "alert-rtl-small"
            |> AlertDialog.trigger
                (Button.new
                    |> Button.text "إظهار الحوار (صغير)"
                    |> Button.outline
                )
            |> AlertDialog.media [] [ Phosphor.bluetooth Regular |> Phosphor.toHtml [] ]
            |> AlertDialog.title [ text "السماح للملحق بالاتصال؟" ]
            |> AlertDialog.description [ text "هل تريد السماح لملحق USB بالاتصال بهذا الجهاز؟" ]
            |> AlertDialog.cancel
                (Button.new
                    |> Button.text "عدم السماح"
                    |> Button.outline
                )
            |> AlertDialog.action []
                (Button.new
                    |> Button.text "السماح"
                )
            |> AlertDialog.small
            |> AlertDialog.toHtml [ dir "rtl" ]
        ]
