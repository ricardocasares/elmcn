module UI.Accordion exposing
    ( Accordion, Ready, NeedsId
    , new
    , id
    , Item, item, open, disabled, onToggle, attributes
    , items
    , multiple
    , toHtml
    )

{-| A vertically stacked set of interactive headings that each reveal a section of content.

An accordion is built with `new`, given an `id`, filled with items, and rendered with `toHtml`:

    Accordion.new
        |> Accordion.id "faq"
        |> Accordion.items
            [ Accordion.item [ text "Is it accessible?" ]
                [ text "Yes. It adheres to the WAI-ARIA design pattern." ]
            , Accordion.item [ text "Is it styled?" ]
                [ text "Yes. It comes with default styles that match the other components." ]
                |> Accordion.open
            ]
        |> Accordion.toHtml [ class "max-w-lg" ]

Each item is a native `<details>` with a `<summary>` trigger, so it opens and closes, is reached with Tab and toggled with Enter or Space, and only one item stays open at a time (the items share a `name`, which is why the `id` is required) with no JavaScript, ports or component state. Use `multiple` to let several items stay open at once.

The open state lives in the browser. Give an item `open` to render it open, and `onToggle` to be told when the user opens or closes it, for example to keep the state in your model.

Opening and closing animates the height with a `grid-template-rows` transition on `::details-content`, which works in Chrome, Safari and Firefox; browsers without `::details-content` toggle instantly. The content stays visible while it collapses and is hidden, and taken out of the tab order, once closed.

@docs Accordion, Ready, NeedsId


# Constructor

@docs new


# Required

`toHtml` won't accept an accordion until it has an `id`.

@docs id


# Items

@docs Item, item, open, disabled, onToggle, attributes

@docs items


# Setters

@docs multiple


# Rendering

@docs toHtml

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, name, property, tabindex)
import Html.Events
import Json.Decode as Decode
import Json.Encode as Encode


