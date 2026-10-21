module Examples.Sidebar exposing (..)

import Examples.Sidebar.Block01 as Block01
import Examples.Sidebar.Block02 as Block02
import Examples.Sidebar.Block03 as Block03
import Examples.Sidebar.Block04 as Block04
import Examples.Sidebar.Block05 as Block05
import Examples.Sidebar.Block06 as Block06
import Examples.Sidebar.Block07 as Block07
import Examples.Sidebar.Block08 as Block08
import Examples.Sidebar.Block09 as Block09
import Examples.Sidebar.Block10 as Block10
import Examples.Sidebar.Block11 as Block11
import Examples.Sidebar.Block12 as Block12
import Examples.Sidebar.Block13 as Block13
import Examples.Sidebar.Block14 as Block14
import Examples.Sidebar.Block15 as Block15
import Examples.Sidebar.Block16 as Block16
import Html exposing (Html, div, p, span, text)
import Html.Attributes exposing (alt, class, dir, href, src, title)
import Html.Events exposing (onClick)
import Phosphor exposing (IconVariant, IconWeight(..))
import State exposing (State)
import UI.Avatar as Avatar
import UI.Button as Button
import UI.DropdownMenu as DropdownMenu
import UI.Sidebar as Sidebar


{-| A sidebar that collapses to icons, with a workspace switcher, collapsible items, project actions and a user menu.
-}
demo : State -> Html State.Msg
demo state =
    Sidebar.new
        |> Sidebar.state (sidebarState "demo" state) (setSidebarState "demo")
        |> Sidebar.collapsesToIcons
        |> Sidebar.header [ teamSwitcher "demo" english state ]
        |> Sidebar.content [ navMain english, navProjects "demo" english ]
        |> Sidebar.footer [ navUser "demo" english ]
        |> Sidebar.rail
        |> Sidebar.page []
            [ Html.header [ class "flex h-16 shrink-0 items-center gap-2 transition-[width,height] ease-linear md:group-has-data-[collapsible=icon]/sidebar-wrapper:h-12" ]
                [ div [ class "flex items-center gap-2 px-4" ]
                    [ Sidebar.trigger [ class "-ms-1" ] (sidebarState "demo" state) (setSidebarState "demo") ]
                ]
            ]
        |> Sidebar.toHtml []


{-| Use `header` for a sticky header, such as a workspace switcher.
-}
header : State -> Html State.Msg
header state =
    Sidebar.new
        |> Sidebar.state (sidebarState "header" state) (setSidebarState "header")
        |> Sidebar.header
            [ Sidebar.menu []
                [ Sidebar.menuItem []
                    [ DropdownMenu.new
                        |> DropdownMenu.id "sidebar-header-workspace"
                        |> DropdownMenu.trigger Sidebar.menuButtonAttributes
                            [ text "Select Workspace"
                            , Phosphor.caretDown Regular
                                |> Phosphor.withClass "ms-auto"
                                |> Phosphor.toHtml []
                            ]
                        |> DropdownMenu.content
                            [ DropdownMenu.item [] [ span [] [ text "Acme Inc" ] ]
                            , DropdownMenu.item [] [ span [] [ text "Acme Corp." ] ]
                            ]
                        |> DropdownMenu.toHtml []
                    ]
                ]
            ]
        |> Sidebar.page []
            [ Html.header [ class "flex h-12 items-center justify-between px-4" ]
                [ Sidebar.trigger [] (sidebarState "header" state) (setSidebarState "header") ]
            ]
        |> Sidebar.toHtml []


