module State exposing (Msg, State, drawer, drawerMsg, get, init, set, update)

{-| Shared state for the examples that need some, such as a select that remembers what was picked.

It is a flat map from a key the example chooses to a string, so the examples stay independent of each other and of the site, plus the one `Drawer.State` the swipeable drawers share. An example that uses it has the type `State -> Html State.Msg` instead of `Html msg`.

-}

import Dict exposing (Dict)
import UI.Drawer as Drawer


type State
    = State
        { values : Dict String String
        , drawer : Drawer.State
        }


type Msg
    = Set String String
    | DrawerMsg Drawer.Msg


init : State
init =
    State { values = Dict.empty, drawer = Drawer.init }


update : Msg -> State -> State
update msg (State state) =
    case msg of
        Set key value ->
            State { state | values = Dict.insert key value state.values }

        DrawerMsg inner ->
            State { state | drawer = Drawer.update inner state.drawer }


get : String -> State -> Maybe String
get key (State state) =
    Dict.get key state.values


set : String -> String -> Msg
set =
    Set


drawer : State -> Drawer.State
drawer (State state) =
    state.drawer


drawerMsg : Drawer.Msg -> Msg
drawerMsg =
    DrawerMsg
