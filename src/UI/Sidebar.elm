module UI.Sidebar exposing
    ( Sidebar, Ready, NeedsState
    , State, init
    , new
    , state
    , header, content, footer, rail, page
    , right, floating, inset
    , offcanvas, collapsesToIcons, neverCollapses
    , width, mobileWidth
    , toHtml
    , trigger
    , group, groupLabel, groupAction, groupContent, separator
    , menu, menuItem, menuButton, menuLink, menuButtonAttributes
    , menuAction, menuActionAttributes, menuBadge, menuSkeleton
    , menuSub, menuSubItem, menuSubLink, menuSubButton
    , collapsible, Trigger, menuTrigger, groupTrigger, defaultOpen
    , active, outline, small, large, tooltip, showOnHover, showIcon
    )

{-| A composable, themeable and customizable sidebar.

A sidebar is built with `new`, given its `state`, filled in with parts, and rendered with `toHtml`. The page content goes in `page`, next to it:

    Sidebar.new
        |> Sidebar.state model.sidebar SidebarChanged
        |> Sidebar.header [ workspaceSwitcher ]
        |> Sidebar.content
            [ Sidebar.group []
                [ Sidebar.groupLabel [] [ text "Projects" ]
                , Sidebar.menu []
                    [ Sidebar.menuItem []
                        [ Sidebar.menuLink [ href "#", Sidebar.active ]
                            [ Phosphor.frameCorners Regular |> Phosphor.toHtml []
                            , span [] [ text "Design Engineering" ]
                            ]
                        ]
                    ]
                ]
            ]
        |> Sidebar.footer [ userMenu ]
        |> Sidebar.rail
        |> Sidebar.page []
            [ Html.header [ class "flex h-12 items-center px-4" ]
                [ Sidebar.trigger [] model.sidebar SidebarChanged ]
            ]
        |> Sidebar.toHtml []

The [`State`](#State) lives in your model, starting from [`init`](#init). The [`trigger`](#trigger), the [`rail`](#rail) and the mobile sheet ask to change it with the message you gave [`state`](#state):

    type alias Model =
        { sidebar : Sidebar.State }

    init =
        { sidebar = Sidebar.init }

    update msg model =
        case msg of
            SidebarChanged sidebar ->
                { model | sidebar = sidebar }

From the `md` breakpoint up, the sidebar is a panel beside the content that sticks to the viewport while the page scrolls, and collapses out of view or down to its icons. Below it, the same panel becomes a sheet that slides over the page: a native `<dialog>` inside `<elmcn-dialog>`, the small custom element behind `Dialog` and `Drawer`, which opens it when `openMobile` is true and closes it for real once it has slid out. Import the element once from your JavaScript entry point:

    import "./UI/elmcn-dialog";

The sheet traps focus, makes the rest of the page inert and stops it scrolling. Escape and a tap on the overlay ask to close it.

@docs Sidebar, Ready, NeedsState


# State

@docs State, init


# Constructor

@docs new


# Required

`toHtml` won't accept a sidebar until it has its `state`.

@docs state


# Parts

Every part is optional. The header and footer stay put while the content scrolls between them. The `page` part is the page content beside the sidebar, which it fills.

@docs header, content, footer, rail, page


# Side and variants

The last one wins. The sidebar sits at the start of the page, the left in left-to-right text and the right in right-to-left text, unless given `right`.

@docs right, floating, inset


# Collapsing

The last one wins. Collapsing only exists from `md` up: below it the sidebar is a sheet. A class that reacts to the collapsed state, such as `group-data-[collapsible=icon]:hidden`, needs the `md:` prefix for the same reason.

@docs offcanvas, collapsesToIcons, neverCollapses


# Setters

@docs width, mobileWidth


# Rendering

@docs toHtml


# Trigger

@docs trigger


# Groups

The content is made of groups, each with a label and a menu.

@docs group, groupLabel, groupAction, groupContent, separator


# Menus

A menu is a list of items. An item holds a button or a link, and can hold an action, a badge and a submenu beside it.

@docs menu, menuItem, menuButton, menuLink, menuButtonAttributes

@docs menuAction, menuActionAttributes, menuBadge, menuSkeleton

@docs menuSub, menuSubItem, menuSubLink, menuSubButton


# Collapsible

A collapsible group or item is a native `<details>`, with no state of its own to keep. Its trigger is the `<summary>`, styled as a group label or a menu button, and its content animates open and closed.

    Sidebar.menuItem []
        [ Sidebar.collapsible [ Sidebar.defaultOpen ]
            (Sidebar.menuTrigger []
                [ Phosphor.terminalWindow Regular |> Phosphor.toHtml []
                , span [] [ text "Playground" ]
                , Phosphor.caretRight Regular
                    |> Phosphor.toHtml [ class "ms-auto transition-transform duration-200 group-open/collapsible:rotate-90" ]
                ]
            )
            [ Sidebar.menuSub []
                [ Sidebar.menuSubItem [] [ Sidebar.menuSubLink [ href "#" ] [ span [] [ text "History" ] ] ] ]
            ]
        ]

@docs collapsible, Trigger, menuTrigger, groupTrigger, defaultOpen


# Modifiers

Attributes for the buttons, links and actions above. `active` marks the current page, `small` and `large` change the size, `outline` the look, and `tooltip` names an icon once the sidebar has collapsed to icons.

@docs active, outline, small, large, tooltip, showOnHover, showIcon

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, property, tabindex, type_)
import Html.Events
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import UI.Button as Button
import UI.Skeleton as Skeleton


{-| A sidebar being built.

`state` is [`Ready`](#Ready) once the sidebar has its [`state`](#state).

-}
type Sidebar state msg
    = Sidebar
        { state : State
        , onChange : Maybe (State -> msg)
        , header : List (Html msg)
        , content : List (Html msg)
        , footer : List (Html msg)
        , rail : Bool
        , page : Maybe ( List (Attribute msg), List (Html msg) )
        , side : Side
        , variant : Variant
        , collapsible : Collapsible
        , width : Maybe String
        , mobileWidth : Maybe String
        }


{-| Whether the sidebar is open beside the content from `md` up, and whether its sheet is open below `md`. The two are separate, like shadcn's `open` and `openMobile`: a phone opens the sheet without touching the desktop state.
-}
type alias State =
    { open : Bool
    , openMobile : Bool
    }


{-| Open beside the content, with the sheet closed.
-}
init : State
init =
    { open = True, openMobile = False }


type Side
    = Left
    | Right


type Variant
    = Default
    | Floating
    | Inset


type Collapsible
    = Offcanvas
    | Icon
    | None


{-| The sidebar can be rendered.
-}
type Ready
    = Ready


{-| A sidebar that still needs its [`state`](#state) before it can be rendered.
-}
type NeedsState
    = NeedsState



-- CONSTRUCTOR


{-| An empty sidebar on the left that collapses out of view. Give it its [`state`](#state) to make it renderable.
-}
new : Sidebar NeedsState msg
new =
    Sidebar
        { state = init
        , onChange = Nothing
        , header = []
        , content = []
        , footer = []
        , rail = False
        , page = Nothing
        , side = Left
        , variant = Default
        , collapsible = Offcanvas
        , width = Nothing
        , mobileWidth = Nothing
        }



-- REQUIRED


{-| The state of the sidebar, and the message it sends when it asks to change it: from the [`trigger`](#trigger), the [`rail`](#rail), and Escape or a tap on the overlay of the sheet. The sidebar animates whenever the value changes:

    Sidebar.state model.sidebar SidebarChanged

-}
state : State -> (State -> msg) -> Sidebar NeedsState msg -> Sidebar Ready msg
state current onChange (Sidebar config) =
    Sidebar { config | state = current, onChange = Just onChange }



-- PARTS


{-| The top of the sidebar, for branding or a workspace switcher. A column with a gap.
-}
header : List (Html msg) -> Sidebar state msg -> Sidebar state msg
header children (Sidebar config) =
    Sidebar { config | header = children }


{-| The scrollable middle of the sidebar, where the [`group`](#group)s go.
-}
content : List (Html msg) -> Sidebar state msg -> Sidebar state msg
content children (Sidebar config) =
    Sidebar { config | content = children }


{-| The bottom of the sidebar, for a user menu or settings. A column with a gap.
-}
footer : List (Html msg) -> Sidebar state msg -> Sidebar state msg
footer children (Sidebar config) =
    Sidebar { config | footer = children }


{-| A thin strip along the edge of the sidebar that toggles it when clicked, from `md` up.
-}
rail : Sidebar state msg -> Sidebar state msg
rail (Sidebar config) =
    Sidebar { config | rail = True }


{-| The page content beside the sidebar, a `<main>` that fills the rest of the width. With the [`inset`](#inset) variant it floats on the sidebar's background with rounded corners. The attributes come after the styles so they can override them.
-}
page : List (Attribute msg) -> List (Html msg) -> Sidebar state msg -> Sidebar state msg
page attrs children (Sidebar config) =
    Sidebar { config | page = Just ( attrs, children ) }



-- SIDE AND VARIANTS


{-| Puts the sidebar at the end of the page: the right in left-to-right text and the left in right-to-left text.
-}
right : Sidebar state msg -> Sidebar state msg
right (Sidebar config) =
    Sidebar { config | side = Right }


{-| A panel with rounded corners, a ring and a shadow, set in from the edges of the page.
-}
floating : Sidebar state msg -> Sidebar state msg
floating (Sidebar config) =
    Sidebar { config | variant = Floating }


{-| A sidebar on the page's background, with the [`page`](#page) content set in beside it as a rounded card.
-}
inset : Sidebar state msg -> Sidebar state msg
inset (Sidebar config) =
    Sidebar { config | variant = Inset }



-- COLLAPSING


{-| Slides out of view when closed, leaving a [`rail`](#rail) to open it again. The default.
-}
offcanvas : Sidebar state msg -> Sidebar state msg
offcanvas (Sidebar config) =
    Sidebar { config | collapsible = Offcanvas }


{-| Shrinks to a column of icons when closed: labels, badges, actions and submenus hide, and a [`tooltip`](#tooltip) names each button on hover.
-}
collapsesToIcons : Sidebar state msg -> Sidebar state msg
collapsesToIcons (Sidebar config) =
    Sidebar { config | collapsible = Icon }


{-| Always open beside the content, with no sheet below `md`. The state is ignored.
-}
neverCollapses : Sidebar state msg -> Sidebar state msg
neverCollapses (Sidebar config) =
    Sidebar { config | collapsible = None }



-- SETTERS


{-| A CSS width for the sidebar from `md` up, instead of `16rem`.
-}
width : String -> Sidebar state msg -> Sidebar state msg
width value (Sidebar config) =
    Sidebar { config | width = Just value }


{-| A CSS width for the sheet below `md`, instead of `18rem`.
-}
mobileWidth : String -> Sidebar state msg -> Sidebar state msg
mobileWidth value (Sidebar config) =
    Sidebar { config | mobileWidth = Just value }



-- RENDERING


{-| Renders the sidebar and the `page` content side by side in a wrapper as tall as the viewport, with the attributes on the wrapper after the styles. Pass `dir "rtl"` to mirror it.
-}
toHtml : List (Attribute msg) -> Sidebar Ready msg -> Html msg
toHtml attrs (Sidebar config) =
    Html.div
        ([ attribute "data-slot" "sidebar-wrapper"
         , attribute "style"
            ("--sidebar-width: "
                ++ Maybe.withDefault "16rem" config.width
                ++ "; --sidebar-width-mobile: "
                ++ Maybe.withDefault "18rem" config.mobileWidth
                ++ "; --sidebar-width-icon: 3rem"
            )

         -- `overflow-x-clip` keeps a sidebar that has slid out past the edge from
         -- widening the page. Unlike `hidden`, `clip` leaves the panel free to stick.
         , class "group/sidebar-wrapper flex min-h-svh w-full overflow-x-clip"
         , class
            (case config.variant of
                Inset ->
                    "md:bg-sidebar"

                _ ->
                    ""
            )
         ]
            ++ attrs
        )
        (case config.side of
            Left ->
                [ viewSidebar config, viewMain config ]

            Right ->
                [ viewMain config, viewSidebar config ]
        )


type alias Config msg =
    { state : State
    , onChange : Maybe (State -> msg)
    , header : List (Html msg)
    , content : List (Html msg)
    , footer : List (Html msg)
    , rail : Bool
    , page : Maybe ( List (Attribute msg), List (Html msg) )
    , side : Side
    , variant : Variant
    , collapsible : Collapsible
    , width : Maybe String
    , mobileWidth : Maybe String
    }


viewMain : Config msg -> Html msg
viewMain config =
    case config.page of
        Nothing ->
            Html.text ""

        Just ( attrs, children ) ->
            Html.main_
                ([ attribute "data-slot" "sidebar-inset"
                 , class "relative flex w-full flex-1 flex-col bg-background"
                 , class
                    (case config.variant of
                        Inset ->
                            "md:m-2 md:rounded-xl md:shadow-sm "
                                ++ (case config.side of
                                        Left ->
                                            if config.state.open || config.collapsible == None then
                                                "md:ms-0"

                                            else
                                                "md:ms-2"

                                        Right ->
                                            if config.state.open || config.collapsible == None then
                                                "md:me-0"

                                            else
                                                "md:me-2"
                                   )

                        _ ->
                            ""
                    )
                 ]
                    ++ attrs
                )
                children


viewSidebar : Config msg -> Html msg
viewSidebar config =
    let
        parts =
            List.filterMap identity
                [ if List.isEmpty config.header then
                    Nothing

                  else
                    Just (Html.div [ attribute "data-slot" "sidebar-header", attribute "data-sidebar" "header", class "flex flex-col gap-2 p-2" ] config.header)
                , Just
                    (Html.div
                        [ attribute "data-slot" "sidebar-content"
                        , attribute "data-sidebar" "content"
                        , class "scrollbar-none flex min-h-0 flex-1 flex-col gap-0 overflow-auto md:group-data-[collapsible=icon]:overflow-hidden"
                        ]
                        config.content
                    )
                , if List.isEmpty config.footer then
                    Nothing

                  else
                    Just (Html.div [ attribute "data-slot" "sidebar-footer", attribute "data-sidebar" "footer", class "flex flex-col gap-2 p-2" ] config.footer)
                ]
    in
    case config.collapsible of
        None ->
            Html.div
                [ attribute "data-slot" "sidebar"
                , attribute "data-side" (sideName config.side)
                , attribute "data-variant" (variantName config.variant)
                , attribute "data-state" "expanded"
                , attribute "data-collapsible" ""
                , class "group peer flex h-full w-(--sidebar-width) shrink-0 flex-col bg-sidebar text-sidebar-foreground"
                ]
                parts

        _ ->
            viewCollapsible config parts


viewCollapsible : Config msg -> List (Html msg) -> Html msg
viewCollapsible config parts =
    let
        collapsed =
            not config.state.open

        padded =
            config.variant /= Default

        -- `onChange` is a `Maybe` only because `new` has none yet: `state` is required
        -- by the type, so there is always one here.
        closeMobile =
            List.filterMap identity
                [ Maybe.map (\onChange -> onChange { open = config.state.open, openMobile = False }) config.onChange ]

        -- From `md` up, a right sidebar overflows its gap towards the start so that
        -- it stays flush with the page's edge once the gap has shrunk to nothing.
        gapClass =
            String.join " "
                [ "relative flex h-full w-0 bg-transparent transition-[width] duration-200 ease-linear md:w-(--sidebar-width)"
                , case config.side of
                    Left ->
                        "justify-start"

                    Right ->
                        "justify-end"
                , if collapsed then
                    case config.collapsible of
                        Icon ->
                            if padded then
                                "md:w-[calc(var(--sidebar-width-icon)+(--spacing(4)))]"

                            else
                                "md:w-(--sidebar-width-icon)"

                        _ ->
                            "md:w-0"

                  else
                    ""
                ]

        -- The panel. Below `md` it is a modal sheet filling the viewport, with the
        -- overlay and the sliding panel inside. From `md` up it is in flow, sticky
        -- to the top of the viewport and as tall as it, overflowing its gap when the
        -- gap has shrunk, and sliding or shrinking with it.
        containerClass =
            String.join " "
                [ "fixed inset-0 z-50 m-0 hidden h-full max-h-none w-full max-w-none border-0 bg-transparent p-0 text-inherit outline-none open:block backdrop:bg-transparent"
                , "md:sticky md:inset-auto md:top-0 md:z-10 md:flex md:max-h-svh md:w-(--sidebar-width) md:shrink-0 md:transition-[translate,width] md:duration-200 md:ease-linear"

                -- The page behind stops scrolling while the sheet is open, keeping its
                -- scrollbar gutter so that nothing shifts.
                , "[html:has(&:modal)]:overflow-hidden [html:has(&:modal)]:[scrollbar-gutter:stable]"

                -- On iOS the page behind is dimmed and blurred by a filter on the root
                -- instead of by the overlay, which would make Safari paint a solid bar
                -- under its toolbar. See `UI.Dialog` for the details.
                , "supports-[-webkit-touch-callout:none]:[html:has(&:modal)]:transition-[filter] supports-[-webkit-touch-callout:none]:[html:has(&:modal)]:duration-200 supports-[-webkit-touch-callout:none]:[html:has(&:modal)]:ease-in-out supports-[-webkit-touch-callout:none]:[html:has(elmcn-dialog[open]>&:modal)]:[filter:blur(var(--blur-xs))_brightness(0.9)]"
                , if padded then
                    "md:p-2"

                  else
                    case config.side of
                        Left ->
                            "md:border-e"

                        Right ->
                            "md:border-s"
                , if collapsed then
                    case config.collapsible of
                        Icon ->
                            if padded then
                                "md:w-[calc(var(--sidebar-width-icon)+(--spacing(4))+2px)] md:[translate:0_0]"

                            else
                                "md:w-(--sidebar-width-icon) md:[translate:0_0]"

                        _ ->
                            case config.side of
                                Left ->
                                    "md:[translate:-100%_0] md:rtl:[translate:100%_0]"

                                Right ->
                                    "md:[translate:100%_0] md:rtl:[translate:-100%_0]"

                  else
                    "md:[translate:0_0]"
                ]

        innerClass =
            String.join " "
                [ "absolute inset-y-0 start-0 flex w-(--sidebar-width-mobile) flex-col border-e bg-sidebar text-sidebar-foreground shadow-lg md:static md:inset-auto md:size-full md:border-0 md:shadow-none"

                -- The sheet fades and slides in from `@starting-style` and out before the
                -- element closes the dialog. Plain properties, because Safari ignores
                -- `@starting-style` values set through variables.
                , "opacity-0 transition-[opacity,translate] duration-200 ease-in-out md:opacity-100 md:transition-none [elmcn-dialog[open]>dialog>&]:opacity-100 starting:[elmcn-dialog[open]>dialog>&]:opacity-0"
                , case config.side of
                    Left ->
                        "max-md:[translate:-2.5rem_0] max-md:rtl:[translate:2.5rem_0] [elmcn-dialog[open]>dialog>&]:[translate:0_0] starting:[elmcn-dialog[open]>dialog>&]:[translate:-2.5rem_0] rtl:starting:[elmcn-dialog[open]>dialog>&]:[translate:2.5rem_0]"

                    Right ->
                        "start-auto end-0 border-e-0 border-s max-md:[translate:2.5rem_0] max-md:rtl:[translate:-2.5rem_0] [elmcn-dialog[open]>dialog>&]:[translate:0_0] starting:[elmcn-dialog[open]>dialog>&]:[translate:2.5rem_0] rtl:starting:[elmcn-dialog[open]>dialog>&]:[translate:-2.5rem_0]"
                , case config.variant of
                    Floating ->
                        "md:rounded-lg md:shadow-sm md:ring-1 md:ring-sidebar-border"

                    _ ->
                        ""
                ]
    in
    Html.div
        [ attribute "data-slot" "sidebar"
        , attribute "data-side" (sideName config.side)
        , attribute "data-variant" (variantName config.variant)
        , attribute "data-state"
            (if collapsed then
                "collapsed"

             else
                "expanded"
            )
        , attribute "data-collapsible"
            (if collapsed then
                collapsibleName config.collapsible

             else
                ""
            )
        , class "group peer text-sidebar-foreground"
        ]
        [ Html.div
            [ attribute "data-slot" "sidebar-gap", class gapClass ]
            [ Html.node "elmcn-dialog"
                (class "contents"
                    :: (if config.state.openMobile then
                            [ attribute "open" "" ]

                        else
                            []
                       )
                )
                [ Html.node "dialog"
                    ([ attribute "data-slot" "sidebar-container"
                     , attribute "data-sidebar" "sidebar"
                     , attribute "aria-label" "Sidebar"
                     , class containerClass
                     ]
                        ++ List.concatMap closeRequests closeMobile
                    )
                    [ Html.div
                        ([ attribute "data-slot" "sidebar-overlay"
                         , attribute "aria-hidden" "true"
                         , class "absolute inset-0 select-none md:hidden not-supports-[-webkit-touch-callout:none]:bg-black/10"
                         , class "opacity-0 transition-[opacity,backdrop-filter] duration-200 ease-in-out [elmcn-dialog[open]>dialog>&]:opacity-100 starting:[elmcn-dialog[open]>dialog>&]:opacity-0 not-supports-[-webkit-touch-callout:none]:[backdrop-filter:blur(0)] not-supports-[-webkit-touch-callout:none]:[elmcn-dialog[open]>dialog>&]:[backdrop-filter:blur(var(--blur-xs))] not-supports-[-webkit-touch-callout:none]:starting:[elmcn-dialog[open]>dialog>&]:[backdrop-filter:blur(0)]"
                         ]
                            ++ List.map Html.Events.onClick closeMobile
                        )
                        []
                    , Html.div
                        [ attribute "data-slot" "sidebar-inner"
                        , attribute "data-sidebar" "sidebar"
                        , class innerClass
                        ]
                        parts
                    , if config.rail then
                        viewRail config

                      else
                        Html.text ""
                    ]
                ]
            ]
        ]


viewRail : Config msg -> Html msg
viewRail config =
    let
        collapsed =
            not config.state.open

        offcanvas_ =
            collapsed && config.collapsible == Offcanvas
    in
    Html.button
        ([ type_ "button"
         , attribute "data-slot" "sidebar-rail"
         , attribute "data-sidebar" "rail"
         , attribute "aria-label" "Toggle Sidebar"
         , Html.Attributes.title "Toggle Sidebar"
         , tabindex -1
         , class "absolute inset-y-0 z-20 hidden w-4 transition-all ease-linear after:absolute after:inset-y-0 after:start-1/2 after:w-[2px] hover:after:bg-sidebar-border md:flex"
         , class
            (case config.side of
                Left ->
                    if offcanvas_ then
                        "-end-2 translate-x-0 after:start-full hover:bg-sidebar"

                    else
                        "-end-4 -translate-x-1/2 rtl:translate-x-1/2"

                Right ->
                    if offcanvas_ then
                        "-start-2 translate-x-0 after:start-full hover:bg-sidebar"

                    else
                        "start-0 -translate-x-1/2 rtl:translate-x-1/2"
            )
         , class
            (case ( config.side, collapsed ) of
                ( Left, False ) ->
                    "cursor-w-resize rtl:cursor-e-resize"

                ( Left, True ) ->
                    "cursor-e-resize rtl:cursor-w-resize"

                ( Right, False ) ->
                    "cursor-e-resize rtl:cursor-w-resize"

                ( Right, True ) ->
                    "cursor-w-resize rtl:cursor-e-resize"
            )
         ]
            ++ toggleEvents config
        )
        []


toggleEvents : Config msg -> List (Attribute msg)
toggleEvents config =
    List.filterMap identity
        [ Maybe.map (\onChange -> Html.Events.on "click" (toggle config.state onChange)) config.onChange ]


{-| Toggles the sheet on a narrow viewport and the panel otherwise. The event's `view` is the window, whose width tells which one is showing: below 768px, Tailwind's `md`, it is the sheet.
-}
toggle : State -> (State -> msg) -> Decoder msg
toggle current onChange =
    Decode.maybe (Decode.at [ "view", "innerWidth" ] Decode.float)
        |> Decode.map
            (\innerWidth ->
                if Maybe.withDefault 1024 innerWidth < 768 then
                    onChange { current | openMobile = not current.openMobile }

                else
                    onChange { current | open = not current.open }
            )


{-| Escape asks the sheet to close, caught on `keydown` before it becomes a `cancel` that would close the dialog without its exit transition. See `UI.Dialog` for the details.
-}
closeRequests : msg -> List (Attribute msg)
closeRequests msg =
    [ Html.Events.custom "keydown"
        (Decode.field "key" Decode.string
            |> Decode.andThen
                (\key ->
                    if key == "Escape" then
                        Decode.succeed { message = msg, stopPropagation = True, preventDefault = True }

                    else
                        Decode.fail key
                )
        )
    , Html.Events.preventDefaultOn "cancel" (Decode.succeed ( msg, True ))
    , Html.Events.on "close"
        (Decode.at [ "target", "parentElement", "attributes", "open" ] Decode.value
            |> Decode.map (\_ -> msg)
        )
    ]


sideName : Side -> String
sideName side =
    case side of
        Left ->
            "left"

        Right ->
            "right"


variantName : Variant -> String
variantName variant =
    case variant of
        Default ->
            "sidebar"

        Floating ->
            "floating"

        Inset ->
            "inset"


collapsibleName : Collapsible -> String
collapsibleName collapsible_ =
    case collapsible_ of
        Offcanvas ->
            "offcanvas"

        Icon ->
            "icon"

        None ->
            "none"



-- TRIGGER


{-| A ghost icon button that toggles the sidebar: the sheet below `md`, the panel from `md` up. Put it anywhere, usually in the header of [`page`](#page). The attributes come after the styles so they can override them.

    Sidebar.trigger [ class "-ms-1" ] model.sidebar SidebarChanged

-}
trigger : List (Attribute msg) -> State -> (State -> msg) -> Html msg
trigger attrs current onChange =
    Button.new
        |> Button.icon
            (Html.span
                [ attribute "aria-hidden" "true"
                , class "relative flex size-4 shrink-0 rounded-[3px] border-[1.33px] border-current"
                ]
                [ Html.span [ class "absolute inset-y-0 start-[3.33px] w-[1.33px] bg-current" ] [] ]
            )
        |> Button.label "Toggle Sidebar"
        |> Button.ghost
        |> Button.small
        |> Button.toHtml
            ([ attribute "data-slot" "sidebar-trigger"
             , attribute "data-sidebar" "trigger"
             , Html.Events.on "click" (toggle current onChange)
             ]
                ++ attrs
            )



-- GROUPS


{-| A section of the content, padded, with a [`groupLabel`](#groupLabel), a [`groupAction`](#groupAction) and a [`menu`](#menu) or [`groupContent`](#groupContent) inside.
-}
group : List (Attribute msg) -> List (Html msg) -> Html msg
group attrs children =
    Html.div
        ([ attribute "data-slot" "sidebar-group"
         , attribute "data-sidebar" "group"
         , class "relative flex w-full min-w-0 flex-col p-2"
         ]
            ++ attrs
        )
        children


{-| The heading of a group, which fades out when the sidebar collapses to icons.
-}
groupLabel : List (Attribute msg) -> List (Html msg) -> Html msg
groupLabel attrs children =
    Html.div
        ([ attribute "data-slot" "sidebar-group-label"
         , attribute "data-sidebar" "group-label"
         , class groupLabelClass
         ]
            ++ attrs
        )
        children


groupLabelClass : String
groupLabelClass =
    "flex h-8 shrink-0 items-center rounded-md px-2 text-xs font-medium text-sidebar-foreground/70 ring-sidebar-ring outline-hidden transition-[margin,opacity] duration-200 ease-linear focus-visible:ring-2 md:group-data-[collapsible=icon]:-mt-8 md:group-data-[collapsible=icon]:opacity-0 [&>svg]:size-4 [&>svg]:shrink-0"


{-| A small icon button in the top-right corner of a group, hidden when the sidebar collapses to icons. Give it an icon and an `sr-only` label.
-}
groupAction : List (Attribute msg) -> List (Html msg) -> Html msg
groupAction attrs children =
    Html.button
        ([ type_ "button"
         , attribute "data-slot" "sidebar-group-action"
         , attribute "data-sidebar" "group-action"
         , class "absolute end-3 top-3.5 flex aspect-square w-5 items-center justify-center rounded-md p-0 text-sidebar-foreground ring-sidebar-ring outline-hidden transition-transform hover:bg-sidebar-accent hover:text-sidebar-accent-foreground focus-visible:ring-2 md:group-data-[collapsible=icon]:hidden [&>svg]:size-4 [&>svg]:shrink-0"

         -- A bigger hit area on touch screens.
         , class "after:absolute after:-inset-2 md:after:hidden"
         ]
            ++ attrs
        )
        children


{-| The body of a group, when it isn't a [`menu`](#menu) directly.
-}
groupContent : List (Attribute msg) -> List (Html msg) -> Html msg
groupContent attrs children =
    Html.div
        ([ attribute "data-slot" "sidebar-group-content"
         , attribute "data-sidebar" "group-content"
         , class "w-full text-sm"
         ]
            ++ attrs
        )
        children


{-| A line between parts of the sidebar, set in from its edges.
-}
separator : List (Attribute msg) -> Html msg
separator attrs =
    Html.div
        ([ attribute "data-slot" "sidebar-separator"
         , attribute "data-sidebar" "separator"
         , attribute "role" "none"
         , class "mx-2 h-px w-auto shrink-0 bg-sidebar-border"
         ]
            ++ attrs
        )
        []



-- MENUS


{-| A list of [`menuItem`](#menuItem)s.
-}
menu : List (Attribute msg) -> List (Html msg) -> Html msg
menu attrs children =
    Html.ul
        ([ attribute "data-slot" "sidebar-menu"
         , attribute "data-sidebar" "menu"
         , class "flex w-full min-w-0 flex-col gap-1"
         ]
            ++ attrs
        )
        children


{-| One entry of a menu: a [`menuButton`](#menuButton) or [`menuLink`](#menuLink), and beside it a [`menuAction`](#menuAction), a [`menuBadge`](#menuBadge) or a [`menuSub`](#menuSub).
-}
menuItem : List (Attribute msg) -> List (Html msg) -> Html msg
menuItem attrs children =
    Html.li
        ([ attribute "data-slot" "sidebar-menu-item"
         , attribute "data-sidebar" "menu-item"
         , class "group/menu-item relative"
         ]
            ++ attrs
        )
        children


{-| A button filling the width of its item, with an icon and a label: `[&>span:last-child]` truncates, and `[&_svg]` is sized to `size-4`. Pass [`active`](#active), [`small`](#small), [`large`](#large), [`outline`](#outline) or [`tooltip`](#tooltip) among the attributes.
-}
menuButton : List (Attribute msg) -> List (Html msg) -> Html msg
menuButton attrs children =
    Html.button (type_ "button" :: menuButtonAttributes ++ attrs) children


{-| A [`menuButton`](#menuButton) that is an `<a>`.
-}
menuLink : List (Attribute msg) -> List (Html msg) -> Html msg
menuLink attrs children =
    Html.a (menuButtonAttributes ++ attrs) children


{-| The attributes of a [`menuButton`](#menuButton), for a button rendered by something else, such as a dropdown menu's trigger:

    DropdownMenu.trigger (Sidebar.menuButtonAttributes ++ [ Sidebar.large ]) [ … ]

The [`tooltip`](#tooltip) works there too. A trigger whose menu is open stays highlighted.

-}
menuButtonAttributes : List (Attribute msg)
menuButtonAttributes =
    [ attribute "data-slot" "sidebar-menu-button"
    , attribute "data-sidebar" "menu-button"
    , attribute "data-size" "default"
    , attribute "data-variant" "default"
    , class "peer/menu-button group/menu-button flex w-full items-center gap-2 overflow-hidden rounded-md p-2 text-start text-sm ring-sidebar-ring outline-hidden transition-[width,height,padding] hover:bg-sidebar-accent hover:text-sidebar-accent-foreground focus-visible:ring-2 active:bg-sidebar-accent active:text-sidebar-accent-foreground disabled:pointer-events-none disabled:opacity-50 aria-disabled:pointer-events-none aria-disabled:opacity-50 data-active:bg-sidebar-accent data-active:font-medium data-active:text-sidebar-accent-foreground [&:has(+:popover-open)]:bg-sidebar-accent [&:has(+:popover-open)]:text-sidebar-accent-foreground group-has-data-[sidebar=menu-action]/menu-item:pe-8 md:group-data-[collapsible=icon]:size-8! md:group-data-[collapsible=icon]:p-2! [&_svg]:size-4 [&_svg]:shrink-0 [&>span:last-child]:truncate"
    , class "data-[size=default]:h-8 data-[size=default]:text-sm data-[size=sm]:h-7 data-[size=sm]:text-xs data-[size=lg]:h-12 data-[size=lg]:text-sm md:group-data-[collapsible=icon]:data-[size=lg]:p-0!"
    , class "data-[variant=outline]:bg-background data-[variant=outline]:shadow-[0_0_0_1px_var(--sidebar-border)] data-[variant=outline]:hover:shadow-[0_0_0_1px_var(--sidebar-accent)]"
    , class tooltipClass
    ]


{-| The tooltip is the button's `::after`, out of the button's own clipping because it is `fixed`, and placed beside the button with CSS anchor positioning, which the button is the implicit anchor of. It only shows from `md` up, with the sidebar collapsed to icons, in browsers with anchor positioning.
-}
tooltipClass : String
tooltipClass =
    "after:pointer-events-none after:invisible after:fixed after:z-50 after:ms-1 after:-translate-y-1/2 after:rounded-md after:bg-foreground after:px-3 after:py-1.5 after:text-xs after:whitespace-nowrap after:text-background after:opacity-0 after:transition-[opacity,visibility] after:duration-150 after:content-[attr(data-tooltip)] after:[top:anchor(center)] after:[inset-inline-start:anchor(end)] supports-[anchor-name:none]:md:group-data-[collapsible=icon]:data-[tooltip]:hover:after:visible supports-[anchor-name:none]:md:group-data-[collapsible=icon]:data-[tooltip]:hover:after:opacity-100 supports-[anchor-name:none]:md:group-data-[collapsible=icon]:data-[tooltip]:focus-visible:after:visible supports-[anchor-name:none]:md:group-data-[collapsible=icon]:data-[tooltip]:focus-visible:after:opacity-100"


{-| A small icon button at the end of an item, over its button, hidden when the sidebar collapses to icons. Give it an icon and an `sr-only` label, and [`showOnHover`](#showOnHover) to show it only when the item is hovered.
-}
menuAction : List (Attribute msg) -> List (Html msg) -> Html msg
menuAction attrs children =
    Html.button (type_ "button" :: menuActionAttributes ++ attrs) children


{-| The attributes of a [`menuAction`](#menuAction), for a dropdown menu's trigger:

    DropdownMenu.trigger (Sidebar.menuActionAttributes ++ [ Sidebar.showOnHover ]) [ … ]

-}
menuActionAttributes : List (Attribute msg)
menuActionAttributes =
    [ attribute "data-slot" "sidebar-menu-action"
    , attribute "data-sidebar" "menu-action"
    , class "absolute end-1 top-1.5 flex aspect-square w-5 items-center justify-center rounded-md p-0 text-sidebar-foreground ring-sidebar-ring outline-hidden transition-transform hover:bg-sidebar-accent hover:text-sidebar-accent-foreground peer-hover/menu-button:text-sidebar-accent-foreground peer-data-[size=default]/menu-button:top-1.5 peer-data-[size=lg]/menu-button:top-2.5 peer-data-[size=sm]/menu-button:top-1 focus-visible:ring-2 md:group-data-[collapsible=icon]:hidden [&>svg]:size-4 [&>svg]:shrink-0"

    -- A bigger hit area on touch screens.
    , class "after:absolute after:-inset-2 md:after:hidden"
    ]


{-| A count or a short label at the end of an item, over its button, hidden when the sidebar collapses to icons.
-}
menuBadge : List (Attribute msg) -> List (Html msg) -> Html msg
menuBadge attrs children =
    Html.div
        ([ attribute "data-slot" "sidebar-menu-badge"
         , attribute "data-sidebar" "menu-badge"
         , class "pointer-events-none absolute end-1 flex h-5 min-w-5 items-center justify-center rounded-md px-1 text-xs font-medium text-sidebar-foreground tabular-nums select-none peer-hover/menu-button:text-sidebar-accent-foreground peer-data-active/menu-button:text-sidebar-accent-foreground peer-data-[size=default]/menu-button:top-1.5 peer-data-[size=lg]/menu-button:top-2.5 peer-data-[size=sm]/menu-button:top-1 md:group-data-[collapsible=icon]:hidden"
         ]
            ++ attrs
        )
        children


{-| A placeholder for a [`menuButton`](#menuButton) that is still loading: a bar as wide as `--skeleton-width`, `70%` unless a class such as `[--skeleton-width:55%]` says otherwise, and with [`showIcon`](#showIcon) a square before it.
-}
menuSkeleton : List (Attribute msg) -> Html msg
menuSkeleton attrs =
    Html.div
        ([ attribute "data-slot" "sidebar-menu-skeleton"
         , attribute "data-sidebar" "menu-skeleton"
         , class "flex h-8 items-center gap-2 rounded-md px-2"
         ]
            ++ attrs
        )
        [ Skeleton.view [ attribute "data-sidebar" "menu-skeleton-icon", class "hidden size-4 rounded-md [[data-icon]>&]:block" ]
        , Skeleton.view [ attribute "data-sidebar" "menu-skeleton-text", class "h-4 max-w-(--skeleton-width,70%) flex-1" ]
        ]


{-| A list of [`menuSubItem`](#menuSubItem)s under an item, along a line, hidden when the sidebar collapses to icons.
-}
menuSub : List (Attribute msg) -> List (Html msg) -> Html msg
menuSub attrs children =
    Html.ul
        ([ attribute "data-slot" "sidebar-menu-sub"
         , attribute "data-sidebar" "menu-sub"
         , class "mx-3.5 flex min-w-0 translate-x-px flex-col gap-1 border-s border-sidebar-border px-2.5 py-0.5 rtl:-translate-x-px md:group-data-[collapsible=icon]:hidden"
         ]
            ++ attrs
        )
        children


{-| One entry of a submenu.
-}
menuSubItem : List (Attribute msg) -> List (Html msg) -> Html msg
menuSubItem attrs children =
    Html.li
        ([ attribute "data-slot" "sidebar-menu-sub-item"
         , attribute "data-sidebar" "menu-sub-item"
         , class "group/menu-sub-item relative"
         ]
            ++ attrs
        )
        children


{-| A link filling the width of its subitem, smaller than a [`menuLink`](#menuLink). Pass [`active`](#active) or [`small`](#small) among the attributes.
-}
menuSubLink : List (Attribute msg) -> List (Html msg) -> Html msg
menuSubLink attrs children =
    Html.a (menuSubButtonAttributes ++ attrs) children


{-| A [`menuSubLink`](#menuSubLink) that is a `<button>`.
-}
menuSubButton : List (Attribute msg) -> List (Html msg) -> Html msg
menuSubButton attrs children =
    Html.button (type_ "button" :: menuSubButtonAttributes ++ attrs) children


menuSubButtonAttributes : List (Attribute msg)
menuSubButtonAttributes =
    [ attribute "data-slot" "sidebar-menu-sub-button"
    , attribute "data-sidebar" "menu-sub-button"
    , attribute "data-size" "md"
    , class "flex h-7 min-w-0 -translate-x-px items-center gap-2 overflow-hidden rounded-md px-2 text-sidebar-foreground ring-sidebar-ring outline-hidden rtl:translate-x-px hover:bg-sidebar-accent hover:text-sidebar-accent-foreground focus-visible:ring-2 active:bg-sidebar-accent active:text-sidebar-accent-foreground disabled:pointer-events-none disabled:opacity-50 aria-disabled:pointer-events-none aria-disabled:opacity-50 data-active:bg-sidebar-accent data-active:text-sidebar-accent-foreground data-[size=md]:text-sm data-[size=sm]:text-xs md:group-data-[collapsible=icon]:hidden [&>span:last-child]:truncate [&>svg]:size-4 [&>svg]:shrink-0 [&>svg]:text-sidebar-accent-foreground"
    ]



-- COLLAPSIBLE


{-| A `<details>` whose [`Trigger`](#Trigger) opens and closes the content below it, animating its height. Pass [`defaultOpen`](#defaultOpen) to render it open. Children of the trigger can react to the state with `group-open/collapsible:`.
-}
collapsible : List (Attribute msg) -> Trigger msg -> List (Html msg) -> Html msg
collapsible attrs (Trigger summary) children =
    Html.details
        ([ attribute "data-slot" "collapsible"
         , class "group/collapsible details-content:grid details-content:grid-rows-[0fr] details-content:[content-visibility:visible] details-content:transition-[grid-template-rows] details-content:duration-200 details-content:ease-out open:details-content:grid-rows-[1fr]"
         ]
            ++ attrs
        )
        [ summary
        , Html.div
            [ attribute "data-slot" "collapsible-content"
            , class "invisible min-h-0 overflow-hidden transition-[visibility] duration-200 group-open/collapsible:visible"
            ]
            children
        ]


{-| The `<summary>` of a [`collapsible`](#collapsible), made with [`menuTrigger`](#menuTrigger) or [`groupTrigger`](#groupTrigger).
-}
type Trigger msg
    = Trigger (Html msg)


{-| A trigger that looks like a [`menuButton`](#menuButton), for a collapsible [`menuItem`](#menuItem) with a [`menuSub`](#menuSub) inside.
-}
menuTrigger : List (Attribute msg) -> List (Html msg) -> Trigger msg
menuTrigger attrs children =
    Trigger (Html.summary (summaryClass :: menuButtonAttributes ++ attrs) children)


{-| A trigger that looks like a [`groupLabel`](#groupLabel), for a collapsible [`group`](#group).
-}
groupTrigger : List (Attribute msg) -> List (Html msg) -> Trigger msg
groupTrigger attrs children =
    Trigger
        (Html.summary
            ([ summaryClass
             , attribute "data-slot" "sidebar-group-label"
             , attribute "data-sidebar" "group-label"
             , class groupLabelClass
             ]
                ++ attrs
            )
            children
        )


summaryClass : Attribute msg
summaryClass =
    class "cursor-pointer list-none select-none [&::-webkit-details-marker]:hidden"


{-| Renders a [`collapsible`](#collapsible) open. The browser keeps the state from there.
-}
defaultOpen : Attribute msg
defaultOpen =
    property "open" (Encode.bool True)



-- MODIFIERS


{-| Marks a [`menuButton`](#menuButton), [`menuLink`](#menuLink) or [`menuSubLink`](#menuSubLink) as the current page.
-}
active : Attribute msg
active =
    attribute "data-active" "true"


{-| A [`menuButton`](#menuButton) with a border instead of a background.
-}
outline : Attribute msg
outline =
    attribute "data-variant" "outline"


{-| A shorter [`menuButton`](#menuButton) with smaller text, or a [`menuSubLink`](#menuSubLink) with smaller text.
-}
small : Attribute msg
small =
    attribute "data-size" "sm"


{-| A taller [`menuButton`](#menuButton), for an avatar or a logo with two lines of text beside it.
-}
large : Attribute msg
large =
    attribute "data-size" "lg"


{-| The name a [`menuButton`](#menuButton) shows beside itself on hover once the sidebar has collapsed to icons, in browsers with CSS anchor positioning.
-}
tooltip : String -> Attribute msg
tooltip label =
    attribute "data-tooltip" label


{-| Hides a [`menuAction`](#menuAction) until its item is hovered or focused, or its menu is open, from `md` up.
-}
showOnHover : Attribute msg
showOnHover =
    class "group-focus-within/menu-item:opacity-100 group-hover/menu-item:opacity-100 peer-data-active/menu-button:text-sidebar-accent-foreground [&:has(+:popover-open)]:opacity-100 md:opacity-0"


{-| Shows the square before the bar of a [`menuSkeleton`](#menuSkeleton).
-}
showIcon : Attribute msg
showIcon =
    attribute "data-icon" ""
