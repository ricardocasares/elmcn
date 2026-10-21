module Examples.Sidebar.Block15 exposing (view)

{-| A left and right sidebar: shadcn's `sidebar-15` block.

The left sidebar holds the team switcher, the main navigation, favorites, workspaces and a secondary navigation. The right one, which never collapses and only shows from `lg` up, holds the user menu, a calendar and the calendar list.

-}

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (alt, attribute, class, href, src, title, type_)
import Html.Events exposing (onClick)
import Phosphor exposing (IconVariant, IconWeight(..))
import State exposing (State)
import UI.Avatar as Avatar
import UI.Breadcrumb as Breadcrumb
import UI.DropdownMenu as DropdownMenu
import UI.Separator as Separator
import UI.Sidebar as Sidebar


view : State -> Html State.Msg
view state =
    Sidebar.new
        |> Sidebar.state (sidebarState "block15-left" state) (setSidebarState "block15-left")
        |> Sidebar.header [ teamSwitcher state, navMain ]
        |> Sidebar.content [ navFavorites, navWorkspaces, navSecondary ]
        |> Sidebar.rail
        |> Sidebar.page [] [ sidebarRight state ]
        |> Sidebar.toHtml []


{-| The right sidebar and, in its page, the real content. Upstream gives the sidebar `collapsible="none"` and `className="sticky top-0 hidden h-svh border-l lg:flex"`, and its header `h-16 border-b border-sidebar-border`: those go through the wrapper, since the builder takes no attributes for them. `h-svh` is left out because the docs box is shorter than the viewport and the sidebar's own `h-full` fills it.
-}
sidebarRight : State -> Html State.Msg
sidebarRight state =
    Sidebar.new
        |> Sidebar.state (sidebarState "block15-right" state) (setSidebarState "block15-right")
        |> Sidebar.right
        |> Sidebar.neverCollapses
        |> Sidebar.header [ navUser ]
        |> Sidebar.content
            (datePicker
                :: Sidebar.separator [ class "mx-0" ]
                :: calendars
            )
        |> Sidebar.footer
            [ Sidebar.menu []
                [ Sidebar.menuItem []
                    [ Sidebar.menuButton []
                        [ icon Phosphor.plus
                        , span [] [ text "New Calendar" ]
                        ]
                    ]
                ]
            ]
        |> Sidebar.page [] (pageContent state)
        |> Sidebar.toHtml
            [ class "h-full min-h-0"
            , class "[&>[data-slot=sidebar]]:sticky [&>[data-slot=sidebar]]:top-0 [&>[data-slot=sidebar]]:hidden [&>[data-slot=sidebar]]:border-l lg:[&>[data-slot=sidebar]]:flex"
            , class "[&>[data-slot=sidebar]>[data-slot=sidebar-header]]:h-16 [&>[data-slot=sidebar]>[data-slot=sidebar-header]]:border-b [&>[data-slot=sidebar]>[data-slot=sidebar-header]]:border-sidebar-border"
            ]


pageContent : State -> List (Html State.Msg)
pageContent state =
    [ Html.header [ class "sticky top-0 flex h-14 shrink-0 items-center gap-2 bg-background" ]
        [ div [ class "flex flex-1 items-center gap-2 px-3" ]
            [ Sidebar.trigger [] (sidebarState "block15-left" state) (setSidebarState "block15-left")
            , Separator.new
                |> Separator.vertical
                |> Separator.toHtml [ class "mr-2 my-auto data-[orientation=vertical]:h-4" ]
            , Breadcrumb.new
                |> Breadcrumb.page [ text "Project Management & Task Tracking" ]
                |> Breadcrumb.separator (icon Phosphor.caretRight)
                |> Breadcrumb.toHtml []
            ]
        ]
    , div [ class "flex flex-1 flex-col gap-4 p-4" ]
        [ div [ class "mx-auto h-24 w-full max-w-3xl rounded-xl bg-muted/50" ] []
        , div [ class "mx-auto h-[100vh] w-full max-w-3xl rounded-xl bg-muted/50" ] []
        ]
    ]



