module Examples.DropdownMenu exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (alt, class, dir, src)
import Html.Events exposing (onClick)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.Avatar as Avatar
import UI.Button as Button
import UI.DropdownMenu as DropdownMenu


demo : Html msg
demo =
    DropdownMenu.new
        |> DropdownMenu.id "demo"
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
            , DropdownMenu.group
                [ DropdownMenu.item [] [ text "Team" ]
                , DropdownMenu.submenu [ text "Invite users" ]
                    [ DropdownMenu.item [] [ text "Email" ]
                    , DropdownMenu.item [] [ text "Message" ]
                    , DropdownMenu.separator
                    , DropdownMenu.item [] [ text "More..." ]
                    ]
                , DropdownMenu.item [] [ text "New Team", DropdownMenu.shortcut [ text "⌘+T" ] ]
                ]
            , DropdownMenu.separator
            , DropdownMenu.group
                [ DropdownMenu.item [] [ text "GitHub" ]
                , DropdownMenu.item [] [ text "Support" ]
                , DropdownMenu.item [] [ text "API" ]
                    |> DropdownMenu.disabled
                ]
            , DropdownMenu.separator
            , DropdownMenu.group
                [ DropdownMenu.item [] [ text "Log out", DropdownMenu.shortcut [ text "⇧⌘Q" ] ] ]
            ]
        |> DropdownMenu.toHtml [ class "w-40" ]


basic : Html msg
basic =
    DropdownMenu.new
        |> DropdownMenu.id "basic-menu"
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


{-| A `submenu` opens next to its item on a click, Enter or Space. Escape closes it alone, and picking an item in it closes every menu.
-}
submenu : Html msg
submenu =
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


{-| `shortcut` shows a keyboard shortcut at the right edge of an item. It is only a hint: handling the key is up to you.
-}
shortcuts : Html msg
shortcuts =
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


{-| Icons go before the text. A `destructive` item is for actions such as logging out.
-}
icons : Html msg
icons =
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


{-| A `checkboxItem` shows the state you give it and keeps the menu open when picked, so several can be flipped at once.
-}
checkboxes : State -> Html State.Msg
checkboxes state =
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


{-| Icons work in checkbox items too, and the check mark stays on the right.
-}
checkboxesIcons : State -> Html State.Msg
checkboxesIcons state =
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

        option key default icon label =
            DropdownMenu.checkboxItem (checked key default)
                [ onClick (toggle key default) ]
                [ icon Regular |> Phosphor.toHtml [], text label ]
    in
    DropdownMenu.new
        |> DropdownMenu.id "with-checkboxes-icons"
        |> DropdownMenu.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Notifications" ]
        |> DropdownMenu.content
            [ DropdownMenu.group
                [ DropdownMenu.label [ text "Notification Preferences" ]
                , option "email" "on" Phosphor.envelope "Email notifications"
                , option "sms" "off" Phosphor.chatText "SMS notifications"
                , option "push" "on" Phosphor.bell "Push notifications"
                ]
            ]
        |> DropdownMenu.toHtml [ class "w-48" ]


{-| `radioItem`s share a value in your model: the one equal to it is checked.
-}
radioGroup : State -> Html State.Msg
radioGroup state =
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


{-| Icons work in radio items too, and the check mark stays on the right.
-}
radioIcons : State -> Html State.Msg
radioIcons state =
    let
        method =
            State.get "payment-method" state
                |> Maybe.withDefault "card"

        option value icon label =
            DropdownMenu.radioItem (method == value)
                [ onClick (State.set "payment-method" value) ]
                [ icon Regular |> Phosphor.toHtml [], text label ]
    in
    DropdownMenu.new
        |> DropdownMenu.id "with-radio-icons"
        |> DropdownMenu.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Payment Method" ]
        |> DropdownMenu.content
            [ DropdownMenu.group
                [ DropdownMenu.label [ text "Select Payment Method" ]
                , option "card" Phosphor.creditCard "Credit Card"
                , option "paypal" Phosphor.wallet "PayPal"
                , option "bank" Phosphor.bank "Bank Transfer"
                ]
            ]
        |> DropdownMenu.toHtml [ class "min-w-56" ]


{-| Mark the item for a dangerous action with `destructive`, and keep it apart from the others with a separator.
-}
destructive : Html msg
destructive =
    DropdownMenu.new
        |> DropdownMenu.id "destructive"
        |> DropdownMenu.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Actions" ]
        |> DropdownMenu.content
            [ DropdownMenu.group
                [ DropdownMenu.item [] [ Phosphor.pencilSimple Regular |> Phosphor.toHtml [], text "Edit" ]
                , DropdownMenu.item [] [ Phosphor.shareNetwork Regular |> Phosphor.toHtml [], text "Share" ]
                ]
            , DropdownMenu.separator
            , DropdownMenu.group
                [ DropdownMenu.item [] [ Phosphor.trash Regular |> Phosphor.toHtml [], text "Delete" ]
                    |> DropdownMenu.destructive
                ]
            ]
        |> DropdownMenu.toHtml []


