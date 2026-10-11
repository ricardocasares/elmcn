module Examples.Progress exposing (..)

import Html exposing (Html)
import Html.Attributes exposing (class)
import UI.Progress as Progress


demo : Html msg
demo =
    Progress.view 60 [ class "w-[60%]" ]
