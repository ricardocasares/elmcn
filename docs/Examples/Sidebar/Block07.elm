module Examples.Sidebar.Block07 exposing (view)

{-| sidebar-07: A sidebar that collapses to icons.
-}

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (alt, attribute, class, href, src)
import Html.Events exposing (onClick)
import Phosphor exposing (IconVariant, IconWeight(..))
import State exposing (State)
import UI.Avatar as Avatar
import UI.Breadcrumb as Breadcrumb
import UI.DropdownMenu as DropdownMenu
import UI.Separator as Separator
import UI.Sidebar as Sidebar


key : String
key =
    "block07"


view : State -> Html State.Msg
view state =
    Sidebar.new
        |> Sidebar.state (sidebarState key state) (setSidebarState key)
        |> Sidebar.collapsesToIcons
        |> Sidebar.header [ teamSwitcher state ]
        |> Sidebar.content [ navMain, navProjects ]
        |> Sidebar.footer [ navUser ]
        |> Sidebar.rail
        |> Sidebar.page []
            [ Html.header [ class "flex h-16 shrink-0 items-center gap-2 transition-[width,height] ease-linear md:group-has-data-[collapsible=icon]/sidebar-wrapper:h-12" ]
                [ div [ class "flex items-center gap-2 px-4" ]
                    [ Sidebar.trigger [ class "-ml-1" ] (sidebarState key state) (setSidebarState key)
                    , Separator.new
                        |> Separator.vertical
                        |> Separator.toHtml [ class "mr-2 my-auto data-[orientation=vertical]:h-4" ]
                    , Breadcrumb.new
                        |> Breadcrumb.item [ class "hidden md:block" ]
                            [ Html.a
                                [ attribute "data-slot" "breadcrumb-link"
                                , class "transition-colors hover:text-foreground"
                                , href "#"
                                ]
                                [ text "Build Your Application" ]
                            ]
                        |> Breadcrumb.page [ text "Data Fetching" ]
                        |> Breadcrumb.separator
                            (Phosphor.caretRight Regular
                                |> Phosphor.withClass "hidden md:block"
                                |> Phosphor.toHtml []
                            )
                        |> Breadcrumb.toHtml []
                    ]
                ]
            , div [ class "flex flex-1 flex-col gap-4 p-4 pt-0" ]
                [ div [ class "grid auto-rows-min gap-4 md:grid-cols-3" ]
                    [ div [ class "aspect-video rounded-xl bg-muted/50" ] []
                    , div [ class "aspect-video rounded-xl bg-muted/50" ] []
                    , div [ class "aspect-video rounded-xl bg-muted/50" ] []
                    ]
                , div [ class "min-h-[100vh] flex-1 rounded-xl bg-muted/50 md:min-h-min" ] []
                ]
            ]
        |> Sidebar.toHtml []



-- DATA


type alias Team =
    { name : String, logo : IconWeight -> IconVariant, plan : String }


teams : List Team
teams =
    [ Team "Acme Inc" Phosphor.stack "Enterprise"
    , Team "Acme Corp." Phosphor.waveform "Startup"
    , Team "Evil Corp." Phosphor.command "Free"
    ]


type alias NavItem =
    { title : String, icon : IconWeight -> IconVariant, isActive : Bool, items : List String }


navMainItems : List NavItem
navMainItems =
    [ NavItem "Playground" Phosphor.terminalWindow True [ "History", "Starred", "Settings" ]
    , NavItem "Models" Phosphor.robot False [ "Genesis", "Explorer", "Quantum" ]
    , NavItem "Documentation" Phosphor.bookOpen False [ "Introduction", "Get Started", "Tutorials", "Changelog" ]
    , NavItem "Settings" Phosphor.sliders False [ "General", "Team", "Billing", "Limits" ]
    ]


type alias Project =
    { name : String, slug : String, icon : IconWeight -> IconVariant }


projects : List Project
projects =
    [ Project "Design Engineering" "design" Phosphor.frameCorners
    , Project "Sales & Marketing" "sales" Phosphor.chartPie
    , Project "Travel" "travel" Phosphor.mapTrifold
    ]


user : { name : String, email : String, avatar : String }
user =
    { name = "shadcn", email = "m@example.com", avatar = "https://github.com/shadcn.png" }



-- TEAM SWITCHER


