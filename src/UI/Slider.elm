module UI.Slider exposing
    ( Slider, NeedsValue, NeedsHandler, Ready
    , new
    , value, range, values
    , onChange
    , min, max, step
    , vertical, disabled
    , toHtml
    )

{-| An input where the user selects a value from within a given range.

A slider is built with `new`, given a value and an `onChange` handler, and rendered with `toHtml`:

    Slider.new
        |> Slider.value model.volume
        |> Slider.onChange VolumeChanged
        |> Slider.toHtml []

The value lives in your model, and `onChange` tells you when it changes. The shape of the value decides the shape of the handler: `value` takes a `Float` and makes `onChange` expect a `Float -> msg`, `range` takes two and makes it expect a `( Float, Float ) -> msg`, and `values` takes a list and makes it expect a `List Float -> msg`. A slider needs a value before it can take a handler, and both before it can be rendered.

    Slider.new
        |> Slider.range model.priceRange
        |> Slider.onChange PriceRangeChanged
        |> Slider.min 0
        |> Slider.max 1000
        |> Slider.step 50
        |> Slider.toHtml []

Each thumb is a native `<input type="range">`, so the slider is dragged, focused and moved with the arrow keys with no JavaScript, ports or component state. Thumbs keep their order: a thumb can't be dragged past its neighbours.

@docs Slider, NeedsValue, NeedsHandler, Ready


# Constructor

@docs new


# Value

A slider takes exactly one of these, before its handler.

@docs value, range, values


# Handler

@docs onChange


# Scale

@docs min, max, step


# Setters

@docs vertical, disabled


# Rendering

@docs toHtml

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, type_)
import Html.Events
import Json.Decode as Decode


