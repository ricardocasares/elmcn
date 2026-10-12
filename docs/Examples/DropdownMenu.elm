module Examples.DropdownMenu exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.Button as Button
import UI.DropdownMenu as DropdownMenu


demo : Html msg
demo =
    DropdownMenu.new
        |> DropdownMenu.id "basic"
        |> DropdownMenu.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Open" ]
        |> DropdownMenu.content
            [ DropdownMenu.group
                [ DropdownMenu.label [ text "My Account" ]
                , DropdownMenu.item [] [ text "Profile" ]
                , DropdownMenu.item [] [ text "Billing" ]
                , DropdownMenu.item [] [ text "Settings" ]
                ]
            , DropdownMenu.separator
            , DropdownMenu.item [] [ text "GitHub" ]
            , DropdownMenu.item [] [ text "Support" ]
            , DropdownMenu.item [] [ text "API" ]
                |> DropdownMenu.disabled
            ]
        |> DropdownMenu.toHtml []


{-| The menu opens below the trigger by default. `top`, `left` and `right` open it on another side, and it flips to the opposite side when it doesn't fit.
-}
sides : Html msg
sides =
    let
        menu key label place =
            DropdownMenu.new
                |> DropdownMenu.id ("side-" ++ key)
                |> DropdownMenu.trigger
                    (Button.new
                        |> Button.outline
                        |> Button.toAttributes
                    )
                    [ text label ]
                |> DropdownMenu.content
                    [ DropdownMenu.item [] [ text "Profile" ]
                    , DropdownMenu.item [] [ text "Billing" ]
                    , DropdownMenu.item [] [ text "Settings" ]
                    ]
                |> place
                |> DropdownMenu.toHtml []
    in
    div [ class "flex flex-wrap justify-center gap-2" ]
        [ menu "left" "Left" DropdownMenu.left
        , menu "top" "Top" DropdownMenu.top
        , menu "bottom" "Bottom" identity
        , menu "right" "Right" DropdownMenu.right
        ]


{-| Icons go before the text. A `destructive` item is for actions such as logging out.
-}
withIcons : Html msg
withIcons =
    DropdownMenu.new
        |> DropdownMenu.id "with-icons"
        |> DropdownMenu.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Open" ]
        |> DropdownMenu.content
            [ DropdownMenu.item [] [ Phosphor.user Regular |> Phosphor.toHtml [], text "Profile" ]
            , DropdownMenu.item [] [ Phosphor.creditCard Regular |> Phosphor.toHtml [], text "Billing" ]
            , DropdownMenu.item [] [ Phosphor.gear Regular |> Phosphor.toHtml [], text "Settings" ]
            , DropdownMenu.separator
            , DropdownMenu.item [] [ Phosphor.signOut Regular |> Phosphor.toHtml [], text "Log out" ]
                |> DropdownMenu.destructive
            ]
        |> DropdownMenu.toHtml []


{-| `shortcut` shows a keyboard shortcut at the right edge of an item. It is only a hint: handling the key is up to you.
-}
withShortcuts : Html msg
withShortcuts =
    DropdownMenu.new
        |> DropdownMenu.id "with-shortcuts"
        |> DropdownMenu.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Open" ]
        |> DropdownMenu.content
            [ DropdownMenu.group
                [ DropdownMenu.label [ text "My Account" ]
                , DropdownMenu.item [] [ text "Profile", DropdownMenu.shortcut [ text "⇧⌘P" ] ]
                , DropdownMenu.item [] [ text "Billing", DropdownMenu.shortcut [ text "⌘B" ] ]
                , DropdownMenu.item [] [ text "Settings", DropdownMenu.shortcut [ text "⌘S" ] ]
                ]
            , DropdownMenu.separator
            , DropdownMenu.item [] [ text "Log out", DropdownMenu.shortcut [ text "⇧⌘Q" ] ]
            ]
        |> DropdownMenu.toHtml []


{-| A `submenu` opens next to its item on a click, Enter or Space. Escape closes it alone, and picking an item in it closes every menu.
-}
withSubmenu : Html msg
withSubmenu =
    DropdownMenu.new
        |> DropdownMenu.id "with-submenu"
        |> DropdownMenu.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Open" ]
        |> DropdownMenu.content
            [ DropdownMenu.group
                [ DropdownMenu.item [] [ text "Team" ]
                , DropdownMenu.submenu [ text "Invite users" ]
                    [ DropdownMenu.item [] [ text "Email" ]
                    , DropdownMenu.item [] [ text "Message" ]
                    , DropdownMenu.separator
                    , DropdownMenu.item [] [ text "More..." ]
                    ]
                , DropdownMenu.item [] [ text "New Team", DropdownMenu.shortcut [ text "⌘+T" ] ]
                ]
            ]
        |> DropdownMenu.toHtml []