teamSwitcher : State -> Html State.Msg
teamSwitcher state =
    let
        activeTeam =
            teams
                |> List.filter (\candidate -> Just candidate.name == State.get (key ++ "-team") state)
                |> List.head
                |> Maybe.withDefault
                    (List.head teams
                        |> Maybe.withDefault (Team "" Phosphor.stack "")
                    )
    in
    Sidebar.menu []
        [ Sidebar.menuItem []
            [ DropdownMenu.new
                |> DropdownMenu.id (key ++ "-team")
                |> DropdownMenu.trigger (Sidebar.menuButtonAttributes ++ [ Sidebar.large ])
                    [ div [ class "flex aspect-square size-8 items-center justify-center rounded-lg bg-sidebar-primary text-sidebar-primary-foreground" ]
                        [ icon activeTeam.logo ]
                    , div [ class "grid flex-1 text-left text-sm leading-tight" ]
                        [ span [ class "truncate font-medium" ] [ text activeTeam.name ]
                        , span [ class "truncate text-xs" ] [ text activeTeam.plan ]
                        ]
                    , Phosphor.caretUpDown Regular
                        |> Phosphor.withClass "ml-auto"
                        |> Phosphor.toHtml []
                    ]
                |> DropdownMenu.content
                    [ DropdownMenu.group
                        (DropdownMenu.label [ text "Teams" ]
                            :: List.indexedMap
                                (\index team ->
                                    DropdownMenu.item [ class "gap-2 p-2", onClick (State.set (key ++ "-team") team.name) ]
                                        [ div [ class "flex size-6 items-center justify-center rounded-md border" ]
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
                            [ div [ class "flex size-6 items-center justify-center rounded-md border bg-transparent" ]
                                [ Phosphor.plus Regular
                                    |> Phosphor.withClass "size-4"
                                    |> Phosphor.toHtml []
                                ]
                            , div [ class "font-medium text-muted-foreground" ] [ text "Add team" ]
                            ]
                        ]
                    ]
                |> DropdownMenu.right
                |> DropdownMenu.toHtml [ class "w-fit" ]
            ]
        ]



-- NAV MAIN


navMain : Html State.Msg
navMain =
    Sidebar.group []
        [ Sidebar.groupLabel [] [ text "Platform" ]
        , Sidebar.menu []
            (List.map
                (\item ->
                    Sidebar.menuItem []
                        [ Sidebar.collapsible
                            (if item.isActive then
                                [ Sidebar.defaultOpen ]

                             else
                                []
                            )
                            (Sidebar.menuTrigger [ Sidebar.tooltip item.title ]
                                [ icon item.icon
                                , span [] [ text item.title ]
                                , Phosphor.caretRight Regular
                                    |> Phosphor.withClass "ml-auto transition-transform duration-200 group-open/collapsible:rotate-90"
                                    |> Phosphor.toHtml []
                                ]
                            )
                            [ Sidebar.menuSub []
                                (List.map
                                    (\subItem ->
                                        Sidebar.menuSubItem []
                                            [ Sidebar.menuSubLink [ href "#" ] [ span [] [ text subItem ] ] ]
                                    )
                                    item.items
                                )
                            ]
                        ]
                )
                navMainItems
            )
        ]



-- NAV PROJECTS


navProjects : Html State.Msg
navProjects =
    Sidebar.group [ class "md:group-data-[collapsible=icon]:hidden" ]
        [ Sidebar.groupLabel [] [ text "Projects" ]
        , Sidebar.menu []
            (List.map
                (\project ->
                    Sidebar.menuItem []
                        [ Sidebar.menuLink [ href "#" ] [ icon project.icon, span [] [ text project.name ] ]
                        , DropdownMenu.new
                            |> DropdownMenu.id (key ++ "-project-" ++ project.slug)
                            |> DropdownMenu.trigger (Sidebar.menuActionAttributes ++ [ Sidebar.showOnHover ])
                                [ icon Phosphor.dotsThree, span [ class "sr-only" ] [ text "More" ] ]
                            |> DropdownMenu.content
                                [ DropdownMenu.item [] [ icon Phosphor.folder, span [] [ text "View Project" ] ]
                                , DropdownMenu.item [] [ icon Phosphor.shareFat, span [] [ text "Share Project" ] ]
                                , DropdownMenu.separator
                                , DropdownMenu.item [] [ icon Phosphor.trash, span [] [ text "Delete Project" ] ]
                                    |> DropdownMenu.destructive
                                ]
                            |> DropdownMenu.right
                            |> DropdownMenu.toHtml [ class "w-fit" ]
                        ]
                )
                projects
                ++ [ Sidebar.menuItem []
                        [ Sidebar.menuButton [ class "text-sidebar-foreground/70" ]
                            [ Phosphor.dotsThree Regular
                                |> Phosphor.withClass "text-sidebar-foreground/70"
                                |> Phosphor.toHtml []
                            , span [] [ text "More" ]
                            ]
                        ]
                   ]
            )
        ]



-- NAV USER


navUser : Html State.Msg
navUser =
    let
        avatar =
            Avatar.new
                |> Avatar.fallback [ text "CN" ]
                |> Avatar.img [ src user.avatar, alt user.name ]
                |> Avatar.toHtml []

        details =
            div [ class "grid flex-1 text-left text-sm leading-tight" ]
                [ span [ class "truncate font-medium" ] [ text user.name ]
                , span [ class "truncate text-xs" ] [ text user.email ]
                ]
    in
    Sidebar.menu []
        [ Sidebar.menuItem []
            [ DropdownMenu.new
                |> DropdownMenu.id (key ++ "-user")
                |> DropdownMenu.trigger (Sidebar.menuButtonAttributes ++ [ Sidebar.large ])
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
                        [ DropdownMenu.item [] [ icon Phosphor.sealCheck, text "Account" ]
                        , DropdownMenu.item [] [ icon Phosphor.creditCard, text "Billing" ]
                        , DropdownMenu.item [] [ icon Phosphor.bell, text "Notifications" ]
                        ]
                    , DropdownMenu.separator
                    , DropdownMenu.item [] [ icon Phosphor.signOut, text "Log out" ]
                    ]
                |> DropdownMenu.right
                |> DropdownMenu.alignEnd
                |> DropdownMenu.toHtml [ class "w-fit" ]
            ]
        ]



-- HELPERS


sidebarState : String -> State -> Sidebar.State
sidebarState prefix state =
    { open = State.get (prefix ++ "-sidebar-open") state /= Just "false"
    , openMobile = State.get (prefix ++ "-sidebar-mobile") state == Just "true"
    }


setSidebarState : String -> Sidebar.State -> State.Msg
setSidebarState prefix sidebar =
    State.batch
        [ State.set (prefix ++ "-sidebar-open") (bool sidebar.open)
        , State.set (prefix ++ "-sidebar-mobile") (bool sidebar.openMobile)
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
