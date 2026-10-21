module Examples.Sidebar.Block01 exposing (view)

{-| A simple sidebar with navigation grouped by section.

A port of shadcn's `sidebar-01` block.

-}

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (attribute, class, for, href, id, placeholder)
import Html.Events exposing (onClick)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.Breadcrumb as Breadcrumb
import UI.DropdownMenu as DropdownMenu
import UI.Input as Input
import UI.Label as Label
import UI.Separator as Separator
import UI.Sidebar as Sidebar


key : String
key =
    "block01"


view : State -> Html State.Msg
view state =
    Sidebar.new
        |> Sidebar.state (sidebarState key state) (setSidebarState key)
        |> Sidebar.header
            [ versionSwitcher state
            , searchForm
            ]
        |> Sidebar.content (List.map navGroup navMain)
        |> Sidebar.rail
        |> Sidebar.page []
            [ Html.header [ class "flex h-16 shrink-0 items-center gap-2 border-b px-4" ]
                [ Sidebar.trigger [ class "-ml-1" ] (sidebarState key state) (setSidebarState key)
                , Separator.new
                    |> Separator.vertical
                    |> Separator.toHtml [ class "mr-2 my-auto data-[orientation=vertical]:h-4" ]
                , Breadcrumb.new
                    |> Breadcrumb.item [ class "hidden md:block" ]
                        [ Html.a [ attribute "data-slot" "breadcrumb-link", href "#", class "transition-colors hover:text-foreground" ] [ text "Build Your Application" ] ]
                    |> Breadcrumb.page [ text "Data Fetching" ]
                    |> Breadcrumb.separator
                        (Phosphor.caretRight Regular
                            |> Phosphor.toHtml []
                        )
                    |> Breadcrumb.toHtml []
                ]
            , div [ class "flex flex-1 flex-col gap-4 p-4" ]
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


navItem : String -> NavItem
navItem title =
    { title = title, url = "#", isActive = False }


navMain : List NavGroup
navMain =
    [ { title = "Getting Started"
      , items =
            [ navItem "Installation"
            , navItem "Project Structure"
            ]
      }
    , { title = "Build Your Application"
      , items =
            [ navItem "Routing"
            , { title = "Data Fetching", url = "#", isActive = True }
            , navItem "Rendering"
            , navItem "Caching"
            , navItem "Styling"
            , navItem "Optimizing"
            , navItem "Configuring"
            , navItem "Testing"
            , navItem "Authentication"
            , navItem "Deploying"
            , navItem "Upgrading"
            , navItem "Examples"
            ]
      }
    , { title = "API Reference"
      , items =
            [ navItem "Components"
            , navItem "File Conventions"
            , navItem "Functions"
            , navItem "next.config.js Options"
            , navItem "CLI"
            , navItem "Edge Runtime"
            ]
      }
    , { title = "Architecture"
      , items =
            [ navItem "Accessibility"
            , navItem "Fast Refresh"
            , navItem "Next.js Compiler"
            , navItem "Supported Browsers"
            , navItem "Turbopack"
            ]
      }
    ]



-- SIDEBAR PARTS


navGroup : NavGroup -> Html State.Msg
navGroup group =
    Sidebar.group []
        [ Sidebar.groupLabel [] [ text group.title ]
        , Sidebar.groupContent []
            [ Sidebar.menu [] (List.map navMenuItem group.items) ]
        ]


navMenuItem : NavItem -> Html State.Msg
navMenuItem item =
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


versionSwitcher : State -> Html State.Msg
versionSwitcher state =
    let
        selectedVersion =
            State.get (key ++ "-version") state
                |> Maybe.withDefault (List.head versions |> Maybe.withDefault "")
    in
    Sidebar.menu []
        [ Sidebar.menuItem []
            [ DropdownMenu.new
                |> DropdownMenu.id (key ++ "-version-switcher")
                |> DropdownMenu.trigger
                    (Sidebar.menuButtonAttributes
                        ++ [ Sidebar.large
                           , class "data-open:bg-sidebar-accent data-open:text-sidebar-accent-foreground"
                           ]
                    )
                    [ div [ class "flex aspect-square size-8 items-center justify-center rounded-lg bg-sidebar-primary text-sidebar-primary-foreground" ]
                        [ Phosphor.rows Regular
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
                            DropdownMenu.item [ onClick (State.set (key ++ "-version") version) ]
                                (text ("v" ++ version ++ " ")
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
                [ Label.view [ for (key ++ "-search"), class "sr-only" ] [ text "Search" ]
                , Input.view
                    [ id (key ++ "-search")
                    , placeholder "Search the docs..."
                    , class "h-8 bg-background shadow-none pl-8"
                    ]
                , Phosphor.magnifyingGlass Regular
                    |> Phosphor.withClass "pointer-events-none absolute top-1/2 left-2 size-4 -translate-y-1/2 opacity-50 select-none"
                    |> Phosphor.toHtml []
                ]
            ]
        ]



-- STATE


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