-- LEFT SIDEBAR


type alias Team =
    { name : String, logo : IconWeight -> IconVariant, plan : String }


teams : List Team
teams =
    [ Team "Acme Inc" Phosphor.command "Enterprise"
    , Team "Acme Corp." Phosphor.waveform "Startup"
    , Team "Evil Corp." Phosphor.command "Free"
    ]


teamSwitcher : State -> Html State.Msg
teamSwitcher state =
    let
        activeTeam =
            teams
                |> List.filter (\team -> Just team.name == State.get "block15-team" state)
                |> List.head
                |> Maybe.withDefault (Team "Acme Inc" Phosphor.command "Enterprise")
    in
    Sidebar.menu []
        [ Sidebar.menuItem []
            [ DropdownMenu.new
                |> DropdownMenu.id "block15-team"
                |> DropdownMenu.trigger (Sidebar.menuButtonAttributes ++ [ class "w-fit px-1.5 aria-expanded:bg-muted aria-expanded:text-foreground" ])
                    [ div [ class "flex aspect-square size-5 items-center justify-center rounded-md bg-sidebar-primary text-sidebar-primary-foreground" ]
                        [ icon activeTeam.logo ]
                    , span [ class "truncate font-medium" ] [ text activeTeam.name ]
                    , Phosphor.caretDown Regular
                        |> Phosphor.withClass "opacity-50"
                        |> Phosphor.toHtml []
                    ]
                |> DropdownMenu.content
                    [ DropdownMenu.group
                        (DropdownMenu.label [ span [ class "text-xs text-muted-foreground" ] [ text "Teams" ] ]
                            :: List.indexedMap
                                (\index team ->
                                    DropdownMenu.item [ class "gap-2 p-2", onClick (State.set "block15-team" team.name) ]
                                        [ div [ class "flex size-6 items-center justify-center rounded-xs border" ] [ icon team.logo ]
                                        , text team.name
                                        , DropdownMenu.shortcut [ text ("⌘" ++ String.fromInt (index + 1)) ]
                                        ]
                                )
                                teams
                        )
                    , DropdownMenu.separator
                    , DropdownMenu.group
                        [ DropdownMenu.item [ class "gap-2 p-2" ]
                            [ div [ class "flex size-6 items-center justify-center rounded-md border bg-background" ]
                                [ Phosphor.plus Regular
                                    |> Phosphor.withClass "size-4"
                                    |> Phosphor.toHtml []
                                ]
                            , div [ class "font-medium text-muted-foreground" ] [ text "Add team" ]
                            ]
                        ]
                    ]
                |> DropdownMenu.toHtml [ class "w-64 rounded-lg" ]
            ]
        ]


type alias NavItem =
    { title : String, icon : IconWeight -> IconVariant, isActive : Bool }


navMainItems : List NavItem
navMainItems =
    [ NavItem "Search" Phosphor.magnifyingGlass False
    , NavItem "Ask AI" Phosphor.sparkle False
    , NavItem "Home" Phosphor.house True
    , NavItem "Inbox" Phosphor.tray False
    ]


navMain : Html State.Msg
navMain =
    Sidebar.menu []
        (List.map
            (\item ->
                Sidebar.menuItem []
                    [ Sidebar.menuLink
                        (href "#"
                            :: (if item.isActive then
                                    [ Sidebar.active ]

                                else
                                    []
                               )
                        )
                        [ icon item.icon
                        , span [] [ text item.title ]
                        ]
                    ]
            )
            navMainItems
        )


navSecondaryItems : List NavItem
navSecondaryItems =
    [ NavItem "Calendar" Phosphor.calendar False
    , NavItem "Settings" Phosphor.gear False
    , NavItem "Templates" Phosphor.cube False
    , NavItem "Trash" Phosphor.trash False
    , NavItem "Help" Phosphor.chatCircle False
    ]


