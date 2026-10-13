module Examples.Dialog exposing (..)

import Html exposing (Html, div, p, text)
import Html.Attributes exposing (class, dir, for, id, readonly, tabindex, value)
import Html.Events exposing (onClick)
import State exposing (State)
import UI.Button as Button
import UI.Dialog as Dialog
import UI.Field as Field
import UI.Input as Input
import UI.Label as Label


demo : State -> Html State.Msg
demo state =
    div []
        [ Button.new
            |> Button.text "Open Dialog"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "edit-profile" "open") ]
        , Dialog.new
            |> Dialog.id "edit-profile"
            |> Dialog.modal
            |> Dialog.open (State.get "edit-profile" state == Just "open") (State.set "edit-profile" "closed")
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
                    |> Button.toHtml [ tabindex 0, onClick (State.set "edit-profile" "closed") ]
                , Button.new
                    |> Button.text "Save changes"
                    |> Button.toHtml [ tabindex 0, onClick (State.set "edit-profile" "closed") ]
                ]
            |> Dialog.toHtml [ class "sm:max-w-sm" ]
        ]


{-| Replace the default close control with your own button.
-}
customCloseButton : State -> Html State.Msg
customCloseButton state =
    div []
        [ Button.new
            |> Button.text "Share"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "share" "open") ]
        , Dialog.new
            |> Dialog.id "share"
            |> Dialog.open (State.get "share" state == Just "open") (State.set "share" "closed")
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
                    |> Button.toHtml [ tabindex 0, onClick (State.set "share" "closed") ]
                ]
            |> Dialog.toHtml [ class "sm:max-w-md" ]
        ]


{-| Use `hideCloseButton` to hide the close button.
-}
noCloseButton : State -> Html State.Msg
noCloseButton state =
    div []
        [ Button.new
            |> Button.text "No Close Button"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "no-close-button" "open") ]
        , Dialog.new
            |> Dialog.id "no-close-button"
            |> Dialog.open (State.get "no-close-button" state == Just "open") (State.set "no-close-button" "closed")
            |> Dialog.hideCloseButton
            |> Dialog.title [ text "No Close Button" ]
            |> Dialog.description [ text "This dialog doesn't have a close button in the top-right corner." ]
            |> Dialog.toHtml []
        ]


{-| Keep actions visible while the content scrolls.
-}
stickyFooter : State -> Html State.Msg
stickyFooter state =
    div []
        [ Button.new
            |> Button.text "Sticky Footer"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "sticky-footer" "open") ]
        , Dialog.new
            |> Dialog.id "sticky-footer"
            |> Dialog.open (State.get "sticky-footer" state == Just "open") (State.set "sticky-footer" "closed")
            |> Dialog.title [ text "Sticky Footer" ]
            |> Dialog.description [ text "This dialog has a sticky footer that stays visible while the content scrolls." ]
            |> Dialog.content
                [ div [ class "-mx-4 max-h-[50vh] overflow-y-auto px-4 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden" ]
                    (List.repeat 10 (p [ class "mb-4 leading-normal" ] [ text lorem ]))
                ]
            |> Dialog.footer []
                [ Button.new
                    |> Button.text "Close"
                    |> Button.outline
                    |> Button.toHtml [ tabindex 0, onClick (State.set "sticky-footer" "closed") ]
                ]
            |> Dialog.toHtml []
        ]


{-| Long content can scroll while the header stays in view.
-}
scrollableContent : State -> Html State.Msg
scrollableContent state =
    div []
        [ Button.new
            |> Button.text "Scrollable Content"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "scrollable-content" "open") ]
        , Dialog.new
            |> Dialog.id "scrollable-content"
            |> Dialog.open (State.get "scrollable-content" state == Just "open") (State.set "scrollable-content" "closed")
            |> Dialog.title [ text "Scrollable Content" ]
            |> Dialog.description [ text "This is a dialog with scrollable content." ]
            |> Dialog.content
                [ div [ class "-mx-4 max-h-[50vh] overflow-y-auto px-4 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden" ]
                    (List.repeat 10 (p [ class "mb-4 leading-normal" ] [ text lorem ]))
                ]
            |> Dialog.toHtml []
        ]