{-| An accordion being built.

`id` is [`Ready`](#Ready) once the accordion has an [`id`](#id).

-}
type Accordion id msg
    = Accordion
        { id : String
        , mode : Mode
        , items : List (Item msg)
        }


{-| The accordion can be rendered.
-}
type Ready
    = Ready


{-| An accordion that still needs an [`id`](#id) before it can be rendered.
-}
type NeedsId
    = NeedsId


{-| A section of the accordion, made with [`item`](#item).
-}
type Item msg
    = Item
        { trigger : List (Html msg)
        , content : List (Html msg)
        , open : Bool
        , disabled : Bool
        , onToggle : Maybe (Bool -> msg)
        , attributes : List (Attribute msg)
        }


type Mode
    = Single
    | Multiple



-- CONSTRUCTOR


{-| An empty accordion. Give it an [`id`](#id) to make it renderable.
-}
new : Accordion NeedsId msg
new =
    Accordion
        { id = ""
        , mode = Single
        , items = []
        }



-- REQUIRED


{-| The `id` of the accordion. It must be unique on the page: the items are grouped under it so that opening one closes the others.
-}
id : String -> Accordion NeedsId msg -> Accordion Ready msg
id string (Accordion config) =
    Accordion { config | id = string }



-- ITEMS


{-| A section with the heading that toggles it and the content it reveals.
-}
item : List (Html msg) -> List (Html msg) -> Item msg
item trigger content =
    Item
        { trigger = trigger
        , content = content
        , open = False
        , disabled = False
        , onToggle = Nothing
        , attributes = []
        }


{-| Renders the item open. In a single-open accordion the browser keeps only the last open item open.
-}
open : Item msg -> Item msg
open (Item config) =
    Item { config | open = True }


{-| Shows the heading dimmed and keeps the item from being toggled.
-}
disabled : Item msg -> Item msg
disabled (Item config) =
    Item { config | disabled = True }


{-| Called with `True` when the user opens the item and `False` when they close it, including when another item opening closes this one.
-}
onToggle : (Bool -> msg) -> Item msg -> Item msg
onToggle toMsg (Item config) =
    Item { config | onToggle = Just toMsg }


{-| Attributes for the item, after the styles so they can override them. Pass `px-2.5` to inset the heading and content, or `open:bg-muted/50` to highlight the item while it is open.
-}
attributes : List (Attribute msg) -> Item msg -> Item msg
attributes attrs (Item config) =
    Item { config | attributes = attrs }


{-| The sections, in order.
-}
items : List (Item msg) -> Accordion id msg -> Accordion id msg
items list (Accordion config) =
    Accordion { config | items = list }



-- SETTERS


{-| Lets several items be open at once instead of closing the others when one opens.
-}
multiple : Accordion id msg -> Accordion id msg
multiple (Accordion config) =
    Accordion { config | mode = Multiple }



-- RENDERING


{-| Renders the accordion with the given attributes after the styles, so they can override them. Pass a width such as `class "max-w-lg"`, or `class "gap-2"` with bordered items to space them out.
-}
toHtml : List (Attribute msg) -> Accordion Ready msg -> Html msg
toHtml attrs (Accordion config) =
    Html.div
        ([ attribute "data-slot" "accordion"
         , class "flex w-full flex-col"
         ]
            ++ attrs
        )
        (List.map (viewItem config.id config.mode) config.items)


viewItem : String -> Mode -> Item msg -> Html msg
viewItem groupId mode (Item config) =
    Html.details
        ([ attribute "data-slot" "accordion-item"
         , property "open" (Encode.bool config.open)
         , class "group/accordion-item not-last:border-b details-content:grid details-content:grid-rows-[0fr] details-content:[content-visibility:visible] details-content:transition-[grid-template-rows] details-content:duration-200 details-content:ease-out open:details-content:grid-rows-[1fr]"
         ]
            ++ (case mode of
                    Single ->
                        [ name groupId ]

                    Multiple ->
                        []
               )
            ++ (if config.disabled then
                    [ attribute "data-disabled" "" ]

                else
                    []
               )
            ++ (case config.onToggle of
                    Just toMsg ->
                        [ Html.Events.on "toggle" (Decode.map toMsg (Decode.at [ "target", "open" ] Decode.bool)) ]

                    Nothing ->
                        []
               )
            ++ config.attributes
        )
        [ Html.summary
            ([ attribute "data-slot" "accordion-trigger"
             , class "group/accordion-trigger relative flex flex-1 cursor-pointer list-none items-start justify-between rounded-lg border border-transparent py-2.5 text-left text-sm font-medium transition-all outline-none hover:underline focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50 focus-visible:after:border-ring aria-disabled:pointer-events-none aria-disabled:opacity-50 **:data-[slot=accordion-trigger-icon]:ml-auto **:data-[slot=accordion-trigger-icon]:size-4 **:data-[slot=accordion-trigger-icon]:text-muted-foreground [&::-webkit-details-marker]:hidden"
             ]
                ++ (if config.disabled then
                        [ attribute "aria-disabled" "true", tabindex -1 ]

                    else
                        []
                   )
            )
            (config.trigger
                ++ [ Html.span
                        [ attribute "data-slot" "accordion-trigger-icon"
                        , attribute "aria-hidden" "true"
                        , class "pointer-events-none flex shrink-0 items-center justify-center transition-transform duration-200 group-open/accordion-item:rotate-180"
                        ]
                        [ Html.span [ class "mb-1 size-2 rotate-45 border-r-[1.5px] border-b-[1.5px] border-current" ] [] ]
                   ]
            )
        , Html.div
            [ attribute "data-slot" "accordion-content"
            , class "invisible min-h-0 overflow-hidden text-sm transition-[visibility] duration-200 group-open/accordion-item:visible"
            ]
            [ Html.div
                [ attribute "data-slot" "accordion-content-inner"
                , class "pt-0 pb-2.5 [&_a]:underline [&_a]:underline-offset-3 [&_a]:hover:text-foreground [&_p:not(:last-child)]:mb-4"
                ]
                config.content
            ]
        ]