{-| A slider being built.

`a` is the type of the value, fixed by [`value`](#value), [`range`](#range) or [`values`](#values). `status` is [`NeedsValue`](#NeedsValue) after `new`, [`NeedsHandler`](#NeedsHandler) once the slider has a value, and [`Ready`](#Ready) once it also has an [`onChange`](#onChange) handler.

-}
type Slider a status msg
    = Slider
        { values : List Float
        , toValue : List Float -> Maybe a
        , onChange : Maybe (List Float -> Maybe msg)
        , min : Float
        , max : Float
        , step : Float
        , orientation : Orientation
        , disabled : Bool
        }


{-| A slider that still needs a [`value`](#value), [`range`](#range) or [`values`](#values).
-}
type NeedsValue
    = NeedsValue


{-| A slider that still needs an [`onChange`](#onChange) handler before it can be rendered.
-}
type NeedsHandler
    = NeedsHandler


{-| The slider can be rendered.
-}
type Ready
    = Ready


type Orientation
    = Horizontal
    | Vertical



-- CONSTRUCTOR


{-| An empty slider from 0 to 100 in steps of 1. Give it a value and an [`onChange`](#onChange) handler to make it renderable.
-}
new : Slider a NeedsValue msg
new =
    Slider
        { values = []
        , toValue = always Nothing
        , onChange = Nothing
        , min = 0
        , max = 100
        , step = 1
        , orientation = Horizontal
        , disabled = False
        }



-- VALUE


{-| A single thumb at the given value. `onChange` is then called with the new value.
-}
value : Float -> Slider a NeedsValue msg -> Slider Float NeedsHandler msg
value v =
    withValues [ v ] List.head


{-| Two thumbs, at the given values. `onChange` is then called with the new pair, low first.
-}
range : Float -> Float -> Slider a NeedsValue msg -> Slider ( Float, Float ) NeedsHandler msg
range low high =
    withValues [ low, high ]
        (\list ->
            case list of
                [ a, b ] ->
                    Just ( a, b )

                _ ->
                    Nothing
        )


{-| One thumb per value, in ascending order. `onChange` is then called with the new list, in the same order.
-}
values : List Float -> Slider a NeedsValue msg -> Slider (List Float) NeedsHandler msg
values list =
    withValues list Just


{-| The value's type changes here, which a record update can't do.
-}
withValues : List Float -> (List Float -> Maybe b) -> Slider a NeedsValue msg -> Slider b NeedsHandler msg
withValues list toValue (Slider config) =
    Slider
        { values = list
        , toValue = toValue
        , onChange = Nothing
        , min = config.min
        , max = config.max
        , step = config.step
        , orientation = config.orientation
        , disabled = config.disabled
        }



-- HANDLER


{-| Called with the new value whenever a thumb moves.
-}
onChange : (a -> msg) -> Slider a NeedsHandler msg -> Slider a Ready msg
onChange toMsg (Slider config) =
    Slider { config | onChange = Just (config.toValue >> Maybe.map toMsg) }



-- SCALE


{-| The value at the start of the track. Defaults to 0.
-}
min : Float -> Slider a status msg -> Slider a status msg
min v (Slider config) =
    Slider { config | min = v }


{-| The value at the end of the track. Defaults to 100.
-}
max : Float -> Slider a status msg -> Slider a status msg
max v (Slider config) =
    Slider { config | max = v }


{-| The distance between the values a thumb can land on. Defaults to 1.
-}
step : Float -> Slider a status msg -> Slider a status msg
step v (Slider config) =
    Slider { config | step = v }



-- SETTERS


{-| Lays the track out bottom to top. Give the root a height, such as `class "h-40"`.
-}
vertical : Slider a status msg -> Slider a status msg
vertical (Slider config) =
    Slider { config | orientation = Vertical }


{-| Dims the slider and stops its thumbs from moving.
-}
disabled : Slider a status msg -> Slider a status msg
disabled (Slider config) =
    Slider { config | disabled = True }



-- RENDERING


{-| Renders the slider. The attributes go on the root, after the styles, so classes can override them.

The root is as wide as its container, or as tall when `vertical`. Each thumb is an `<input type="range">` with its `aria-value*` attributes, so a single-thumb slider can sit inside a `Label.view`. Two thumbs that share a value are separated by dragging the top one, the later of the two, away.

-}
toHtml : List (Attribute msg) -> Slider a Ready msg -> Html msg
toHtml attrs (Slider config) =
    let
        orientation =
            case config.orientation of
                Horizontal ->
                    "horizontal"

                Vertical ->
                    "vertical"

        fractions =
            List.map (fraction config) config.values

        -- The indicator runs from the start of the track to the thumb, or between the
        -- first and last thumbs when there are several.
        rangeStart =
            case fractions of
                _ :: _ :: _ ->
                    List.head fractions |> Maybe.map trackPosition |> Maybe.withDefault "0px"

                _ ->
                    "0px"

        rangeEnd =
            List.reverse fractions |> List.head |> Maybe.map trackPosition |> Maybe.withDefault "0px"

        count =
            List.length config.values
    in
    Html.span
        ([ attribute "data-slot" "slider"
         , attribute "data-orientation" orientation
         , class "relative flex touch-none items-center select-none data-disabled:opacity-50"
         , class
            (case config.orientation of
                Horizontal ->
                    "min-h-3 w-full"

                Vertical ->
                    "h-full min-h-40 w-auto min-w-3 flex-col"
            )
         ]
            ++ (if config.disabled then
                    [ attribute "data-disabled" "" ]

                else
                    []
               )
            ++ attrs
        )
        (Html.span
            [ attribute "data-slot" "slider-track"
            , class "relative grow overflow-hidden rounded-full bg-muted select-none"
            , class
                (case config.orientation of
                    Horizontal ->
                        "h-1 w-full"

                    Vertical ->
                        "h-full w-1"
                )
            ]
            [ Html.span
                [ attribute "data-slot" "slider-range"
                , class "absolute bg-primary select-none"
                , class
                    (case config.orientation of
                        Horizontal ->
                            "h-full"

                        Vertical ->
                            "w-full"
                    )

                -- `Html.Attributes.style` would do here, but the custom property on the
                -- thumbs below can't go through it, so both use the attribute.
                , attribute "style"
                    (case config.orientation of
                        Horizontal ->
                            "inset-inline-start: " ++ rangeStart ++ "; width: calc(" ++ rangeEnd ++ " - " ++ rangeStart ++ ")"

                        Vertical ->
                            "bottom: " ++ rangeStart ++ "; height: calc(" ++ rangeEnd ++ " - " ++ rangeStart ++ ")"
                    )
                ]
                []
            ]
            :: List.indexedMap (viewThumb config count) (List.map2 Tuple.pair config.values fractions)
        )


{-| Where a value sits along the track, from 0 to 1.
-}
fraction : { c | min : Float, max : Float } -> Float -> Float
fraction config v =
    if config.max <= config.min then
        0

    else
        clamp 0 1 ((v - config.min) / (config.max - config.min))


{-| The centre of a thumb, measured along the track. A native range input keeps its thumb
inside its own box, so the thumb's centre travels the track length minus the thumb size,
starting half a thumb in. The indicator and the visible thumbs follow the same rule.
-}
trackPosition : Float -> String
trackPosition f =
    "calc(" ++ thumbRadius ++ " + " ++ String.fromFloat f ++ " * (100% - " ++ thumbSize ++ "))"


thumbSize : String
thumbSize =
    "0.75rem"


thumbRadius : String
thumbRadius =
    "0.375rem"


{-| The hit area around a thumb, on each side, matching nova's `after:-inset-2`.
-}
thumbInset : String
thumbInset =
    "0.5rem"


viewThumb :
    { c | values : List Float, onChange : Maybe (List Float -> Maybe msg), min : Float, max : Float, step : Float, orientation : Orientation, disabled : Bool }
    -> Int
    -> Int
    -> ( Float, Float )
    -> Html msg
viewThumb config count index ( v, f ) =
    let
        -- The input sticks out of the root by the hit area on both ends, so that its own
        -- 1.75rem thumb lines up with the 0.75rem one drawn over it. The wrapper lets
        -- pointer events through to the thumbs stacked under it.
        wrapperClass =
            case config.orientation of
                Horizontal ->
                    "pointer-events-none absolute top-1/2 -inset-x-2 h-7 -translate-y-1/2"

                Vertical ->
                    "pointer-events-none absolute left-1/2 -inset-y-2 w-7 -translate-x-1/2"

        inputClass =
            case config.orientation of
                Horizontal ->
                    ""

                Vertical ->
                    "[writing-mode:vertical-lr] [direction:rtl]"

        -- A single thumb takes the whole track, so a click anywhere on it moves the thumb
        -- there. Several thumbs only react on their own thumb, or they would hide each other.
        hitArea =
            if count == 1 then
                "pointer-events-auto"

            else
                "pointer-events-none [&::-webkit-slider-thumb]:pointer-events-auto [&::-moz-range-thumb]:pointer-events-auto"

        thumbPosition =
            "calc(" ++ thumbInset ++ " + " ++ String.fromFloat f ++ " * (100% - " ++ thumbSize ++ " - 2 * " ++ thumbInset ++ "))"

        ( thumbClass, thumbStyle ) =
            case config.orientation of
                Horizontal ->
                    ( "top-1/2 -translate-y-1/2", "inset-inline-start: " ++ thumbPosition )

                Vertical ->
                    ( "left-1/2 -translate-x-1/2", "bottom: " ++ thumbPosition )
    in
    Html.span
        [ class wrapperClass

        -- Later thumbs sit on top of earlier ones, so when two share a value the one
        -- that can still move up is the one that gets grabbed. At the end of the track
        -- nothing can move up, so there the earlier thumbs come to the top instead.
        , Html.Attributes.style "z-index"
            (String.fromInt
                (if v >= config.max then
                    count - index

                 else
                    index + 1
                )
            )
        ]
        [ Html.input
            [ type_ "range"
            , attribute "data-slot" "slider-thumb"
            , attribute "min" (String.fromFloat config.min)
            , attribute "max" (String.fromFloat config.max)
            , attribute "step" (String.fromFloat config.step)
            , Html.Attributes.value (String.fromFloat v)
            , Html.Attributes.disabled config.disabled
            , Html.Events.on "input" (changeDecoder config index)
            , class "peer m-0 block size-full cursor-default appearance-none bg-transparent p-0 opacity-0 outline-none disabled:pointer-events-none"
            , class "[&::-webkit-slider-thumb]:size-7 [&::-webkit-slider-thumb]:appearance-none [&::-moz-range-thumb]:size-7 [&::-moz-range-thumb]:border-0"
            , class inputClass
            , class hitArea
            ]
            []
        , Html.span
            [ attribute "aria-hidden" "true"
            , class "pointer-events-none absolute block size-3 shrink-0 rounded-full border border-ring bg-white ring-ring/50 transition-[color,box-shadow] select-none peer-hover:ring-3 peer-focus-visible:ring-3 peer-active:ring-3 peer-disabled:pointer-events-none"
            , class thumbClass
            , attribute "style" thumbStyle
            ]
            []
        ]


{-| The new list of values when the thumb at `index` is moved. The thumb stays between its
neighbours and inside the scale.
-}
changeDecoder : { c | values : List Float, onChange : Maybe (List Float -> Maybe msg), min : Float, max : Float } -> Int -> Decode.Decoder msg
changeDecoder config index =
    Html.Events.targetValue
        |> Decode.andThen
            (\string ->
                case ( String.toFloat string, config.onChange ) of
                    ( Just moved, Just toMsg ) ->
                        let
                            low =
                                if index == 0 then
                                    config.min

                                else
                                    List.drop (index - 1) config.values
                                        |> List.head
                                        |> Maybe.withDefault config.min

                            high =
                                List.drop (index + 1) config.values
                                    |> List.head
                                    |> Maybe.withDefault config.max

                            moved_ =
                                clamp (Basics.max config.min low) (Basics.min config.max high) moved

                            newValues =
                                List.indexedMap
                                    (\i old ->
                                        if i == index then
                                            moved_

                                        else
                                            old
                                    )
                                    config.values
                        in
                        case toMsg newValues of
                            Just msg ->
                                Decode.succeed msg

                            Nothing ->
                                Decode.fail "The slider's value has a different shape than its handler expects."

                    _ ->
                        Decode.fail "Not a number."
            )
