module Examples.Dialog exposing (..)

import Html exposing (Html, div, p, text)
import Html.Attributes exposing (class, dir, for, id, readonly, value)
import State exposing (State)
import UI.Button as Button
import UI.Dialog as Dialog
import UI.Field as Field
import UI.Input as Input
import UI.Label as Label


demo : Html msg
demo =
    Dialog.new
        |> Dialog.id "edit-profile"
        |> Dialog.trigger
            (Button.new
                |> Button.text "Open Dialog"
                |> Button.outline
            )
        |> Dialog.title [ text "Edit profile" ]
        |> Dialog.description [ text "Make changes to your profile here. Click save when you're done." ]
        |> Dialog.content
            [ Field.group []
                [ Field.view []
                    [ Label.view [ for "edit-profile-name" ] [ text "Name" ]
                    , Input.view [ id "edit-profile-name", value "Pedro Duarte" ]
                    ]
                , Field.view []
                    [ Label.view [ for "edit-profile-username" ] [ text "Username" ]
                    , Input.view [ id "edit-profile-username", value "@peduarte" ]
                    ]
                ]
            ]
        |> Dialog.footer []
            [ Button.new
                |> Button.text "Cancel"
                |> Button.outline
                |> Button.toHtml (Dialog.closes "edit-profile")
            , Button.new
                |> Button.text "Save changes"
                |> Button.toHtml (Dialog.closes "edit-profile")
            ]
        |> Dialog.toHtml [ class "sm:max-w-sm" ]


{-| Replace the default close control with your own button.
-}
customCloseButton : Html msg
customCloseButton =
    Dialog.new
        |> Dialog.id "share"
        |> Dialog.trigger
            (Button.new
                |> Button.text "Share"
                |> Button.outline
            )
        |> Dialog.title [ text "Share link" ]
        |> Dialog.description [ text "Anyone who has this link will be able to view this." ]
        |> Dialog.content
            [ div [ class "flex items-center gap-2" ]
                [ div [ class "grid flex-1 gap-2" ]
                    [ Label.view [ for "share-link", class "sr-only" ] [ text "Link" ]
                    , Input.view [ id "share-link", value "https://ui.shadcn.com/docs/installation", readonly True ]
                    ]
                ]
            ]
        |> Dialog.footer [ class "sm:justify-start" ]
            [ Button.new
                |> Button.text "Close"
                |> Button.toHtml (Dialog.closes "share")
            ]
        |> Dialog.toHtml [ class "sm:max-w-md" ]


{-| Use `hideCloseButton` to hide the close button.
-}
noCloseButton : Html msg
noCloseButton =
    Dialog.new
        |> Dialog.id "no-close-button"
        |> Dialog.trigger
            (Button.new
                |> Button.text "No Close Button"
                |> Button.outline
            )
        |> Dialog.hideCloseButton
        |> Dialog.title [ text "No Close Button" ]
        |> Dialog.description [ text "This dialog doesn't have a close button in the top-right corner." ]
        |> Dialog.toHtml []


{-| Keep actions visible while the content scrolls.
-}
stickyFooter : Html msg
stickyFooter =
    Dialog.new
        |> Dialog.id "sticky-footer"
        |> Dialog.trigger
            (Button.new
                |> Button.text "Sticky Footer"
                |> Button.outline
            )
        |> Dialog.title [ text "Sticky Footer" ]
        |> Dialog.description [ text "This dialog has a sticky footer that stays visible while the content scrolls." ]
        |> Dialog.content
            [ div [ class "-mx-4 max-h-[50vh] overflow-y-auto px-4" ]
                (List.repeat 10 (p [ class "mb-4 leading-normal" ] [ text lorem ]))
            ]
        |> Dialog.footer []
            [ Button.new
                |> Button.text "Close"
                |> Button.outline
                |> Button.toHtml (Dialog.closes "sticky-footer")
            ]
        |> Dialog.toHtml []


{-| Long content can scroll while the header stays in view.
-}
scrollableContent : Html msg
scrollableContent =
    Dialog.new
        |> Dialog.id "scrollable-content"
        |> Dialog.trigger
            (Button.new
                |> Button.text "Scrollable Content"
                |> Button.outline
            )
        |> Dialog.title [ text "Scrollable Content" ]
        |> Dialog.description [ text "This is a dialog with scrollable content." ]
        |> Dialog.content
            [ div [ class "-mx-4 max-h-[50vh] overflow-y-auto px-4" ]
                (List.repeat 10 (p [ class "mb-4 leading-normal" ] [ text lorem ]))
            ]
        |> Dialog.toHtml []


{-| Set `dir "rtl"` on the dialog to lay it out right to left.
-}
rtl : Html msg
rtl =
    div [ dir "rtl" ]
        [ Dialog.new
            |> Dialog.id "edit-profile-rtl"
            |> Dialog.trigger
                (Button.new
                    |> Button.text "فتح الحوار"
                    |> Button.outline
                )
            |> Dialog.title [ text "تعديل الملف الشخصي" ]
            |> Dialog.description [ text "قم بإجراء تغييرات على ملفك الشخصي هنا. انقر فوق حفظ عند الانتهاء." ]
            |> Dialog.content
                [ Field.group []
                    [ Field.view []
                        [ Label.view [ for "edit-profile-rtl-name" ] [ text "الاسم" ]
                        , Input.view [ id "edit-profile-rtl-name", value "Pedro Duarte" ]
                        ]
                    , Field.view []
                        [ Label.view [ for "edit-profile-rtl-username" ] [ text "اسم المستخدم" ]
                        , Input.view [ id "edit-profile-rtl-username", value "@peduarte" ]
                        ]
                    ]
                ]
            |> Dialog.footer []
                [ Button.new
                    |> Button.text "إلغاء"
                    |> Button.outline
                    |> Button.toHtml (Dialog.closes "edit-profile-rtl")
                , Button.new
                    |> Button.text "حفظ التغييرات"
                    |> Button.toHtml (Dialog.closes "edit-profile-rtl")
                ]
            |> Dialog.toHtml [ class "sm:max-w-sm", dir "rtl" ]
        ]


{-| `opens` puts the trigger anywhere on the page, and `onClose` reports when the dialog closes, however it was closed.
-}
closeEvent : State -> Html State.Msg
closeEvent state =
    let
        closed =
            State.get "dialog-closed" state
                |> Maybe.withDefault "0"

        count =
            String.toInt closed
                |> Maybe.withDefault 0
    in
    div [ class "flex flex-col items-center gap-4" ]
        [ p [ class "text-sm text-muted-foreground" ]
            [ text ("Closed " ++ closed ++ " times") ]
        , Button.new
            |> Button.text "Open"
            |> Button.outline
            |> Button.toHtml (Dialog.opens "close-event")
        , Dialog.new
            |> Dialog.id "close-event"
            |> Dialog.onClose (State.set "dialog-closed" (String.fromInt (count + 1)))
            |> Dialog.title [ text "Are you sure?" ]
            |> Dialog.description [ text "Close this dialog with the X, Escape, the backdrop or the button below. Each one counts." ]
            |> Dialog.footer []
                [ Button.new
                    |> Button.text "Continue"
                    |> Button.toHtml (Dialog.closes "close-event")
                ]
            |> Dialog.toHtml []
        ]


lorem : String
lorem =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
