module Examples.Sidebar.Block09 exposing (view)

{-| shadcn's `sidebar-09` block: collapsible nested sidebars.

An icon-collapsible sidebar holds two sidebars that never collapse, side by side: a strip of
mailbox icons and the list of mails in the active mailbox. Picking a mailbox opens the
sidebar and changes the list.

-}

import Html exposing (Html, a, div, span, text)
import Html.Attributes exposing (alt, attribute, checked, class, href, placeholder, src)
import Html.Events exposing (onCheck, onClick)
import Phosphor exposing (IconVariant, IconWeight(..))
import State exposing (State)
import UI.Avatar as Avatar
import UI.Breadcrumb as Breadcrumb
import UI.DropdownMenu as DropdownMenu
import UI.Input as Input
import UI.Label as Label
import UI.Separator as Separator
import UI.Sidebar as Sidebar
import UI.Switch as Switch


view : State -> Html State.Msg
view state =
    Sidebar.new
        |> Sidebar.state (sidebarState "block09" state) (setSidebarState "block09")
        |> Sidebar.collapsesToIcons
        |> Sidebar.width "350px"
        |> Sidebar.content [ iconSidebar state, mailSidebar state ]
        |> Sidebar.page []
            [ Html.header [ class "sticky top-0 flex shrink-0 items-center gap-2 border-b bg-background p-4" ]
                [ Sidebar.trigger [ class "-ml-1" ] (sidebarState "block09" state) (setSidebarState "block09")
                , Separator.new
                    |> Separator.vertical
                    |> Separator.toHtml [ class "mr-2 my-auto data-[orientation=vertical]:h-4" ]
                , Breadcrumb.new
                    |> Breadcrumb.item [ class "hidden md:block" ]
                        [ a [ attribute "data-slot" "breadcrumb-link", class "transition-colors hover:text-foreground", href "#" ] [ text "All Inboxes" ] ]
                    |> Breadcrumb.page [ text "Inbox" ]
                    |> Breadcrumb.separator
                        (Phosphor.caretRight Regular
                            |> Phosphor.withClass "hidden md:block"
                            |> Phosphor.toHtml []
                        )
                    |> Breadcrumb.toHtml []
                ]
            , div [ class "flex flex-1 flex-col gap-4 p-4" ]
                (List.repeat 24 (div [ class "aspect-video h-12 w-full rounded-lg bg-muted/50" ] []))
            ]
        -- Upstream: `overflow-hidden *:data-[sidebar=sidebar]:flex-row` on the outer sidebar. The
        -- nested sidebars sit in the outer content, which becomes the row.
        |> Sidebar.toHtml
            [ class "[&_[data-slot=sidebar-inner]>[data-slot=sidebar-content]]:flex-row [&_[data-slot=sidebar-inner]>[data-slot=sidebar-content]]:overflow-hidden" ]



-- FIRST SIDEBAR


{-| Collapsing is disabled and the width is adjusted to the icon width, so it looks like a strip of icons.
-}
iconSidebar : State -> Html State.Msg
iconSidebar state =
    Sidebar.new
        |> Sidebar.state Sidebar.init (\_ -> State.none)
        |> Sidebar.neverCollapses
        |> Sidebar.width "calc(var(--sidebar-width-icon) + 1px)"
        |> Sidebar.header
            [ Sidebar.menu []
                [ Sidebar.menuItem []
                    [ Sidebar.menuLink [ href "#", Sidebar.large, class "md:h-8 md:p-0" ]
                        [ div [ class "flex aspect-square size-8 items-center justify-center rounded-lg bg-sidebar-primary text-sidebar-primary-foreground" ]
                            [ Phosphor.command Regular
                                |> Phosphor.withClass "size-4"
                                |> Phosphor.toHtml []
                            ]
                        , div [ class "grid flex-1 text-left text-sm leading-tight" ]
                            [ span [ class "truncate font-medium" ] [ text "Acme Inc" ]
                            , span [ class "truncate text-xs" ] [ text "Enterprise" ]
                            ]
                        ]
                    ]
                ]
            ]
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.groupContent [ class "px-1.5 md:px-0" ]
                    [ Sidebar.menu [] (List.map (navItem state) navMain) ]
                ]
            ]
        |> Sidebar.footer [ navUser ]
        -- The wrapper gets out of the way so the sidebar itself is the row's child.
        |> Sidebar.toHtml [ class "contents! [&>[data-slot=sidebar]]:border-r" ]


