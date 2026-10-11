module Examples.RadioGroup exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (checked, class, name)
import UI.Label as Label
import UI.RadioGroup as RadioGroup


demo : Html msg
demo =
    RadioGroup.view []
        [ Label.view [ class "gap-3 font-normal" ]
            [ RadioGroup.item [ name "density", checked False ], text "Default" ]
        , Label.view [ class "gap-3 font-normal" ]
            [ RadioGroup.item [ name "density", checked True ], text "Comfortable" ]
        , Label.view [ class "gap-3 font-normal" ]
            [ RadioGroup.item [ name "density", checked False ], text "Compact" ]
        ]