{-| Use `footer` for a sticky footer, such as a user menu.
-}
footer : State -> Html State.Msg
footer state =
    Sidebar.new
        |> Sidebar.state (sidebarState "footer" state) (setSidebarState "footer")
        |> Sidebar.footer
            [ Sidebar.menu []
                [ Sidebar.menuItem []
                    [ DropdownMenu.new
                        |> DropdownMenu.id "sidebar-footer-user"
                        |> DropdownMenu.trigger Sidebar.menuButtonAttributes
                            [ text "Username"
                            , Phosphor.caretUp Regular
                                |> Phosphor.withClass "ms-auto"
                                |> Phosphor.toHtml []
                            ]
                        |> DropdownMenu.content
                            [ DropdownMenu.item [] [ span [] [ text "Account" ] ]
                            , DropdownMenu.item [] [ span [] [ text "Billing" ] ]
                            , DropdownMenu.item [] [ span [] [ text "Sign out" ] ]
                            ]
                        |> DropdownMenu.top
                        |> DropdownMenu.toHtml []
                    ]
                ]
            ]
        |> Sidebar.page []
            [ Html.header [ class "flex h-12 items-center justify-between px-4" ]
                [ Sidebar.trigger [] (sidebarState "footer" state) (setSidebarState "footer") ]
            ]
        |> Sidebar.toHtml []


{-| A `group` is a section of the content, with a `groupLabel` and a `groupContent`.
-}
group : State -> Html State.Msg
group state =
    Sidebar.new
        |> Sidebar.state (sidebarState "group" state) (setSidebarState "group")
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.groupLabel [] [ text "Help" ]
                , Sidebar.groupContent []
                    [ Sidebar.menu []
                        [ Sidebar.menuItem []
                            [ Sidebar.menuButton [] [ icon Phosphor.lifebuoy, text "Support" ] ]
                        , Sidebar.menuItem []
                            [ Sidebar.menuButton [] [ icon Phosphor.paperPlaneTilt, text "Feedback" ] ]
                        ]
                    ]
                ]
            ]
        |> Sidebar.toHtml []


{-| A `groupAction` is a small button in the corner of a group. Give it an icon and an `sr-only` label.
-}
groupAction : State -> Html State.Msg
groupAction state =
    Sidebar.new
        |> Sidebar.state (sidebarState "group-action" state) (setSidebarState "group-action")
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.groupLabel [] [ text "Projects" ]
                , Sidebar.groupAction [ title "Add Project", onClick (State.set "group-action-clicked" "true") ]
                    [ icon Phosphor.plus, span [ class "sr-only" ] [ text "Add Project" ] ]
                , Sidebar.groupContent []
                    [ Sidebar.menu []
                        [ Sidebar.menuItem []
                            [ Sidebar.menuLink [ href "#" ] [ icon Phosphor.frameCorners, span [] [ text "Design Engineering" ] ] ]
                        , Sidebar.menuItem []
                            [ Sidebar.menuLink [ href "#" ] [ icon Phosphor.chartPie, span [] [ text "Sales & Marketing" ] ] ]
                        , Sidebar.menuItem []
                            [ Sidebar.menuLink [ href "#" ] [ icon Phosphor.mapTrifold, span [] [ text "Travel" ] ] ]
                        ]
                    ]
                ]
            ]
        |> Sidebar.page []
            [ if State.get "group-action-clicked" state == Just "true" then
                p [ class "p-4 text-sm text-muted-foreground" ] [ text "You clicked the group action!" ]

              else
                text ""
            ]
        |> Sidebar.toHtml []


{-| Wrap a group's label and content in a `collapsible`, with a `groupTrigger` as its label, to let the group fold away.
-}
groupCollapsible : State -> Html State.Msg
groupCollapsible state =
    Sidebar.new
        |> Sidebar.state (sidebarState "group-collapsible" state) (setSidebarState "group-collapsible")
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.collapsible [ Sidebar.defaultOpen ]
                    (Sidebar.groupTrigger [ class "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground" ]
                        [ text "Help"
                        , Phosphor.caretDown Regular
                            |> Phosphor.withClass "ms-auto transition-transform group-open/collapsible:rotate-180"
                            |> Phosphor.toHtml []
                        ]
                    )
                    [ Sidebar.groupContent []
                        [ Sidebar.menu []
                            [ Sidebar.menuItem []
                                [ Sidebar.menuButton [] [ icon Phosphor.lifebuoy, text "Support" ] ]
                            , Sidebar.menuItem []
                                [ Sidebar.menuButton [] [ icon Phosphor.paperPlaneTilt, text "Feedback" ] ]
                            ]
                        ]
                    ]
                ]
            ]
        |> Sidebar.toHtml []