{-| A `checkboxItem` shows the state you give it and keeps the menu open when picked, so several can be flipped at once.
-}
withCheckboxes : State -> Html State.Msg
withCheckboxes state =
    let
        checked key default =
            State.get key state
                |> Maybe.withDefault default
                |> (==) "on"

        toggle key default =
            State.set key
                (if checked key default then
                    "off"

                 else
                    "on"
                )
    in
    DropdownMenu.new
        |> DropdownMenu.id "with-checkboxes"
        |> DropdownMenu.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Checkboxes" ]
        |> DropdownMenu.content
            [ DropdownMenu.group
                [ DropdownMenu.label [ text "Appearance" ]
                , DropdownMenu.checkboxItem (checked "status-bar" "on")
                    [ onClick (toggle "status-bar" "on") ]
                    [ Phosphor.layout Regular |> Phosphor.toHtml [], text "Status Bar" ]
                , DropdownMenu.checkboxItem (checked "activity-bar" "off")
                    [ onClick (toggle "activity-bar" "off") ]
                    [ Phosphor.pulse Regular |> Phosphor.toHtml [], text "Activity Bar" ]
                    |> DropdownMenu.disabled
                , DropdownMenu.checkboxItem (checked "panel" "off")
                    [ onClick (toggle "panel" "off") ]
                    [ Phosphor.sidebar Regular |> Phosphor.toHtml [], text "Panel" ]
                ]
            ]
        |> DropdownMenu.toHtml [ class "min-w-40" ]


{-| `radioItem`s share a value in your model: the one equal to it is checked.
-}
withRadioGroup : State -> Html State.Msg
withRadioGroup state =
    let
        position =
            State.get "panel-position" state
                |> Maybe.withDefault "bottom"

        option value icon label =
            DropdownMenu.radioItem (position == value)
                [ onClick (State.set "panel-position" value) ]
                [ icon Regular |> Phosphor.toHtml [], text label ]
    in
    DropdownMenu.new
        |> DropdownMenu.id "with-radio-group"
        |> DropdownMenu.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Radio Group" ]
        |> DropdownMenu.content
            [ DropdownMenu.group
                [ DropdownMenu.label [ text "Panel Position" ]
                , option "top" Phosphor.arrowUp "Top"
                , option "bottom" Phosphor.arrowDown "Bottom"
                , option "right" Phosphor.arrowRight "Right"
                    |> DropdownMenu.disabled
                ]
            ]
        |> DropdownMenu.toHtml []


{-| `inset` indents items and labels without an icon or a check mark so that they line up with the ones that have one.
-}
withInset : State -> Html State.Msg
withInset state =
    let
        checked key default =
            State.get key state
                |> Maybe.withDefault default
                |> (==) "on"

        toggle key default =
            State.set key
                (if checked key default then
                    "off"

                 else
                    "on"
                )

        theme =
            State.get "theme" state
                |> Maybe.withDefault "system"

        option value label =
            DropdownMenu.radioItem (theme == value)
                [ onClick (State.set "theme" value) ]
                [ text label ]
    in
    DropdownMenu.new
        |> DropdownMenu.id "with-inset"
        |> DropdownMenu.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Open" ]
        |> DropdownMenu.content
            [ DropdownMenu.group
                [ DropdownMenu.label [ text "Actions" ]
                , DropdownMenu.item [] [ Phosphor.copy Regular |> Phosphor.toHtml [], text "Copy" ]
                , DropdownMenu.item [] [ Phosphor.scissors Regular |> Phosphor.toHtml [], text "Cut" ]
                , DropdownMenu.item [] [ text "Paste" ]
                    |> DropdownMenu.inset
                ]
            , DropdownMenu.separator
            , DropdownMenu.group
                [ DropdownMenu.label [ text "Appearance" ]
                    |> DropdownMenu.inset
                , DropdownMenu.checkboxItem (checked "bookmarks" "on")
                    [ onClick (toggle "bookmarks" "on") ]
                    [ text "Bookmarks" ]
                    |> DropdownMenu.inset
                , DropdownMenu.checkboxItem (checked "full-urls" "off")
                    [ onClick (toggle "full-urls" "off") ]
                    [ text "Full URLs" ]
                    |> DropdownMenu.inset
                ]
            , DropdownMenu.separator
            , DropdownMenu.group
                [ DropdownMenu.label [ text "Theme" ]
                    |> DropdownMenu.inset
                , option "light" "Light"
                    |> DropdownMenu.inset
                , option "dark" "Dark"
                    |> DropdownMenu.inset
                , option "system" "System"
                    |> DropdownMenu.inset
                ]
            ]
        |> DropdownMenu.toHtml [ class "w-44" ]
