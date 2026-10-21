module Examples.Sidebar.Block16 exposing (view)

{-| A sidebar with a sticky site header: shadcn's `sidebar-16` block.

The site header sits above the sidebar and the page, so the sidebar's panel is
pushed below it with `--header-height`.

-}

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (alt, attribute, class, for, href, id, placeholder, src)
import Phosphor exposing (IconVariant, IconWeight(..))
import State exposing (State)
import UI.Avatar as Avatar
import UI.Breadcrumb as Breadcrumb
import UI.DropdownMenu as DropdownMenu
import UI.Input as Input
import UI.Label as Label
import UI.Separator as Separator
import UI.Sidebar as Sidebar


key : String
key =
    "block16"


view : State -> Html State.Msg
view state =
    div
        [ class "flex w-full flex-col [--header-height:calc(--spacing(14))]"

        -- The sidebar's panel starts below the site header and stops at the bottom of the viewport.
        , class "[&_[data-slot=sidebar-container]]:md:top-(--header-height) [&_[data-slot=sidebar-container]]:md:max-h-[calc(100svh-var(--header-height))]"
        ]
        [ siteHeader state
        , Sidebar.new
            |> Sidebar.state (sidebarState key state) (setSidebarState key)
            |> Sidebar.header
                [ Sidebar.menu []
                    [ Sidebar.menuItem []
                        [ Sidebar.menuLink [ href "#", Sidebar.large ]
                            [ div [ class "flex aspect-square size-8 items-center justify-center rounded-lg bg-sidebar-primary text-sidebar-primary-foreground" ]
                                [ Phosphor.terminal Regular
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
                [ navMain
                , navProjects
                , navSecondary
                ]
            |> Sidebar.footer [ navUser ]
            |> Sidebar.page []
                [ div [ class "flex flex-1 flex-col gap-4 p-4" ]
                    [ div [ class "grid auto-rows-min gap-4 md:grid-cols-3" ]
                        [ div [ class "aspect-video rounded-xl bg-muted/50" ] []
                        , div [ class "aspect-video rounded-xl bg-muted/50" ] []
                        , div [ class "aspect-video rounded-xl bg-muted/50" ] []
                        ]
                    , div [ class "min-h-screen flex-1 rounded-xl bg-muted/50 md:min-h-min" ] []
                    ]
                ]
            |> Sidebar.toHtml []
        ]



-- SITE HEADER


siteHeader : State -> Html State.Msg
siteHeader state =
    Html.header [ class "sticky top-0 z-50 flex w-full items-center border-b bg-background" ]
        [ div [ class "flex h-(--header-height) w-full items-center gap-2 px-4" ]
            [ Sidebar.trigger [ class "h-8 w-8" ] (sidebarState key state) (setSidebarState key)
            , Separator.new
                |> Separator.vertical
                |> Separator.toHtml [ class "mr-2" ]
            , Breadcrumb.new
                |> Breadcrumb.link [ href "#" ] [ text "Build Your Application" ]
                |> Breadcrumb.page [ text "Data Fetching" ]
                |> Breadcrumb.separator (Phosphor.caretRight Regular |> Phosphor.toHtml [])
                |> Breadcrumb.toHtml [ class "hidden sm:block" ]
            , searchForm [ class "w-full sm:ml-auto sm:w-auto" ]
            ]
        ]


searchForm : List (Html.Attribute msg) -> Html msg
searchForm attrs =
    Html.form attrs
        [ div [ class "relative" ]
            [ Label.view [ for (key ++ "-search"), class "sr-only" ] [ text "Search" ]
            , Input.view
                [ class "h-8 bg-background shadow-none"
                , id (key ++ "-search")
                , placeholder "Type to search..."
                , class "h-8 pl-7"
                ]
            , Phosphor.magnifyingGlass Regular
                |> Phosphor.withClass "pointer-events-none absolute top-1/2 left-2 size-4 -translate-y-1/2 opacity-50 select-none"
                |> Phosphor.toHtml []
            ]
        ]



-- NAV MAIN


type alias NavItem =
    { title : String
    , icon : IconWeight -> IconVariant
    , isActive : Bool
    , items : List String
    }


navMainItems : List NavItem
navMainItems =
    [ { title = "Playground", icon = Phosphor.terminalWindow, isActive = True, items = [ "History", "Starred", "Settings" ] }
    , { title = "Models", icon = Phosphor.robot, isActive = False, items = [ "Genesis", "Explorer", "Quantum" ] }
    , { title = "Documentation", icon = Phosphor.bookOpen, isActive = False, items = [ "Introduction", "Get Started", "Tutorials", "Changelog" ] }
    , { title = "Settings", icon = Phosphor.sliders, isActive = False, items = [ "General", "Team", "Billing", "Limits" ] }
    ]


{-| Upstream, the menu button is a link and the collapsible's trigger is the menu action beside
it. A `<details>` with the collapsible's classes does the same here: its `<summary>` is the
action, absolutely positioned over the link, and its content is the submenu.
-}
navMain : Html State.Msg
navMain =
    Sidebar.group []
        [ Sidebar.groupLabel [] [ text "Platform" ]
        , Sidebar.menu []
            (List.map
                (\item ->
                    Sidebar.menuItem []
                        (Sidebar.menuLink [ href "#", Sidebar.tooltip item.title ]
                            [ icon item.icon
                            , span [] [ text item.title ]
                            ]
                            :: (if List.isEmpty item.items then
                                    []

                                else
                                    [ Html.details
                                        (attribute "data-slot" "collapsible"
                                            :: class "group/collapsible details-content:grid details-content:grid-rows-[0fr] details-content:[content-visibility:visible] details-content:transition-[grid-template-rows] details-content:duration-200 details-content:ease-out open:details-content:grid-rows-[1fr]"
                                            :: (if item.isActive then
                                                    [ Sidebar.defaultOpen ]

                                                else
                                                    []
                                               )
                                        )
                                        [ Html.summary
                                            (class "cursor-pointer list-none select-none [&::-webkit-details-marker]:hidden group-open/collapsible:rotate-90"
                                                :: Sidebar.menuActionAttributes
                                            )
                                            [ icon Phosphor.caretRight
                                            , span [ class "sr-only" ] [ text "Toggle" ]
                                            ]
                                        , div
                                            [ attribute "data-slot" "collapsible-content"
                                            , class "invisible min-h-0 overflow-hidden transition-[visibility] duration-200 group-open/collapsible:visible"
                                            ]
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
                                    ]
                               )
                        )
                )
                navMainItems
            )
        ]



-- NAV PROJECTS


type alias Project =
    { name : String
    , slug : String
    , icon : IconWeight -> IconVariant
    }


projects : List Project
projects =
    [ { name = "Design Engineering", slug = "design", icon = Phosphor.frameCorners }
    , { name = "Sales & Marketing", slug = "sales", icon = Phosphor.chartPie }
    , { name = "Travel", slug = "travel", icon = Phosphor.mapTrifold }
    ]


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
                                [ DropdownMenu.item [] [ mutedIcon Phosphor.folder, span [] [ text "View Project" ] ]
                                , DropdownMenu.item [] [ mutedIcon Phosphor.shareFat, span [] [ text "Share Project" ] ]
                                , DropdownMenu.separator
                                , DropdownMenu.item [] [ mutedIcon Phosphor.trash, span [] [ text "Delete Project" ] ]
                                ]
                            |> DropdownMenu.right
                            |> DropdownMenu.toHtml [ class "w-48" ]
                        ]
                )
                projects
                ++ [ Sidebar.menuItem []
                        [ Sidebar.menuButton []
                            [ icon Phosphor.dotsThree
                            , span [] [ text "More" ]
                            ]
                        ]
                   ]
            )
        ]



-- NAV SECONDARY


navSecondary : Html State.Msg
navSecondary =
    Sidebar.group [ class "mt-auto" ]
        [ Sidebar.groupContent []
            [ Sidebar.menu []
                (List.map
                    (\( title, i ) ->
                        Sidebar.menuItem []
                            [ Sidebar.menuLink [ href "#", Sidebar.small ]
                                [ icon i
                                , span [] [ text title ]
                                ]
                            ]
                    )
                    [ ( "Support", Phosphor.lifebuoy )
                    , ( "Feedback", Phosphor.paperPlaneTilt )
                    ]
                )
            ]
        ]



-- NAV USER


user : { name : String, email : String }
user =
    { name = "shadcn", email = "m@example.com" }


navUser : Html State.Msg
navUser =
    let
        avatar =
            Avatar.new
                |> Avatar.fallback [ text "CN" ]
                |> Avatar.img [ src "https://github.com/shadcn.png", alt user.name ]
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
                    , DropdownMenu.group
                        [ DropdownMenu.item [] [ icon Phosphor.signOut, text "Log out" ] ]
                    ]
                |> DropdownMenu.right
                |> DropdownMenu.alignEnd
                |> DropdownMenu.toHtml [ class "min-w-56 rounded-lg" ]
            ]
        ]



-- HELPERS


icon : (IconWeight -> IconVariant) -> Html msg
icon i =
    i Regular
        |> Phosphor.toHtml []


mutedIcon : (IconWeight -> IconVariant) -> Html msg
mutedIcon i =
    i Regular
        |> Phosphor.withClass "text-muted-foreground"
        |> Phosphor.toHtml []


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