{-| A `menu` is a list of `menuItem`s, each with a `menuButton` or a `menuLink`.
-}
menu : State -> Html State.Msg
menu state =
    Sidebar.new
        |> Sidebar.state (sidebarState "menu" state) (setSidebarState "menu")
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.groupLabel [] [ text "Projects" ]
                , Sidebar.groupContent []
                    [ Sidebar.menu []
                        (List.map
                            (\project ->
                                Sidebar.menuItem []
                                    [ Sidebar.menuLink [ href "#" ] [ icon project.icon, span [] [ text project.name ] ] ]
                            )
                            projects
                        )
                    ]
                ]
            ]
        |> Sidebar.toHtml []


{-| A `menuAction` sits at the end of an item, over its button. Here it opens a dropdown menu, so it takes `menuActionAttributes` instead.
-}
menuAction : State -> Html State.Msg
menuAction state =
    Sidebar.new
        |> Sidebar.state (sidebarState "menu-action" state) (setSidebarState "menu-action")
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.groupLabel [] [ text "Projects" ]
                , Sidebar.groupContent []
                    [ Sidebar.menu []
                        (List.map
                            (\project ->
                                Sidebar.menuItem []
                                    [ Sidebar.menuLink [ href "#", class "group-has-[:popover-open]/menu-item:bg-sidebar-accent" ]
                                        [ icon project.icon, span [] [ text project.name ] ]
                                    , DropdownMenu.new
                                        |> DropdownMenu.id ("sidebar-menu-action-" ++ project.slug)
                                        |> DropdownMenu.trigger Sidebar.menuActionAttributes
                                            [ icon Phosphor.dotsThree, span [ class "sr-only" ] [ text "More" ] ]
                                        |> DropdownMenu.content
                                            [ DropdownMenu.item [] [ span [] [ text "Edit Project" ] ]
                                            , DropdownMenu.item [] [ span [] [ text "Delete Project" ] ]
                                            ]
                                        |> DropdownMenu.right
                                        |> DropdownMenu.toHtml []
                                    ]
                            )
                            projects
                        )
                    ]
                ]
            ]
        |> Sidebar.toHtml []


{-| A `menuSub` lists `menuSubItem`s under an item, along a line.
-}
menuSub : State -> Html State.Msg
menuSub state =
    Sidebar.new
        |> Sidebar.state (sidebarState "menu-sub" state) (setSidebarState "menu-sub")
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.groupContent []
                    [ Sidebar.menu []
                        (List.map
                            (\item ->
                                Sidebar.menuItem []
                                    [ Sidebar.menuLink [ href "#" ] [ span [] [ text item.title ] ]
                                    , Sidebar.menuSub []
                                        (List.map
                                            (\subItem ->
                                                Sidebar.menuSubItem []
                                                    [ Sidebar.menuSubLink [ href "#" ] [ span [] [ text subItem ] ] ]
                                            )
                                            item.items
                                        )
                                    ]
                            )
                            docsItems
                        )
                    ]
                ]
            ]
        |> Sidebar.toHtml []


{-| Wrap an item's button and submenu in a `collapsible`, with a `menuTrigger` as its button, to let the submenu fold away.
-}
menuCollapsible : State -> Html State.Msg
menuCollapsible state =
    Sidebar.new
        |> Sidebar.state (sidebarState "menu-collapsible" state) (setSidebarState "menu-collapsible")
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.groupContent []
                    [ Sidebar.menu []
                        (List.indexedMap
                            (\index item ->
                                Sidebar.menuItem []
                                    [ Sidebar.collapsible
                                        (if index == 0 then
                                            [ Sidebar.defaultOpen ]

                                         else
                                            []
                                        )
                                        (Sidebar.menuTrigger []
                                            [ span [] [ text item.title ]
                                            , Phosphor.caretRight Regular
                                                |> Phosphor.withClass "ms-auto transition-transform group-open/collapsible:rotate-90"
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
                            docsItems
                        )
                    ]
                ]
            ]
        |> Sidebar.toHtml []


{-| A `menuBadge` shows a count at the end of an item.
-}
menuBadge : State -> Html State.Msg
menuBadge state =
    Sidebar.new
        |> Sidebar.state (sidebarState "menu-badge" state) (setSidebarState "menu-badge")
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.groupLabel [] [ text "Projects" ]
                , Sidebar.groupContent []
                    [ Sidebar.menu []
                        (List.map
                            (\project ->
                                Sidebar.menuItem []
                                    [ Sidebar.menuLink [ href "#" ] [ icon project.icon, span [] [ text project.name ] ]
                                    , Sidebar.menuBadge [] [ text project.badge ]
                                    ]
                            )
                            projects
                        )
                    ]
                ]
            ]
        |> Sidebar.toHtml []


