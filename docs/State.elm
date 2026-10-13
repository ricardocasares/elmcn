module State exposing (Msg, State, advance, attempt, batch, delay, get, init, none, remove, run, runIf, set, update)

{-| Shared state for the examples that need some, such as a select that remembers what was picked.

It is a flat map from a key the example chooses to a string, so the examples stay independent of each other and of the site. An example that uses it has the type `State -> Html State.Msg` instead of `Html msg`.

A message can also take time or touch the page, as the message scroller's examples do: `delay` runs a message later, `advance` counts a key up on a timer, and `run` and `attempt` run `Browser.Dom` tasks.

-}

import Browser.Dom
import Dict exposing (Dict)
import Process
import Task exposing (Task)


type State
    = State (Dict String String)


type Msg
    = Set String String
    | Remove String
    | Batch (List Msg)
    | Delay Float Msg
    | Advance Counter
    | Attempt (Task Browser.Dom.Error Msg)
    | RunIf (State -> Bool) (Task Browser.Dom.Error ())
    | None


type alias Counter =
    { key : String
    , to : Int
    , every : Float
    , each : Msg

    -- What the key held after the last tick. A tick that finds something else, such as
    -- a key that was reset, ends the count.
    , expect : Maybe Int
    }


init : State
init =
    State Dict.empty


update : Msg -> State -> ( State, Cmd Msg )
update msg state =
    case msg of
        Set key value ->
            ( insert key value state, Cmd.none )

        Remove key ->
            ( delete key state, Cmd.none )

        Batch messages ->
            List.foldl
                (\next ( current, cmds ) ->
                    let
                        ( updated, cmd ) =
                            update next current
                    in
                    ( updated, cmd :: cmds )
                )
                ( state, [] )
                messages
                |> Tuple.mapSecond (List.reverse >> Cmd.batch)

        Delay milliseconds next ->
            ( state, Task.perform (\_ -> next) (Process.sleep milliseconds) )

        Advance counter ->
            if counter.expect /= Nothing && counter.expect /= count counter.key state then
                ( state, Cmd.none )

            else
                let
                    next =
                        Maybe.withDefault 0 (count counter.key state) + 1

                    ( updated, eachCmd ) =
                        update counter.each (insert counter.key (String.fromInt next) state)
                in
                ( updated
                , Cmd.batch
                    [ eachCmd
                    , if next < counter.to then
                        Task.perform (\_ -> Advance { counter | expect = Just next }) (Process.sleep counter.every)

                      else
                        Cmd.none
                    ]
                )

        Attempt task ->
            ( state, Task.attempt (Result.withDefault None) task )

        RunIf condition task ->
            if condition state then
                ( state, Task.attempt (\_ -> None) task )

            else
                ( state, Cmd.none )

        None ->
            ( state, Cmd.none )


get : String -> State -> Maybe String
get key (State values) =
    Dict.get key values


insert : String -> String -> State -> State
insert key value (State values) =
    State (Dict.insert key value values)


delete : String -> State -> State
delete key (State values) =
    State (Dict.remove key values)


count : String -> State -> Maybe Int
count key state =
    get key state |> Maybe.andThen String.toInt



-- MESSAGES


set : String -> String -> Msg
set =
    Set


remove : String -> Msg
remove =
    Remove


{-| Several messages, one after the other, in a single update.
-}
batch : List Msg -> Msg
batch =
    Batch


{-| Does nothing.
-}
none : Msg
none =
    None


{-| Sends the message after the given number of milliseconds.
-}
delay : Float -> Msg -> Msg
delay =
    Delay


{-| Counts the key up by one every `every` milliseconds, starting now, until it reaches `to`, and sends `each` after every step. A key that holds anything but the last count ends it, so setting or removing the key stops it.
-}
advance : { key : String, to : Int, every : Float, each : Msg } -> Msg
advance { key, to, every, each } =
    Advance { key = key, to = to, every = every, each = each, expect = Nothing }


{-| Runs a task that finds the next message, such as measuring something before changing it. A task that fails does nothing.
-}
attempt : Task Browser.Dom.Error Msg -> Msg
attempt =
    Attempt


{-| Runs a `Browser.Dom` task, such as a scroll command, and ignores how it ends.
-}
run : Task Browser.Dom.Error () -> Msg
run task =
    Attempt (Task.map (\_ -> None) task)


{-| Runs the task if the condition holds for the state when the message arrives, not when it was made, which is what a message sent by `advance` needs.
-}
runIf : (State -> Bool) -> Task Browser.Dom.Error () -> Msg
runIf =
    RunIf