navSecondary : Html State.Msg
navSecondary =
    Sidebar.group [ class "mt-auto" ]
        [ Sidebar.groupContent []
            [ Sidebar.menu []
                (List.map
                    (\item ->
                        Sidebar.menuItem []
                            [ Sidebar.menuLink [ href "#" ]
                                [ icon item.icon
                                , span [] [ text item.title ]
                                ]
                            ]
                    )
                    navSecondaryItems
                )
            ]
        ]


type alias Favorite =
    { name : String, emoji : String }


favorites : List Favorite
favorites =
    [ Favorite "Project Management & Task Tracking" "📊"
    , Favorite "Family Recipe Collection & Meal Planning" "🍳"
    , Favorite "Fitness Tracker & Workout Routines" "💪"
    , Favorite "Book Notes & Reading List" "📚"
    , Favorite "Sustainable Gardening Tips & Plant Care" "🌱"
    , Favorite "Language Learning Progress & Resources" "🗣️"
    , Favorite "Home Renovation Ideas & Budget Tracker" "🏠"
    , Favorite "Personal Finance & Investment Portfolio" "💰"
    , Favorite "Movie & TV Show Watchlist with Reviews" "🎬"
    , Favorite "Daily Habit Tracker & Goal Setting" "✅"
    ]


navFavorites : Html State.Msg
navFavorites =
    Sidebar.group [ class "md:group-data-[collapsible=icon]:hidden" ]
        [ Sidebar.groupLabel [] [ text "Favorites" ]
        , Sidebar.menu []
            (List.indexedMap
                (\index item ->
                    Sidebar.menuItem []
                        [ Sidebar.menuLink [ href "#", title item.name ]
                            [ span [] [ text item.emoji ]
                            , span [] [ text item.name ]
                            ]
                        , DropdownMenu.new
                            |> DropdownMenu.id ("block15-favorite-" ++ String.fromInt index)
                            |> DropdownMenu.trigger (Sidebar.menuActionAttributes ++ [ Sidebar.showOnHover, class "aria-expanded:bg-muted" ])
                                [ icon Phosphor.dotsThreeOutline
                                , span [ class "sr-only" ] [ text "More" ]
                                ]
                            |> DropdownMenu.content
                                [ DropdownMenu.item [] [ mutedIcon Phosphor.star, span [] [ text "Remove from Favorites" ] ]
                                , DropdownMenu.separator
                                , DropdownMenu.item [] [ mutedIcon Phosphor.link, span [] [ text "Copy Link" ] ]
                                , DropdownMenu.item [] [ mutedIcon Phosphor.arrowUpRight, span [] [ text "Open in New Tab" ] ]
                                , DropdownMenu.separator
                                , DropdownMenu.item [] [ mutedIcon Phosphor.trash, span [] [ text "Delete" ] ]
                                ]
                            |> DropdownMenu.right
                            |> DropdownMenu.toHtml [ class "w-56 rounded-lg" ]
                        ]
                )
                favorites
                ++ [ Sidebar.menuItem []
                        [ Sidebar.menuButton [ class "text-sidebar-foreground/70" ]
                            [ icon Phosphor.dotsThreeOutline
                            , span [] [ text "More" ]
                            ]
                        ]
                   ]
            )
        ]


type alias Workspace =
    { name : String, emoji : String, pages : List Favorite }


workspaces : List Workspace
workspaces =
    [ Workspace "Personal Life Management"
        "🏠"
        [ Favorite "Daily Journal & Reflection" "📔"
        , Favorite "Health & Wellness Tracker" "🍏"
        , Favorite "Personal Growth & Learning Goals" "🌟"
        ]
    , Workspace "Professional Development"
        "💼"
        [ Favorite "Career Objectives & Milestones" "🎯"
        , Favorite "Skill Acquisition & Training Log" "🧠"
        , Favorite "Networking Contacts & Events" "🤝"
        ]
    , Workspace "Creative Projects"
        "🎨"
        [ Favorite "Writing Ideas & Story Outlines" "✍️"
        , Favorite "Art & Design Portfolio" "🖼️"
        , Favorite "Music Composition & Practice Log" "🎵"
        ]
    , Workspace "Home Management"
        "🏡"
        [ Favorite "Household Budget & Expense Tracking" "💰"
        , Favorite "Home Maintenance Schedule & Tasks" "🔧"
        , Favorite "Family Calendar & Event Planning" "📅"
        ]
    , Workspace "Travel & Adventure"
        "🧳"
        [ Favorite "Trip Planning & Itineraries" "🗺️"
        , Favorite "Travel Bucket List & Inspiration" "🌎"
        , Favorite "Travel Journal & Photo Gallery" "📸"
        ]
    ]