{-| A `menuSkeleton` stands in for a button while its data loads. Each one is as wide as its `--skeleton-width`.
-}
menuSkeleton : State -> Html State.Msg
menuSkeleton state =
    let
        loaded =
            State.get "menu-skeleton" state == Just "loaded"
    in
    Sidebar.new
        |> Sidebar.state (sidebarState "menu-skeleton" state) (setSidebarState "menu-skeleton")
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.groupLabel [] [ text "Projects" ]
                , Sidebar.groupContent []
                    [ if loaded then
                        Sidebar.menu []
                            (List.map
                                (\project ->
                                    Sidebar.menuItem []
                                        [ Sidebar.menuLink [ href "#" ] [ icon project.icon, span [] [ text project.name ] ] ]
                                )
                                projects
                            )

                      else
                        Sidebar.menu []
                            (List.map
                                (\width ->
                                    Sidebar.menuItem []
                                        [ Sidebar.menuSkeleton [ Sidebar.showIcon, class width ] ]
                                )
                                [ "[--skeleton-width:72%]", "[--skeleton-width:56%]", "[--skeleton-width:84%]", "[--skeleton-width:63%]", "[--skeleton-width:48%]" ]
                            )
                    ]
                ]
            ]
        |> Sidebar.page []
            [ Html.header [ class "flex h-12 items-center px-4" ]
                [ Button.new
                    |> Button.text
                        (if loaded then
                            "Reload projects"

                         else
                            "Load projects"
                        )
                    |> Button.outline
                    |> Button.small
                    |> Button.toHtml
                        [ onClick
                            (State.batch
                                [ State.set "menu-skeleton" "loading"
                                , State.delay 2000 (State.set "menu-skeleton" "loaded")
                                ]
                            )
                        ]
                ]
            ]
        |> Sidebar.toHtml []


{-| The `State` is yours to change from anywhere: a button of your own can open and close the sidebar.
-}
controlled : State -> Html State.Msg
controlled state =
    let
        current =
            sidebarState "controlled" state
    in
    Sidebar.new
        |> Sidebar.state current (setSidebarState "controlled")
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.groupLabel [] [ text "Projects" ]
                , Sidebar.groupContent []
                    [ Sidebar.menu []
                        (List.map
                            (\project ->
                                Sidebar.menuItem []
                                    [ Sidebar.menuLink [ href "#" ] [ icon project.icon, span [] [ text project.name ] ] ]
                            )
                            projects
                        )
                    ]
                ]
            ]
        |> Sidebar.page []
            [ Html.header [ class "flex h-12 items-center justify-between px-4" ]
                [ Button.new
                    |> Button.text
                        (if current.open then
                            "Close Sidebar"

                         else
                            "Open Sidebar"
                        )
                    |> Button.startIcon (icon Phosphor.sidebarSimple)
                    |> Button.ghost
                    |> Button.small
                    |> Button.toHtml [ onClick (setSidebarState "controlled" { current | open = not current.open }) ]
                ]
            ]
        |> Sidebar.toHtml []


