module Examples.Sidebar.Block11 exposing (view)

{-| A sidebar with a collapsible file tree. Port of shadcn's `sidebar-11` block.
-}

import Html exposing (Html, div, text)
import Html.Attributes exposing (attribute, class, href)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.Breadcrumb as Breadcrumb
import UI.Separator as Separator
import UI.Sidebar as Sidebar


key : String
key =
    "block11"


view : State -> Html State.Msg
view state =
    Sidebar.new
        |> Sidebar.state (sidebarState key state) (setSidebarState key)
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.groupLabel [] [ text "Changes" ]
                , Sidebar.groupContent []
                    [ Sidebar.menu [] (List.map viewChange changes) ]
                ]
            , Sidebar.group []
                [ Sidebar.groupLabel [] [ text "Files" ]
                , Sidebar.groupContent []
                    [ Sidebar.menu [] (List.map viewTree tree) ]
                ]
            ]
        |> Sidebar.rail
        |> Sidebar.page []
            [ Html.header [ class "flex h-16 shrink-0 items-center gap-2 border-b px-4" ]
                [ Sidebar.trigger [ class "-ml-1" ] (sidebarState key state) (setSidebarState key)
                , Separator.new
                    |> Separator.vertical
                    |> Separator.toHtml [ class "mr-2 my-auto data-[orientation=vertical]:h-4" ]
                , Breadcrumb.new
                    |> Breadcrumb.item [ class "hidden md:block" ] [ breadcrumbLink "components" ]
                    |> Breadcrumb.item [ class "hidden md:block" ] [ breadcrumbLink "ui" ]
                    |> Breadcrumb.page [ text "button.tsx" ]
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
                , div [ class "min-h-screen flex-1 rounded-xl bg-muted/50 md:min-h-min" ] []
                ]
            ]
        |> Sidebar.toHtml []


{-| Upstream's `BreadcrumbItem className="hidden md:block"` puts the class on the `<li>`, which `Breadcrumb.link` does not expose, so the item is built by hand.
-}
breadcrumbLink : String -> Html msg
breadcrumbLink label =
    Html.a
        [ attribute "data-slot" "breadcrumb-link"
        , class "transition-colors hover:text-foreground"
        , href "#"
        ]
        [ text label ]



-- CHANGES


type alias Change =
    { file : String
    , state : String
    }


changes : List Change
changes =
    [ { file = "README.md", state = "M" }
    , { file = "api/hello/route.ts", state = "U" }
    , { file = "app/layout.tsx", state = "M" }
    ]


viewChange : Change -> Html msg
viewChange change =
    Sidebar.menuItem []
        [ Sidebar.menuButton []
            [ Phosphor.file Regular |> Phosphor.toHtml []
            , text change.file
            ]
        , Sidebar.menuBadge [] [ text change.state ]
        ]



-- FILE TREE


type Tree
    = File String
    | Folder String (List Tree)


tree : List Tree
tree =
    [ Folder "app"
        [ Folder "api"
            [ Folder "hello" [ File "route.ts" ]
            , File "page.tsx"
            , File "layout.tsx"
            , Folder "blog" [ File "page.tsx" ]
            ]
        ]
    , Folder "components"
        [ Folder "ui" [ File "button.tsx", File "card.tsx" ]
        , File "header.tsx"
        , File "footer.tsx"
        ]
    , Folder "lib" [ File "util.ts" ]
    , Folder "public" [ File "favicon.ico", File "vercel.svg" ]
    , File ".eslintrc.json"
    , File ".gitignore"
    , File "next.config.js"
    , File "tailwind.config.js"
    , File "package.json"
    , File "README.md"
    ]


{-| Like upstream, a file is a bare menu button and a folder is a menu item holding a collapsible, whose content is a submenu of the same.
-}
viewTree : Tree -> Html msg
viewTree node =
    case node of
        File name ->
            Sidebar.menuButton
                (class "data-[active=true]:bg-transparent"
                    :: (if name == "button.tsx" then
                            [ Sidebar.active ]

                        else
                            []
                       )
                )
                [ Phosphor.file Regular |> Phosphor.toHtml []
                , text name
                ]

        Folder name children ->
            Sidebar.menuItem []
                [ Sidebar.collapsible
                    (if name == "components" || name == "ui" then
                        [ Sidebar.defaultOpen ]

                     else
                        []
                    )
                    (Sidebar.menuTrigger []
                        [ Phosphor.caretRight Regular
                            |> Phosphor.withClass "transition-transform group-open/collapsible:rotate-90"
                            |> Phosphor.toHtml []
                        , Phosphor.folder Regular |> Phosphor.toHtml []
                        , text name
                        ]
                    )
                    [ Sidebar.menuSub [] (List.map viewTree children) ]
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