{-| Upstream wraps the whole item in a `Collapsible` whose trigger is the chevron action and whose content is the submenu. A `<details>` can't hold a visible link outside its `<summary>`, so here the item holds the link and the plus action, and a `<details>` with the chevron as its `<summary>`, styled like `Sidebar.collapsible` and `Sidebar.menuAction`.
-}
navWorkspaces : Html State.Msg
navWorkspaces =
    Sidebar.group []
        [ Sidebar.groupLabel [] [ text "Workspaces" ]
        , Sidebar.groupContent []
            [ Sidebar.menu []
                (List.map
                    (\workspace ->
                        Sidebar.menuItem []
                            [ Sidebar.menuLink [ href "#" ]
                                [ span [] [ text workspace.emoji ]
                                , span [] [ text workspace.name ]
                                ]
                            , Sidebar.menuAction [ Sidebar.showOnHover ] [ icon Phosphor.plus ]
                            , Html.details
                                [ attribute "data-slot" "collapsible"
                                , class "group/collapsible details-content:grid details-content:grid-rows-[0fr] details-content:[content-visibility:visible] details-content:transition-[grid-template-rows] details-content:duration-200 details-content:ease-out open:details-content:grid-rows-[1fr]"
                                ]
                                [ Html.summary
                                    (Sidebar.menuActionAttributes
                                        ++ [ Sidebar.showOnHover
                                           , class "cursor-pointer list-none select-none [&::-webkit-details-marker]:hidden"
                                           , class "left-2 bg-sidebar-accent text-sidebar-accent-foreground group-open/collapsible:rotate-90"
                                           ]
                                    )
                                    [ icon Phosphor.caretRight ]
                                , div
                                    [ attribute "data-slot" "collapsible-content"
                                    , class "invisible min-h-0 overflow-hidden transition-[visibility] duration-200 group-open/collapsible:visible"
                                    ]
                                    [ Sidebar.menuSub []
                                        (List.map
                                            (\page ->
                                                Sidebar.menuSubItem []
                                                    [ Sidebar.menuSubLink [ href "#" ]
                                                        [ span [] [ text page.emoji ]
                                                        , span [] [ text page.name ]
                                                        ]
                                                    ]
                                            )
                                            workspace.pages
                                        )
                                    ]
                                ]
                            ]
                    )
                    workspaces
                    ++ [ Sidebar.menuItem []
                            [ Sidebar.menuButton [ class "text-sidebar-foreground/70" ]
                                [ icon Phosphor.dotsThreeOutline
                                , span [] [ text "More" ]
                                ]
                            ]
                       ]
                )
            ]
        ]



-- RIGHT SIDEBAR