{-| Pass `dir "rtl"` to mirror the sidebar: it moves to the right, slides out that way, and its submenus hang off the right.
-}
rtl : State -> Html State.Msg
rtl state =
    let
        arabic_ =
            State.get "rtl-language" state /= Just "en"

        strings =
            if arabic_ then
                arabic

            else
                english
    in
    Sidebar.new
        |> Sidebar.state (sidebarState "rtl" state) (setSidebarState "rtl")
        |> Sidebar.collapsesToIcons
        |> Sidebar.header [ teamSwitcher "rtl" strings state ]
        |> Sidebar.content [ navMain strings, navProjects "rtl" strings ]
        |> Sidebar.footer [ navUser "rtl" strings ]
        |> Sidebar.rail
        |> Sidebar.page []
            [ Html.header [ class "flex h-16 shrink-0 items-center justify-between gap-2 px-4 transition-[width,height] ease-linear md:group-has-data-[collapsible=icon]/sidebar-wrapper:h-12" ]
                [ Sidebar.trigger [ class "-ms-1" ] (sidebarState "rtl" state) (setSidebarState "rtl")
                , Button.new
                    |> Button.text
                        (if arabic_ then
                            "English"

                         else
                            "العربية"
                        )
                    |> Button.outline
                    |> Button.small
                    |> Button.toHtml
                        [ onClick
                            (State.set "rtl-language"
                                (if arabic_ then
                                    "en"

                                 else
                                    "ar"
                                )
                            )
                        ]
                ]
            ]
        |> Sidebar.toHtml
            [ dir
                (if arabic_ then
                    "rtl"

                 else
                    "ltr"
                )
            ]



-- BLOCKS
--
-- The sidebar blocks from ui.shadcn.com/blocks/sidebar, each a module of its own under
-- docs/Examples/Sidebar/, shown with its whole source.


{-| A simple sidebar with navigation grouped by section.
-}
sidebar01 : State -> Html State.Msg
sidebar01 =
    Block01.view


{-| A sidebar with collapsible sections.
-}
sidebar02 : State -> Html State.Msg
sidebar02 =
    Block02.view


{-| A sidebar with submenus.
-}
sidebar03 : State -> Html State.Msg
sidebar03 =
    Block03.view


{-| A floating sidebar with submenus.
-}
sidebar04 : State -> Html State.Msg
sidebar04 =
    Block04.view


{-| A sidebar with collapsible submenus.
-}
sidebar05 : State -> Html State.Msg
sidebar05 =
    Block05.view


{-| A sidebar with submenus as dropdowns.
-}
sidebar06 : State -> Html State.Msg
sidebar06 =
    Block06.view


{-| A sidebar that collapses to icons.
-}
sidebar07 : State -> Html State.Msg
sidebar07 =
    Block07.view


{-| An inset sidebar with secondary navigation.
-}
sidebar08 : State -> Html State.Msg
sidebar08 =
    Block08.view


{-| Collapsible nested sidebars.
-}
sidebar09 : State -> Html State.Msg
sidebar09 =
    Block09.view


{-| A sidebar in a popover.
-}
sidebar10 : State -> Html State.Msg
sidebar10 =
    Block10.view


{-| A sidebar with a collapsible file tree.
-}
sidebar11 : State -> Html State.Msg
sidebar11 =
    Block11.view


{-| A sidebar with a calendar.
-}
sidebar12 : State -> Html State.Msg
sidebar12 =
    Block12.view


{-| A sidebar in a dialog.
-}
sidebar13 : State -> Html State.Msg
sidebar13 =
    Block13.view


{-| A sidebar on the right.
-}
sidebar14 : State -> Html State.Msg
sidebar14 =
    Block14.view


{-| A left and right sidebar.
-}
sidebar15 : State -> Html State.Msg
sidebar15 =
    Block15.view


{-| A sidebar with a sticky site header.
-}
sidebar16 : State -> Html State.Msg
sidebar16 =
    Block16.view



-- HELPERS


{-| The sidebar's state, kept in the docs' shared string map under two keys.
-}
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


icon : (IconWeight -> IconVariant) -> Html msg
icon i =
    i Regular
        |> Phosphor.toHtml []


type alias Project =
    { name : String, slug : String, icon : IconWeight -> IconVariant, badge : String }


