module Examples.Sidebar.Block12 exposing (view)

{-| A sidebar with a calendar.

A port of shadcn's `sidebar-12` block. The date picker is a static month grid, since there is no
Calendar component, and the calendars are collapsible groups whose checked items live in the state.

-}

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (alt, attribute, class, src, type_)
import Html.Events exposing (onClick)
import Phosphor exposing (IconVariant, IconWeight(..))
import State exposing (State)
import UI.Avatar as Avatar
import UI.Breadcrumb as Breadcrumb
import UI.DropdownMenu as DropdownMenu
import UI.Separator as Separator
import UI.Sidebar as Sidebar


key : String
key =
    "block12"


view : State -> Html State.Msg
view state =
    Sidebar.new
        |> Sidebar.state (sidebarState key state) (setSidebarState key)
        |> Sidebar.header [ navUser ]
        |> Sidebar.content
            (datePicker state
                :: Sidebar.separator [ class "mx-0" ]
                :: List.concat (List.indexedMap (calendarGroup state) calendars)
            )
        |> Sidebar.footer
            [ Sidebar.menu []
                [ Sidebar.menuItem []
                    [ Sidebar.menuButton []
                        [ icon Phosphor.plus
                        , span [] [ text "New Calendar" ]
                        ]
                    ]
                ]
            ]
        |> Sidebar.rail
        |> Sidebar.page []
            [ Html.header [ class "sticky top-0 flex h-16 shrink-0 items-center gap-2 border-b bg-background px-4" ]
                [ Sidebar.trigger [ class "-ml-1" ] (sidebarState key state) (setSidebarState key)
                , Separator.new
                    |> Separator.vertical
                    |> Separator.toHtml [ class "mr-2 my-auto data-[orientation=vertical]:h-4" ]
                , Breadcrumb.new
                    |> Breadcrumb.page [ text "October 2024" ]
                    |> Breadcrumb.separator
                        (Phosphor.caretRight Regular
                            |> Phosphor.toHtml []
                        )
                    |> Breadcrumb.toHtml []
                ]
            , div [ class "flex flex-1 flex-col gap-4 p-4" ]
                [ div [ class "grid auto-rows-min gap-4 md:grid-cols-5" ]
                    (List.repeat 20 (div [ class "aspect-square rounded-xl bg-muted/50" ] []))
                ]
            ]
        |> Sidebar.toHtml []



-- DATA


type alias User =
    { name : String
    , email : String
    , avatar : String
    }


user : User
user =
    { name = "shadcn"
    , email = "m@example.com"
    , avatar = "https://github.com/shadcn.png"
    }


type alias Calendar =
    { name : String
    , items : List String
    }


calendars : List Calendar
calendars =
    [ { name = "My Calendars", items = [ "Personal", "Work", "Family" ] }
    , { name = "Favorites", items = [ "Holidays", "Birthdays" ] }
    , { name = "Other", items = [ "Travel", "Reminders", "Deadlines" ] }
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
                |> DropdownMenu.id (key ++ "-nav-user")
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
                        [ DropdownMenu.item [] [ icon Phosphor.checkCircle, text "Account" ]
                        , DropdownMenu.item [] [ icon Phosphor.creditCard, text "Billing" ]
                        , DropdownMenu.item [] [ icon Phosphor.bell, text "Notifications" ]
                        ]
                    , DropdownMenu.separator
                    , DropdownMenu.item [] [ icon Phosphor.signOut, text "Log out" ]
                    ]
                |> DropdownMenu.right
                |> DropdownMenu.toHtml [ class "min-w-56 rounded-lg" ]
            ]
        ]



-- DATE PICKER


{-| The month shown by the date picker: October 2026, which starts on a Thursday and fills five weeks.
-}
month : { name : String, year : String, days : Int, leading : Int, previousMonthDays : Int, today : Int }
month =
    { name = "October"
    , year = "2026"
    , days = 31
    , leading = 4
    , previousMonthDays = 30
    , today = 21
    }


dateKey : String
dateKey =
    key ++ "-date"


selectedDay : State -> Int
selectedDay state =
    State.get dateKey state
        |> Maybe.andThen String.toInt
        |> Maybe.withDefault 12


datePicker : State -> Html State.Msg
datePicker state =
    Sidebar.group [ class "px-0" ]
        [ Sidebar.groupContent []
            [ div
                [ attribute "data-slot" "calendar"
                , class "group/calendar bg-transparent p-3 [--cell-size:2.1rem]"
                ]
                [ div [ class "relative flex flex-col gap-4 md:flex-row" ]
                    [ div [ class "absolute inset-x-0 top-0 flex w-full items-center justify-between gap-1" ]
                        [ navButton "Go to the Previous Month" Phosphor.caretLeft
                        , navButton "Go to the Next Month" Phosphor.caretRight
                        ]
                    , div [ class "flex w-full flex-col gap-4" ]
                        [ div [ class "flex h-(--cell-size) w-full items-center justify-center px-(--cell-size)" ]
                            [ div [ class "flex h-(--cell-size) w-full items-center justify-center gap-1.5 text-sm font-medium" ]
                                [ dropdown month.name
                                , dropdown month.year
                                ]
                            ]
                        , div [ class "w-full border-collapse" ]
                            [ div [ class "grid grid-cols-7" ]
                                (List.map weekday [ "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" ])
                            , div [ class "mt-2 grid grid-cols-7 gap-y-2" ]
                                (List.map (day state) (List.range 1 (month.leading + month.days)))
                            ]
                        ]
                    ]
                ]
            ]
        ]


