module Examples.Sidebar.Block02 exposing (view)

{-| shadcn's sidebar-02 block: a sidebar with collapsible sections.
-}

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, for, href, id, placeholder)
import Html.Events exposing (onClick)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.Breadcrumb as Breadcrumb
import UI.DropdownMenu as DropdownMenu
import UI.Input as Input
import UI.Label as Label
import UI.Separator as Separator
import UI.Sidebar as Sidebar


view : State -> Html State.Msg
view state =
    Sidebar.new
        |> Sidebar.state (sidebarState "block02" state) (setSidebarState "block02")
        |> Sidebar.header [ versionSwitcher state, searchForm ]
        |> Sidebar.content (List.map navGroup navMain)
        |> Sidebar.rail
        |> Sidebar.page []
            [ Html.header [ class "sticky top-0 flex h-16 shrink-0 items-center gap-2 border-b bg-background px-4" ]
                [ Sidebar.trigger [ class "-ml-1" ] (sidebarState "block02" state) (setSidebarState "block02")
                , Separator.new
                    |> Separator.vertical
                    |> Separator.toHtml [ class "mr-2" ]
                , Breadcrumb.new
                    |> Breadcrumb.item [ class "hidden md:block" ]
                        [ Html.a [ href "#", class "transition-colors hover:text-foreground" ] [ text "Build Your Application" ] ]
                    |> Breadcrumb.page [ text "Data Fetching" ]
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
        |> Sidebar.toHtml []



-- DATA


versions : List String
versions =
    [ "1.0.1", "1.1.0-alpha", "2.0.0-beta1" ]


type alias NavGroup =
    { title : String
    , items : List NavItem
    }


type alias NavItem =
    { title : String
    , url : String
    , isActive : Bool
    }


navMain : List NavGroup
navMain =
    [ { title = "Getting Started"
      , items =
            [ NavItem "Installation" "#" False
            , NavItem "Project Structure" "#" False
            ]
      }
    , { title = "Build Your Application"
      , items =
            [ NavItem "Routing" "#" False
            , NavItem "Data Fetching" "#" True
            , NavItem "Rendering" "#" False
            , NavItem "Caching" "#" False
            , NavItem "Styling" "#" False
            , NavItem "Optimizing" "#" False
            , NavItem "Configuring" "#" False
            , NavItem "Testing" "#" False
            , NavItem "Authentication" "#" False
            , NavItem "Deploying" "#" False
            , NavItem "Upgrading" "#" False
            , NavItem "Examples" "#" False
            ]
      }
    , { title = "API Reference"
      , items =
            [ NavItem "Components" "#" False
            , NavItem "File Conventions" "#" False
            , NavItem "Functions" "#" False
            , NavItem "next.config.js Options" "#" False
            , NavItem "CLI" "#" False
            , NavItem "Edge Runtime" "#" False
            ]
      }
    , { title = "Architecture"
      , items =
            [ NavItem "Accessibility" "#" False
            , NavItem "Fast Refresh" "#" False
            , NavItem "Next.js Compiler" "#" False
            , NavItem "Supported Browsers" "#" False
            , NavItem "Turbopack" "#" False
            ]
      }
    , { title = "Community"
      , items =
            [ NavItem "Contribution Guide" "#" False ]
      }
    ]



-- SIDEBAR


versionSwitcher : State -> Html State.Msg
versionSwitcher state =
    let
        selectedVersion =
            State.get "block02-version" state
                |> Maybe.withDefault (List.head versions |> Maybe.withDefault "")
    in
    Sidebar.menu []
        [ Sidebar.menuItem []
            [ DropdownMenu.new
                |> DropdownMenu.id "block02-version-switcher"
                |> DropdownMenu.trigger (Sidebar.menuButtonAttributes ++ [ Sidebar.large ])
                    [ div [ class "flex aspect-square size-8 items-center justify-center rounded-lg bg-sidebar-primary text-sidebar-primary-foreground" ]
                        [ Phosphor.stack Regular
                            |> Phosphor.withClass "size-4"
                            |> Phosphor.toHtml []
                        ]
                    , div [ class "flex flex-col gap-0.5 leading-none" ]
                        [ span [ class "font-medium" ] [ text "Documentation" ]
                        , span [ class "" ] [ text ("v" ++ selectedVersion) ]
                        ]
                    , Phosphor.caretUpDown Regular
                        |> Phosphor.withClass "ml-auto"
                        |> Phosphor.toHtml []
                    ]
                |> DropdownMenu.content
                    (List.map
                        (\version ->
                            DropdownMenu.item [ onClick (State.set "block02-version" version) ]
                                (text ("v" ++ version)
                                    :: (if version == selectedVersion then
                                            [ Phosphor.check Regular
                                                |> Phosphor.withClass "ml-auto"
                                                |> Phosphor.toHtml []
                                            ]

                                        else
                                            []
                                       )
                                )
                        )
                        versions
                    )
                |> DropdownMenu.toHtml []
            ]
        ]


searchForm : Html State.Msg
searchForm =
    Html.form []
        [ Sidebar.group [ class "py-0" ]
            [ Sidebar.groupContent [ class "relative" ]
                [ Label.view [ for "block02-search", class "sr-only" ] [ text "Search" ]
                , Input.view [ class "h-8 bg-background shadow-none", id "block02-search", placeholder "Search the docs...", class "pl-8" ]
                , Phosphor.magnifyingGlass Regular
                    |> Phosphor.withClass "pointer-events-none absolute top-1/2 left-2 size-4 -translate-y-1/2 opacity-50 select-none"
                    |> Phosphor.toHtml []
                ]
            ]
        ]


navGroup : NavGroup -> Html State.Msg
navGroup group =
    Sidebar.group []
        [ Sidebar.collapsible [ Sidebar.defaultOpen ]
            (Sidebar.groupTrigger [ class "group/label text-sm text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground" ]
                [ text (group.title ++ " ")
                , Phosphor.caretRight Regular
                    |> Phosphor.withClass "ml-auto transition-transform group-open/collapsible:rotate-90"
                    |> Phosphor.toHtml []
                ]
            )
            [ Sidebar.groupContent []
                [ Sidebar.menu []
                    (List.map
                        (\item ->
                            Sidebar.menuItem []
                                [ Sidebar.menuLink
                                    (href item.url
                                        :: (if item.isActive then
                                                [ Sidebar.active ]

                                            else
                                                []
                                           )
                                    )
                                    [ text item.title ]
                                ]
                        )
                        group.items
                    )
                ]
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
