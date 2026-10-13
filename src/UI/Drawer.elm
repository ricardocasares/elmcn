module UI.Drawer exposing
    ( Drawer, Ready, NeedsId
    , new
    , id
    , trigger, opens, shows, closes, hides
    , title, description, content, footer
    , down, up, left, right, downOnMobile
    , swipeHandle, nonModal, height, width, onClose
    , State, Msg, init, update, dismissed, swipeable, snapPoints
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

The [swipe handle](#swipeHandle) is a visual cue on its own. Made [`swipeable`](#swipeable), the drawer follows a swipe like a scrolling page does, then settles at the nearest of its [`snapPoints`](#snapPoints) or closes. That needs a `State` in your model and `update` in your update, but no JavaScript.

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

A swipe is a scroll gesture, handled by the browser rather than by Elm. The drawer sits in a scroller that is hidden but snaps to two places, closed and open, so a finger or a trackpad drags it with momentum and rubber band, off the main thread, and the backdrop fades in step with it through a CSS view timeline. A swipe that ends closed removes the open drawer, and the only thing Elm sees of it is one message.

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

One `State` can serve every drawer on the page. Without `swipeable` the drawer slides in the same way, but the scroller can't be dragged.

A mouse can't drag the drawer, since a mouse doesn't scroll by dragging: the wheel and a trackpad work, and touch is the primary input. Browsers that don't support `scrollend` or view timelines keep a drawer that opens and closes, without the swipe dismissal or the synced backdrop.

@docs State, Msg, init, update, dismissed, swipeable, snapPoints


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


{-| How many times each drawer has been swiped away.

A swiped drawer is still an open `<dialog>`, and nothing but JavaScript can close that, so it is replaced by a fresh closed one: the number is part of its key.

-}
type State
    = State (Dict String Int)


{-| What a swipeable drawer sends when a swipe closes it.
-}
type Msg
    = Dismissed String


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

A scrollable child (`overflow-y-auto`) chains to the drawer once it is scrolled to its start, so pulling it down further swipes the drawer away, like on a phone.

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


{-| Sent when the drawer closes, however it was closed except by a swipe: see [`dismissed`](#dismissed).
-}
onClose : msg -> Drawer id msg -> Drawer id msg
onClose msg (Drawer config) =
    Drawer { config | onClose = Just msg }



-- SWIPING


{-| No drawer has been swiped away yet.
-}
init : State
init =
    State Dict.empty


{-| Replaces a drawer that was swiped away with a closed one, ready to open again.
-}
update : Msg -> State -> State
update (Dismissed drawerId) (State generations) =
    State (Dict.update drawerId (Maybe.withDefault 0 >> (+) 1 >> Just) generations)


{-| The `id` of the drawer a message is about. A swiped drawer is replaced rather than closed, so its `close` event never fires and `onClose` is not sent. Do here whatever `onClose` would have done:

    DrawerMsg drawerMsg ->
        ( { model | drawer = Drawer.update drawerMsg model.drawer }
        , if Drawer.dismissed drawerMsg == "goal" then
            saveGoal model

          else
            Cmd.none
        )

-}
dismissed : Msg -> String
dismissed (Dismissed drawerId) =
    drawerId


{-| Lets a swipe drag the drawer, and shows the swipe handle. It needs the `State` from your model and a way to wrap its messages. Let go a little over halfway out, or flick it toward its edge, and the drawer closes; let go sooner and it settles back, or at the nearest of the [`snapPoints`](#snapPoints).

A drawer closed by a swipe is already off screen, so its `<dialog>` is replaced by a closed one, since nothing else can close a modal dialog without JavaScript. Focus is not given back to the trigger, and `onClose` is not sent; see [`dismissed`](#dismissed).

-}
swipeable : State -> (Msg -> msg) -> Drawer id msg -> Drawer id msg
swipeable state toMsg (Drawer config) =
    Drawer { config | handle = True, swipe = Just ( state, toMsg ) }


{-| Heights a vertical drawer settles at when a swipe ends, instead of sizing itself to its content. A number up to `1` is a fraction of the viewport height, and a bigger one is in pixels. The drawer opens at the first one, and is as tall as the viewport behind its visible part.

    Drawer.snapPoints [ 496, 1 ]

A swipe from the smallest point toward the edge still closes the drawer. Side drawers ignore snap points.

-}
snapPoints : List Float -> Drawer id msg -> Drawer id msg
snapPoints points (Drawer config) =
    Drawer { config | snapPoints = points }


snapPointCss : Float -> String
snapPointCss point =
    if point <= 1 then
        String.fromFloat (point * 100) ++ "dvh"

    else
        String.fromFloat point ++ "px"


{-| Only a scroll that ended at the closed position of a drawer that is still open counts.

The drawer scrolls to 0 when it is closed, and a drawer that closes any other way, or is not open yet, rests there too. The scroll offset is negative in the directions that scroll backwards, and one axis is always 0.

-}
dismissDecoder : Bool -> msg -> Decoder msg
dismissDecoder modal msg =
    Decode.map3
        (\scrollTop scrollLeft open ->
            if abs scrollTop <= 1 && abs scrollLeft <= 1 && open then
                Decode.succeed msg

            else
                Decode.fail "not swiped away"
        )
        (Decode.at [ "currentTarget", "scrollTop" ] Decode.float)
        (Decode.at [ "currentTarget", "scrollLeft" ] Decode.float)
        (if modal then
            Decode.at [ "currentTarget", "parentNode", "open" ] Decode.bool

         else
            Decode.succeed True
        )
        |> Decode.andThen identity



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

        -- Side drawers have no use for snap points.
        points =
            case layout of
                FixedSide Left ->
                    []

                FixedSide Right ->
                    []

                _ ->
                    config.snapPoints

        swiping =
            case config.swipe of
                Just _ ->
                    True

                Nothing ->
                    False

        generation =
            config.swipe
                |> Maybe.andThen (\( State generations, _ ) -> Dict.get config.id generations)
                |> Maybe.withDefault 0

        sizes =
            List.filterMap identity
                [ case points of
                    [] ->
                        Maybe.map (\value -> "--drawer-height: " ++ value ++ "; --drawer-max-height: none") config.height

                    _ ->
                        Just "--drawer-height: 100dvh; --drawer-max-height: none"
                , Maybe.map (\value -> "--drawer-width: " ++ value) config.width
                ]

        handle =
            if config.handle then
                Just (viewHandle layout [])

            else if config.downOnMobile then
                Just (viewHandle layout [ class "md:hidden" ])

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

                     -- `overflow-clip`, not `overflow-hidden`: the scroller inside does
                     -- the scrolling, and the dialog must stay put while it focuses.
                     , class "fixed inset-0 z-50 m-0 hidden h-full max-h-none w-full max-w-none overflow-clip bg-transparent p-0 text-inherit outline-none backdrop:bg-transparent open:block"
                     ]
                        ++ (if config.modal then
                                -- The dialog fills the viewport so that the whole dimmed
                                -- area is a button closing it: Safari has no `closedby`
                                -- and phones have no Escape key. `closedby` still lets
                                -- browsers that have it close on Escape and a click
                                -- outside natively. The page behind stops scrolling while
                                -- the drawer is modal, keeping its scrollbar gutter so
                                -- that nothing shifts. The dimming is an element inside
                                -- the dialog, not `::backdrop`: WebKit has no `overlay`
                                -- transition, so a closing dialog leaves the top layer at
                                -- once and its backdrop with it, while the dimming stays
                                -- for the slide.
                                [ attribute "closedby" "any"
                                , class "[html:has(&:modal)]:overflow-hidden [html:has(&:modal)]:[scrollbar-gutter:stable]"
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
                    [ -- The scroller is the drawer's whole gesture: it holds the closed
                      -- and open positions as snap points, its scrollbar is hidden, and
                      -- its scrolling is smooth, so the entrance is a scroll too. It
                      -- shares its view timeline with the backdrop through
                      -- `timeline-scope`, since the backdrop is not inside the panel.
                      Html.div
                        ([ attribute "data-slot" "drawer-scroller"
                         , class "absolute inset-0 [timeline-scope:--drawer] scroll-smooth [scrollbar-width:none] overscroll-contain motion-reduce:scroll-auto [&::-webkit-scrollbar]:hidden"
                         , class (scrollerClass swiping layout)
                         ]
                            ++ (case config.swipe of
                                    Just ( _, toMsg ) ->
                                        -- A swipe ends in a scroll that ends: `scroll` also
                                        -- fires while the drawer opens and closes.
                                        [ Html.Events.on "scrollend" (dismissDecoder config.modal (toMsg (Dismissed config.id))) ]

                                    Nothing ->
                                        []
                               )
                            ++ (if config.modal then
                                    []

                                else
                                    [ class "pointer-events-none" ]
                               )
                        )
                        [ Html.div
                            [ class "pointer-events-none relative flex"
                            , class (contentClass layout)
                            ]
                            (List.filterMap identity
                                [ if config.modal then
                                    -- It covers all of what scrolls, behind everything else,
                                    -- and fades in as the panel's edge comes into view.
                                    Just
                                        (Html.button
                                            ([ Html.Attributes.type_ "button"
                                             , attribute "data-slot" "drawer-backdrop"
                                             , attribute "aria-hidden" "true"
                                             , Html.Attributes.tabindex -1
                                             , class "pointer-events-auto absolute inset-0 cursor-default bg-black/10 opacity-0 backdrop-blur-xs [animation-fill-mode:both] [animation-name:drawer-fade] [animation-range:entry] [animation-timeline:--drawer] [animation-timing-function:linear] [dialog:not([open])_&]:[animation:drawer-fade-out_450ms_linear_both]"
                                             ]
                                                ++ backdropRange points
                                                ++ closes config.id
                                            )
                                            []
                                        )

                                  else
                                    Nothing

                                -- The exit area and the bleed only exist while the drawer is
                                -- open. Chrome keeps a scroller's offset through `display:
                                -- none`, so a drawer closed by a button would reopen already
                                -- scrolled in, with nothing left to animate. Without them the
                                -- scroller has no room, and its offset clamps back to zero.
                                , Just (Html.div [ class "shrink-0 [:not(:is([open],:popover-open))>*>*>&]:hidden", class (exitClass layout) ] [])
                                , Just
                                    (Html.div
                                        ([ attribute "data-slot" "drawer-stage"
                                         , class "shrink-0 outline-none"
                                         , class (stageClass (not (List.isEmpty points)) layout)
                                         ]
                                            ++ (if List.isEmpty points then
                                                    entrance

                                                else
                                                    []
                                               )
                                        )
                                        [ Html.div
                                            ([ attribute "data-slot" "drawer-popup"
                                             , class "group/drawer-popup pointer-events-auto relative flex min-h-0 bg-popover text-sm text-popover-foreground outline-none select-none will-change-transform [interpolate-size:allow-keywords]"

                                             -- Slides from its edge on close, and shrinks and peeks out behind
                                             -- the drawers nested in it, one step per level.
                                             , class "transition-[translate,scale,filter,height] duration-450 ease-[cubic-bezier(0.22,1,0.36,1)] [&:has(dialog[open])]:overflow-hidden [&:has(dialog[open])]:brightness-95 [&:has(dialog[open])]:scale-95 [&:has(dialog[open]_dialog[open])]:scale-90 [&:has(dialog[open]_dialog[open]_dialog[open])]:scale-[0.85]"
                                             , class (panelClass layout)
                                             ]
                                                ++ (if List.isEmpty sizes then
                                                        []

                                                    else
                                                        [ attribute "style" (String.join "; " sizes) ]
                                                   )
                                                ++ attrs
                                            )
                                            (List.concat
                                                [ List.indexedMap (viewSnapPoint layout) points
                                                , List.filterMap identity [ handle ]
                                                , [ Html.div
                                                        [ attribute "data-slot" "drawer-content"
                                                        , class "flex min-h-0 flex-1 flex-col overflow-hidden overscroll-auto rounded-[inherit] transition-opacity duration-300 ease-[cubic-bezier(0.45,1.005,0,1.005)] select-text [&:has(dialog[open])]:opacity-0"
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
                                                  ]
                                                ]
                                            )
                                        ]
                                    )
                                , Just (Html.div [ class "relative shrink-0 bg-popover [:not(:is([open],:popover-open))>*>*>&]:hidden", class (bleedClass layout) ] [])
                                ]
                            )
                        ]
                    ]
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


viewHandle : Layout -> List (Attribute msg) -> Html msg
viewHandle layout attrs =
    Html.div
        ([ attribute "data-slot" "drawer-swipe-handle"
         , attribute "aria-hidden" "true"
         , class "relative z-10 flex shrink-0 transition-opacity duration-200 after:block after:shrink-0 after:rounded-full after:bg-muted [:has(dialog[open])>&]:opacity-0"
         , class (handleClass layout)
         ]
            ++ attrs
        )
        []


{-| A snap point is a marker inside the panel, `point` in from its leading edge. It snaps to the
leading edge of the scroller by way of a scroll margin of one viewport, which leaves exactly `point`
of the panel in view. The margin also makes the marker's snap area as tall as the viewport, so that
the dialog focusing the first marker on opening scrolls it to the same place, whichever way the
browser aligns what it scrolls into view. The marker is two pixels tall, since Chrome ignores a
smaller one.
-}
viewSnapPoint : Layout -> Int -> Float -> Html msg
viewSnapPoint layout index point =
    Html.div
        ([ attribute "data-slot" "drawer-snap-point"
         , class "pointer-events-none absolute left-0 h-0.5 w-0.5 snap-start outline-none"
         , case layout of
            FixedSide Up ->
                class "scroll-mb-[100dvh]"

            _ ->
                class "scroll-mt-[100dvh]"
         , attribute "style"
            ((case layout of
                FixedSide Up ->
                    "bottom: "

                _ ->
                    "top: "
             )
                ++ snapPointCss point
            )
         ]
            ++ (case layout of
                    DownBelowMd _ ->
                        [ class "md:hidden" ]

                    FixedSide _ ->
                        []
               )
            ++ (if index == 0 then
                    entrance

                else
                    []
               )
        )
        []



-- LAYOUT


{-| A fixed side, or a side from `md` up with the bottom below it. Tailwind only finds
classes written out in full, so every combination is spelled out below.

Every layout is the same scroller seen from a different edge. It scrolls along the axis the drawer
slides on, and a swipe is a scroll toward the origin, where the closed drawer rests. The origin is
the top for `Down`, the bottom for `Up`, the left for `Right` and the right for `Left`, which is why
the last two flip the direction, and the second one the writing mode.

-}
type Layout
    = FixedSide Side
    | DownBelowMd Side


panelClass : Layout -> String
panelClass layout =
    case layout of
        FixedSide Down ->
            "flex-col rounded-t-xl border-t origin-bottom h-(--drawer-height) max-h-(--drawer-max-height) [--drawer-height:auto] [--drawer-max-height:calc(100dvh-6rem)] translate-y-[calc(100%+2px)] [:is([open],:popover-open)>*>*>*>&]:translate-y-0 [&:has(dialog[open])]:-translate-y-[calc(1rem+5%)] [&:has(dialog[open]_dialog[open])]:-translate-y-[calc(2rem+10%)] [&:has(dialog[open]_dialog[open]_dialog[open])]:-translate-y-[calc(3rem+15%)] [view-timeline:--drawer_y]"

        FixedSide Up ->
            "flex-col rounded-b-xl border-b origin-top h-(--drawer-height) max-h-(--drawer-max-height) [--drawer-height:auto] [--drawer-max-height:calc(100dvh-6rem)] -translate-y-[calc(100%+2px)] [:is([open],:popover-open)>*>*>*>&]:translate-y-0 [&:has(dialog[open])]:translate-y-[calc(1rem+5%)] [&:has(dialog[open]_dialog[open])]:translate-y-[calc(2rem+10%)] [&:has(dialog[open]_dialog[open]_dialog[open])]:translate-y-[calc(3rem+15%)] [view-timeline:--drawer_y]"

        FixedSide Left ->
            "h-full flex-row rounded-r-xl border-r origin-left w-(--drawer-width) [--drawer-width:75dvw] sm:[--drawer-width:24rem] -translate-x-[calc(100%+2px)] [:is([open],:popover-open)>*>*>*>&]:translate-x-0 [&:has(dialog[open])]:translate-x-[calc(1rem+5%)] [&:has(dialog[open]_dialog[open])]:translate-x-[calc(2rem+10%)] [&:has(dialog[open]_dialog[open]_dialog[open])]:translate-x-[calc(3rem+15%)] [view-timeline:--drawer_x]"

        FixedSide Right ->
            "h-full flex-row rounded-l-xl border-l origin-right w-(--drawer-width) [--drawer-width:75dvw] sm:[--drawer-width:24rem] translate-x-[calc(100%+2px)] [:is([open],:popover-open)>*>*>*>&]:translate-x-0 [&:has(dialog[open])]:-translate-x-[calc(1rem+5%)] [&:has(dialog[open]_dialog[open])]:-translate-x-[calc(2rem+10%)] [&:has(dialog[open]_dialog[open]_dialog[open])]:-translate-x-[calc(3rem+15%)] [view-timeline:--drawer_x]"

        DownBelowMd side ->
            "max-md:flex-col max-md:rounded-t-xl max-md:border-t max-md:origin-bottom max-md:h-(--drawer-height) max-md:max-h-(--drawer-max-height) max-md:[--drawer-height:auto] max-md:[--drawer-max-height:calc(100dvh-6rem)] max-md:translate-y-[calc(100%+2px)] max-md:[:is([open],:popover-open)>*>*>*>&]:translate-y-0 max-md:[&:has(dialog[open])]:-translate-y-[calc(1rem+5%)] max-md:[&:has(dialog[open]_dialog[open])]:-translate-y-[calc(2rem+10%)] max-md:[&:has(dialog[open]_dialog[open]_dialog[open])]:-translate-y-[calc(3rem+15%)] max-md:[view-timeline:--drawer_y] "
                ++ (case side of
                        Up ->
                            "md:flex-col md:rounded-b-xl md:border-b md:origin-top md:h-(--drawer-height) md:max-h-(--drawer-max-height) md:[--drawer-height:auto] md:[--drawer-max-height:calc(100dvh-6rem)] md:-translate-y-[calc(100%+2px)] md:[:is([open],:popover-open)>*>*>*>&]:translate-y-0 md:[&:has(dialog[open])]:translate-y-[calc(1rem+5%)] md:[&:has(dialog[open]_dialog[open])]:translate-y-[calc(2rem+10%)] md:[&:has(dialog[open]_dialog[open]_dialog[open])]:translate-y-[calc(3rem+15%)] md:[view-timeline:--drawer_y]"

                        Left ->
                            "md:h-full md:flex-row md:rounded-r-xl md:border-r md:origin-left md:w-(--drawer-width) md:[--drawer-width:24rem] md:-translate-x-[calc(100%+2px)] md:[:is([open],:popover-open)>*>*>*>&]:translate-x-0 md:[&:has(dialog[open])]:translate-x-[calc(1rem+5%)] md:[&:has(dialog[open]_dialog[open])]:translate-x-[calc(2rem+10%)] md:[&:has(dialog[open]_dialog[open]_dialog[open])]:translate-x-[calc(3rem+15%)] md:[view-timeline:--drawer_x]"

                        _ ->
                            "md:h-full md:flex-row md:rounded-l-xl md:border-l md:origin-right md:w-(--drawer-width) md:[--drawer-width:24rem] md:translate-x-[calc(100%+2px)] md:[:is([open],:popover-open)>*>*>*>&]:translate-x-0 md:[&:has(dialog[open])]:-translate-x-[calc(1rem+5%)] md:[&:has(dialog[open]_dialog[open])]:-translate-x-[calc(2rem+10%)] md:[&:has(dialog[open]_dialog[open]_dialog[open])]:-translate-x-[calc(3rem+15%)] md:[view-timeline:--drawer_x]"
                   )


scrollerClass : Bool -> Layout -> String
scrollerClass swiping layout =
    case layout of
        FixedSide Down ->
            if swiping then
                "overflow-y-auto overflow-x-hidden [scroll-snap-type:y_mandatory]"

            else
                "overflow-y-hidden overflow-x-hidden [scroll-snap-type:y_mandatory]"

        FixedSide Up ->
            if swiping then
                "overflow-y-auto overflow-x-hidden [scroll-snap-type:y_mandatory] [writing-mode:vertical-rl] [direction:rtl]"

            else
                "overflow-y-hidden overflow-x-hidden [scroll-snap-type:y_mandatory] [writing-mode:vertical-rl] [direction:rtl]"

        FixedSide Left ->
            if swiping then
                "overflow-x-auto overflow-y-hidden [scroll-snap-type:x_mandatory] [direction:rtl]"

            else
                "overflow-x-hidden overflow-y-hidden [scroll-snap-type:x_mandatory] [direction:rtl]"

        FixedSide Right ->
            if swiping then
                "overflow-x-auto overflow-y-hidden [scroll-snap-type:x_mandatory]"

            else
                "overflow-x-hidden overflow-y-hidden [scroll-snap-type:x_mandatory]"

        DownBelowMd side ->
            (if swiping then
                "max-md:overflow-y-auto max-md:overflow-x-hidden max-md:[scroll-snap-type:y_mandatory] "

             else
                "max-md:overflow-y-hidden max-md:overflow-x-hidden max-md:[scroll-snap-type:y_mandatory] "
            )
                ++ (case side of
                        Up ->
                            if swiping then
                                "md:overflow-y-auto md:overflow-x-hidden md:[scroll-snap-type:y_mandatory] md:[writing-mode:vertical-rl] md:[direction:rtl]"

                            else
                                "md:overflow-y-hidden md:overflow-x-hidden md:[scroll-snap-type:y_mandatory] md:[writing-mode:vertical-rl] md:[direction:rtl]"

                        Left ->
                            if swiping then
                                "md:overflow-x-auto md:overflow-y-hidden md:[scroll-snap-type:x_mandatory] md:[direction:rtl]"

                            else
                                "md:overflow-x-hidden md:overflow-y-hidden md:[scroll-snap-type:x_mandatory] md:[direction:rtl]"

                        _ ->
                            if swiping then
                                "md:overflow-x-auto md:overflow-y-hidden md:[scroll-snap-type:x_mandatory]"

                            else
                                "md:overflow-x-hidden md:overflow-y-hidden md:[scroll-snap-type:x_mandatory]"
                   )


contentClass : Layout -> String
contentClass layout =
    case layout of
        FixedSide Down ->
            "flex-col"

        FixedSide Up ->
            "w-full flex-row"

        FixedSide Left ->
            "h-full flex-row"

        FixedSide Right ->
            "h-full flex-row"

        DownBelowMd side ->
            "max-md:flex-col "
                ++ (case side of
                        Up ->
                            "md:w-full md:flex-row"

                        Left ->
                            "md:h-full md:flex-row"

                        _ ->
                            "md:h-full md:flex-row"
                   )


exitClass : Layout -> String
exitClass layout =
    case layout of
        FixedSide Down ->
            "h-[100dvh] snap-start"

        FixedSide Up ->
            "h-[100dvh] [writing-mode:horizontal-tb] [direction:ltr] snap-start"

        FixedSide Left ->
            "w-[100dvw] snap-start"

        FixedSide Right ->
            "w-[100dvw] snap-start"

        DownBelowMd side ->
            "max-md:h-[100dvh] max-md:snap-start "
                ++ (case side of
                        Up ->
                            "md:h-[100dvh] md:[writing-mode:horizontal-tb] md:[direction:ltr] md:snap-start"

                        Left ->
                            "md:w-[100dvw] md:snap-start"

                        _ ->
                            "md:w-[100dvw] md:snap-start"
                   )


stageClass : Bool -> Layout -> String
stageClass snapped layout =
    case layout of
        FixedSide Down ->
            if snapped then
                ""

            else
                "snap-end"

        FixedSide Up ->
            if snapped then
                "[writing-mode:horizontal-tb] [direction:ltr]"

            else
                "[writing-mode:horizontal-tb] [direction:ltr] snap-end"

        FixedSide Left ->
            if snapped then
                "[direction:ltr]"

            else
                "[direction:ltr] snap-end"

        FixedSide Right ->
            if snapped then
                ""

            else
                "snap-end"

        DownBelowMd side ->
            (if snapped then
                " "

             else
                "max-md:snap-end "
            )
                ++ (case side of
                        Up ->
                            if snapped then
                                "md:[writing-mode:horizontal-tb] md:[direction:ltr]"

                            else
                                "md:[writing-mode:horizontal-tb] md:[direction:ltr] md:snap-end"

                        Left ->
                            if snapped then
                                "md:[direction:ltr]"

                            else
                                "md:[direction:ltr] md:snap-end"

                        _ ->
                            if snapped then
                                ""

                            else
                                "md:snap-end"
                   )


bleedClass : Layout -> String
bleedClass layout =
    case layout of
        FixedSide Down ->
            "h-[100dvh]"

        FixedSide Up ->
            "h-[100dvh] [writing-mode:horizontal-tb] [direction:ltr]"

        FixedSide Left ->
            "w-[100dvw]"

        FixedSide Right ->
            "w-[100dvw]"

        DownBelowMd side ->
            "max-md:h-[100dvh] "
                ++ (case side of
                        Up ->
                            "md:h-[100dvh] md:[writing-mode:horizontal-tb] md:[direction:ltr]"

                        Left ->
                            "md:w-[100dvw]"

                        _ ->
                            "md:w-[100dvw]"
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


{-| With snap points, the drawer opens with its first one in view, and the backdrop is at full
strength by then.
-}
backdropRange : List Float -> List (Attribute msg)
backdropRange points =
    case points of
        first :: _ ->
            [ attribute "style" ("animation-range: entry 0% entry " ++ snapPointCss first) ]

        [] ->
            []


{-| The browser scrolls whatever is focused on opening into view, and the scroller smooths that
scroll, which is the whole entrance. The stage is what is brought into view, or the first snap
point inside the panel.
-}
entrance : List (Attribute msg)
entrance =
    [ attribute "autofocus" "", Html.Attributes.tabindex -1 ]
