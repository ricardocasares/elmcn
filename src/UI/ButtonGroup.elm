module UI.ButtonGroup exposing
    ( ButtonGroup
    , new
    , vertical
    , toHtml
    , text, label, separator
    )

{-| A container that groups related buttons together with consistent styling.

A group is built with `new`, optionally made `vertical`, and rendered with `toHtml` around its children:

    ButtonGroup.new
        |> ButtonGroup.toHtml []
            [ Button.new
                |> Button.text "Archive"
                |> Button.outline
                |> Button.toHtml []
            , Button.new
                |> Button.text "Report"
                |> Button.outline
                |> Button.toHtml []
            ]

The children are joined into one bar: they lose the radius where they meet, share their borders, and only the ends stay rounded. Any child with a `data-slot` attribute takes part, so a `Button`, an `Input`, an `InputGroup`, a `Select` or a `Popover` trigger can sit next to each other. Buttons without a border, such as `secondary` ones, are divided with a [`separator`](#separator).

Groups nest. A group whose children are groups gets a gap between them instead, which makes a toolbar of joined bars:

    ButtonGroup.new
        |> ButtonGroup.toHtml []
            [ ButtonGroup.new
                |> ButtonGroup.toHtml [] [ previous, next ]
            , ButtonGroup.new
                |> ButtonGroup.toHtml [] [ more ]
            ]

The group is a `<div role="group">`. Give it an `aria-label` or `aria-labelledby` when there is no visible label. Use a `ToggleGroup` instead when the buttons toggle a state rather than perform an action.

@docs ButtonGroup


# Constructor

@docs new


# Orientation

@docs vertical


# Rendering

@docs toHtml


# Parts

Cells that are not buttons, rendered inside the group's children.

@docs text, label, separator

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)


{-| A button group being built.
-}
type ButtonGroup
    = ButtonGroup { orientation : Orientation }


type Orientation
    = Horizontal
    | Vertical



-- CONSTRUCTOR


{-| A horizontal group.
-}
new : ButtonGroup
new =
    ButtonGroup { orientation = Horizontal }



-- ORIENTATION


{-| Stacks the children instead of placing them in a row.
-}
vertical : ButtonGroup -> ButtonGroup
vertical (ButtonGroup config) =
    ButtonGroup { config | orientation = Vertical }



-- RENDERING


{-| Renders the `<div role="group">` with the given attributes after the styles, so they can override them, and the children in order.
-}
toHtml : List (Attribute msg) -> List (Html msg) -> ButtonGroup -> Html msg
toHtml attrs children (ButtonGroup config) =
    Html.div
        ([ attribute "role" "group"
         , attribute "data-slot" "button-group"
         , attribute "data-orientation" (orientationName config.orientation)
         , class "flex w-fit items-stretch has-[>[data-slot=button-group]]:gap-2 *:focus-visible:relative *:focus-visible:z-10 [&>input]:flex-1"

         -- A select's or a popover's trigger sits inside a wrapper, so it is joined and raised on focus by its own rules.
         , class "[&>[data-slot=select]>[data-slot=select-trigger]:focus-visible]:relative [&>[data-slot=select]>[data-slot=select-trigger]:focus-visible]:z-10"
         , class "[&>[data-slot=popover]>[data-slot=popover-trigger]:focus-visible]:relative [&>[data-slot=popover]>[data-slot=popover-trigger]:focus-visible]:z-10"
         , class (orientationClass config.orientation)
         ]
            ++ attrs
        )
        children



-- Children lose their radius where they meet and share their borders. The last child
-- with a `data-slot` gets the end radius back with `!`, since the first rule took it
-- away. These override the children's own radius: a selector with a parent has a
-- higher specificity than the child's single class.


orientationClass : Orientation -> String
orientationClass orientation =
    case orientation of
        Horizontal ->
            "*:data-slot:rounded-e-none [&>[data-slot]~[data-slot]]:rounded-s-none [&>[data-slot]~[data-slot]]:border-s-0 [&>[data-slot]:not(:has(~[data-slot]))]:rounded-e-lg!"
                ++ " [&>[data-slot=select]>[data-slot=select-trigger]]:rounded-e-none [&>[data-slot]~[data-slot=select]>[data-slot=select-trigger]]:rounded-s-none [&>[data-slot]~[data-slot=select]>[data-slot=select-trigger]]:border-s-0 [&>[data-slot=select]:not(:has(~[data-slot]))>[data-slot=select-trigger]]:rounded-e-lg!"
                ++ " [&>[data-slot=popover]>[data-slot=popover-trigger]]:rounded-e-none [&>[data-slot]~[data-slot=popover]>[data-slot=popover-trigger]]:rounded-s-none [&>[data-slot]~[data-slot=popover]>[data-slot=popover-trigger]]:border-s-0 [&>[data-slot=popover]:not(:has(~[data-slot]))>[data-slot=popover-trigger]]:rounded-e-lg!"

        Vertical ->
            "flex-col *:data-slot:rounded-b-none [&>[data-slot]~[data-slot]]:rounded-t-none [&>[data-slot]~[data-slot]]:border-t-0 [&>[data-slot]:not(:has(~[data-slot]))]:rounded-b-lg!"
                ++ " [&>[data-slot=select]>[data-slot=select-trigger]]:rounded-b-none [&>[data-slot]~[data-slot=select]>[data-slot=select-trigger]]:rounded-t-none [&>[data-slot]~[data-slot=select]>[data-slot=select-trigger]]:border-t-0 [&>[data-slot=select]:not(:has(~[data-slot]))>[data-slot=select-trigger]]:rounded-b-lg!"
                ++ " [&>[data-slot=popover]>[data-slot=popover-trigger]]:rounded-b-none [&>[data-slot]~[data-slot=popover]>[data-slot=popover-trigger]]:rounded-t-none [&>[data-slot]~[data-slot=popover]>[data-slot=popover-trigger]]:border-t-0 [&>[data-slot=popover]:not(:has(~[data-slot]))>[data-slot=popover-trigger]]:rounded-b-lg!"


orientationName : Orientation -> String
orientationName orientation =
    case orientation of
        Horizontal ->
            "horizontal"

        Vertical ->
            "vertical"



-- PARTS


{-| A static cell: muted, bordered text that lines up with the buttons, such as a prefix or a unit. An icon inside it is sized to match.

    ButtonGroup.text [] [ Html.text "https://" ]

-}
text : List (Attribute msg) -> List (Html msg) -> Html msg
text attrs children =
    Html.div (textAttributes ++ attrs) children


{-| The same cell as a `<label>`, for naming the control next to it. Pass `for` with the control's `id`.

    ButtonGroup.label [ for "gpu-size" ] [ Html.text "GPU Size" ]

-}
label : List (Attribute msg) -> List (Html msg) -> Html msg
label attrs children =
    Html.label (textAttributes ++ attrs) children


textAttributes : List (Attribute msg)
textAttributes =
    [ attribute "data-slot" "button-group-text"
    , class "flex items-center gap-2 rounded-lg border bg-muted px-2.5 text-sm font-medium [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4"
    ]


{-| A line between two children, for buttons that have no border of their own. It runs across the group, so it follows the group's orientation.

    ButtonGroup.new
        |> ButtonGroup.toHtml []
            [ Button.new
                |> Button.text "Copy"
                |> Button.secondary
                |> Button.toHtml []
            , ButtonGroup.separator []
            , Button.new
                |> Button.text "Paste"
                |> Button.secondary
                |> Button.toHtml []
            ]

-}
separator : List (Attribute msg) -> Html msg
separator attrs =
    Html.div
        ([ attribute "data-slot" "button-group-separator"
         , attribute "role" "none"
         , class "relative mx-px w-px shrink-0 self-stretch bg-input [[data-orientation=vertical]>&]:mx-0 [[data-orientation=vertical]>&]:my-px [[data-orientation=vertical]>&]:h-px [[data-orientation=vertical]>&]:w-auto"
         ]
            ++ attrs
        )
        []