navButton : String -> (IconWeight -> IconVariant) -> Html msg
navButton label i =
    Html.button
        [ type_ "button"
        , attribute "aria-label" label
        , class "inline-flex size-(--cell-size) items-center justify-center rounded-md p-0 text-sm select-none hover:bg-accent hover:text-accent-foreground aria-disabled:opacity-50 [&_svg]:size-4 [&_svg]:shrink-0"
        ]
        [ icon i ]


dropdown : String -> Html msg
dropdown label =
    span [ class "relative rounded-md border border-input shadow-xs has-focus:border-ring has-focus:ring-[3px] has-focus:ring-ring/50" ]
        [ span [ class "flex h-8 items-center gap-1 rounded-md pr-1 pl-2 text-sm font-medium [&>svg]:size-3.5 [&>svg]:text-muted-foreground" ]
            [ text label
            , icon Phosphor.caretDown
            ]
        ]


weekday : String -> Html msg
weekday name =
    div [ class "rounded-md text-center text-[0.8rem] font-normal text-muted-foreground select-none" ] [ text name ]


{-| One cell of the grid, counted from the first cell. Cells before the first of the month show the end of the previous month.
-}
day : State -> Int -> Html State.Msg
day state cell =
    let
        outside =
            cell <= month.leading

        number =
            if outside then
                month.previousMonthDays - month.leading + cell

            else
                cell - month.leading

        selected =
            not outside && number == selectedDay state

        today =
            not outside && number == month.today
    in
    div
        [ attribute "data-selected" (bool selected)
        , attribute "data-today" (bool today)
        , class "group/day relative aspect-square w-full p-0 text-center select-none data-[today=true]:rounded-md data-[today=true]:bg-accent data-[today=true]:text-accent-foreground"
        ]
        [ Html.button
            ([ type_ "button"
             , attribute "data-selected" (bool selected)
             , attribute "data-outside" (bool outside)
             , class "flex aspect-square size-auto w-full min-w-(--cell-size) flex-col items-center justify-center gap-1 rounded-md text-sm leading-none font-normal hover:bg-accent hover:text-accent-foreground data-[outside=true]:text-muted-foreground data-[selected=true]:bg-primary data-[selected=true]:text-primary-foreground data-[selected=true]:hover:bg-primary data-[selected=true]:hover:text-primary-foreground"
             ]
                ++ (if outside then
                        []

                    else
                        [ onClick (State.set dateKey (String.fromInt number)) ]
                   )
            )
            [ text (String.fromInt number) ]
        ]



-- CALENDARS


calendarGroup : State -> Int -> Calendar -> List (Html State.Msg)
calendarGroup state index calendar =
    [ Sidebar.group []
        [ Sidebar.collapsible
            (if index == 0 then
                [ Sidebar.defaultOpen ]

             else
                []
            )
            (Sidebar.groupTrigger [ class "group/label w-full text-sm text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground" ]
                [ text calendar.name
                , Phosphor.caretRight Regular
                    |> Phosphor.withClass "ml-auto transition-transform group-open/collapsible:rotate-90"
                    |> Phosphor.toHtml []
                ]
            )
            [ Sidebar.groupContent []
                [ Sidebar.menu []
                    (List.indexedMap (calendarItem state calendar.name) calendar.items)
                ]
            ]
        ]
    , Sidebar.separator [ class "mx-0" ]
    ]


calendarItem : State -> String -> Int -> String -> Html State.Msg
calendarItem state calendarName index item =
    let
        itemKey =
            key ++ "-" ++ slug calendarName ++ "-" ++ slug item

        active =
            case State.get itemKey state of
                Just value ->
                    value == "true"

                Nothing ->
                    index < 2
    in
    Sidebar.menuItem []
        [ Sidebar.menuButton [ onClick (State.set itemKey (bool (not active))) ]
            [ div
                [ attribute "data-active" (bool active)
                , class "group/calendar-item flex aspect-square size-4 shrink-0 items-center justify-center rounded-sm border border-sidebar-border text-sidebar-primary-foreground data-[active=true]:border-sidebar-primary data-[active=true]:bg-sidebar-primary"
                ]
                [ Phosphor.check Regular
                    |> Phosphor.withClass "hidden size-3 group-data-[active=true]/calendar-item:block"
                    |> Phosphor.toHtml []
                ]
            , text item
            ]
        ]


slug : String -> String
slug =
    String.toLower >> String.replace " " "-"



-- HELPERS


icon : (IconWeight -> IconVariant) -> Html msg
icon i =
    i Regular
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
