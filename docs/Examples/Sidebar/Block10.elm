module Examples.Sidebar.Block10 exposing (view)

{-| A sidebar in a popover.

A port of shadcn's `sidebar-10` block: a sidebar with a team switcher and the main
navigation in its header, favorites and collapsible workspaces in its content, and a
secondary navigation at the bottom. The page header has a "nav actions" popover that
holds a never-collapsing sidebar.

-}

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (attribute, class, href, title, type_)
import Html.Events exposing (onClick)
import Phosphor exposing (IconVariant, IconWeight(..))
import State exposing (State)
import UI.Breadcrumb as Breadcrumb
import UI.Button as Button
import UI.DropdownMenu as DropdownMenu
import UI.Popover as Popover
import UI.Separator as Separator
import UI.Sidebar as Sidebar


view : State -> Html State.Msg
view state =
    Sidebar.new
        |> Sidebar.state (sidebarState "block10" state) (setSidebarState "block10")
        |> Sidebar.header [ teamSwitcher state, navMain ]
        |> Sidebar.content [ navFavorites, navWorkspaces, navSecondary ]
        |> Sidebar.rail
        |> Sidebar.page []
            [ Html.header [ class "flex h-14 shrink-0 items-center gap-2" ]
                [ div [ class "flex flex-1 items-center gap-2 px-3" ]
                    [ Sidebar.trigger [] (sidebarState "block10" state) (setSidebarState "block10")
                    , Separator.new
                        |> Separator.vertical
                        |> Separator.toHtml [ class "mr-2 my-auto data-[orientation=vertical]:h-4" ]
                    , Breadcrumb.new
                        |> Breadcrumb.page [ span [ class "line-clamp-1" ] [ text "Project Management & Task Tracking" ] ]
                        |> Breadcrumb.separator (icon Phosphor.caretRight)
                        |> Breadcrumb.toHtml []
                    ]
                , div [ class "ml-auto px-3" ] [ navActions ]
                ]
            , div [ class "flex flex-1 flex-col gap-4 px-4 py-10" ]
                [ div [ class "mx-auto h-24 w-full max-w-3xl rounded-xl bg-muted/50" ] []
                , div [ class "mx-auto h-full w-full max-w-3xl rounded-xl bg-muted/50" ] []
                ]
            ]
        -- Upstream's `border-r-0` on the sidebar: the border sits on the sidebar container.
        |> Sidebar.toHtml [ class "md:[&_[data-slot=sidebar-container]]:border-e-0" ]



-- TEAM SWITCHER


