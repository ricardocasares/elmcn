module UI.Select exposing
    ( Select, Ready, NeedsId, NeedsHandler
    , new
    , id, onSelect
    , Item, item, disabled
    , items, group
    , placeholder, value
    , small
    , toHtml
    )

{-| Displays a list of options for the user to pick from, triggered by a button.

A select is built with `new`, given an `id` and an `onSelect` handler, filled with items, and rendered with `toHtml`:

    Select.new
        |> Select.id "fruit"
        |> Select.onSelect FruitChosen
        |> Select.placeholder "Select a fruit"
        |> Select.value model.fruit
        |> Select.items
            [ Select.item Apple [ text "Apple" ]
            , Select.item Banana [ text "Banana" ]
            , Select.item Grapes [ text "Grapes" ] |> Select.disabled
            ]
        |> Select.toHtml []

The selected value lives in your model, and `onSelect` tells you when it changes. Values can be any type that supports `==`.

The list is a native popover anchored to the trigger with CSS anchor positioning, so it opens, closes on Escape or a click outside, and flips when there is no room below, with no JavaScript, ports or component state. The `id` is required because the trigger and the popover find each other by it.

@docs Select, Ready, NeedsId, NeedsHandler


# Constructor

@docs new


# Required

`toHtml` won't accept a select until it has both.

@docs id, onSelect


# Items

@docs Item, item, disabled

Items are added in groups. Consecutive groups are separated by a line.

@docs items, group


# Value

@docs placeholder, value


# Sizes

@docs small


# Rendering

@docs toHtml

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, type_)
import Html.Events exposing (onClick)