navUser : Html State.Msg
navUser =
    let
        avatar =
            Avatar.new
                |> Avatar.fallback [ text "CN" ]
                |> Avatar.img [ src "https://github.com/shadcn.png", alt "shadcn" ]
                |> Avatar.toHtml []

        details =
            div [ class "grid flex-1 text-left text-sm leading-tight" ]
                [ span [ class "truncate font-medium" ] [ text "shadcn" ]
                , span [ class "truncate text-xs" ] [ text "m@example.com" ]
                ]
    in
    Sidebar.menu []
        [ Sidebar.menuItem []
            [ DropdownMenu.new
                |> DropdownMenu.id "block15-user"
                |> DropdownMenu.trigger (Sidebar.menuButtonAttributes ++ [ Sidebar.large, class "aria-expanded:bg-muted" ])
                    [ avatar
                    , details
                    , Phosphor.caretUpDown Regular
                        |> Phosphor.withClass "ml-auto size-4"
                        |> Phosphor.toHtml []
                    ]
                |> DropdownMenu.content
                    [ DropdownMenu.group
                        [ DropdownMenu.label
                            [ div [ class "flex items-center gap-2 px-1 py-1.5 text-left text-sm font-normal" ] [ avatar, details ] ]
                        ]
                    , DropdownMenu.separator
                    , DropdownMenu.group
                        [ DropdownMenu.item [] [ icon Phosphor.sparkle, text "Upgrade to Pro" ] ]
                    , DropdownMenu.separator
                    , DropdownMenu.group
                        [ DropdownMenu.item [] [ icon Phosphor.checkCircle, text "Account" ]
                        , DropdownMenu.item [] [ icon Phosphor.creditCard, text "Billing" ]
                        , DropdownMenu.item [] [ icon Phosphor.bell, text "Notifications" ]
                        ]
                    , DropdownMenu.separator
                    , DropdownMenu.group
                        [ DropdownMenu.item [] [ icon Phosphor.signOut, text "Log out" ] ]
                    ]
                |> DropdownMenu.right
                |> DropdownMenu.toHtml [ class "min-w-56 rounded-lg" ]
            ]
        ]


{-| Upstream renders shadcn's `Calendar` with a dropdown caption, the 12th of the current month selected. There is no Calendar component, so this is a static month, October 2026, with the 12th selected and the 21st as today.
-}
datePicker : Html State.Msg
datePicker =
    Sidebar.group [ class "px-0" ]
        [ Sidebar.groupContent []
            [ div
                [ attribute "data-slot" "calendar"
                , class "group/calendar bg-background p-3 [--cell-size:--spacing(8)] bg-transparent [--cell-size:2.1rem]"
                ]
                [ div [ class "relative flex flex-col gap-4" ]
                    [ div [ class "flex w-full flex-col gap-4" ]
                        [ div [ class "absolute inset-x-0 top-0 flex w-full items-center justify-between gap-1" ]
                            [ calendarNav "Previous month" Phosphor.caretLeft
                            , calendarNav "Next month" Phosphor.caretRight
                            ]
                        , div [ class "flex h-(--cell-size) w-full items-center justify-center px-(--cell-size)" ]
                            [ div [ class "flex h-(--cell-size) w-full items-center justify-center gap-1.5 text-sm font-medium" ]
                                [ calendarDropdown "October"
                                , calendarDropdown "2026"
                                ]
                            ]
                        , div [ class "w-full border-collapse" ]
                            [ div [ class "flex" ]
                                (List.map
                                    (\day -> div [ class "flex-1 rounded-md text-[0.8rem] font-normal text-muted-foreground select-none" ] [ text day ])
                                    [ "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" ]
                                )
                            , div [ class "grid grid-cols-7" ] (List.map calendarDay calendarDays)
                            ]
                        ]
                    ]
                ]
            ]
        ]


calendarNav : String -> (IconWeight -> IconVariant) -> Html msg
calendarNav label i =
    Html.button
        [ type_ "button"
        , attribute "aria-label" label
        , class "inline-flex size-(--cell-size) shrink-0 items-center justify-center rounded-md p-0 text-sm font-medium transition-colors outline-none select-none hover:bg-accent hover:text-accent-foreground focus-visible:ring-[3px] focus-visible:ring-ring/50 aria-disabled:opacity-50 [&_svg]:size-4 [&_svg]:shrink-0"
        ]
        [ icon i ]


calendarDropdown : String -> Html msg
calendarDropdown label =
    div [ class "relative rounded-md border border-input shadow-xs has-focus:border-ring has-focus:ring-[3px] has-focus:ring-ring/50" ]
        [ Html.button
            [ type_ "button"
            , class "flex h-8 items-center gap-1 rounded-md pr-1 pl-2 text-sm font-medium [&>svg]:size-3.5 [&>svg]:text-muted-foreground"
            ]
            [ text label, icon Phosphor.caretDown ]
        ]


