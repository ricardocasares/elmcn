module State exposing (Msg, State, get, init, set, update)

{-| Shared state for the examples that need some, such as a select that remembers what was picked.

It is a flat map from a key the example chooses to a string, so the examples stay independent of each other and of the site. An example that uses it has the type `State -> Html State.Msg` instead of `Html msg`.

-}

import Dict exposing (Dict)


type State
    = State (Dict String String)


type Msg
    = Set String String


init : State
init =
    State Dict.empty


update : Msg -> State -> State
update (Set key value) (State dict) =
    State (Dict.insert key value dict)


get : String -> State -> Maybe String
get key (State dict) =
    Dict.get key dict


set : String -> String -> Msg
set =
    Set