{-| A select being built.

`id` is [`Ready`](#Ready) once the select has an [`id`](#id), and `handler` is [`Ready`](#Ready) once it has an [`onSelect`](#onSelect) handler. `a` is the type of the item values.

-}
type Select a id handler msg
    = Select
        { id : String
        , onSelect : Maybe (a -> msg)
        , placeholder : String
        , value : Maybe a
        , size : Size
        , groups : List (Group a msg)
        }


{-| The select can be rendered.
-}
type Ready
    = Ready


{-| A select that still needs an [`id`](#id) before it can be rendered.
-}
type NeedsId
    = NeedsId


{-| A select that still needs an [`onSelect`](#onSelect) handler before it can be rendered.
-}
type NeedsHandler
    = NeedsHandler


{-| An option in the list, made with [`item`](#item).
-}
type Item a msg
    = Item
        { value : a
        , label : List (Html msg)
        , disabled : Bool
        }


type Group a msg
    = Group (Maybe String) (List (Item a msg))


type Size
    = Medium
    | Small



-- CONSTRUCTOR


{-| An empty select. Give it an [`id`](#id) and an [`onSelect`](#onSelect) handler to make it renderable.
-}
new : Select a NeedsId NeedsHandler msg
new =
    Select
        { id = ""
        , onSelect = Nothing
        , placeholder = ""
        , value = Nothing
        , size = Medium
        , groups = []
        }



-- REQUIRED


{-| The `id` of the trigger button, so a `Label.view [ for "…" ]` can point at it. It must be unique on the page: the popover is named after it.
-}
id : String -> Select a NeedsId handler msg -> Select a Ready handler msg
id string (Select config) =
    Select { config | id = string }


{-| Called with the value of the item the user picks.
-}
onSelect : (a -> msg) -> Select a id NeedsHandler msg -> Select a id Ready msg
onSelect toMsg (Select config) =
    Select { config | onSelect = Just toMsg }



-- ITEMS


{-| An option with the value it stands for and its label. The label is shown in the list and, when selected, in the trigger.
-}
item : a -> List (Html msg) -> Item a msg
item v label =
    Item { value = v, label = label, disabled = False }


{-| Shows the item dimmed and makes it unselectable.
-}
disabled : Item a msg -> Item a msg
disabled (Item config) =
    Item { config | disabled = True }


{-| Adds a group of items without a heading.
-}
items : List (Item a msg) -> Select a id handler msg -> Select a id handler msg
items list (Select config) =
    Select { config | groups = config.groups ++ [ Group Nothing list ] }


{-| Adds a group of items under a heading.
-}
group : String -> List (Item a msg) -> Select a id handler msg -> Select a id handler msg
group label list (Select config) =
    Select { config | groups = config.groups ++ [ Group (Just label) list ] }



-- VALUE


{-| Shown in the trigger while nothing is selected.
-}
placeholder : String -> Select a id handler msg -> Select a id handler msg
placeholder string (Select config) =
    Select { config | placeholder = string }


{-| The selected value, usually from your model. The matching item's label is shown in the trigger and the item is marked in the list.
-}
value : Maybe a -> Select a id handler msg -> Select a id handler msg
value v (Select config) =
    Select { config | value = v }



-- SIZES


{-| -}
small : Select a id handler msg -> Select a id handler msg
small (Select config) =
    Select { config | size = Small }



-- RENDERING


{-| Renders the trigger `<button>` with the given attributes after the styles, so they can override them, followed by the popover with the list. Pass `disabled True` to disable the whole select, or `aria-invalid` to show the error state.
-}
toHtml : List (Attribute msg) -> Select a Ready Ready msg -> Html msg
toHtml attrs (Select config) =
    let
        popoverId =
            config.id ++ "-popover"

        anchor =
            "--select-" ++ config.id

        selected =
            config.groups
                |> List.concatMap (\(Group _ list) -> list)
                |> List.filter (\(Item i) -> Just i.value == config.value)
                |> List.head
    in
    Html.span
        [ attribute "data-slot" "select", class "contents" ]
        [ Html.button
            ([ type_ "button"
             , Html.Attributes.id config.id
             , attribute "popovertarget" popoverId
             , attribute "data-slot" "select-trigger"
             , attribute "data-size" (sizeName config.size)
             , attribute "style" ("anchor-name: " ++ anchor)
             , class "flex w-fit items-center justify-between gap-1.5 rounded-lg border border-input bg-transparent py-2 pr-2 pl-2.5 text-sm whitespace-nowrap transition-colors outline-none select-none disabled:cursor-not-allowed disabled:opacity-50 data-[size=default]:h-8 data-[size=sm]:h-7 data-[size=sm]:rounded-[min(var(--radius-md),10px)] data-placeholder:text-muted-foreground dark:bg-input/30 dark:hover:bg-input/50 *:data-[slot=select-value]:line-clamp-1 *:data-[slot=select-value]:flex *:data-[slot=select-value]:items-center *:data-[slot=select-value]:gap-1.5 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
             , class "focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50"
             , class "aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20 dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40"
             ]
                ++ (case selected of
                        Nothing ->
                            [ attribute "data-placeholder" "" ]

                        Just _ ->
                            []
                   )
                ++ attrs
            )
            [ Html.span [ attribute "data-slot" "select-value", class "flex flex-1 text-left" ]
                (case selected of
                    Just (Item i) ->
                        i.label

                    Nothing ->
                        [ Html.text config.placeholder ]
                )
            , Html.span
                [ attribute "data-slot" "select-trigger-icon"
                , attribute "aria-hidden" "true"
                , class "pointer-events-none flex size-4 items-center justify-center text-muted-foreground"
                ]
                [ Html.span [ class "mb-1 size-2 rotate-45 border-r-[1.5px] border-b-[1.5px] border-current" ] [] ]
            ]
        , Html.div
            [ Html.Attributes.id popoverId
            , attribute "popover" "auto"
            , attribute "role" "listbox"
            , attribute "aria-labelledby" config.id
            , attribute "data-slot" "select-content"
            , attribute "style" ("position-anchor: " ++ anchor)
            , class "fixed isolate z-50 m-0 inset-auto min-w-36 w-[anchor-size(width)] max-h-[calc(100%-0.5rem)] overflow-x-hidden overflow-y-auto rounded-lg border-0 p-0 text-popover-foreground shadow-md ring-1 ring-foreground/10 [position-area:bottom] [position-try-fallbacks:flip-block] [position-try-order:most-block-size] mt-1"
            , class "origin-top scale-95 opacity-0 transition-[opacity,scale,display,overlay] transition-discrete duration-100 ease-out open:scale-100 open:opacity-100 starting:open:scale-95 starting:open:opacity-0"
            , class "bg-popover/70 before:pointer-events-none before:absolute before:inset-0 before:-z-1 before:rounded-[inherit] before:backdrop-blur-2xl before:backdrop-saturate-150"
            ]
            (config.groups
                |> List.map (viewGroup popoverId config.onSelect config.value)
                |> List.intersperse separator
            )
        ]


viewGroup : String -> Maybe (a -> msg) -> Maybe a -> Group a msg -> Html msg
viewGroup popoverId handler current (Group label list) =
    Html.div
        [ attribute "data-slot" "select-group"
        , attribute "role" "group"
        , class "scroll-my-1 p-1"
        ]
        ((case label of
            Just string ->
                [ Html.div
                    [ attribute "data-slot" "select-label"
                    , class "px-1.5 py-1 text-xs text-muted-foreground"
                    ]
                    [ Html.text string ]
                ]

            Nothing ->
                []
         )
            ++ List.map (viewItem popoverId handler current) list
        )


viewItem : String -> Maybe (a -> msg) -> Maybe a -> Item a msg -> Html msg
viewItem popoverId handler current (Item config) =
    let
        isSelected =
            Just config.value == current
    in
    Html.button
        ([ type_ "button"
         , attribute "role" "option"
         , attribute "aria-selected" (boolean isSelected)
         , attribute "data-slot" "select-item"
         , attribute "popovertarget" popoverId
         , attribute "popovertargetaction" "hide"
         , Html.Attributes.disabled config.disabled
         , class "relative flex w-full cursor-default items-center gap-1.5 rounded-md py-1 pr-8 pl-1.5 text-left text-sm outline-hidden select-none hover:bg-foreground/10 focus:bg-foreground/10 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
         ]
            ++ (case handler of
                    Just toMsg ->
                        [ onClick (toMsg config.value) ]

                    Nothing ->
                        []
               )
        )
        [ Html.span [ attribute "data-slot" "select-item-text", class "flex flex-1 gap-2" ] config.label
        , Html.span
            [ attribute "data-slot" "select-item-indicator"
            , attribute "aria-hidden" "true"
            , class "pointer-events-none absolute right-2 flex size-4 items-center justify-center"
            , class
                (if isSelected then
                    "visible"

                 else
                    "invisible"
                )
            ]
            [ Html.span [ class "mb-0.5 h-2.5 w-1.5 rotate-45 border-r-[1.5px] border-b-[1.5px] border-current" ] [] ]
        ]


separator : Html msg
separator =
    Html.div
        [ attribute "data-slot" "select-separator"
        , attribute "role" "separator"
        , class "pointer-events-none my-1 h-px bg-border"
        ]
        []


boolean : Bool -> String
boolean b =
    if b then
        "true"

    else
        "false"


sizeName : Size -> String
sizeName size =
    case size of
        Medium ->
            "default"

        Small ->
            "sm"
