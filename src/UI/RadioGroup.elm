module UI.RadioGroup exposing (view, item)

{-| A set of checkable buttons, known as radio buttons, where no more than one can be checked at a time.

Items are native `<input type="radio">`; give them the same `name`:

    RadioGroup.view []
        [ label [ class "flex items-center gap-3" ]
            [ RadioGroup.item [ name "density", checked (model.density == Comfortable), onClick (DensityChosen Comfortable) ]
            , text "Comfortable"
            ]
        , label [ class "flex items-center gap-3" ]
            [ RadioGroup.item [ name "density", checked (model.density == Compact), onClick (DensityChosen Compact) ]
            , text "Compact"
            ]
        ]

@docs view, item

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, type_)


{-| Lays out the items.
-}
view : List (Attribute msg) -> List (Html msg) -> Html msg
view attrs children =
    Html.div (attribute "role" "radiogroup" :: attribute "data-slot" "radio-group" :: class "grid w-full gap-2" :: attrs) children


{-| The attributes go on the `<input>`.
-}
item : List (Attribute msg) -> Html msg
item attrs =
    Html.span [ class "relative inline-grid size-4 shrink-0 place-items-center *:col-start-1 *:row-start-1" ]
        [ Html.input
            ([ type_ "radio"
             , attribute "data-slot" "radio-group-item"
             , class "peer aspect-square size-4 shrink-0 appearance-none rounded-full border border-input outline-none focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20 checked:border-primary checked:bg-primary aria-invalid:checked:border-primary dark:bg-input/30 dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40 dark:checked:bg-primary"
             ]
                ++ attrs
            )
            []
        , Html.span
            [ attribute "data-slot" "radio-group-indicator"
            , class "pointer-events-none invisible size-2 rounded-full bg-primary-foreground peer-checked:visible"
            ]
            []
        ]
