module Component exposing (Component, Entry, Example)

import Html exposing (Html)


{-| A documented component. `Generated.components` builds these from `registry.json`,
the `src/UI` sources and the `docs/Examples` modules, so none of it is written by hand.
-}
type alias Component =
    { slug : String
    , title : String
    , description : String
    , module_ : String
    , file : String
    , packages : List String
    , usage : String
    , examples : List Example
    , api : List Entry
    }


type alias Example =
    { id : String
    , title : String
    , description : String
    , view : Html Never
    , code : String
    }


type alias Entry =
    { name : String
    , signature : String
    , description : String
    }
