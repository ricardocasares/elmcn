module UI.ToggleGroup exposing
    ( ToggleGroup, Ready, NeedsHandler
    , new
    , onToggle
    , Item, item, label, disabled
    , items
    , pressed
    , outline
    , small, large
    , spacing, vertical
    , toHtml
    )

{-| A set of two-state buttons that can be toggled on or off.

A group is built with `new`, given an `onToggle` handler, told which values are `pressed`, filled with items, and rendered with `toHtml`:

    ToggleGroup.new
        |> ToggleGroup.onToggle FormatToggled
        |> ToggleGroup.pressed model.formats
        |> ToggleGroup.outline
        |> ToggleGroup.items
            [ ToggleGroup.item Bold [ Phosphor.textB Regular |> Phosphor.toHtml [] ]
                |> ToggleGroup.label "Toggle bold"
            , ToggleGroup.item Italic [ Phosphor.textItalic Regular |> Phosphor.toHtml [] ]
                |> ToggleGroup.label "Toggle italic"
            ]
        |> ToggleGroup.toHtml []

The pressed values live in your model, and `onToggle` tells you which item was clicked. Values can be any type that supports `==`. Whether the group allows one pressed item or many is up to your `update`. For multiple selection, add or remove the value:

    FormatToggled format ->
        if List.member format model.formats then
            { model | formats = List.filter ((/=) format) model.formats }

        else
            { model | formats = format :: model.formats }

For single selection, keep a `Maybe` and pass it with `Maybe.toList`:

    ViewChosen view ->
        { model | view = Just view }

Items are joined into one bar with `spacing 0`, and the arrow keys move focus between them (a `focusgroup`). The group is a `<div role="group">`; give it an `aria-label` when there is no visible label.

@docs ToggleGroup, Ready, NeedsHandler


# Constructor

@docs new


# Required

`toHtml` won't accept a group without a handler.

@docs onToggle


# Items

@docs Item, item, label, disabled

@docs items


# State

@docs pressed


# Variants

The variant and size apply to every item. The default variant has no border.

@docs outline


# Sizes

@docs small, large


# Layout

@docs spacing, vertical


# Rendering

@docs toHtml

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, type_)
import Html.Events exposing (onClick)
import UI.Toggle as Toggle exposing (Toggle)