{-| Set `dir "rtl"` on the dialog to lay it out right to left.
-}
rtl : State -> Html State.Msg
rtl state =
    div [ dir "rtl" ]
        [ Button.new
            |> Button.text "فتح الحوار"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "edit-profile-rtl" "open") ]
        , Dialog.new
            |> Dialog.id "edit-profile-rtl"
            |> Dialog.open (State.get "edit-profile-rtl" state == Just "open") (State.set "edit-profile-rtl" "closed")
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
                    |> Button.toHtml [ tabindex 0, onClick (State.set "edit-profile-rtl" "closed") ]
                , Button.new
                    |> Button.text "حفظ التغييرات"
                    |> Button.toHtml [ tabindex 0, onClick (State.set "edit-profile-rtl" "closed") ]
                ]
            |> Dialog.toHtml [ class "sm:max-w-sm", dir "rtl" ]
        ]


{-| `modal` keeps the dialog open when the overlay is tapped. Escape and the buttons still close it.
-}
modal : State -> Html State.Msg
modal state =
    div []
        [ Button.new
            |> Button.text "Modal"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "modal" "open") ]
        , Dialog.new
            |> Dialog.id "modal"
            |> Dialog.open (State.get "modal" state == Just "open") (State.set "modal" "closed")
            |> Dialog.modal
            |> Dialog.title [ text "Modal" ]
            |> Dialog.description [ text "Tapping outside won't close this dialog. Press Escape or use a button." ]
            |> Dialog.footer []
                [ Button.new
                    |> Button.text "Close"
                    |> Button.outline
                    |> Button.toHtml [ tabindex 0, onClick (State.set "modal" "closed") ]
                ]
            |> Dialog.toHtml []
        ]


{-| Put a dialog in another's `content` to open it on top. Escape and a tap outside close the top one first, and only one overlay dims the page.
-}
nested : State -> Html State.Msg
nested state =
    div []
        [ Button.new
            |> Button.text "Nested"
            |> Button.outline
            |> Button.toHtml [ onClick (State.set "nested" "open") ]
        , Dialog.new
            |> Dialog.id "nested"
            |> Dialog.open (State.get "nested" state == Just "open") (State.set "nested" "closed")
            |> Dialog.title [ text "Notifications" ]
            |> Dialog.description [ text "You are all caught up. Good job!" ]
            |> Dialog.content
                [ Dialog.new
                    |> Dialog.id "nested-customize"
                    |> Dialog.open (State.get "nested-customize" state == Just "open") (State.set "nested-customize" "closed")
                    |> Dialog.title [ text "Customize notifications" ]
                    |> Dialog.description [ text "Review your settings here." ]
                    |> Dialog.content
                        [ Dialog.new
                            |> Dialog.id "nested-advanced"
                            |> Dialog.open (State.get "nested-advanced" state == Just "open") (State.set "nested-advanced" "closed")
                            |> Dialog.title [ text "Advanced settings" ]
                            |> Dialog.description [ text "Fine-tune when and how notifications reach you." ]
                            |> Dialog.footer []
                                [ Button.new
                                    |> Button.text "Close"
                                    |> Button.outline
                                    |> Button.toHtml [ tabindex 0, onClick (State.set "nested-advanced" "closed") ]
                                ]
                            |> Dialog.toHtml [ class "sm:max-w-lg" ]
                        ]
                    |> Dialog.footer []
                        [ Button.new
                            |> Button.text "Close"
                            |> Button.outline
                            |> Button.toHtml [ tabindex 0, onClick (State.set "nested-customize" "closed") ]
                        , Button.new
                            |> Button.text "Advanced"
                            |> Button.toHtml [ tabindex 0, onClick (State.set "nested-advanced" "open") ]
                        ]
                    |> Dialog.toHtml []
                ]
            |> Dialog.footer []
                [ Button.new
                    |> Button.text "Close"
                    |> Button.outline
                    |> Button.toHtml [ tabindex 0, onClick (State.set "nested" "closed") ]
                , Button.new
                    |> Button.text "Customize"
                    |> Button.toHtml [ tabindex 0, onClick (State.set "nested-customize" "open") ]
                ]
            |> Dialog.toHtml [ class "sm:max-w-md" ]
        ]


lorem : String
lorem =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
