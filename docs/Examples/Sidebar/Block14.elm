module Examples.Sidebar.Block14 exposing (view)

{-| A sidebar on the right.
-}

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, href)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.Breadcrumb as Breadcrumb
import UI.Sidebar as Sidebar


view : State -> Html State.Msg
view state =
    Sidebar.new
        |> Sidebar.state (sidebarState "block14" state) (setSidebarState "block14")
        |> Sidebar.right
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.groupLabel [] [ text "Table of Contents" ]
                , Sidebar.groupContent []
                    [ Sidebar.menu [] (List.map navSection navMain) ]
                ]
            ]
        |> Sidebar.rail
        |> Sidebar.page []
            [ Html.header [ class "flex h-16 shrink-0 items-center gap-2 border-b px-4" ]
                [ Breadcrumb.new
                    |> Breadcrumb.item [ class "hidden md:block" ]
                        [ Html.a
                            [ href "#", class "transition-colors hover:text-foreground" ]
                            [ text "Build Your Application" ]
                        ]
                    |> Breadcrumb.page [ text "Data Fetching" ]
                    |> Breadcrumb.separator
                        (Phosphor.caretRight Regular
                            |> Phosphor.withClass "hidden md:block"
                            |> Phosphor.toHtml []
                        )
                    |> Breadcrumb.toHtml []
                , Sidebar.trigger [ class "-mr-1 ml-auto rotate-180" ] (sidebarState "block14" state) (setSidebarState "block14")
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


type alias Section =
    { title : String
    , url : String
    , items : List Item
    }


type alias Item =
    { title : String
    , url : String
    , isActive : Bool
    }


navSection : Section -> Html State.Msg
navSection section =
    Sidebar.menuItem []
        (Sidebar.menuLink [ href section.url, class "font-medium" ] [ text section.title ]
            :: (if List.isEmpty section.items then
                    []

                else
                    [ Sidebar.menuSub [] (List.map navItem section.items) ]
               )
        )


navItem : Item -> Html State.Msg
navItem item =
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


navMain : List Section
navMain =
    [ { title = "Getting Started"
      , url = "#"
      , items =
            [ page "Installation"
            , page "Project Structure"
            ]
      }
    , { title = "Build Your Application"
      , url = "#"
      , items =
            [ page "Routing"
            , { title = "Data Fetching", url = "#", isActive = True }
            , page "Rendering"
            , page "Caching"
            , page "Styling"
            , page "Optimizing"
            , page "Configuring"
            , page "Testing"
            , page "Authentication"
            , page "Deploying"
            , page "Upgrading"
            , page "Examples"
            ]
      }
    , { title = "API Reference"
      , url = "#"
      , items =
            [ page "Components"
            , page "File Conventions"
            , page "Functions"
            , page "next.config.js Options"
            , page "CLI"
            , page "Edge Runtime"
            ]
      }
    , { title = "Architecture"
      , url = "#"
      , items =
            [ page "Accessibility"
            , page "Fast Refresh"
            , page "Next.js Compiler"
            , page "Supported Browsers"
            , page "Turbopack"
            ]
      }
    , { title = "Community"
      , url = "#"
      , items = [ page "Contribution Guide" ]
      }
    ]


page : String -> Item
page title =
    { title = title, url = "#", isActive = False }



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
