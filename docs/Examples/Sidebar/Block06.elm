module Examples.Sidebar.Block06 exposing (view)

{-| A port of shadcn's `sidebar-06` block: a sidebar with submenus as dropdowns.
-}

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (attribute, class, href, placeholder, type_)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.Breadcrumb as Breadcrumb
import UI.Button as Button
import UI.Card as Card
import UI.DropdownMenu as DropdownMenu
import UI.Input as Input
import UI.Separator as Separator
import UI.Sidebar as Sidebar


view : State -> Html State.Msg
view state =
    Sidebar.new
        |> Sidebar.state (sidebarState "block06" state) (setSidebarState "block06")
        |> Sidebar.header
            [ Sidebar.menu []
                [ Sidebar.menuItem []
                    [ Sidebar.menuLink [ href "#", Sidebar.large ]
                        [ div [ class "flex aspect-square size-8 items-center justify-center rounded-lg bg-sidebar-primary text-sidebar-primary-foreground" ]
                            [ Phosphor.stack Regular
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
        |> Sidebar.content [ navMain ]
        |> Sidebar.footer [ div [ class "p-1" ] [ optInForm ] ]
        |> Sidebar.rail
        |> Sidebar.page []
            [ Html.header [ class "flex h-16 shrink-0 items-center gap-2 border-b px-4" ]
                [ Sidebar.trigger [ class "-ml-1" ] (sidebarState "block06" state) (setSidebarState "block06")
                , Separator.new
                    |> Separator.vertical
                    |> Separator.toHtml [ class "mr-2 my-auto data-[orientation=vertical]:h-4" ]
                , Breadcrumb.new
                    |> Breadcrumb.item [ class "hidden md:block" ]
                        [ Html.a [ attribute "data-slot" "breadcrumb-link", class "transition-colors hover:text-foreground", href "#" ] [ text "Build Your Application" ] ]
                    |> Breadcrumb.page [ text "Data Fetching" ]
                    |> Breadcrumb.separator
                        (Phosphor.caretRight Regular
                            |> Phosphor.withClass "hidden md:block"
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
                , div [ class "min-h-[100vh] flex-1 rounded-xl bg-muted/50 md:min-h-min" ] []
                ]
            ]
        |> Sidebar.toHtml []



-- NAV MAIN


navMain : Html State.Msg
navMain =
    Sidebar.group []
        [ Sidebar.menu [] (List.map navMainItem navMainItems) ]


navMainItem : NavItem -> Html State.Msg
navMainItem item =
    Sidebar.menuItem []
        [ DropdownMenu.new
            |> DropdownMenu.id ("block06-nav-" ++ item.slug)
            |> DropdownMenu.trigger (Sidebar.menuButtonAttributes ++ [ class "aria-expanded:bg-muted" ])
                [ text item.title
                , text " "
                , Phosphor.dotsThree Regular
                    |> Phosphor.withClass "ml-auto"
                    |> Phosphor.toHtml []
                ]
            |> DropdownMenu.content
                (List.map
                    (\entry -> DropdownMenu.item [] [ text entry.title ])
                    item.items
                )
            |> DropdownMenu.right
            |> DropdownMenu.toHtml [ class "min-w-56 rounded-lg" ]
        ]



-- DATA


type alias NavItem =
    { title : String
    , slug : String
    , items : List SubItem
    }


type alias SubItem =
    { title : String
    , url : String
    , isActive : Bool
    }


subItem : String -> SubItem
subItem title =
    { title = title, url = "#", isActive = False }


navMainItems : List NavItem
navMainItems =
    [ { title = "Getting Started"
      , slug = "getting-started"
      , items =
            [ subItem "Installation"
            , subItem "Project Structure"
            ]
      }
    , { title = "Build Your Application"
      , slug = "build-your-application"
      , items =
            [ subItem "Routing"
            , { title = "Data Fetching", url = "#", isActive = True }
            , subItem "Rendering"
            , subItem "Caching"
            , subItem "Styling"
            , subItem "Optimizing"
            , subItem "Configuring"
            , subItem "Testing"
            , subItem "Authentication"
            , subItem "Deploying"
            , subItem "Upgrading"
            , subItem "Examples"
            ]
      }
    , { title = "API Reference"
      , slug = "api-reference"
      , items =
            [ subItem "Components"
            , subItem "File Conventions"
            , subItem "Functions"
            , subItem "next.config.js Options"
            , subItem "CLI"
            , subItem "Edge Runtime"
            ]
      }
    , { title = "Architecture"
      , slug = "architecture"
      , items =
            [ subItem "Accessibility"
            , subItem "Fast Refresh"
            , subItem "Next.js Compiler"
            , subItem "Supported Browsers"
            , subItem "Turbopack"
            ]
      }
    ]



-- OPT-IN FORM


optInForm : Html State.Msg
optInForm =
    Card.new
        |> Card.title [ span [ class "text-sm" ] [ text "Subscribe to our newsletter" ] ]
        |> Card.description [ text "Opt-in to receive updates and news about the sidebar." ]
        |> Card.content [ class "px-4" ]
            [ Html.form []
                [ div [ class "grid gap-2.5" ]
                    [ Input.view [ class "h-8 bg-background shadow-none", type_ "email", placeholder "Email" ]
                    , Button.new
                        |> Button.text "Subscribe"
                        |> Button.toHtml [ class "w-full bg-sidebar-primary text-sidebar-primary-foreground shadow-none" ]
                    ]
                ]
            ]
        |> Card.toHtml [ class "gap-2 py-4 shadow-none" ]



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
