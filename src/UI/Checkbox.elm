module UI.Checkbox exposing (view)

{-| A control that allows the user to toggle between checked and not checked.

It is a native `<input type="checkbox">`, so it works in forms and with `onCheck`:

    label [ class "flex items-center gap-3" ]
        [ Checkbox.view [ checked model.terms, onCheck TermsToggled ]
        , text "Accept terms and conditions"
        ]

@docs view

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, type_)


{-| The attributes go on the `<input>`.
-}
view : List (Attribute msg) -> Html msg
view attrs =
    Html.span [ class "relative inline-grid size-4 shrink-0 place-items-center *:col-start-1 *:row-start-1" ]
        [ Html.input
            ([ type_ "checkbox"
             , attribute "data-slot" "checkbox"
             , class "peer size-4 shrink-0 appearance-none rounded-[4px] border border-input transition-colors outline-none focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20 checked:border-primary checked:bg-primary aria-invalid:checked:border-primary dark:bg-input/30 dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40 dark:checked:bg-primary"
             ]
                ++ attrs
            )
            []
        , Html.span
            [ attribute "data-slot" "checkbox-indicator"
            , class "pointer-events-none invisible mb-0.5 h-2.5 w-1.5 rotate-45 border-r-2 border-b-2 border-primary-foreground peer-checked:visible"
            ]
            []
        ]