{-| The trigger can be anything: here an icon button around an `Avatar`. `alignEnd` lines the menu up with the end of the trigger.
-}
avatar : Html msg
avatar =
    let
        picture =
            Avatar.new
                |> Avatar.fallback [ text "LR" ]
                |> Avatar.img [ src "https://github.com/shadcn.png", alt "shadcn" ]
                |> Avatar.toHtml []
    in
    DropdownMenu.new
        |> DropdownMenu.id "avatar"
        |> DropdownMenu.trigger
            (Button.new
                |> Button.icon picture
                |> Button.label "Account"
                |> Button.ghost
                |> Button.rounded
                |> Button.toAttributes
            )
            [ picture ]
        |> DropdownMenu.content
            [ DropdownMenu.group
                [ DropdownMenu.item [] [ Phosphor.sealCheck Regular |> Phosphor.toHtml [], text "Account" ]
                , DropdownMenu.item [] [ Phosphor.creditCard Regular |> Phosphor.toHtml [], text "Billing" ]
                , DropdownMenu.item [] [ Phosphor.bell Regular |> Phosphor.toHtml [], text "Notifications" ]
                ]
            , DropdownMenu.separator
            , DropdownMenu.item [] [ Phosphor.signOut Regular |> Phosphor.toHtml [], text "Sign Out" ]
            ]
        |> DropdownMenu.alignEnd
        |> DropdownMenu.toHtml []


{-| Submenus nest to any depth, and checkbox and radio items work inside them.
-}
complex : State -> Html State.Msg
complex state =
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

        check key default icon label =
            DropdownMenu.checkboxItem (checked key default)
                [ onClick (toggle key default) ]
                [ icon Regular |> Phosphor.toHtml [], text label ]

        theme =
            State.get "complex-theme" state
                |> Maybe.withDefault "light"

        option value icon label =
            DropdownMenu.radioItem (theme == value)
                [ onClick (State.set "complex-theme" value) ]
                [ icon Regular |> Phosphor.toHtml [], text label ]

        entry icon label =
            DropdownMenu.item [] [ icon Regular |> Phosphor.toHtml [], text label ]

        sub icon label items =
            DropdownMenu.submenu [ icon Regular |> Phosphor.toHtml [], text label ] items
    in
    DropdownMenu.new
        |> DropdownMenu.id "complex"
        |> DropdownMenu.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Complex Menu" ]
        |> DropdownMenu.content
            [ DropdownMenu.group
                [ DropdownMenu.label [ text "File" ]
                , DropdownMenu.item [] [ Phosphor.file Regular |> Phosphor.toHtml [], text "New File", DropdownMenu.shortcut [ text "⌘N" ] ]
                , DropdownMenu.item [] [ Phosphor.folder Regular |> Phosphor.toHtml [], text "New Folder", DropdownMenu.shortcut [ text "⇧⌘N" ] ]
                , sub Phosphor.folderOpen
                    "Open Recent"
                    [ DropdownMenu.group
                        [ DropdownMenu.label [ text "Recent Projects" ]
                        , entry Phosphor.fileCode "Project Alpha"
                        , entry Phosphor.fileCode "Project Beta"
                        , sub Phosphor.dotsThree
                            "More Projects"
                            [ entry Phosphor.fileCode "Project Gamma"
                            , entry Phosphor.fileCode "Project Delta"
                            ]
                        ]
                    , DropdownMenu.separator
                    , DropdownMenu.group
                        [ entry Phosphor.magnifyingGlass "Browse..." ]
                    ]
                , DropdownMenu.separator
                , DropdownMenu.item [] [ Phosphor.floppyDisk Regular |> Phosphor.toHtml [], text "Save", DropdownMenu.shortcut [ text "⌘S" ] ]
                , DropdownMenu.item [] [ Phosphor.downloadSimple Regular |> Phosphor.toHtml [], text "Export", DropdownMenu.shortcut [ text "⇧⌘E" ] ]
                ]
            , DropdownMenu.separator
            , DropdownMenu.group
                [ DropdownMenu.label [ text "View" ]
                , check "complex-sidebar" "on" Phosphor.eye "Show Sidebar"
                , check "complex-status-bar" "off" Phosphor.layout "Show Status Bar"
                , sub Phosphor.palette
                    "Theme"
                    [ DropdownMenu.group
                        [ DropdownMenu.label [ text "Appearance" ]
                        , option "light" Phosphor.sun "Light"
                        , option "dark" Phosphor.moon "Dark"
                        , option "system" Phosphor.monitor "System"
                        ]
                    ]
                ]
            , DropdownMenu.separator
            , DropdownMenu.group
                [ DropdownMenu.label [ text "Account" ]
                , DropdownMenu.item [] [ Phosphor.user Regular |> Phosphor.toHtml [], text "Profile", DropdownMenu.shortcut [ text "⇧⌘P" ] ]
                , entry Phosphor.creditCard "Billing"
                , sub Phosphor.gear
                    "Settings"
                    [ DropdownMenu.group
                        [ DropdownMenu.label [ text "Preferences" ]
                        , entry Phosphor.keyboard "Keyboard Shortcuts"
                        , entry Phosphor.translate "Language"
                        , sub Phosphor.bell
                            "Notifications"
                            [ DropdownMenu.group
                                [ DropdownMenu.label [ text "Notification Types" ]
                                , check "complex-push" "on" Phosphor.bell "Push Notifications"
                                , check "complex-email" "on" Phosphor.envelope "Email Notifications"
                                ]
                            ]
                        ]
                    , DropdownMenu.separator
                    , DropdownMenu.group
                        [ entry Phosphor.shield "Privacy & Security" ]
                    ]
                ]
            , DropdownMenu.separator
            , DropdownMenu.group
                [ entry Phosphor.question "Help & Support"
                , entry Phosphor.fileText "Documentation"
                ]
            , DropdownMenu.separator
            , DropdownMenu.group
                [ DropdownMenu.item [] [ Phosphor.signOut Regular |> Phosphor.toHtml [], text "Sign Out", DropdownMenu.shortcut [ text "⇧⌘Q" ] ]
                    |> DropdownMenu.destructive
                ]
            ]
        |> DropdownMenu.toHtml [ class "w-44" ]


