module UI.Drawer exposing
    ( Drawer, Ready, NeedsId
    , new
    , id
    , trigger, opens, shows, closes, hides
    , title, description, content, footer
    , down, up, left, right, downOnMobile
    , swipeHandle, nonModal, height, width, onClose
    , State, Msg, init, update, swipeable, snapPoints
    , toHtml
    )

{-| A panel that slides in from an edge of the screen.

A drawer is built with `new`, given an `id` and a `trigger`, filled in with parts, and rendered with `toHtml`:

    Drawer.new
        |> Drawer.id "goal"
        |> Drawer.trigger
            (Button.new
                |> Button.text "Open Drawer"
                |> Button.secondary
            )
        |> Drawer.title [ text "Move Goal" ]
        |> Drawer.description [ text "Set your daily activity goal." ]
        |> Drawer.content [ div [ class "flex-1 p-4" ] [ text "…" ] ]
        |> Drawer.footer []
            [ Button.new
                |> Button.text "Submit"
                |> Button.toHtml [ onClick Submit ]
            , Button.new
                |> Button.text "Cancel"
                |> Button.outline
                |> Button.toHtml (Drawer.closes "goal")
            ]
        |> Drawer.toHtml []

The drawer is a native `<dialog>` opened by its trigger through an invoker command, so it sits in the top layer over a dimmed backdrop, traps focus, makes the rest of the page inert, closes on Escape, a tap on the backdrop or any button with the [`closes`](#closes) attributes, and gives focus back to the trigger, with no JavaScript, ports or component state. It slides in from the bottom unless given a [side](#sides). Drawers nest: a drawer opened from inside another one stacks in front, and the ones behind shrink and peek out from the edge.

The open state lives in the browser. Give the drawer `onClose` to be told when it closes.

The [swipe handle](#swipeHandle) is a visual cue on its own. Made [`swipeable`](#swipeable), it follows the finger, and when let go it springs back, snaps to the nearest of the [`snapPoints`](#snapPoints), or closes the drawer if it was pulled far enough. That needs a `State` in your model and `update` in your update, but no JavaScript.

@docs Drawer, Ready, NeedsId


# Constructor

@docs new


# Required

`toHtml` won't accept a drawer until it has an `id`.

@docs id


# Trigger

@docs trigger, opens, shows, closes, hides


# Parts

Every part is optional. The header appears when the drawer has a `title` or a `description`. The parts stack in a flex column, so give the content `class "flex-1 p-4"` to fill the space between the header and the footer, and `overflow-y-auto` as well to scroll it.

@docs title, description, content, footer


# Sides

The last one wins. A vertical drawer sizes itself to its content, capped at `calc(100dvh - 6rem)`. A side drawer spans three quarters of the viewport, or `24rem` from `sm` up.

@docs down, up, left, right, downOnMobile


# Setters

@docs swipeHandle, nonModal, height, width, onClose


# Swiping

Keep a `State` in your model, route its messages through `update`, and give both to the drawer:

    type alias Model =
        { drawer : Drawer.State }

    type Msg
        = DrawerMsg Drawer.Msg

    update msg model =
        case msg of
            DrawerMsg drawerMsg ->
                { model | drawer = Drawer.update drawerMsg model.drawer }

    view model =
        Drawer.new
            |> Drawer.id "sheet"
            |> Drawer.snapPoints [ 496, 1 ]
            |> Drawer.swipeable model.drawer DrawerMsg
            |> Drawer.toHtml []

One `State` can serve every drawer on the page, since only one is dragged at a time.

@docs State, Msg, init, update, swipeable, snapPoints


# Rendering

@docs toHtml

-}

import Dict exposing (Dict)
import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)
import Html.Events
import Html.Keyed
import Json.Decode as Decode exposing (Decoder)
import UI.Button as Button exposing (Button)


{-| A drawer being built.

`id` is [`Ready`](#Ready) once the drawer has an [`id`](#id).

-}
type Drawer id msg
    = Drawer
        { id : String
        , trigger : Maybe (List (Attribute msg) -> Html msg)
        , title : List (Html msg)
        , description : List (Html msg)
        , content : List (Html msg)
        , footer : Maybe ( List (Attribute msg), List (Html msg) )
        , side : Side
        , downOnMobile : Bool
        , handle : Bool
        , swipe : Maybe ( State, Msg -> msg )
        , snapPoints : List Float
        , modal : Bool
        , height : Maybe String
        , width : Maybe String
        , onClose : Maybe msg
        }


type Side
    = Down
    | Up
    | Left
    | Right


{-| Where a swipe is, if one is in progress, and which snap point the drawer sits at.
-}
type State
    = State
        { drag : Maybe Drag
        , snap : Maybe Int
        , closing : Maybe Closing
        , generations : Dict String Int
        }


type alias Drag =
    { id : String
    , side : Side
    , start : Float
    , current : Float
    , size : Float
    , viewport : Float
    }


{-| A drawer sliding out after a swipe, until its panel's transition ends.
-}
type alias Closing =
    { id : String
    , side : Side
    , size : Float
    }


{-| What the handle and the dialog send while swiping.
-}
type Msg
    = Start Drag
    | Move Float
    | End (List Float)
    | Cancel
    | Closed String


{-| The drawer can be rendered.
-}
type Ready
    = Ready


{-| A drawer that still needs an [`id`](#id) before it can be rendered.
-}
type NeedsId
    = NeedsId



-- CONSTRUCTOR


{-| An empty drawer sliding in from the bottom. Give it an [`id`](#id) to make it renderable.
-}
new : Drawer NeedsId msg
new =
    Drawer
        { id = ""
        , trigger = Nothing
        , title = []
        , description = []
        , content = []
        , footer = Nothing
        , side = Down
        , downOnMobile = False
        , handle = False
        , swipe = Nothing
        , snapPoints = []
        , modal = True
        , height = Nothing
        , width = Nothing
        , onClose = Nothing
        }



-- REQUIRED


{-| The `id` of the `<dialog>`. It must be unique on the page: the trigger and the close buttons point at it, and the title and description are named after it.
-}
id : String -> Drawer NeedsId msg -> Drawer Ready msg
id string (Drawer config) =
    Drawer { config | id = string }



-- TRIGGER


{-| The button that opens the drawer, rendered right before it. It takes a `Button` without its `toHtml`, and renders it with the [`opens`](#opens) attributes for this drawer, or the [`shows`](#shows) ones when the drawer is [`nonModal`](#nonModal):

    Drawer.trigger
        (Button.new
            |> Button.text "Open Drawer"
            |> Button.secondary
        )

For a trigger elsewhere on the page, or one that isn't a `Button`, use `opens` directly instead.

-}
trigger : Button shape Button.Ready msg -> Drawer id msg -> Drawer id msg
trigger button (Drawer config) =
    Drawer { config | trigger = Just (\attrs -> Button.toHtml attrs button) }


{-| The attributes that make a `<button>` open the drawer with the given `id` as a modal, for a trigger that isn't rendered next to the drawer:

    Button.new
        |> Button.text "Open Drawer"
        |> Button.toHtml (Drawer.opens "goal")

-}
opens : String -> List (Attribute msg)
opens drawerId =
    [ attribute "commandfor" drawerId
    , attribute "command" "show-modal"
    ]


{-| The attributes that make a `<button>` open a [`nonModal`](#nonModal) drawer with the given `id`.
-}
shows : String -> List (Attribute msg)
shows drawerId =
    [ attribute "commandfor" drawerId
    , attribute "command" "show-popover"
    ]


{-| The attributes that make a `<button>` close the drawer with the given `id`, for a Cancel or Close button in the footer:

    Button.new
        |> Button.text "Cancel"
        |> Button.outline
        |> Button.toHtml (Drawer.closes "goal")

-}
closes : String -> List (Attribute msg)
closes drawerId =
    [ attribute "commandfor" drawerId
    , attribute "command" "close"
    ]


{-| The attributes that make a `<button>` close a [`nonModal`](#nonModal) drawer with the given `id`. A non-modal drawer is a popover rather than an open dialog, so `closes` does nothing to it.
-}
hides : String -> List (Attribute msg)
hides drawerId =
    [ attribute "commandfor" drawerId
    , attribute "command" "hide-popover"
    ]



-- PARTS


{-| The heading of the drawer, an `<h2>` the drawer is labelled by.
-}
title : List (Html msg) -> Drawer id msg -> Drawer id msg
title children (Drawer config) =
    Drawer { config | title = children }


{-| Supporting text below the title, a `<p>` the drawer is described by.
-}
description : List (Html msg) -> Drawer id msg -> Drawer id msg
description children (Drawer config) =
    Drawer { config | description = children }


{-| The body of the drawer, between the header and the footer. The children go straight into the drawer's flex column without padding, so a single `div [ class "flex-1 p-4" ]` is the usual shape.
-}
content : List (Html msg) -> Drawer id msg -> Drawer id msg
content children (Drawer config) =
    Drawer { config | content = children }


{-| The bottom of the drawer, with its buttons stacked and pushed to the end. The attributes come after the styles so they can override them.
-}
footer : List (Attribute msg) -> List (Html msg) -> Drawer id msg -> Drawer id msg
footer attrs children (Drawer config) =
    Drawer { config | footer = Just ( attrs, children ) }



-- SIDES


{-| Slides up from the bottom. The default.
-}
down : Drawer id msg -> Drawer id msg
down (Drawer config) =
    Drawer { config | side = Down }


{-| Slides down from the top.
-}
up : Drawer id msg -> Drawer id msg
up (Drawer config) =
    Drawer { config | side = Up }


{-| Slides in from the left.
-}
left : Drawer id msg -> Drawer id msg
left (Drawer config) =
    Drawer { config | side = Left }


{-| Slides in from the right.
-}
right : Drawer id msg -> Drawer id msg
right (Drawer config) =
    Drawer { config | side = Right }


{-| Below the `md` breakpoint, slides up from the bottom with a swipe handle instead of using the side it was given. This is how shadcn's demos switch between a side drawer on desktop and a bottom sheet on phones.
-}
downOnMobile : Drawer id msg -> Drawer id msg
downOnMobile (Drawer config) =
    Drawer { config | downOnMobile = True }



-- SETTERS


{-| Shows a swipe handle along the edge the drawer slid in from, a bar that hints the drawer can be dragged. On its own it is purely visual; see [`swipeable`](#swipeable).
-}
swipeHandle : Drawer id msg -> Drawer id msg
swipeHandle (Drawer config) =
    Drawer { config | handle = True }


{-| Opens the drawer without a backdrop, leaving the rest of the page usable and scrollable. The drawer is then a manual popover rather than a modal dialog: it stays open until a button with the [`hides`](#hides) attributes closes it, and a trigger elsewhere on the page needs the [`shows`](#shows) attributes instead of `opens`.
-}
nonModal : Drawer id msg -> Drawer id msg
nonModal (Drawer config) =
    Drawer { config | modal = False }


{-| A CSS height for a vertical drawer, such as `"31rem"` or `"100dvh"`, instead of the height of its content. It lifts the default cap, and changing it animates, so a drawer can snap between heights:

    Drawer.height
        (if expanded then
            "100dvh"

         else
            "31rem"
        )

-}
height : String -> Drawer id msg -> Drawer id msg
height value (Drawer config) =
    Drawer { config | height = Just value }


{-| A CSS width for a side drawer, such as `"30rem"`, instead of the default.
-}
width : String -> Drawer id msg -> Drawer id msg
width value (Drawer config) =
    Drawer { config | width = Just value }


{-| Sent when the drawer closes, however it was closed.
-}
onClose : msg -> Drawer id msg -> Drawer id msg
onClose msg (Drawer config) =
    Drawer { config | onClose = Just msg }



-- SWIPING


{-| No swipe in progress, at the first snap point.
-}
init : State
init =
    State { drag = Nothing, snap = Nothing, closing = Nothing, generations = Dict.empty }


{-| Follows a swipe, and when it ends either closes the drawer or picks the nearest snap point.
-}
update : Msg -> State -> State
update msg (State state) =
    case msg of
        Start drag ->
            State { state | drag = Just drag }

        Move position ->
            State { state | drag = Maybe.map (\drag -> { drag | current = position }) state.drag }

        End points ->
            case state.drag of
                Just drag ->
                    if dismisses points drag then
                        State { state | drag = Nothing, closing = Just { id = drag.id, side = drag.side, size = drag.size } }

                    else if List.isEmpty points then
                        State { state | drag = Nothing }

                    else
                        State { state | drag = Nothing, snap = nearestSnapPoint points drag }

                Nothing ->
                    State state

        Cancel ->
            State { state | drag = Nothing }

        Closed drawerId ->
            -- The slide out is over: the next render replaces the dialog with a fresh,
            -- closed one, which is how the open one leaves the top layer.
            State
                { state
                    | closing =
                        if Maybe.map .id state.closing == Just drawerId then
                            Nothing

                        else
                            state.closing
                    , generations = Dict.update drawerId (Maybe.withDefault 0 >> (+) 1 >> Just) state.generations
                }


{-| A swipe a quarter of the way out closes a drawer. With snap points, it is a swipe past the smallest one by a quarter of its height.
-}
dismisses : List Float -> Drag -> Bool
dismisses points drag =
    let
        delta =
            drag.current - drag.start

        towardEdge =
            case drag.side of
                Down ->
                    delta

                Right ->
                    delta

                Up ->
                    -delta

                Left ->
                    -delta
    in
    case List.minimum (List.map (snapPointPx drag.viewport) points) of
        Nothing ->
            towardEdge > drag.size / 4

        Just smallest ->
            drag.size - towardEdge < smallest * 0.75


{-| Lets the swipe handle drag the drawer. It shows the handle, and needs the `State` from your model and a way to wrap its messages. Let go a quarter of the way out, the drawer closes; let go sooner, it springs back or snaps to the nearest of the [`snapPoints`](#snapPoints).

A drawer closed by a swipe slides out, then its `<dialog>` is replaced by a closed one, since nothing else can close a modal dialog without JavaScript. The `onClose` message is still sent, but focus is not given back to the trigger.

-}
swipeable : State -> (Msg -> msg) -> Drawer id msg -> Drawer id msg
swipeable state toMsg (Drawer config) =
    Drawer { config | handle = True, swipe = Just ( state, toMsg ) }


{-| Heights a vertical drawer snaps to when a swipe ends, instead of sizing itself to its content. A number up to `1` is a fraction of the viewport height, and a bigger one is in pixels. The drawer opens at the first one.

    Drawer.snapPoints [ 496, 1 ]

-}
snapPoints : List Float -> Drawer id msg -> Drawer id msg
snapPoints points (Drawer config) =
    Drawer { config | snapPoints = points }


nearestSnapPoint : List Float -> Drag -> Maybe Int
nearestSnapPoint points drag =
    let
        size =
            case drag.side of
                Down ->
                    drag.size + drag.start - drag.current

                Up ->
                    drag.size + drag.current - drag.start

                _ ->
                    drag.size
    in
    points
        |> List.indexedMap (\index point -> ( index, abs (snapPointPx drag.viewport point - size) ))
        |> List.sortBy Tuple.second
        |> List.head
        |> Maybe.map Tuple.first


snapPointPx : Float -> Float -> Float
snapPointPx viewport point =
    if point <= 1 then
        point * viewport

    else
        point


snapPointCss : Float -> String
snapPointCss point =
    if point <= 1 then
        String.fromFloat (point * 100) ++ "dvh"

    else
        String.fromFloat point ++ "px"


{-| How far the panel follows the pointer. Without snap points, pulling the drawer
further open is damped, since there is nowhere to go. With them, it stops at the
top of the viewport.
-}
swipeOffset : List Float -> Drag -> Float
swipeOffset points drag =
    let
        delta =
            drag.current - drag.start
    in
    if List.isEmpty points then
        let
            opening =
                case drag.side of
                    Down ->
                        delta < 0

                    Up ->
                        delta > 0

                    Left ->
                        delta > 0

                    Right ->
                        delta < 0
        in
        if opening then
            delta * 0.2

        else
            delta

    else
        case drag.side of
            Down ->
                max delta (drag.size - drag.viewport)

            Up ->
                min delta (drag.viewport - drag.size)

            _ ->
                delta


{-| Just past the edge, like the closed transform of the slide in.
-}
closedOffset : Closing -> Float
closedOffset out =
    case out.side of
        Down ->
            out.size + 2

        Right ->
            out.size + 2

        Up ->
            -(out.size + 2)

        Left ->
            -(out.size + 2)


isVertical : Side -> Bool
isVertical side =
    side == Down || side == Up


{-| Reads the pointer, the panel the handle sits in and the viewport off the event, and
settles the side a `downOnMobile` drawer is on from the viewport width.
-}
startDecoder : String -> Layout -> Decoder Drag
startDecoder drawerId layout =
    Decode.map6
        (\clientX clientY panelWidth panelHeight innerWidth innerHeight ->
            let
                side =
                    case layout of
                        FixedSide fixed ->
                            fixed

                        DownBelowMd fixed ->
                            if innerWidth < 768 then
                                Down

                            else
                                fixed
            in
            if isVertical side then
                { id = drawerId, side = side, start = clientY, current = clientY, size = panelHeight, viewport = innerHeight }

            else
                { id = drawerId, side = side, start = clientX, current = clientX, size = panelWidth, viewport = innerWidth }
        )
        (Decode.field "clientX" Decode.float)
        (Decode.field "clientY" Decode.float)
        (Decode.at [ "currentTarget", "parentElement", "clientWidth" ] Decode.float)
        (Decode.at [ "currentTarget", "parentElement", "clientHeight" ] Decode.float)
        (Decode.at [ "view", "innerWidth" ] Decode.float)
        (Decode.at [ "view", "innerHeight" ] Decode.float)


{-| Only the panel's slide counts, not the backdrop's fade or a nested drawer's.
-}
slideEndDecoder : msg -> Decoder msg
slideEndDecoder msg =
    Decode.field "propertyName" Decode.string
        |> Decode.andThen
            (\property ->
                if property == "translate" then
                    Decode.succeed msg

                else
                    Decode.fail "not the slide"
            )


moveDecoder : Side -> Decoder Float
moveDecoder side =
    Decode.field
        (if isVertical side then
            "clientY"

         else
            "clientX"
        )
        Decode.float



-- RENDERING


{-| Renders the trigger, if any, followed by the `<dialog>`. The attributes go on the panel inside it, after the styles, so they can override them.
-}
toHtml : List (Attribute msg) -> Drawer Ready msg -> Html msg
toHtml attrs (Drawer config) =
    let
        titleId =
            config.id ++ "-title"

        descriptionId =
            config.id ++ "-description"

        hasHeader =
            not (List.isEmpty config.title && List.isEmpty config.description)

        layout =
            if config.downOnMobile then
                case config.side of
                    Down ->
                        FixedSide Down

                    side ->
                        DownBelowMd side

            else
                FixedSide config.side

        drag =
            config.swipe
                |> Maybe.andThen (\( State state, _ ) -> state.drag)
                |> Maybe.andThen (\swipe -> ifThis swipe.id swipe)

        closing =
            config.swipe
                |> Maybe.andThen (\( State state, _ ) -> state.closing)
                |> Maybe.andThen (\swipe -> ifThis swipe.id swipe)

        ifThis drawerId value =
            if drawerId == config.id then
                Just value

            else
                Nothing

        generation =
            config.swipe
                |> Maybe.andThen (\( State state, _ ) -> Dict.get config.id state.generations)
                |> Maybe.withDefault 0

        -- Where the panel sits along its axis: under the pointer during a swipe, and
        -- just past its edge while sliding out.
        swipeVar side offset =
            (if isVertical side then
                "--drawer-swipe-y: "

             else
                "--drawer-swipe-x: "
            )
                ++ String.fromFloat offset
                ++ "px"

        snapHeight =
            case config.snapPoints of
                [] ->
                    config.height

                first :: _ ->
                    config.swipe
                        |> Maybe.andThen (\( State state, _ ) -> state.snap)
                        |> Maybe.andThen (\index -> List.drop index config.snapPoints |> List.head)
                        |> Maybe.withDefault first
                        |> snapPointCss
                        |> Just

        sizes =
            List.filterMap identity
                [ Maybe.map (\value -> "--drawer-height: " ++ value ++ "; --drawer-max-height: none") snapHeight
                , Maybe.map (\value -> "--drawer-width: " ++ value) config.width
                , case ( drag, closing ) of
                    ( Just swipe, _ ) ->
                        Just (swipeVar swipe.side (swipeOffset config.snapPoints swipe))

                    ( Nothing, Just out ) ->
                        Just (swipeVar out.side (closedOffset out))

                    ( Nothing, Nothing ) ->
                        Nothing
                ]

        -- While a swipe is on, the dialog follows the pointer wherever it goes, since
        -- the handle is too small to keep it, and the panel stops easing.
        swiping =
            case ( drag, config.swipe ) of
                ( Just swipe, Just ( _, toMsg ) ) ->
                    [ Html.Events.on "pointermove" (Decode.map (toMsg << Move) (moveDecoder swipe.side))
                    , Html.Events.on "pointerup" (Decode.succeed (toMsg (End config.snapPoints)))
                    , Html.Events.on "pointercancel" (Decode.succeed (toMsg Cancel))
                    , class "pointer-events-auto"
                    ]

                _ ->
                    case ( closing, config.onClose ) of
                        ( Just _, Just msg ) ->
                            [ Html.Events.on "transitionend" (slideEndDecoder msg) ]

                        _ ->
                            []

        -- Fades the backdrop out with the slide, and reports the end of the slide.
        slidingOut =
            case ( closing, config.swipe ) of
                ( Just _, Just ( _, toMsg ) ) ->
                    [ attribute "data-closing" ""
                    , Html.Events.on "transitionend" (slideEndDecoder (toMsg (Closed config.id)))
                    ]

                _ ->
                    []

        handle =
            if config.handle then
                Just (viewHandle config.id layout [] config.swipe)

            else if config.downOnMobile then
                Just (viewHandle config.id layout [ class "md:hidden" ] config.swipe)

            else
                Nothing
    in
    Html.Keyed.node "span"
        [ attribute "data-slot" "drawer", class "contents" ]
        (List.filterMap identity
            [ Maybe.map
                (\toButton ->
                    ( "trigger"
                    , toButton
                        (attribute "data-slot" "drawer-trigger"
                            :: (if config.modal then
                                    opens config.id

                                else
                                    shows config.id
                               )
                        )
                    )
                )
                config.trigger
            , Just
                ( "dialog-" ++ String.fromInt generation
                , Html.node "dialog"
                    ([ Html.Attributes.id config.id

                     -- `overflow-clip`, not `overflow-hidden`: opening focuses the first
                     -- button in the panel while the panel still sits past the edge, and
                     -- a hidden overflow would scroll it into view, pinning the panel in
                     -- place for the whole slide. A clipped overflow can't scroll.
                     , class "fixed inset-0 z-50 m-0 hidden h-full max-h-none w-full max-w-none overflow-clip bg-transparent p-0 text-inherit outline-none open:block"
                     ]
                        ++ (if config.modal then
                                -- The dialog fills the viewport so that the whole dimmed
                                -- area is a button closing it: Safari has no `closedby`
                                -- and phones have no Escape key. `closedby` still lets
                                -- browsers that have it close on Escape and a click
                                -- outside natively. The page behind stops scrolling while
                                -- the drawer is modal, keeping its scrollbar gutter so
                                -- that nothing shifts.
                                [ attribute "closedby" "any"
                                , class "[html:has(&:modal)]:overflow-hidden [html:has(&:modal)]:[scrollbar-gutter:stable] backdrop:bg-black/10 backdrop:opacity-0 backdrop:backdrop-blur-xs backdrop:transition-opacity backdrop:duration-450 backdrop:ease-[cubic-bezier(0.32,0.72,0,1)] open:backdrop:opacity-100 starting:open:backdrop:opacity-0 data-closing:open:backdrop:opacity-0"
                                ]

                            else
                                -- Invoker commands can't open a dialog non-modally, so a
                                -- non-modal drawer is a manual popover instead: in the top
                                -- layer, but with the page behind it still usable. The
                                -- dialog lets clicks through to the page.
                                [ attribute "popover" "manual"
                                , class "pointer-events-none"
                                ]
                           )
                        ++ [ -- The `display` and `overlay` changes wait for the panel to slide out.
                             class "transition-[display,overlay] duration-450 transition-discrete"
                           ]
                        ++ swiping
                        ++ slidingOut
                        ++ (if List.isEmpty config.title then
                                []

                            else
                                [ attribute "aria-labelledby" titleId ]
                           )
                        ++ (if List.isEmpty config.description then
                                []

                            else
                                [ attribute "aria-describedby" descriptionId ]
                           )
                        ++ (case config.onClose of
                                Just msg ->
                                    [ Html.Events.on "close" (Decode.succeed msg) ]

                                Nothing ->
                                    []
                           )
                    )
                    (Html.div
                        ([ attribute "data-slot" "drawer-popup"
                         , class "group/drawer-popup pointer-events-auto absolute z-50 flex min-h-0 bg-popover text-sm text-popover-foreground outline-none select-none will-change-transform [interpolate-size:allow-keywords]"

                         -- Slides from its edge on open and back on close, and shrinks and
                         -- peeks out behind the drawers nested in it, one step per level.
                         , class "transition-[translate,scale,filter,height] duration-450 ease-[cubic-bezier(0.22,1,0.36,1)] data-swiping:duration-0 [&:has(dialog[open])]:overflow-hidden [&:has(dialog[open])]:brightness-95 [&:has(dialog[open])]:scale-95 [&:has(dialog[open]_dialog[open])]:scale-90 [&:has(dialog[open]_dialog[open]_dialog[open])]:scale-[0.85]"
                         , class (layoutClass layout)
                         ]
                            ++ (if List.isEmpty sizes then
                                    []

                                else
                                    [ attribute "style" (String.join "; " sizes) ]
                               )
                            ++ (case drag of
                                    Just _ ->
                                        [ attribute "data-swiping" "" ]

                                    Nothing ->
                                        []
                               )
                            ++ attrs
                        )
                        (List.filterMap identity
                            [ handle
                            , Just
                                (Html.div
                                    [ attribute "data-slot" "drawer-content"
                                    , class "flex min-h-0 flex-1 flex-col overflow-hidden overscroll-contain rounded-[inherit] transition-opacity duration-300 ease-[cubic-bezier(0.45,1.005,0,1.005)] select-text [&:has(dialog[open])]:opacity-0"
                                    ]
                                    (List.filterMap identity
                                        [ if hasHeader then
                                            Just
                                                (Html.div
                                                    [ attribute "data-slot" "drawer-header"
                                                    , class "flex shrink-0 flex-col gap-0.5 p-4 pb-0 md:gap-0.5 md:text-left"
                                                    , class (headerClass layout)
                                                    ]
                                                    (List.filterMap identity
                                                        [ if List.isEmpty config.title then
                                                            Nothing

                                                          else
                                                            Just
                                                                (Html.h2
                                                                    [ Html.Attributes.id titleId
                                                                    , attribute "data-slot" "drawer-title"
                                                                    , class "text-base font-medium text-foreground"
                                                                    ]
                                                                    config.title
                                                                )
                                                        , if List.isEmpty config.description then
                                                            Nothing

                                                          else
                                                            Just
                                                                (Html.p
                                                                    [ Html.Attributes.id descriptionId
                                                                    , attribute "data-slot" "drawer-description"
                                                                    , class "text-sm text-balance text-muted-foreground"
                                                                    ]
                                                                    config.description
                                                                )
                                                        ]
                                                    )
                                                )

                                          else
                                            Nothing
                                        ]
                                        ++ config.content
                                        ++ List.filterMap identity
                                            [ Maybe.map viewFooter config.footer ]
                                    )
                                )
                            ]
                        )
                        :: (if config.modal then
                                -- Behind the panel and after it in the tree, so that the
                                -- dialog focuses the panel's first control on opening, not
                                -- the backdrop.
                                [ Html.button
                                    ([ Html.Attributes.type_ "button"
                                     , attribute "data-slot" "drawer-backdrop"
                                     , attribute "aria-hidden" "true"
                                     , Html.Attributes.tabindex -1
                                     , class "absolute inset-0 -z-10 cursor-default"
                                     ]
                                        ++ closes config.id
                                    )
                                    []
                                ]

                            else
                                []
                           )
                    )
                )
            ]
        )


viewFooter : ( List (Attribute msg), List (Html msg) ) -> Html msg
viewFooter ( attrs, children ) =
    Html.div
        ([ attribute "data-slot" "drawer-footer"
         , class "mt-auto flex shrink-0 flex-col gap-2 p-4 pt-0"
         ]
            ++ attrs
        )
        children


viewHandle : String -> Layout -> List (Attribute msg) -> Maybe ( State, Msg -> msg ) -> Html msg
viewHandle drawerId layout attrs swipe =
    Html.div
        ([ attribute "data-slot" "drawer-swipe-handle"
         , attribute "aria-hidden" "true"
         , class "relative z-10 flex shrink-0 cursor-grab touch-none transition-opacity duration-200 active:cursor-grabbing after:block after:shrink-0 after:rounded-full after:bg-muted [:has(dialog[open])>&]:opacity-0"
         , class (handleClass layout)
         ]
            ++ (case swipe of
                    Just ( _, toMsg ) ->
                        -- Prevented so that a mouse drag selects no text.
                        [ Html.Events.preventDefaultOn "pointerdown"
                            (Decode.map (\drag -> ( toMsg (Start drag), True )) (startDecoder drawerId layout))
                        ]

                    Nothing ->
                        []
               )
            ++ attrs
        )
        []



-- LAYOUT


{-| A fixed side, or a side from `md` up with the bottom below it. Tailwind only finds
classes written out in full, so every combination is spelled out below.
-}
type Layout
    = FixedSide Side
    | DownBelowMd Side


layoutClass : Layout -> String
layoutClass layout =
    case layout of
        FixedSide Down ->
            "after:pointer-events-none after:absolute after:inset-x-0 after:top-full after:h-[100dvh] after:bg-popover inset-x-0 bottom-0 flex-col rounded-t-xl border-t origin-bottom h-(--drawer-height) max-h-(--drawer-max-height) [--drawer-height:auto] [--drawer-max-height:calc(100dvh-6rem)] translate-y-[calc(100%+2px)] [:is([open],:popover-open)>&]:translate-y-(--drawer-swipe-y,0px) starting:[:is([open],:popover-open)>&]:translate-y-[calc(100%+2px)] [&:has(dialog[open])]:-translate-y-[calc(1rem+5%)] [&:has(dialog[open]_dialog[open])]:-translate-y-[calc(2rem+10%)] [&:has(dialog[open]_dialog[open]_dialog[open])]:-translate-y-[calc(3rem+15%)]"

        FixedSide Up ->
            "after:pointer-events-none after:absolute after:inset-x-0 after:bottom-full after:h-[100dvh] after:bg-popover inset-x-0 top-0 flex-col rounded-b-xl border-b origin-top h-(--drawer-height) max-h-(--drawer-max-height) [--drawer-height:auto] [--drawer-max-height:calc(100dvh-6rem)] -translate-y-[calc(100%+2px)] [:is([open],:popover-open)>&]:translate-y-(--drawer-swipe-y,0px) starting:[:is([open],:popover-open)>&]:-translate-y-[calc(100%+2px)] [&:has(dialog[open])]:translate-y-[calc(1rem+5%)] [&:has(dialog[open]_dialog[open])]:translate-y-[calc(2rem+10%)] [&:has(dialog[open]_dialog[open]_dialog[open])]:translate-y-[calc(3rem+15%)]"

        FixedSide Left ->
            "after:pointer-events-none after:absolute after:inset-y-0 after:right-full after:w-[100dvw] after:bg-popover inset-y-0 left-0 flex-row rounded-r-xl border-r origin-left w-(--drawer-width) [--drawer-width:75%] sm:[--drawer-width:24rem] -translate-x-[calc(100%+2px)] [:is([open],:popover-open)>&]:translate-x-(--drawer-swipe-x,0px) starting:[:is([open],:popover-open)>&]:-translate-x-[calc(100%+2px)] [&:has(dialog[open])]:translate-x-[calc(1rem+5%)] [&:has(dialog[open]_dialog[open])]:translate-x-[calc(2rem+10%)] [&:has(dialog[open]_dialog[open]_dialog[open])]:translate-x-[calc(3rem+15%)]"

        FixedSide Right ->
            "after:pointer-events-none after:absolute after:inset-y-0 after:left-full after:w-[100dvw] after:bg-popover inset-y-0 right-0 flex-row rounded-l-xl border-l origin-right w-(--drawer-width) [--drawer-width:75%] sm:[--drawer-width:24rem] translate-x-[calc(100%+2px)] [:is([open],:popover-open)>&]:translate-x-(--drawer-swipe-x,0px) starting:[:is([open],:popover-open)>&]:translate-x-[calc(100%+2px)] [&:has(dialog[open])]:-translate-x-[calc(1rem+5%)] [&:has(dialog[open]_dialog[open])]:-translate-x-[calc(2rem+10%)] [&:has(dialog[open]_dialog[open]_dialog[open])]:-translate-x-[calc(3rem+15%)]"

        DownBelowMd side ->
            "max-md:after:pointer-events-none max-md:after:absolute max-md:after:inset-x-0 max-md:after:top-full max-md:after:h-[100dvh] max-md:after:bg-popover max-md:inset-x-0 max-md:bottom-0 max-md:flex-col max-md:rounded-t-xl max-md:border-t max-md:origin-bottom max-md:h-(--drawer-height) max-md:max-h-(--drawer-max-height) max-md:[--drawer-height:auto] max-md:[--drawer-max-height:calc(100dvh-6rem)] max-md:translate-y-[calc(100%+2px)] max-md:[:is([open],:popover-open)>&]:translate-y-(--drawer-swipe-y,0px) max-md:starting:[:is([open],:popover-open)>&]:translate-y-[calc(100%+2px)] max-md:[&:has(dialog[open])]:-translate-y-[calc(1rem+5%)] max-md:[&:has(dialog[open]_dialog[open])]:-translate-y-[calc(2rem+10%)] max-md:[&:has(dialog[open]_dialog[open]_dialog[open])]:-translate-y-[calc(3rem+15%)] "
                ++ (case side of
                        Up ->
                            "md:after:pointer-events-none md:after:absolute md:after:inset-x-0 md:after:bottom-full md:after:h-[100dvh] md:after:bg-popover md:inset-x-0 md:top-0 md:flex-col md:rounded-b-xl md:border-b md:origin-top md:h-(--drawer-height) md:max-h-(--drawer-max-height) md:[--drawer-height:auto] md:[--drawer-max-height:calc(100dvh-6rem)] md:-translate-y-[calc(100%+2px)] md:[:is([open],:popover-open)>&]:translate-y-(--drawer-swipe-y,0px) md:starting:[:is([open],:popover-open)>&]:-translate-y-[calc(100%+2px)] md:[&:has(dialog[open])]:translate-y-[calc(1rem+5%)] md:[&:has(dialog[open]_dialog[open])]:translate-y-[calc(2rem+10%)] md:[&:has(dialog[open]_dialog[open]_dialog[open])]:translate-y-[calc(3rem+15%)]"

                        Left ->
                            "md:after:pointer-events-none md:after:absolute md:after:inset-y-0 md:after:right-full md:after:w-[100dvw] md:after:bg-popover md:inset-y-0 md:left-0 md:flex-row md:rounded-r-xl md:border-r md:origin-left md:w-(--drawer-width) md:[--drawer-width:24rem] md:-translate-x-[calc(100%+2px)] md:[:is([open],:popover-open)>&]:translate-x-(--drawer-swipe-x,0px) md:starting:[:is([open],:popover-open)>&]:-translate-x-[calc(100%+2px)] md:[&:has(dialog[open])]:translate-x-[calc(1rem+5%)] md:[&:has(dialog[open]_dialog[open])]:translate-x-[calc(2rem+10%)] md:[&:has(dialog[open]_dialog[open]_dialog[open])]:translate-x-[calc(3rem+15%)]"

                        _ ->
                            "md:after:pointer-events-none md:after:absolute md:after:inset-y-0 md:after:left-full md:after:w-[100dvw] md:after:bg-popover md:inset-y-0 md:right-0 md:flex-row md:rounded-l-xl md:border-l md:origin-right md:w-(--drawer-width) md:[--drawer-width:24rem] md:translate-x-[calc(100%+2px)] md:[:is([open],:popover-open)>&]:translate-x-(--drawer-swipe-x,0px) md:starting:[:is([open],:popover-open)>&]:translate-x-[calc(100%+2px)] md:[&:has(dialog[open])]:-translate-x-[calc(1rem+5%)] md:[&:has(dialog[open]_dialog[open])]:-translate-x-[calc(2rem+10%)] md:[&:has(dialog[open]_dialog[open]_dialog[open])]:-translate-x-[calc(3rem+15%)]"
                   )


handleClass : Layout -> String
handleClass layout =
    case layout of
        FixedSide Down ->
            "h-3 w-full items-end justify-center after:h-1 after:w-24"

        FixedSide Up ->
            "order-last h-3 w-full items-start justify-center after:h-1 after:w-24"

        FixedSide Left ->
            "order-last h-full w-3 items-center justify-start after:h-24 after:w-1"

        FixedSide Right ->
            "h-full w-3 items-center justify-end after:h-24 after:w-1"

        DownBelowMd side ->
            "max-md:h-3 max-md:w-full max-md:items-end max-md:justify-center max-md:after:h-1 max-md:after:w-24 "
                ++ (case side of
                        Up ->
                            "md:order-last md:h-3 md:w-full md:items-start md:justify-center md:after:h-1 md:after:w-24"

                        Left ->
                            "md:order-last md:h-full md:w-3 md:items-center md:justify-start md:after:h-24 md:after:w-1"

                        _ ->
                            "md:h-full md:w-3 md:items-center md:justify-end md:after:h-24 md:after:w-1"
                   )


{-| A vertical drawer centres its header on small screens.
-}
headerClass : Layout -> String
headerClass layout =
    case layout of
        FixedSide Down ->
            "text-center"

        FixedSide Up ->
            "text-center"

        FixedSide _ ->
            ""

        DownBelowMd _ ->
            "max-md:text-center"