projects : List Project
projects =
    [ Project "Design Engineering" "design" Phosphor.frameCorners "24"
    , Project "Sales & Marketing" "sales" Phosphor.chartPie "12"
    , Project "Travel" "travel" Phosphor.mapTrifold "3"
    , Project "Support" "support" Phosphor.lifebuoy "21"
    , Project "Feedback" "feedback" Phosphor.paperPlaneTilt "8"
    ]


docsItems : List { title : String, items : List String }
docsItems =
    [ { title = "Getting Started", items = [ "Installation", "Project Structure" ] }
    , { title = "Build Your Application"
      , items = [ "Routing", "Data Fetching", "Rendering", "Caching", "Styling", "Optimizing", "Configuring", "Testing", "Authentication", "Deploying", "Upgrading", "Examples" ]
      }
    , { title = "API Reference", items = [ "Components", "File Conventions", "Functions", "next.config.js Options", "CLI", "Edge Runtime" ] }
    , { title = "Architecture", items = [ "Accessibility", "Fast Refresh", "Next.js Compiler", "Supported Browsers", "Turbopack" ] }
    ]



-- THE DEMO'S PARTS


type alias Strings =
    { teams : List { name : String, plan : String, logo : IconWeight -> IconVariant }
    , addTeam : String
    , platform : String
    , navMain : List { title : String, icon : IconWeight -> IconVariant, isActive : Bool, items : List String }
    , projects : String
    , projectList : List { name : String, slug : String, icon : IconWeight -> IconVariant }
    , viewProject : String
    , shareProject : String
    , deleteProject : String
    , more : String
    , user : { name : String, email : String }
    , upgradeToPro : String
    , account : String
    , billing : String
    , notifications : String
    , logOut : String
    }


english : Strings
english =
    { teams =
        [ { name = "Acme Inc", plan = "Enterprise", logo = Phosphor.stack }
        , { name = "Acme Corp.", plan = "Startup", logo = Phosphor.waveform }
        , { name = "Evil Corp.", plan = "Free", logo = Phosphor.command }
        ]
    , addTeam = "Add team"
    , platform = "Platform"
    , navMain =
        [ { title = "Playground", icon = Phosphor.terminalWindow, isActive = True, items = [ "History", "Starred", "Settings" ] }
        , { title = "Models", icon = Phosphor.robot, isActive = False, items = [ "Genesis", "Explorer", "Quantum" ] }
        , { title = "Documentation", icon = Phosphor.bookOpen, isActive = False, items = [ "Introduction", "Get Started", "Tutorials", "Changelog" ] }
        , { title = "Settings", icon = Phosphor.sliders, isActive = False, items = [ "General", "Team", "Billing", "Limits" ] }
        ]
    , projects = "Projects"
    , projectList =
        [ { name = "Design Engineering", slug = "design", icon = Phosphor.frameCorners }
        , { name = "Sales & Marketing", slug = "sales", icon = Phosphor.chartPie }
        , { name = "Travel", slug = "travel", icon = Phosphor.mapTrifold }
        ]
    , viewProject = "View Project"
    , shareProject = "Share Project"
    , deleteProject = "Delete Project"
    , more = "More"
    , user = { name = "shadcn", email = "m@example.com" }
    , upgradeToPro = "Upgrade to Pro"
    , account = "Account"
    , billing = "Billing"
    , notifications = "Notifications"
    , logOut = "Log out"
    }