navItem : State -> NavItem -> Html State.Msg
navItem state item =
    let
        sidebar =
            sidebarState "block09" state
    in
    Sidebar.menuItem []
        [ Sidebar.menuButton
            ([ Sidebar.tooltip item.title
             , class "px-2.5 md:px-2"
             , onClick
                (State.batch
                    [ State.set "block09-active" item.title
                    , setSidebarState "block09" { sidebar | open = True }
                    ]
                )
             ]
                ++ (if activeItem state == item.title then
                        [ Sidebar.active ]

                    else
                        []
                   )
            )
            [ icon item.icon
            , span [] [ text item.title ]
            ]
        ]


navUser : Html State.Msg
navUser =
    let
        avatar =
            Avatar.new
                |> Avatar.fallback [ text "CN" ]
                |> Avatar.img [ src "https://github.com/shadcn.png", alt user.name ]
                |> Avatar.toHtml [ class "h-8 w-8 rounded-lg" ]

        details =
            div [ class "grid flex-1 text-left text-sm leading-tight" ]
                [ span [ class "truncate font-medium" ] [ text user.name ]
                , span [ class "truncate text-xs" ] [ text user.email ]
                ]
    in
    Sidebar.menu []
        [ Sidebar.menuItem []
            [ DropdownMenu.new
                |> DropdownMenu.id "block09-nav-user"
                |> DropdownMenu.trigger (Sidebar.menuButtonAttributes ++ [ Sidebar.large, class "md:h-8 md:p-0" ])
                    [ avatar
                    , details
                    , Phosphor.caretUpDown Regular
                        |> Phosphor.withClass "ml-auto size-4"
                        |> Phosphor.toHtml []
                    ]
                |> DropdownMenu.content
                    [ DropdownMenu.label
                        [ div [ class "flex items-center gap-2 px-1 py-1.5 text-left text-sm font-normal" ] [ avatar, details ] ]
                    , DropdownMenu.separator
                    , DropdownMenu.group
                        [ DropdownMenu.item [] [ icon Phosphor.sparkle, text "Upgrade to Pro" ] ]
                    , DropdownMenu.separator
                    , DropdownMenu.group
                        [ DropdownMenu.item [] [ icon Phosphor.sealCheck, text "Account" ]
                        , DropdownMenu.item [] [ icon Phosphor.creditCard, text "Billing" ]
                        , DropdownMenu.item [] [ icon Phosphor.bell, text "Notifications" ]
                        ]
                    , DropdownMenu.separator
                    , DropdownMenu.item [] [ icon Phosphor.signOut, text "Log out" ]
                    ]
                |> DropdownMenu.right
                |> DropdownMenu.alignEnd
                |> DropdownMenu.toHtml [ class "min-w-56 rounded-lg" ]
            ]
        ]



-- SECOND SIDEBAR


{-| Collapsing is disabled and the sidebar fills the remaining space.
-}
mailSidebar : State -> Html State.Msg
mailSidebar state =
    let
        unreads =
            State.get "block09-unreads" state == Just "true"
    in
    Sidebar.new
        |> Sidebar.state Sidebar.init (\_ -> State.none)
        |> Sidebar.neverCollapses
        |> Sidebar.header
            [ div [ class "flex w-full items-center justify-between" ]
                [ div [ class "text-base font-medium text-foreground" ] [ text (activeItem state) ]
                , Label.view [ class "flex items-center gap-2 text-sm" ]
                    [ span [] [ text "Unreads" ]
                    , Switch.new
                        |> Switch.toHtml
                            [ class "shadow-none"
                            , checked unreads
                            , onCheck (\on -> State.set "block09-unreads" (bool on))
                            ]
                    ]
                ]
            , Input.view [ class "h-8 bg-background shadow-none", placeholder "Type to search..." ]
            ]
        |> Sidebar.content
            [ Sidebar.group [ class "px-0" ]
                [ Sidebar.groupContent [] (List.map mailItem (mailsFor (activeItem state))) ]
            ]
        -- Upstream: `hidden flex-1 md:flex` on the sidebar and `gap-3.5 border-b p-4` on its header.
        |> Sidebar.toHtml
            [ class "contents! [&>[data-slot=sidebar]]:flex-1 [&>[data-slot=sidebar]]:max-md:hidden"
            , class "[&_[data-slot=sidebar-header]]:gap-3.5 [&_[data-slot=sidebar-header]]:border-b [&_[data-slot=sidebar-header]]:p-4"
            ]


