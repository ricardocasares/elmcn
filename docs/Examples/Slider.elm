module Examples.Slider exposing (..)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, dir)
import State exposing (State)
import UI.Label as Label
import UI.Slider as Slider


demo : State -> Html State.Msg
demo state =
    Slider.new
        |> Slider.value (floatAt "volume" 50 state)
        |> Slider.onChange (State.set "volume" << String.fromFloat)
        |> Slider.toHtml [ class "max-w-sm" ]


{-| `range` takes two values and `onChange` gets the new pair back.
-}
range : State -> Html State.Msg
range state =
    let
        ( low, high ) =
            pairAt "range" ( 25, 50 ) state
    in
    Slider.new
        |> Slider.range low high
        |> Slider.onChange (State.set "range" << encodePair)
        |> Slider.step 5
        |> Slider.toHtml [ class "max-w-sm" ]


{-| `values` takes any number of values. Thumbs keep their order.
-}
multipleThumbs : State -> Html State.Msg
multipleThumbs state =
    Slider.new
        |> Slider.values (listAt "multiple" [ 10, 20, 70 ] state)
        |> Slider.onChange (State.set "multiple" << encodeList)
        |> Slider.step 10
        |> Slider.toHtml [ class "max-w-sm" ]


{-| Give a `vertical` slider a height.
-}
vertical : State -> Html State.Msg
vertical state =
    div [ class "flex items-center gap-6" ]
        [ Slider.new
            |> Slider.value (floatAt "vertical-a" 50 state)
            |> Slider.onChange (State.set "vertical-a" << String.fromFloat)
            |> Slider.vertical
            |> Slider.toHtml [ class "h-40" ]
        , Slider.new
            |> Slider.value (floatAt "vertical-b" 25 state)
            |> Slider.onChange (State.set "vertical-b" << String.fromFloat)
            |> Slider.vertical
            |> Slider.toHtml [ class "h-40" ]
        ]


{-| The value lives in the model, so anything can show it.
-}
controlled : State -> Html State.Msg
controlled state =
    let
        ( low, high ) =
            pairAt "temperature" ( 0.3, 0.7 ) state
    in
    div [ class "grid w-full max-w-sm gap-3" ]
        [ div [ class "flex items-center justify-between gap-2" ]
            [ Label.view [] [ text "Temperature" ]
            , span [ class "text-sm text-muted-foreground" ]
                [ text (String.fromFloat low ++ ", " ++ String.fromFloat high) ]
            ]
        , Slider.new
            |> Slider.range low high
            |> Slider.onChange (State.set "temperature" << encodePair)
            |> Slider.min 0
            |> Slider.max 1
            |> Slider.step 0.1
            |> Slider.toHtml []
        ]


disabled : State -> Html State.Msg
disabled state =
    Slider.new
        |> Slider.value (floatAt "disabled" 50 state)
        |> Slider.onChange (State.set "disabled" << String.fromFloat)
        |> Slider.disabled
        |> Slider.toHtml [ class "max-w-sm" ]


rtl : State -> Html State.Msg
rtl state =
    let
        ( low, high ) =
            pairAt "rtl" ( 25, 50 ) state
    in
    Slider.new
        |> Slider.range low high
        |> Slider.onChange (State.set "rtl" << encodePair)
        |> Slider.toHtml [ class "max-w-sm", dir "rtl" ]



-- The shared example state holds strings, so the values go through these.


floatAt : String -> Float -> State -> Float
floatAt key default state =
    State.get key state
        |> Maybe.andThen String.toFloat
        |> Maybe.withDefault default


listAt : String -> List Float -> State -> List Float
listAt key default state =
    State.get key state
        |> Maybe.map (String.split "," >> List.filterMap String.toFloat)
        |> Maybe.withDefault default


pairAt : String -> ( Float, Float ) -> State -> ( Float, Float )
pairAt key default state =
    case listAt key [] state of
        [ low, high ] ->
            ( low, high )

        _ ->
            default


encodeList : List Float -> String
encodeList =
    List.map String.fromFloat >> String.join ","


encodePair : ( Float, Float ) -> String
encodePair ( low, high ) =
    encodeList [ low, high ]
