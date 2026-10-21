module Examples.Sidebar.Block04 exposing (view)

{-| A floating sidebar with submenus.
-}

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (attribute, class, href)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.Breadcrumb as Breadcrumb
import UI.Separator as Separator
import UI.Sidebar as Sidebar


type alias NavItem =
    { title : String
    , url : String
    , isActive : Bool
    }


type alias NavGroup =
    { title : String
    , url : String
    , items : List NavItem
    }


navMain : List NavGroup
navMain =
    [ { title = "Getting Started"
      , url = "#"
      , items =
            [ NavItem "Installation" "#" False
            , NavItem "Project Structure" "#" False
            ]
      }
    , { title = "Build Your Application"
      , url = "#"
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
      , url = "#"
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
      , url = "#"
      , items =
            [ NavItem "Accessibility" "#" False
            , NavItem "Fast Refresh" "#" False
            , NavItem "Next.js Compiler" "#" False
            , NavItem "Supported Browsers" "#" False
            , NavItem "Turbopack" "#" False
            ]
      }
    , { title = "Community"
      , url = "#"
      , items =
            [ NavItem "Contribution Guide" "#" False
            ]
      }
    ]


view : State -> Html State.Msg
view state =
    Sidebar.new
        |> Sidebar.state (sidebarState "block04" state) (setSidebarState "block04")
        |> Sidebar.floating
        |> Sidebar.width "19rem"
        |> Sidebar.header [ appHeader ]
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.menu [ class "gap-2" ] (List.map navGroup navMain) ]
            ]
        |> Sidebar.page []
            [ Html.header [ class "flex h-16 shrink-0 items-center gap-2 px-4" ]
                [ Sidebar.trigger [ class "-ml-1" ] (sidebarState "block04" state) (setSidebarState "block04")
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
                        (span [ class "hidden md:block [&>svg]:size-3.5" ]
                            [ Phosphor.caretRight Regular |> Phosphor.toHtml [] ]
                        )
                    |> Breadcrumb.toHtml []
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


appHeader : Html msg
appHeader =
    Sidebar.menu []
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


navGroup : NavGroup -> Html msg
navGroup item =
    Sidebar.menuItem []
        (Sidebar.menuLink [ href item.url, class "font-medium" ] [ text item.title ]
            :: (if List.isEmpty item.items then
                    []

                else
                    [ Sidebar.menuSub [ class "ml-0 border-l-0 px-1.5" ]
                        (List.map navSubItem item.items)
                    ]
               )
        )


navSubItem : NavItem -> Html msg
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