teamSwitcher : State -> Html State.Msg
teamSwitcher state =
    let
        activeTeam =
            teams
                |> List.filter (\candidate -> Just candidate.name == State.get "block10-team" state)
                |> List.head
                |> Maybe.withDefault
                    (List.head teams
                        |> Maybe.withDefault { name = "", plan = "", logo = Phosphor.command }
                    )
    in
    Sidebar.menu []
        [ Sidebar.menuItem []
            [ DropdownMenu.new
                |> DropdownMenu.id "block10-team-switcher"
                |> DropdownMenu.trigger (Sidebar.menuButtonAttributes ++ [ class "w-fit! px-1.5" ])
                    [ div [ class "flex aspect-square size-5 items-center justify-center rounded-md bg-sidebar-primary text-sidebar-primary-foreground" ]
                        [ icon activeTeam.logo ]
                    , span [ class "truncate font-medium" ] [ text activeTeam.name ]
                    , Phosphor.caretDown Regular
                        |> Phosphor.withClass "opacity-50"
                        |> Phosphor.toHtml []
                    ]
                |> DropdownMenu.content
                    [ DropdownMenu.group
                        (DropdownMenu.label [ text "Teams" ]
                            :: List.indexedMap
                                (\index team ->
                                    DropdownMenu.item [ class "gap-2 p-2", onClick (State.set "block10-team" team.name) ]
                                        [ div [ class "flex size-6 items-center justify-center rounded-xs border" ]
                                            [ icon team.logo ]
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



-- NAV MAIN


navMain : Html msg
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
            mainItems
        )



-- NAV FAVORITES


navFavorites : Html msg
navFavorites =
    Sidebar.group [ class "md:group-data-[collapsible=icon]:hidden" ]
        [ Sidebar.groupLabel [] [ text "Favorites" ]
        , Sidebar.menu [] (List.indexedMap favoriteItem favorites ++ [ moreItem ])
        ]


favoriteItem : Int -> Page -> Html msg
favoriteItem index item =
    Sidebar.menuItem []
        [ Sidebar.menuLink [ href "#", title item.name ]
            [ span [] [ text item.emoji ]
            , span [] [ text item.name ]
            ]
        , DropdownMenu.new
            |> DropdownMenu.id ("block10-favorite-" ++ String.fromInt index)
            |> DropdownMenu.trigger (Sidebar.menuActionAttributes ++ [ Sidebar.showOnHover, class "[&:has(+:popover-open)]:bg-muted" ])
                [ icon Phosphor.dotsThreeOutline
                , span [ class "sr-only" ] [ text "More" ]
                ]
            |> DropdownMenu.content
                [ DropdownMenu.group
                    [ DropdownMenu.item []
                        [ mutedIcon Phosphor.star
                        , span [] [ text "Remove from Favorites" ]
                        ]
                    ]
                , DropdownMenu.separator
                , DropdownMenu.group
                    [ DropdownMenu.item []
                        [ mutedIcon Phosphor.link
                        , span [] [ text "Copy Link" ]
                        ]
                    , DropdownMenu.item []
                        [ mutedIcon Phosphor.arrowUpRight
                        , span [] [ text "Open in New Tab" ]
                        ]
                    , DropdownMenu.separator
                    , DropdownMenu.item []
                        [ mutedIcon Phosphor.trash
                        , span [] [ text "Delete" ]
                        ]
                    ]
                ]
            |> DropdownMenu.right
            |> DropdownMenu.toHtml [ class "w-56 rounded-lg" ]
        ]


moreItem : Html msg
moreItem =
    Sidebar.menuItem []
        [ Sidebar.menuButton [ class "text-sidebar-foreground/70" ]
            [ icon Phosphor.dotsThreeOutline
            , span [] [ text "More" ]
            ]
        ]



-- NAV WORKSPACES


navWorkspaces : Html msg
navWorkspaces =
    Sidebar.group []
        [ Sidebar.groupLabel [] [ text "Workspaces" ]
        , Sidebar.groupContent []
            [ Sidebar.menu [] (List.map workspaceItem workspaces ++ [ moreItem ]) ]
        ]


{-| Upstream wraps the item in a `Collapsible` whose trigger is a `SidebarMenuAction`.
`Sidebar.collapsible` only offers menu-button and group-label triggers, so this is a
plain `<details>` with the same classes, whose `<summary>` is styled as a menu action.
-}
workspaceItem : Workspace -> Html msg
workspaceItem workspace =
    Sidebar.menuItem []
        [ Sidebar.menuLink [ href "#" ]
            [ span [] [ text workspace.emoji ]
            , span [] [ text workspace.name ]
            ]
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
        , Sidebar.menuAction [ Sidebar.showOnHover ] [ icon Phosphor.plus ]
        ]



-- NAV SECONDARY


navSecondary : Html msg
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
                    secondaryItems
                )
            ]
        ]



-- NAV ACTIONS


navActions : Html State.Msg
navActions =
    div [ class "flex items-center gap-2 text-sm" ]
        [ div [ class "hidden font-medium text-muted-foreground md:inline-block" ] [ text "Edit Oct 08" ]
        , Html.button (type_ "button" :: iconButton Phosphor.star ++ [ class "h-7 w-7" ])
            [ icon Phosphor.star ]
        , Popover.new
            |> Popover.id "block10-nav-actions"
            |> Popover.trigger (iconButton Phosphor.dotsThreeOutline ++ [ class "h-7 w-7 [&:has(+:popover-open)]:bg-accent" ])
                [ icon Phosphor.dotsThreeOutline ]
            |> Popover.content
                [ Sidebar.new
                    |> Sidebar.state Sidebar.init (\_ -> State.none)
                    |> Sidebar.neverCollapses
                    |> Sidebar.content (List.map actionGroup actions)
                    -- The wrapper is as tall as the viewport by default, and the sidebar
                    -- has the sidebar background: upstream's `bg-transparent`.
                    |> Sidebar.toHtml [ class "min-h-0! *:data-[slot=sidebar]:bg-transparent" ]
                ]
            |> Popover.alignEnd
            |> Popover.toHtml [ class "w-56 overflow-hidden rounded-lg p-0!" ]
        ]


{-| The styles of a ghost icon button, for a `<button>` that has no accessible name, like upstream's.
-}
iconButton : (IconWeight -> IconVariant) -> List (Html.Attribute msg)
iconButton i =
    Button.new
        |> Button.icon (icon i)
        |> Button.ghost
        |> Button.toAttributes


actionGroup : List Action -> Html msg
actionGroup group =
    Sidebar.group [ class "border-b last:border-none" ]
        [ Sidebar.groupContent [ class "gap-0" ]
            [ Sidebar.menu []
                (List.map
                    (\action ->
                        Sidebar.menuItem []
                            [ Sidebar.menuButton []
                                [ icon action.icon
                                , span [] [ text action.label ]
                                ]
                            ]
                    )
                    group
                )
            ]
        ]



-- STATE


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



-- ICONS


icon : (IconWeight -> IconVariant) -> Html msg
icon i =
    i Regular
        |> Phosphor.toHtml []


mutedIcon : (IconWeight -> IconVariant) -> Html msg
mutedIcon i =
    i Regular
        |> Phosphor.withClass "text-muted-foreground"
        |> Phosphor.toHtml []



-- DATA


type alias Team =
    { name : String, plan : String, logo : IconWeight -> IconVariant }


teams : List Team
teams =
    [ { name = "Acme Inc", plan = "Enterprise", logo = Phosphor.command }
    , { name = "Acme Corp.", plan = "Startup", logo = Phosphor.waveform }
    , { name = "Evil Corp.", plan = "Free", logo = Phosphor.command }
    ]


type alias NavItem =
    { title : String, icon : IconWeight -> IconVariant, isActive : Bool }


mainItems : List NavItem
mainItems =
    [ { title = "Search", icon = Phosphor.magnifyingGlass, isActive = False }
    , { title = "Ask AI", icon = Phosphor.sparkle, isActive = False }
    , { title = "Home", icon = Phosphor.house, isActive = True }
    , { title = "Inbox", icon = Phosphor.tray, isActive = False }
    ]


secondaryItems : List NavItem
secondaryItems =
    [ { title = "Calendar", icon = Phosphor.calendar, isActive = False }
    , { title = "Settings", icon = Phosphor.gear, isActive = False }
    , { title = "Templates", icon = Phosphor.cube, isActive = False }
    , { title = "Trash", icon = Phosphor.trash, isActive = False }
    , { title = "Help", icon = Phosphor.chatCircle, isActive = False }
    ]


type alias Page =
    { name : String, emoji : String }


favorites : List Page
favorites =
    [ { name = "Project Management & Task Tracking", emoji = "📊" }
    , { name = "Family Recipe Collection & Meal Planning", emoji = "🍳" }
    , { name = "Fitness Tracker & Workout Routines", emoji = "💪" }
    , { name = "Book Notes & Reading List", emoji = "📚" }
    , { name = "Sustainable Gardening Tips & Plant Care", emoji = "🌱" }
    , { name = "Language Learning Progress & Resources", emoji = "🗣️" }
    , { name = "Home Renovation Ideas & Budget Tracker", emoji = "🏠" }
    , { name = "Personal Finance & Investment Portfolio", emoji = "💰" }
    , { name = "Movie & TV Show Watchlist with Reviews", emoji = "🎬" }
    , { name = "Daily Habit Tracker & Goal Setting", emoji = "✅" }
    ]


type alias Workspace =
    { name : String, emoji : String, pages : List Page }


workspaces : List Workspace
workspaces =
    [ { name = "Personal Life Management"
      , emoji = "🏠"
      , pages =
            [ { name = "Daily Journal & Reflection", emoji = "📔" }
            , { name = "Health & Wellness Tracker", emoji = "🍏" }
            , { name = "Personal Growth & Learning Goals", emoji = "🌟" }
            ]
      }
    , { name = "Professional Development"
      , emoji = "💼"
      , pages =
            [ { name = "Career Objectives & Milestones", emoji = "🎯" }
            , { name = "Skill Acquisition & Training Log", emoji = "🧠" }
            , { name = "Networking Contacts & Events", emoji = "🤝" }
            ]
      }
    , { name = "Creative Projects"
      , emoji = "🎨"
      , pages =
            [ { name = "Writing Ideas & Story Outlines", emoji = "✍️" }
            , { name = "Art & Design Portfolio", emoji = "🖼️" }
            , { name = "Music Composition & Practice Log", emoji = "🎵" }
            ]
      }
    , { name = "Home Management"
      , emoji = "🏡"
      , pages =
            [ { name = "Household Budget & Expense Tracking", emoji = "💰" }
            , { name = "Home Maintenance Schedule & Tasks", emoji = "🔧" }
            , { name = "Family Calendar & Event Planning", emoji = "📅" }
            ]
      }
    , { name = "Travel & Adventure"
      , emoji = "🧳"
      , pages =
            [ { name = "Trip Planning & Itineraries", emoji = "🗺️" }
            , { name = "Travel Bucket List & Inspiration", emoji = "🌎" }
            , { name = "Travel Journal & Photo Gallery", emoji = "📸" }
            ]
      }
    ]


type alias Action =
    { label : String, icon : IconWeight -> IconVariant }


actions : List (List Action)
actions =
    [ [ { label = "Customize Page", icon = Phosphor.gear }
      , { label = "Turn into wiki", icon = Phosphor.fileText }
      ]
    , [ { label = "Copy Link", icon = Phosphor.link }
      , { label = "Duplicate", icon = Phosphor.copy }
      , { label = "Move to", icon = Phosphor.arrowBendUpRight }
      , { label = "Move to Trash", icon = Phosphor.trash }
      ]
    , [ { label = "Undo", icon = Phosphor.arrowBendUpLeft }
      , { label = "View analytics", icon = Phosphor.chartLine }
      , { label = "Version History", icon = Phosphor.rows }
      , { label = "Show delete pages", icon = Phosphor.trash }
      , { label = "Notifications", icon = Phosphor.bell }
      ]
    , [ { label = "Import", icon = Phosphor.arrowUp }
      , { label = "Export", icon = Phosphor.arrowDown }
      ]
    ]