type alias CalendarDay =
    { day : Int, outside : Bool, selected : Bool, today : Bool }


{-| October 2026 starts on a Thursday and has 31 days; the grid is filled with the days around it.
-}
calendarDays : List CalendarDay
calendarDays =
    List.map (\day -> CalendarDay day True False False) (List.range 27 30)
        ++ List.map (\day -> CalendarDay day False (day == 12) (day == 21)) (List.range 1 31)
        ++ List.map (\day -> CalendarDay day True False False) (List.range 1 7)


calendarDay : CalendarDay -> Html msg
calendarDay day =
    div
        [ attribute "data-selected" (bool day.selected)
        , class "group/day relative aspect-square h-full w-full p-0 text-center select-none"
        ]
        [ Html.button
            [ type_ "button"
            , attribute "data-selected-single" (bool day.selected)
            , class "flex aspect-square size-auto w-full min-w-(--cell-size) flex-col items-center justify-center gap-1 rounded-md text-sm leading-none font-normal transition-colors outline-none hover:bg-accent hover:text-accent-foreground focus-visible:ring-[3px] focus-visible:ring-ring/50 data-[selected-single=true]:bg-primary data-[selected-single=true]:text-primary-foreground data-[selected-single=true]:hover:bg-primary data-[selected-single=true]:hover:text-primary-foreground"
            , class
                (if day.outside then
                    "text-muted-foreground"

                 else if day.today then
                    "bg-accent text-accent-foreground"

                 else
                    ""
                )
            ]
            [ text (String.fromInt day.day) ]
        ]


type alias Calendar =
    { name : String, items : List String }


calendarList : List Calendar
calendarList =
    [ Calendar "My Calendars" [ "Personal", "Work", "Family" ]
    , Calendar "Favorites" [ "Holidays", "Birthdays" ]
    , Calendar "Other" [ "Travel", "Reminders", "Deadlines" ]
    ]


calendars : List (Html State.Msg)
calendars =
    List.concat
        (List.indexedMap
            (\index calendar ->
                [ Sidebar.group []
                    [ Sidebar.collapsible
                        (if index == 0 then
                            [ Sidebar.defaultOpen ]

                         else
                            []
                        )
                        (Sidebar.groupTrigger [ class "group/label w-full text-sm text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground" ]
                            [ text calendar.name
                            , Phosphor.caretRight Regular
                                |> Phosphor.withClass "ml-auto transition-transform group-open/collapsible:rotate-90"
                                |> Phosphor.toHtml []
                            ]
                        )
                        [ Sidebar.groupContent []
                            [ Sidebar.menu []
                                (List.indexedMap
                                    (\itemIndex item ->
                                        Sidebar.menuItem []
                                            [ Sidebar.menuButton []
                                                [ div
                                                    [ attribute "data-active" (bool (itemIndex < 2))
                                                    , class "group/calendar-item flex aspect-square size-4 shrink-0 items-center justify-center rounded-xs border border-sidebar-border text-sidebar-primary-foreground data-[active=true]:border-sidebar-primary data-[active=true]:bg-sidebar-primary"
                                                    ]
                                                    [ Phosphor.check Regular
                                                        |> Phosphor.withClass "hidden size-3 group-data-[active=true]/calendar-item:block"
                                                        |> Phosphor.toHtml []
                                                    ]
                                                , text item
                                                ]
                                            ]
                                    )
                                    calendar.items
                                )
                            ]
                        ]
                    ]
                , Sidebar.separator [ class "mx-0" ]
                ]
            )
            calendarList
        )



-- HELPERS


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


mutedIcon : (IconWeight -> IconVariant) -> Html msg
mutedIcon i =
    i Regular
        |> Phosphor.withClass "text-muted-foreground"
        |> Phosphor.toHtml []