{-| A toggle group being built.

`handler` is [`Ready`](#Ready) once the group has an [`onToggle`](#onToggle) handler. `a` is the type of the item values.

-}
type ToggleGroup a handler msg
    = ToggleGroup
        { onToggle : Maybe (a -> msg)
        , pressed : List a
        , variant : Variant
        , size : Size
        , spacing : Int
        , orientation : Orientation
        , items : List (Item a msg)
        }


{-| The group can be rendered.
-}
type Ready
    = Ready


{-| A group that still needs an [`onToggle`](#onToggle) handler before it can be rendered.
-}
type NeedsHandler
    = NeedsHandler


{-| A toggle in the group, made with [`item`](#item).
-}
type Item a msg
    = Item
        { value : a
        , content : List (Html msg)
        , label : Maybe String
        , disabled : Bool
        }


type Variant
    = Default
    | Outline


type Size
    = Medium
    | Small
    | Large


type Orientation
    = Horizontal
    | Vertical



-- CONSTRUCTOR


{-| An empty group with nothing pressed, at the default variant and size, with a gap of 2 between the items. Give it an [`onToggle`](#onToggle) handler to make it renderable.
-}
new : ToggleGroup a NeedsHandler msg
new =
    ToggleGroup
        { onToggle = Nothing
        , pressed = []
        , variant = Default
        , size = Medium
        , spacing = 2
        , orientation = Horizontal
        , items = []
        }



-- REQUIRED


{-| Called with the value of the item the user clicks, whether it was pressed or not.
-}
onToggle : (a -> msg) -> ToggleGroup a NeedsHandler msg -> ToggleGroup a Ready msg
onToggle toMsg (ToggleGroup config) =
    ToggleGroup { config | onToggle = Just toMsg }



-- ITEMS


{-| A toggle with the value it stands for and its content: an icon, text, or both.
-}
item : a -> List (Html msg) -> Item a msg
item value content =
    Item { value = value, content = content, label = Nothing, disabled = False }


{-| The accessible name of the item, set as `aria-label`. An icon-only item needs one.
-}
label : String -> Item a msg -> Item a msg
label name (Item config) =
    Item { config | label = Just name }


{-| Shows the item dimmed and makes it unclickable.
-}
disabled : Item a msg -> Item a msg
disabled (Item config) =
    Item { config | disabled = True }


{-| Adds items to the group, in order.
-}
items : List (Item a msg) -> ToggleGroup a handler msg -> ToggleGroup a handler msg
items list (ToggleGroup config) =
    ToggleGroup { config | items = config.items ++ list }



-- STATE


{-| The values that are on, usually from your model. The matching items are filled and have `aria-pressed="true"`.
-}
pressed : List a -> ToggleGroup a handler msg -> ToggleGroup a handler msg
pressed values (ToggleGroup config) =
    ToggleGroup { config | pressed = values }



-- VARIANTS


{-| Bordered items.
-}
outline : ToggleGroup a handler msg -> ToggleGroup a handler msg
outline (ToggleGroup config) =
    ToggleGroup { config | variant = Outline }



-- SIZES


{-| -}
small : ToggleGroup a handler msg -> ToggleGroup a handler msg
small (ToggleGroup config) =
    ToggleGroup { config | size = Small }


{-| -}
large : ToggleGroup a handler msg -> ToggleGroup a handler msg
large (ToggleGroup config) =
    ToggleGroup { config | size = Large }



-- LAYOUT


{-| The gap between the items, in Tailwind spacing units. The default is 2. With `spacing 0` the items are joined into one bar: they lose their radius and share their borders, and only the ends are rounded.
-}
spacing : Int -> ToggleGroup a handler msg -> ToggleGroup a handler msg
spacing gap (ToggleGroup config) =
    ToggleGroup { config | spacing = max 0 gap }


{-| Stacks the items instead of placing them in a row.
-}
vertical : ToggleGroup a handler msg -> ToggleGroup a handler msg
vertical (ToggleGroup config) =
    ToggleGroup { config | orientation = Vertical }



-- RENDERING


{-| Renders the `<div role="group">` with the given attributes after the styles, so they can override them, and the items as `<button type="button" aria-pressed>`s.
-}
toHtml : List (Attribute msg) -> ToggleGroup a Ready msg -> Html msg
toHtml attrs (ToggleGroup config) =
    let
        toggle =
            Toggle.new
                |> withVariant config.variant
                |> withSize config.size
    in
    Html.div
        ([ attribute "role" "group"
         , attribute "data-slot" "toggle-group"
         , attribute "data-variant" (variantName config.variant)
         , attribute "data-size" (sizeName config.size)
         , attribute "data-spacing" (String.fromInt config.spacing)
         , attribute "data-orientation" (orientationName config.orientation)
         , attribute "style" ("--gap: " ++ String.fromInt config.spacing)

         -- Arrow keys move focus between the items, and the group is one Tab stop.
         , attribute "focusgroup" (focusgroup config.orientation)
         , class "group/toggle-group flex w-fit gap-[--spacing(var(--gap))]"
         , class (orientationClass config.orientation)
         , class (radiusClass config.size)
         ]
            ++ attrs
        )
        (List.map (viewItem config toggle) config.items)


viewItem :
    { config | onToggle : Maybe (a -> msg), pressed : List a, variant : Variant, size : Size, spacing : Int, orientation : Orientation }
    -> Toggle
    -> Item a msg
    -> Html msg
viewItem config toggle (Item item_) =
    Html.button
        ([ type_ "button"
         , attribute "data-slot" "toggle-group-item"
         , attribute "data-variant" (variantName config.variant)
         , attribute "data-size" (sizeName config.size)
         , attribute "data-spacing" (String.fromInt config.spacing)
         , Html.Attributes.disabled item_.disabled
         , class "shrink-0 focus:z-10 focus-visible:z-10"
         ]
            ++ joinedClasses config
            ++ Toggle.toAttributes
                (toggle
                    |> Toggle.pressed (List.member item_.value config.pressed)
                )
            ++ List.filterMap identity
                [ Maybe.map (attribute "aria-label") item_.label
                , Maybe.map (\toMsg -> onClick (toMsg item_.value)) config.onToggle
                ]
        )
        item_.content



-- Joined items lose their radius and padding, and outline items share a border. These
-- override the toggle's own radius and padding: a utility with a variant comes after
-- the plain ones in the generated CSS, and one with more variants after one with fewer.


joinedClasses : { config | variant : Variant, spacing : Int, orientation : Orientation } -> List (Attribute msg)
joinedClasses config =
    if config.spacing > 0 then
        []

    else
        [ class "group-data-[spacing=0]/toggle-group:rounded-none group-data-[spacing=0]/toggle-group:px-2 group-data-[spacing=0]/toggle-group:has-data-[icon=inline-end]:pe-1.5 group-data-[spacing=0]/toggle-group:has-data-[icon=inline-start]:ps-1.5"
        , class
            (case config.orientation of
                Horizontal ->
                    "group-data-[spacing=0]/toggle-group:first:rounded-s-lg group-data-[spacing=0]/toggle-group:last:rounded-e-lg"

                Vertical ->
                    "group-data-[spacing=0]/toggle-group:first:rounded-t-lg group-data-[spacing=0]/toggle-group:last:rounded-b-lg"
            )
        , class
            (case ( config.variant, config.orientation ) of
                ( Outline, Horizontal ) ->
                    "group-data-[spacing=0]/toggle-group:border-s-0 group-data-[spacing=0]/toggle-group:first:border-s"

                ( Outline, Vertical ) ->
                    "group-data-[spacing=0]/toggle-group:border-t-0 group-data-[spacing=0]/toggle-group:first:border-t"

                ( Default, _ ) ->
                    ""
            )
        ]


withVariant : Variant -> Toggle -> Toggle
withVariant variant =
    case variant of
        Default ->
            identity

        Outline ->
            Toggle.outline


withSize : Size -> Toggle -> Toggle
withSize size =
    case size of
        Medium ->
            identity

        Small ->
            Toggle.small

        Large ->
            Toggle.large


orientationClass : Orientation -> String
orientationClass orientation =
    case orientation of
        Horizontal ->
            "flex-row items-center"

        Vertical ->
            "flex-col items-stretch"


radiusClass : Size -> String
radiusClass size =
    case size of
        Small ->
            "rounded-[min(var(--radius-md),10px)]"

        _ ->
            "rounded-lg"


focusgroup : Orientation -> String
focusgroup orientation =
    case orientation of
        Horizontal ->
            "toolbar inline wrap"

        Vertical ->
            "toolbar block wrap"


variantName : Variant -> String
variantName variant =
    case variant of
        Default ->
            "default"

        Outline ->
            "outline"


sizeName : Size -> String
sizeName size =
    case size of
        Medium ->
            "default"

        Small ->
            "sm"

        Large ->
            "lg"


orientationName : Orientation -> String
orientationName orientation =
    case orientation of
        Horizontal ->
            "horizontal"

        Vertical ->
            "vertical"