{-| In right-to-left text the menu opens from the end of the trigger and its submenus open to the left. Items, check marks and shortcuts follow the text direction.
-}
rtl : State -> Html State.Msg
rtl state =
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

        check key default label =
            DropdownMenu.checkboxItem (checked key default)
                [ onClick (toggle key default) ]
                [ text label ]

        position =
            State.get "rtl-position" state
                |> Maybe.withDefault "bottom"

        option value label =
            DropdownMenu.radioItem (position == value)
                [ onClick (State.set "rtl-position" value) ]
                [ text label ]
    in
    div [ dir "rtl" ]
        [ DropdownMenu.new
            |> DropdownMenu.id "rtl"
            |> DropdownMenu.trigger
                (Button.new
                    |> Button.outline
                    |> Button.toAttributes
                )
                [ text "افتح القائمة" ]
            |> DropdownMenu.content
                [ DropdownMenu.group
                    [ DropdownMenu.submenu [ text "الحساب" ]
                        [ DropdownMenu.group
                            [ DropdownMenu.item [] [ Phosphor.user Regular |> Phosphor.toHtml [], text "الملف الشخصي" ]
                            , DropdownMenu.item [] [ Phosphor.creditCard Regular |> Phosphor.toHtml [], text "الفوترة" ]
                            , DropdownMenu.item [] [ Phosphor.gear Regular |> Phosphor.toHtml [], text "الإعدادات" ]
                            ]
                        ]
                    ]
                , DropdownMenu.separator
                , DropdownMenu.group
                    [ DropdownMenu.label [ text "الفريق" ]
                    , DropdownMenu.item [] [ text "الفريق" ]
                    , DropdownMenu.submenu [ text "دعوة المستخدمين" ]
                        [ DropdownMenu.item [] [ text "البريد الإلكتروني" ]
                        , DropdownMenu.item [] [ text "رسالة" ]
                        , DropdownMenu.submenu [ text "المزيد" ]
                            [ DropdownMenu.item [] [ text "تقويم" ]
                            , DropdownMenu.item [] [ text "دردشة" ]
                            , DropdownMenu.separator
                            , DropdownMenu.item [] [ text "خطاف ويب" ]
                            ]
                        , DropdownMenu.separator
                        , DropdownMenu.item [] [ text "متقدم..." ]
                        ]
                    , DropdownMenu.item [] [ text "فريق جديد", DropdownMenu.shortcut [ text "⌘+T" ] ]
                    ]
                , DropdownMenu.separator
                , DropdownMenu.group
                    [ DropdownMenu.label [ text "عرض" ]
                    , check "rtl-status-bar" "on" "شريط الحالة"
                    , check "rtl-activity-bar" "off" "شريط النشاط"
                    , check "rtl-panel" "off" "اللوحة"
                    ]
                , DropdownMenu.separator
                , DropdownMenu.group
                    [ DropdownMenu.label [ text "الموضع" ]
                    , option "top" "أعلى"
                    , option "bottom" "أسفل"
                    , option "right" "يمين"
                    , option "left" "يسار"
                    ]
                , DropdownMenu.separator
                , DropdownMenu.group
                    [ DropdownMenu.item [] [ text "تسجيل الخروج" ]
                        |> DropdownMenu.destructive
                    ]
                ]
            |> DropdownMenu.alignEnd
            |> DropdownMenu.toHtml [ class "w-36" ]
        ]


{-| `inset` indents items and labels without an icon or a check mark so that they line up with the ones that have one.
-}
inset : State -> Html State.Msg
inset state =
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
