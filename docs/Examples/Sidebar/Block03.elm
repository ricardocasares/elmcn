module Examples.Sidebar.Block03 exposing (view)

{-| shadcn's `sidebar-03` block: a sidebar with submenus.
-}

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, href)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.Breadcrumb as Breadcrumb
import UI.Separator as Separator
import UI.Sidebar as Sidebar


view : State -> Html State.Msg
view state =
    Sidebar.new
        |> Sidebar.state (sidebarState "block03" state) (setSidebarState "block03")
        |> Sidebar.header
            [ Sidebar.menu []
                [ Sidebar.menuItem []
                    [ Sidebar.menuLink [ href "#", Sidebar.large ]
                        [ div [ class "flex aspect-square size-8 items-center justify-center rounded-lg bg-sidebar-primary text-sidebar-primary-foreground" ]
                            [ Phosphor.rows Regular
                                |> Phosphor.withClass "size-4"
                                |> Phosphor.toHtml []
                            ]
                        , div [ class "flex flex-col gap-0.5 leading-none" ]
                            [ span [ class "font-medium" ] [ text "Documentation" ]
                            , span [ class "" ] [ text "v1.0.0" ]
                            ]
                        ]
                    ]
                ]
            ]
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.menu [] (List.map navMainItem navMain) ]
            ]
        |> Sidebar.rail
        |> Sidebar.page []
            [ Html.header [ class "flex h-16 shrink-0 items-center gap-2 border-b" ]
                [ div [ class "flex items-center gap-2 px-3" ]
                    [ Sidebar.trigger [] (sidebarState "block03" state) (setSidebarState "block03")
                    , Separator.new
                        |> Separator.vertical
                        |> Separator.toHtml [ class "mr-2" ]
                    , Breadcrumb.new
                        |> Breadcrumb.item [ class "hidden md:block" ]
                            [ Html.a
                                [ Html.Attributes.attribute "data-slot" "breadcrumb-link"
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
            , div [ class "flex flex-1 flex-col gap-4 p-4" ]
                [ div [ class "grid auto-rows-min gap-4 md:grid-cols-3" ]
                    [ div [ class "aspect-video rounded-xl bg-muted/50" ] []
                    , div [ class "aspect-video rounded-xl bg-muted/50" ] []
                    , div [ class "aspect-video rounded-xl bg-muted/50" ] []
                    ]
                , div [ class "min-h-[100vh] flex-1 rounded-xl bg-muted/50 md:min-h-min" ] []
                ]
            ]
        |> Sidebar.toHtml []



-- NAV


type alias NavItem =
    { title : String
    , url : String
    , items : List SubItem
    }


type alias SubItem =
    { title : String
    , url : String
    , isActive : Bool
    }


navMainItem : NavItem -> Html msg
navMainItem item =
    Sidebar.menuItem []
        (Sidebar.menuLink [ href item.url, class "font-medium" ] [ text item.title ]
            :: (if List.isEmpty item.items then
                    []

                else
                    [ Sidebar.menuSub [] (List.map navSubItem item.items) ]
               )
        )


navSubItem : SubItem -> Html msg
navSubItem item =
    Sidebar.menuSubItem []
        [ Sidebar.menuSubLink
            (href item.url
                :: (if item.isActive then
                        [ Sidebar.active ]

                    else
                        []
                   )
            )
            [ text item.title ]
        ]



-- DATA


sub : String -> SubItem
sub title =
    { title = title, url = "#", isActive = False }


navMain : List NavItem
navMain =
    [ { title = "Getting Started"
      , url = "#"
      , items = [ sub "Installation", sub "Project Structure" ]
      }
    , { title = "Build Your Application"
      , url = "#"
      , items =
            [ sub "Routing"
            , { title = "Data Fetching", url = "#", isActive = True }
            , sub "Rendering"
            , sub "Caching"
            , sub "Styling"
            , sub "Optimizing"
            , sub "Configuring"
            , sub "Testing"
            , sub "Authentication"
            , sub "Deploying"
            , sub "Upgrading"
            , sub "Examples"
            ]
      }
    , { title = "API Reference"
      , url = "#"
      , items =
            [ sub "Components"
            , sub "File Conventions"
            , sub "Functions"
            , sub "next.config.js Options"
            , sub "CLI"
            , sub "Edge Runtime"
            ]
      }
    , { title = "Architecture"
      , url = "#"
      , items =
            [ sub "Accessibility"
            , sub "Fast Refresh"
            , sub "Next.js Compiler"
            , sub "Supported Browsers"
            , sub "Turbopack"
            ]
      }
    , { title = "Community"
      , url = "#"
      , items = [ sub "Contribution Guide" ]
      }
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
