module Examples.AlertDialog exposing (..)

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, dir, href)
import Html.Events exposing (onClick)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.AlertDialog as AlertDialog
import UI.Button as Button


demo : State -> Html State.Msg
demo state =
    div []
        [ Button.new
            |> Button.text "Show Dialog"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "alert-demo" "open") ]
        , AlertDialog.new
            |> AlertDialog.id "alert-demo"
            |> AlertDialog.open (State.get "alert-demo" state == Just "open") (State.set "alert-demo" "closed")
            |> AlertDialog.title [ text "Are you absolutely sure?" ]
            |> AlertDialog.description [ text "This action cannot be undone. This will permanently delete your account from our servers." ]
            |> AlertDialog.cancel
                (Button.new
                    |> Button.text "Cancel"
                    |> Button.outline
                )
            |> AlertDialog.action (State.set "alert-demo" "closed")
                (Button.new
                    |> Button.text "Continue"
                )
            |> AlertDialog.toHtml []
        ]


{-| A basic alert dialog with a title, description, and cancel and continue buttons.
-}
basic : State -> Html State.Msg
basic state =
    div []
        [ Button.new
            |> Button.text "Show Dialog"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "alert-basic" "open") ]
        , AlertDialog.new
            |> AlertDialog.id "alert-basic"
            |> AlertDialog.open (State.get "alert-basic" state == Just "open") (State.set "alert-basic" "closed")
            |> AlertDialog.title [ text "Are you absolutely sure?" ]
            |> AlertDialog.description [ text "This action cannot be undone. This will permanently delete your account and remove your data from our servers." ]
            |> AlertDialog.cancel
                (Button.new
                    |> Button.text "Cancel"
                    |> Button.outline
                )
            |> AlertDialog.action (State.set "alert-basic" "closed")
                (Button.new
                    |> Button.text "Continue"
                )
            |> AlertDialog.toHtml []
        ]


{-| Use `small` to make the alert dialog smaller.
-}
small : State -> Html State.Msg
small state =
    div []
        [ Button.new
            |> Button.text "Show Dialog"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "alert-small" "open") ]
        , AlertDialog.new
            |> AlertDialog.id "alert-small"
            |> AlertDialog.open (State.get "alert-small" state == Just "open") (State.set "alert-small" "closed")
            |> AlertDialog.title [ text "Allow accessory to connect?" ]
            |> AlertDialog.description [ text "Do you want to allow the USB accessory to connect to this device?" ]
            |> AlertDialog.cancel
                (Button.new
                    |> Button.text "Don't allow"
                    |> Button.outline
                )
            |> AlertDialog.action (State.set "alert-small" "closed")
                (Button.new
                    |> Button.text "Allow"
                )
            |> AlertDialog.small
            |> AlertDialog.toHtml []
        ]


{-| Use `media` to add a media element such as an icon or image to the alert dialog.
-}
media : State -> Html State.Msg
media state =
    div []
        [ Button.new
            |> Button.text "Share Project"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "alert-media" "open") ]
        , AlertDialog.new
            |> AlertDialog.id "alert-media"
            |> AlertDialog.open (State.get "alert-media" state == Just "open") (State.set "alert-media" "closed")
            |> AlertDialog.media [] [ Phosphor.plusCircle Regular |> Phosphor.toHtml [] ]
            |> AlertDialog.title [ text "Share this project?" ]
            |> AlertDialog.description [ text "Anyone with the link will be able to view and edit this project." ]
            |> AlertDialog.cancel
                (Button.new
                    |> Button.text "Cancel"
                    |> Button.outline
                )
            |> AlertDialog.action (State.set "alert-media" "closed")
                (Button.new
                    |> Button.text "Share"
                )
            |> AlertDialog.toHtml []
        ]


{-| Use `small` to make the alert dialog smaller and `media` to add a media element such as an icon or image to the alert dialog.
-}
smallWithMedia : State -> Html State.Msg
smallWithMedia state =
    div []
        [ Button.new
            |> Button.text "Show Dialog"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "alert-small-media" "open") ]
        , AlertDialog.new
            |> AlertDialog.id "alert-small-media"
            |> AlertDialog.open (State.get "alert-small-media" state == Just "open") (State.set "alert-small-media" "closed")
            |> AlertDialog.media [] [ Phosphor.bluetooth Regular |> Phosphor.toHtml [] ]
            |> AlertDialog.title [ text "Allow accessory to connect?" ]
            |> AlertDialog.description [ text "Do you want to allow the USB accessory to connect to this device?" ]
            |> AlertDialog.cancel
                (Button.new
                    |> Button.text "Don't allow"
                    |> Button.outline
                )
            |> AlertDialog.action (State.set "alert-small-media" "closed")
                (Button.new
                    |> Button.text "Allow"
                )
            |> AlertDialog.small
            |> AlertDialog.toHtml []
        ]


{-| Make the `action` `destructive` to add a destructive action button to the alert dialog.
-}
destructive : State -> Html State.Msg
destructive state =
    div []
        [ Button.new
            |> Button.text "Delete Chat"
            |> Button.destructive
            |> Button.toHtml [ onClick (State.set "alert-destructive" "open") ]
        , AlertDialog.new
            |> AlertDialog.id "alert-destructive"
            |> AlertDialog.open (State.get "alert-destructive" state == Just "open") (State.set "alert-destructive" "closed")
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
            |> AlertDialog.action (State.set "alert-destructive" "closed")
                (Button.new
                    |> Button.text "Delete"
                    |> Button.destructive
                )
            |> AlertDialog.small
            |> AlertDialog.toHtml []
        ]


{-| Set `dir "rtl"` on the dialog to lay it out right to left.
-}
rtl : State -> Html State.Msg
rtl state =
    div [ class "flex gap-4", dir "rtl" ]
        [ Button.new
            |> Button.text "إظهار الحوار"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "alert-rtl" "open") ]
        , AlertDialog.new
            |> AlertDialog.id "alert-rtl"
            |> AlertDialog.open (State.get "alert-rtl" state == Just "open") (State.set "alert-rtl" "closed")
            |> AlertDialog.title [ text "هل أنت متأكد تمامًا؟" ]
            |> AlertDialog.description [ text "لا يمكن التراجع عن هذا الإجراء. سيؤدي هذا إلى حذف حسابك نهائيًا من خوادمنا." ]
            |> AlertDialog.cancel
                (Button.new
                    |> Button.text "إلغاء"
                    |> Button.outline
                )
            |> AlertDialog.action (State.set "alert-rtl" "closed")
                (Button.new
                    |> Button.text "متابعة"
                )
            |> AlertDialog.toHtml [ dir "rtl" ]
        , Button.new
            |> Button.text "إظهار الحوار (صغير)"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "alert-rtl-small" "open") ]
        , AlertDialog.new
            |> AlertDialog.id "alert-rtl-small"
            |> AlertDialog.open (State.get "alert-rtl-small" state == Just "open") (State.set "alert-rtl-small" "closed")
            |> AlertDialog.media [] [ Phosphor.bluetooth Regular |> Phosphor.toHtml [] ]
            |> AlertDialog.title [ text "السماح للملحق بالاتصال؟" ]
            |> AlertDialog.description [ text "هل تريد السماح لملحق USB بالاتصال بهذا الجهاز؟" ]
            |> AlertDialog.cancel
                (Button.new
                    |> Button.text "عدم السماح"
                    |> Button.outline
                )
            |> AlertDialog.action (State.set "alert-rtl-small" "closed")
                (Button.new
                    |> Button.text "السماح"
                )
            |> AlertDialog.small
            |> AlertDialog.toHtml [ dir "rtl" ]
        ]
