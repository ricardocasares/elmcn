module UI.NativeSelect exposing
    ( NativeSelect
    , new
    , Option, option, optionGroup, options
    , small
    , toHtml
    )

{-| A styled native HTML select element.

    NativeSelect.new
        |> NativeSelect.options
            [ NativeSelect.option [ value "" ] [ text "Select status" ]
            , NativeSelect.option [ value "todo" ] [ text "Todo" ]
            , NativeSelect.option [ value "done" ] [ text "Done" ]
            ]
        |> NativeSelect.toHtml [ onInput StatusChosen ]

It is a native `<select>`, so it works in forms and with `onInput`, `value` and `selected`.

@docs NativeSelect


# Constructor

@docs new


# Options

@docs Option, option, optionGroup, options


# Sizes

@docs small


# Rendering

@docs toHtml

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)


{-| A select being built.
-}
type NativeSelect msg
    = NativeSelect
        { size : Size
        , options : List (Option msg)
        }


type Size
    = Medium
    | Small



-- CONSTRUCTOR


{-| An empty select at the default size.
-}
new : NativeSelect msg
new =
    NativeSelect { size = Medium, options = [] }



-- OPTIONS


{-| An `<option>` or `<optgroup>`, made with `option` or `optionGroup`.
-}
type Option msg
    = Option (Html msg)


{-| Renders an `<option>`. Pass `value`, `selected` or `disabled` as attributes.
-}
option : List (Attribute msg) -> List (Html msg) -> Option msg
option attrs children =
    Option (Html.option (attribute "data-slot" "native-select-option" :: class "bg-[Canvas] text-[CanvasText]" :: attrs) children)


{-| Renders an `<optgroup>` with the given label.

    NativeSelect.optionGroup "Engineering"
        [ NativeSelect.option [] [ text "Frontend" ]
        , NativeSelect.option [] [ text "Backend" ]
        ]

-}
optionGroup : String -> List (Option msg) -> Option msg
optionGroup label children =
    Option
        (Html.optgroup
            [ attribute "data-slot" "native-select-optgroup"
            , attribute "label" label
            , class "bg-[Canvas] text-[CanvasText]"
            ]
            (List.map (\(Option child) -> child) children)
        )


{-| The options of the select, in order. Replaces any options given before.
-}
options : List (Option msg) -> NativeSelect msg -> NativeSelect msg
options children (NativeSelect config) =
    NativeSelect { config | options = children }



-- SIZES


{-| -}
small : NativeSelect msg -> NativeSelect msg
small (NativeSelect config) =
    NativeSelect { config | size = Small }



-- RENDERING


{-| Renders the select. The attributes go on the `<select>`.
-}
toHtml : List (Attribute msg) -> NativeSelect msg -> Html msg
toHtml attrs (NativeSelect config) =
    Html.div
        [ attribute "data-slot" "native-select-wrapper"
        , class "group/native-select relative w-fit has-[select:disabled]:opacity-50"
        ]
        [ Html.select
            ([ attribute "data-slot" "native-select"
             , attribute "data-size" (sizeName config.size)
             , class "h-8 w-full min-w-0 appearance-none rounded-lg border border-input bg-transparent py-1 pr-8 pl-2.5 text-sm transition-colors outline-none select-none selection:bg-primary selection:text-primary-foreground placeholder:text-muted-foreground disabled:pointer-events-none disabled:cursor-not-allowed data-[size=sm]:h-7 data-[size=sm]:rounded-[min(var(--radius-md),10px)] data-[size=sm]:py-0.5 dark:bg-input/30 dark:hover:bg-input/50"
             , class "focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50"
             , class "aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20 dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40"
             ]
                ++ attrs
            )
            (List.map (\(Option child) -> child) config.options)
        , Html.span
            [ attribute "data-slot" "native-select-icon"
            , attribute "aria-hidden" "true"
            , class "pointer-events-none absolute top-1/2 right-3.5 size-2 -translate-y-[75%] rotate-45 border-r-[1.5px] border-b-[1.5px] border-muted-foreground select-none"
            ]
            []
        ]


sizeName : Size -> String
sizeName size =
    case size of
        Medium ->
            "default"

        Small ->
            "sm"
