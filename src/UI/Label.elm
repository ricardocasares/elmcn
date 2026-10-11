module UI.Label exposing (view)

{-| Renders an accessible label associated with controls.

    Label.view [ for "email" ] [ text "Your email address" ]

@docs view

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)


{-| Renders a `<label>`.
-}
view : List (Attribute msg) -> List (Html msg) -> Html msg
view attrs children =
    Html.label
        (attribute "data-slot" "label"
            :: class "flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50"
            :: attrs
        )
        children
