module Examples.Sidebar.Block08 exposing (view)

{-| A port of shadcn's `sidebar-08` block: an inset sidebar with secondary navigation.
-}

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (alt, attribute, class, href, src)
import Phosphor exposing (IconVariant, IconWeight(..))
import State exposing (State)
import UI.Avatar as Avatar
import UI.Breadcrumb as Breadcrumb
import UI.DropdownMenu as DropdownMenu
import UI.Separator as Separator
import UI.Sidebar as Sidebar


key : String
key =
    "block08"


view : State -> Html State.Msg
view state =
    Sidebar.new
        |> Sidebar.state (sidebarState key state) (setSidebarState key)
        |> Sidebar.inset
        |> Sidebar.header
            [ Sidebar.menu []
                [ Sidebar.menuItem []
                    [ Sidebar.menuLink [ href "#", Sidebar.large ]
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
            [ navMain
            , navProjects
            , navSecondary [ class "mt-auto" ]
            ]
        |> Sidebar.footer [ navUser ]
        |> Sidebar.page []
            [ Html.header [ class "flex h-16 shrink-0 items-center gap-2" ]
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
                , div [ class "min-h-screen flex-1 rounded-xl bg-muted/50 md:min-h-min" ] []
                ]
            ]
        |> Sidebar.toHtml []



-- DATA


type alias NavItem =
    { title : String
    , icon : IconWeight -> IconVariant
    , isActive : Bool
    , items : List String
    }


navMainItems : List NavItem
navMainItems =
    [ { title = "Playground", icon = Phosphor.terminal, isActive = True, items = [ "History", "Starred", "Settings" ] }
    , { title = "Models", icon = Phosphor.robot, isActive = False, items = [ "Genesis", "Explorer", "Quantum" ] }
    , { title = "Documentation", icon = Phosphor.bookOpen, isActive = False, items = [ "Introduction", "Get Started", "Tutorials", "Changelog" ] }
    , { title = "Settings", icon = Phosphor.sliders, isActive = False, items = [ "General", "Team", "Billing", "Limits" ] }
    ]


navSecondaryItems : List { title : String, icon : IconWeight -> IconVariant }
navSecondaryItems =
    [ { title = "Support", icon = Phosphor.lifebuoy }
    , { title = "Feedback", icon = Phosphor.paperPlaneTilt }
    ]


projects : List { name : String, slug : String, icon : IconWeight -> IconVariant }
projects =
    [ { name = "Design Engineering", slug = "design", icon = Phosphor.frameCorners }
    , { name = "Sales & Marketing", slug = "sales", icon = Phosphor.chartPie }
    , { name = "Travel", slug = "travel", icon = Phosphor.mapTrifold }
    ]


user : { name : String, email : String, avatar : String }
user =
    { name = "shadcn", email = "m@example.com", avatar = "https://github.com/shadcn.png" }



-- NAV MAIN


{-| Upstream puts the link and a separate collapsible trigger (a menu action with a chevron) side by side in the item. The collapsible is a `<details>` with the same classes as `Sidebar.collapsible`, whose `<summary>` is styled as a menu action.
-}
navMain : Html State.Msg
navMain =
    Sidebar.group []
        [ Sidebar.groupLabel [] [ text "Platform" ]
        , Sidebar.menu [] (List.map navMainItem navMainItems)
        ]


navMainItem : NavItem -> Html State.Msg
navMainItem item =
    Sidebar.menuItem []
        [ Sidebar.menuLink [ href "#", Sidebar.tooltip item.title ]
            [ icon item.icon
            , span [] [ text item.title ]
            ]
        , Html.details
            (attribute "data-slot" "collapsible"
                :: class "group/collapsible details-content:grid details-content:grid-rows-[0fr] details-content:[content-visibility:visible] details-content:transition-[grid-template-rows] details-content:duration-200 details-content:ease-out open:details-content:grid-rows-[1fr]"
                :: (if item.isActive then
                        [ Sidebar.defaultOpen ]

                    else
                        []
                   )
            )
            [ Html.summary
                (class "cursor-pointer list-none select-none [&::-webkit-details-marker]:hidden"
                    :: class "group-open/collapsible:rotate-90"
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
                            |> DropdownMenu.trigger (Sidebar.menuActionAttributes ++ [ Sidebar.showOnHover, class "aria-expanded:bg-muted" ])
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


navSecondary : List (Html.Attribute State.Msg) -> Html State.Msg
navSecondary attrs =
    Sidebar.group attrs
        [ Sidebar.groupContent []
            [ Sidebar.menu []
                (List.map
                    (\item ->
                        Sidebar.menuItem []
                            [ Sidebar.menuLink [ href "#", Sidebar.small ]
                                [ icon item.icon
                                , span [] [ text item.title ]
                                ]
                            ]
                    )
                    navSecondaryItems
                )
            ]
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