arabic : Strings
arabic =
    { teams = [ { name = "شركة أكمي", plan = "المؤسسة", logo = Phosphor.stack } ]
    , addTeam = "إضافة فريق"
    , platform = "المنصة"
    , navMain =
        [ { title = "ملعب", icon = Phosphor.terminalWindow, isActive = True, items = [ "السجل", "المميز", "الإعدادات" ] }
        , { title = "النماذج", icon = Phosphor.robot, isActive = False, items = [ "جينيسيس", "إكسبلورر", "كوانتوم" ] }
        , { title = "التوثيق", icon = Phosphor.bookOpen, isActive = False, items = [ "مقدمة", "ابدأ", "الدروس", "سجل التغييرات" ] }
        , { title = "الإعدادات", icon = Phosphor.sliders, isActive = False, items = [ "عام", "الفريق", "الفوترة", "الحدود" ] }
        ]
    , projects = "المشاريع"
    , projectList =
        [ { name = "هندسة التصميم", slug = "design", icon = Phosphor.frameCorners }
        , { name = "المبيعات والتسويق", slug = "sales", icon = Phosphor.chartPie }
        , { name = "السفر", slug = "travel", icon = Phosphor.mapTrifold }
        ]
    , viewProject = "عرض المشروع"
    , shareProject = "مشاركة المشروع"
    , deleteProject = "حذف المشروع"
    , more = "المزيد"
    , user = { name = "shadcn", email = "m@example.com" }
    , upgradeToPro = "ترقية إلى Pro"
    , account = "الحساب"
    , billing = "الفوترة"
    , notifications = "الإشعارات"
    , logOut = "تسجيل الخروج"
    }


teamSwitcher : String -> Strings -> State -> Html State.Msg
teamSwitcher key strings state =
    let
        team =
            strings.teams
                |> List.filter (\candidate -> Just candidate.name == State.get (key ++ "-team") state)
                |> List.head
                |> Maybe.withDefault
                    (List.head strings.teams
                        |> Maybe.withDefault { name = "", plan = "", logo = Phosphor.stack }
                    )
    in
    Sidebar.menu []
        [ Sidebar.menuItem []
            [ DropdownMenu.new
                |> DropdownMenu.id (key ++ "-sidebar-team")
                |> DropdownMenu.trigger (Sidebar.menuButtonAttributes ++ [ Sidebar.large ])
                    [ div [ class "flex aspect-square size-8 items-center justify-center rounded-lg bg-sidebar-primary text-sidebar-primary-foreground" ]
                        [ icon team.logo ]
                    , div [ class "grid flex-1 text-start text-sm leading-tight" ]
                        [ span [ class "truncate font-medium" ] [ text team.name ]
                        , span [ class "truncate text-xs" ] [ text team.plan ]
                        ]
                    , Phosphor.caretUpDown Regular
                        |> Phosphor.withClass "ms-auto"
                        |> Phosphor.toHtml []
                    ]
                |> DropdownMenu.content
                    [ DropdownMenu.group
                        (DropdownMenu.label [ text "Teams" ]
                            :: List.indexedMap
                                (\index t ->
                                    DropdownMenu.item [ class "gap-2 p-2", onClick (State.set (key ++ "-team") t.name) ]
                                        [ div [ class "flex size-6 items-center justify-center rounded-md border" ]
                                            [ t.logo Regular
                                                |> Phosphor.withClass "size-3.5 shrink-0"
                                                |> Phosphor.toHtml []
                                            ]
                                        , text t.name
                                        , DropdownMenu.shortcut [ text ("⌘" ++ String.fromInt (index + 1)) ]
                                        ]
                                )
                                strings.teams
                        )
                    , DropdownMenu.separator
                    , DropdownMenu.group
                        [ DropdownMenu.item [ class "gap-2 p-2" ]
                            [ div [ class "flex size-6 items-center justify-center rounded-md border bg-transparent" ] [ icon Phosphor.plus ]
                            , div [ class "font-medium text-muted-foreground" ] [ text strings.addTeam ]
                            ]
                        ]
                    ]
                |> DropdownMenu.right
                |> DropdownMenu.toHtml [ class "min-w-56 rounded-lg" ]
            ]
        ]


navMain : Strings -> Html State.Msg
navMain strings =
    Sidebar.group []
        [ Sidebar.groupLabel [] [ text strings.platform ]
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
                                    |> Phosphor.withClass "ms-auto transition-transform duration-200 group-open/collapsible:rotate-90 rtl:rotate-180 rtl:group-open/collapsible:rotate-90"
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
                strings.navMain
            )
        ]


