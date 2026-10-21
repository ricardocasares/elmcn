module Examples.Sidebar.Block13 exposing (view)

{-| A sidebar in a dialog: shadcn's sidebar-13 block.
-}

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (attribute, class, href)
import Html.Events exposing (onClick, preventDefaultOn)
import Json.Decode as Decode
import Phosphor exposing (IconVariant, IconWeight(..))
import State exposing (State)
import UI.Breadcrumb as Breadcrumb
import UI.Button as Button
import UI.Dialog as Dialog
import UI.Sidebar as Sidebar


view : State -> Html State.Msg
view state =
    div [ class "flex h-svh items-center justify-center" ]
        [ settingsDialog state ]



-- SETTINGS DIALOG


type alias NavItem =
    { name : String, icon : IconWeight -> IconVariant }


nav : List NavItem
nav =
    [ NavItem "Notifications" Phosphor.bell
    , NavItem "Navigation" Phosphor.list
    , NavItem "Home" Phosphor.house
    , NavItem "Appearance" Phosphor.palette
    , NavItem "Messages & media" Phosphor.chatCircle
    , NavItem "Language & region" Phosphor.globe
    , NavItem "Accessibility" Phosphor.keyboard
    , NavItem "Mark as read" Phosphor.check
    , NavItem "Audio & video" Phosphor.video
    , NavItem "Connected accounts" Phosphor.link
    , NavItem "Privacy & visibility" Phosphor.lock
    , NavItem "Advanced" Phosphor.gear
    ]


settingsDialog : State -> Html State.Msg
settingsDialog state =
    let
        isOpen =
            State.get "block13-open" state == Just "true"

        section =
            State.get "block13-section" state
                |> Maybe.withDefault "Messages & media"
    in
    div []
        [ Button.new
            |> Button.text "Open Dialog"
            |> Button.small
            |> Button.toHtml [ onClick (State.set "block13-open" "true") ]
        , Dialog.new
            |> Dialog.id "block13-settings"
            |> Dialog.open isOpen (State.set "block13-open" "false")
            |> Dialog.title [ text "Settings" ]
            |> Dialog.description [ text "Customize your settings here." ]
            |> Dialog.content
                [ Sidebar.new
                    |> Sidebar.state (sidebarState "block13" state) (setSidebarState "block13")
                    |> Sidebar.neverCollapses
                    |> Sidebar.content
                        [ Sidebar.group []
                            [ Sidebar.groupContent []
                                [ Sidebar.menu []
                                    (List.map
                                        (\item ->
                                            Sidebar.menuItem []
                                                [ Sidebar.menuLink
                                                    ([ href "#"
                                                     , preventDefaultOn "click" (Decode.succeed ( State.set "block13-section" item.name, True ))
                                                     ]
                                                        ++ (if item.name == section then
                                                                [ Sidebar.active ]

                                                            else
                                                                []
                                                           )
                                                    )
                                                    [ icon item.icon
                                                    , span [] [ text item.name ]
                                                    ]
                                                ]
                                        )
                                        nav
                                    )
                                ]
                            ]
                        ]
                    |> Sidebar.page [ class "flex h-[480px] flex-1 flex-col overflow-hidden" ]
                        [ Html.header [ class "flex h-16 shrink-0 items-center gap-2 transition-[width,height] ease-linear group-has-data-[collapsible=icon]/sidebar-wrapper:h-12" ]
                            [ div [ class "flex items-center gap-2 px-4" ]
                                [ Breadcrumb.new
                                    |> Breadcrumb.item [ class "hidden md:block" ]
                                        [ Html.a [ attribute "data-slot" "breadcrumb-link", class "transition-colors hover:text-foreground", href "#" ] [ text "Settings" ] ]
                                    |> Breadcrumb.page [ text section ]
                                    |> Breadcrumb.separator
                                        (Phosphor.caretRight Regular
                                            |> Phosphor.withClass "hidden md:block"
                                            |> Phosphor.toHtml []
                                        )
                                    |> Breadcrumb.toHtml []
                                ]
                            ]
                        , div [ class "flex flex-1 flex-col gap-4 overflow-y-auto p-4 pt-0" ]
                            (List.repeat 10 (div [ class "aspect-video max-w-3xl rounded-xl bg-muted/50" ] []))
                        ]
                    -- Upstream gives the sidebar `hidden md:flex`; the wrapper's attributes
                    -- are the only ones we can set, so the sidebar is hidden through it.
                    |> Sidebar.toHtml [ class "items-start max-md:[&>[data-slot=sidebar]]:hidden" ]
                ]
            -- `gap-0`: the title and description are visually hidden, so their header
            -- row must not open a gap above the sidebar.
            |> Dialog.toHtml [ class "gap-0! overflow-hidden p-0! md:max-h-[500px] md:max-w-[700px] lg:max-w-[800px] [&>[data-slot=dialog-header]]:sr-only" ]
        ]



-- HELPERS


{-| The sidebar's state, kept in the docs' shared string map under two keys.
-}
sidebarState : String -> State -> Sidebar.State
sidebarState key state =
    { open = State.get (key ++ "-sidebar-open") state /= Just "false"
    , openMobile = State.get (key ++ "-sidebar-mobile") state == Just "true"
    }


setSidebarState : String -> Sidebar.State -> State.Msg
setSidebarState key sidebar =
    State.batch
        [ State.set (key ++ "-sidebar-open") (bool sidebar.open)
        , State.set (key ++ "-sidebar-mobile") (bool sidebar.openMobile)
        ]


bool : Bool -> String
bool value =
    if value then
        "true"

    else
        "false"


icon : (IconWeight -> IconVariant) -> Html msg
icon i =
    i Regular
        |> Phosphor.toHtml []