mailItem : Mail -> Html msg
mailItem mail =
    a [ href "#", class "flex flex-col items-start gap-2 border-b p-4 text-sm leading-tight whitespace-nowrap last:border-b-0 hover:bg-sidebar-accent hover:text-sidebar-accent-foreground" ]
        [ div [ class "flex w-full items-center gap-2" ]
            [ span [] [ text mail.name ]
            , text " "
            , span [ class "ml-auto text-xs" ] [ text mail.date ]
            ]
        , span [ class "font-medium" ] [ text mail.subject ]
        , span [ class "line-clamp-2 w-[260px] text-xs whitespace-break-spaces" ] [ text mail.teaser ]
        ]


{-| Upstream shuffles the mails and shows between 5 and 10 of them each time a mailbox is
picked. Without randomness, each mailbox gets its own rotation and count of the same list.
-}
mailsFor : String -> List Mail
mailsFor title =
    let
        index =
            List.indexedMap Tuple.pair navMain
                |> List.filter (\( _, item ) -> item.title == title)
                |> List.head
                |> Maybe.map Tuple.first
                |> Maybe.withDefault 0
    in
    (List.drop (index * 2) mails ++ List.take (index * 2) mails)
        |> List.take (10 - index)



-- STATE


activeItem : State -> String
activeItem state =
    State.get "block09-active" state
        |> Maybe.withDefault "Inbox"


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



-- DATA


type alias NavItem =
    { title : String
    , icon : IconWeight -> IconVariant
    }


type alias Mail =
    { name : String
    , email : String
    , subject : String
    , date : String
    , teaser : String
    }


user : { name : String, email : String }
user =
    { name = "shadcn", email = "m@example.com" }


navMain : List NavItem
navMain =
    [ NavItem "Inbox" Phosphor.tray
    , NavItem "Drafts" Phosphor.file
    , NavItem "Sent" Phosphor.paperPlaneTilt
    , NavItem "Junk" Phosphor.archive
    , NavItem "Trash" Phosphor.trash
    ]


mails : List Mail
mails =
    [ Mail "William Smith" "williamsmith@example.com" "Meeting Tomorrow" "09:34 AM" "Hi team, just a reminder about our meeting tomorrow at 10 AM.\nPlease come prepared with your project updates."
    , Mail "Alice Smith" "alicesmith@example.com" "Re: Project Update" "Yesterday" "Thanks for the update. The progress looks great so far.\nLet's schedule a call to discuss the next steps."
    , Mail "Bob Johnson" "bobjohnson@example.com" "Weekend Plans" "2 days ago" "Hey everyone! I'm thinking of organizing a team outing this weekend.\nWould you be interested in a hiking trip or a beach day?"
    , Mail "Emily Davis" "emilydavis@example.com" "Re: Question about Budget" "2 days ago" "I've reviewed the budget numbers you sent over.\nCan we set up a quick call to discuss some potential adjustments?"
    , Mail "Michael Wilson" "michaelwilson@example.com" "Important Announcement" "1 week ago" "Please join us for an all-hands meeting this Friday at 3 PM.\nWe have some exciting news to share about the company's future."
    , Mail "Sarah Brown" "sarahbrown@example.com" "Re: Feedback on Proposal" "1 week ago" "Thank you for sending over the proposal. I've reviewed it and have some thoughts.\nCould we schedule a meeting to discuss my feedback in detail?"
    , Mail "David Lee" "davidlee@example.com" "New Project Idea" "1 week ago" "I've been brainstorming and came up with an interesting project concept.\nDo you have time this week to discuss its potential impact and feasibility?"
    , Mail "Olivia Wilson" "oliviawilson@example.com" "Vacation Plans" "1 week ago" "Just a heads up that I'll be taking a two-week vacation next month.\nI'll make sure all my projects are up to date before I leave."
    , Mail "James Martin" "jamesmartin@example.com" "Re: Conference Registration" "1 week ago" "I've completed the registration for the upcoming tech conference.\nLet me know if you need any additional information from my end."
    , Mail "Sophia White" "sophiawhite@example.com" "Team Dinner" "1 week ago" "To celebrate our recent project success, I'd like to organize a team dinner.\nAre you available next Friday evening? Please let me know your preferences."
    ]