navProjects : String -> Strings -> Html State.Msg
navProjects key strings =
    Sidebar.group [ class "md:group-data-[collapsible=icon]:hidden" ]
        [ Sidebar.groupLabel [] [ text strings.projects ]
        , Sidebar.menu []
            (List.map
                (\project ->
                    Sidebar.menuItem []
                        [ Sidebar.menuLink [ href "#" ] [ icon project.icon, span [] [ text project.name ] ]
                        , DropdownMenu.new
                            |> DropdownMenu.id (key ++ "-sidebar-project-" ++ project.slug)
                            |> DropdownMenu.trigger (Sidebar.menuActionAttributes ++ [ Sidebar.showOnHover ])
                                [ icon Phosphor.dotsThree, span [ class "sr-only" ] [ text strings.more ] ]
                            |> DropdownMenu.content
                                [ DropdownMenu.item [] [ mutedIcon Phosphor.folder, span [] [ text strings.viewProject ] ]
                                , DropdownMenu.item [] [ mutedIcon Phosphor.shareFat, span [] [ text strings.shareProject ] ]
                                , DropdownMenu.separator
                                , DropdownMenu.item [] [ mutedIcon Phosphor.trash, span [] [ text strings.deleteProject ] ]
                                ]
                            |> DropdownMenu.right
                            |> DropdownMenu.toHtml [ class "w-48 rounded-lg" ]
                        ]
                )
                strings.projectList
                ++ [ Sidebar.menuItem []
                        [ Sidebar.menuButton [ class "text-sidebar-foreground/70" ]
                            [ Phosphor.dotsThree Regular
                                |> Phosphor.withClass "text-sidebar-foreground/70"
                                |> Phosphor.toHtml []
                            , span [] [ text strings.more ]
                            ]
                        ]
                   ]
            )
        ]


navUser : String -> Strings -> Html State.Msg
navUser key strings =
    let
        avatar =
            Avatar.new
                |> Avatar.fallback [ text "CN" ]
                |> Avatar.img [ src "https://github.com/shadcn.png", alt strings.user.name ]
                |> Avatar.toHtml []

        details =
            div [ class "grid flex-1 text-start text-sm leading-tight" ]
                [ span [ class "truncate font-medium" ] [ text strings.user.name ]
                , span [ class "truncate text-xs" ] [ text strings.user.email ]
                ]
    in
    Sidebar.menu []
        [ Sidebar.menuItem []
            [ DropdownMenu.new
                |> DropdownMenu.id (key ++ "-sidebar-user")
                |> DropdownMenu.trigger (Sidebar.menuButtonAttributes ++ [ Sidebar.large ])
                    [ avatar
                    , details
                    , Phosphor.caretUpDown Regular
                        |> Phosphor.withClass "ms-auto size-4"
                        |> Phosphor.toHtml []
                    ]
                |> DropdownMenu.content
                    [ DropdownMenu.group
                        [ DropdownMenu.label
                            [ div [ class "flex items-center gap-2 text-start text-sm font-normal" ] [ avatar, details ] ]
                        ]
                    , DropdownMenu.separator
                    , DropdownMenu.group
                        [ DropdownMenu.item [] [ icon Phosphor.sparkle, text strings.upgradeToPro ] ]
                    , DropdownMenu.separator
                    , DropdownMenu.group
                        [ DropdownMenu.item [] [ icon Phosphor.sealCheck, text strings.account ]
                        , DropdownMenu.item [] [ icon Phosphor.creditCard, text strings.billing ]
                        , DropdownMenu.item [] [ icon Phosphor.bell, text strings.notifications ]
                        ]
                    , DropdownMenu.separator
                    , DropdownMenu.group
                        [ DropdownMenu.item [] [ icon Phosphor.signOut, text strings.logOut ] ]
                    ]
                |> DropdownMenu.right
                |> DropdownMenu.alignEnd
                |> DropdownMenu.toHtml [ class "min-w-56 rounded-lg" ]
            ]
        ]


mutedIcon : (IconWeight -> IconVariant) -> Html msg
mutedIcon i =
    i Regular
        |> Phosphor.withClass "text-muted-foreground"
        |> Phosphor.toHtml []
