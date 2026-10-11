module UI.Field exposing
    ( view, horizontal, responsive
    , label, title, description, content
    , error, errors
    , set, legend, smallLegend, group, separator
    , invalid, disabled
    )

{-| Combines labels, controls, and help text to compose accessible form fields and grouped inputs.

A field is a label, a control and optional help text, stacked by default:

    Field.view []
        [ Field.label [ for "username" ] [ text "Username" ]
        , Input.view [ id "username", placeholder "Max Leiter" ]
        , Field.description [] [ text "Choose a unique username for your account." ]
        ]

Every part is a plain function from attributes and children to `Html`, so fields nest and combine freely. `horizontal` puts the control beside the label, which suits a checkbox or a switch, and `content` keeps a label and its description together on one side:

    Field.horizontal []
        [ Checkbox.view [ id "newsletter" ]
        , Field.content []
            [ Field.label [ for "newsletter" ] [ text "Subscribe to newsletter" ]
            , Field.description [] [ text "Receive weekly updates about new features." ]
            ]
        ]

A `label` wrapped around a `horizontal` field becomes a choice card, a bordered box that is selected as a whole:

    Field.label [ for "kubernetes" ]
        [ Field.horizontal []
            [ Field.content []
                [ Field.title [] [ text "Kubernetes" ]
                , Field.description [] [ text "Run GPU workloads on a K8s cluster." ]
                ]
            , RadioGroup.item [ id "kubernetes", name "env" ]
            ]
        ]

Mark a field `invalid` and the control `aria-invalid` to show an error:

    Field.view [ Field.invalid ]
        [ Field.label [ for "email" ] [ text "Email" ]
        , Input.view [ id "email", type_ "email", attribute "aria-invalid" "true" ]
        , Field.error [] [ text "Enter a valid email address." ]
        ]


# Field

@docs view, horizontal, responsive


# Parts

@docs label, title, description, content


# Errors

@docs error, errors


# Grouping

@docs set, legend, smallLegend, group, separator


# States

@docs invalid, disabled

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)
import UI.Label as Label
import UI.Separator as Separator



-- FIELD


{-| A field with its parts stacked. It is a `role="group"`.
-}
view : List (Attribute msg) -> List (Html msg) -> Html msg
view =
    field "vertical" "flex-col *:w-full [&>.sr-only]:w-auto"


{-| A field with its parts in a row, for a checkbox, a radio or a switch beside its label. With `content` inside, the control aligns to the first line of text.
-}
horizontal : List (Attribute msg) -> List (Html msg) -> Html msg
horizontal =
    field "horizontal" ("flex-row items-center has-[>[data-slot=field-content]]:items-start *:data-[slot=field-label]:flex-auto " ++ controlOffset "")


{-| Stacked when narrow, in a row once the enclosing `group` is at least `md` wide.
-}
responsive : List (Attribute msg) -> List (Html msg) -> Html msg
responsive =
    field "responsive" ("flex-col *:w-full [&>.sr-only]:w-auto @md/field-group:flex-row @md/field-group:items-center @md/field-group:*:w-auto @md/field-group:has-[>[data-slot=field-content]]:items-start @md/field-group:*:data-[slot=field-label]:flex-auto " ++ controlOffset "@md/field-group:")


field : String -> String -> List (Attribute msg) -> List (Html msg) -> Html msg
field orientation classes attrs children =
    Html.div
        ([ attribute "role" "group"
         , attribute "data-slot" "field"
         , attribute "data-orientation" orientation
         , class "group/field flex w-full gap-2 data-[invalid=true]:text-destructive"
         , class classes
         ]
            ++ attrs
        )
        children


{-| Nudges a checkbox or a radio down a pixel so it sits on the first line of the content beside it.
-}
controlOffset : String -> String
controlOffset prefix =
    prefix ++ "has-[>[data-slot=field-content]]:[&>:has(>[data-slot=checkbox])]:mt-px " ++ prefix ++ "has-[>[data-slot=field-content]]:[&>:has(>[data-slot=radio-group-item])]:mt-px"



-- PARTS


{-| The label of the field, a `<label>`. Point `for` at the control's `id`.
-}
label : List (Attribute msg) -> List (Html msg) -> Html msg
label attrs children =
    Label.view
        ([ attribute "data-slot" "field-label"
         , class "group/field-label peer/field-label flex w-fit gap-2 leading-snug group-data-[disabled=true]/field:opacity-50"
         , class "has-[>[data-slot=field]]:w-full has-[>[data-slot=field]]:flex-col has-[>[data-slot=field]]:rounded-lg has-[>[data-slot=field]]:border has-[>[data-slot=field]]:not-has-[:disabled,[data-disabled]]:hover:bg-muted/50 has-[>[data-slot=field]]:has-[:focus-visible]:border-ring has-[>[data-slot=field]]:has-[:focus-visible]:ring-3 has-[>[data-slot=field]]:has-[:focus-visible]:ring-ring/50 *:data-[slot=field]:p-2.5"
         , class "has-checked:border-primary/30 has-checked:bg-primary/5 dark:has-checked:border-primary/20 dark:has-checked:bg-primary/10"
         ]
            ++ attrs
        )
        children


{-| Looks like a label but is a `<div>`, for a field that already sits inside a `label`, or whose control has no `id` to point at.
-}
title : List (Attribute msg) -> List (Html msg) -> Html msg
title attrs children =
    Html.div
        (attribute "data-slot" "field-label"
            :: class "flex w-fit items-center gap-2 text-sm leading-snug font-medium group-data-[disabled=true]/field:opacity-50"
            :: attrs
        )
        children


{-| Help text, a `<p>`. It can go before or after the control. Links inside it are underlined.
-}
description : List (Attribute msg) -> List (Html msg) -> Html msg
description attrs children =
    Html.p
        (attribute "data-slot" "field-description"
            :: class "text-left text-sm leading-normal font-normal text-muted-foreground group-data-[orientation=horizontal]/field:text-balance last:mt-0 nth-last-2:-mt-1 [[data-variant=legend]+&]:-mt-1.5 [&>a]:underline [&>a]:underline-offset-4 [&>a:hover]:text-primary"
            :: attrs
        )
        children


{-| Keeps a `label` or `title` and its `description` together, taking the space the control leaves in a `horizontal` field.
-}
content : List (Attribute msg) -> List (Html msg) -> Html msg
content attrs children =
    Html.div
        (attribute "data-slot" "field-content"
            :: class "group/field-content flex flex-1 flex-col gap-0.5 leading-snug"
            :: attrs
        )
        children



-- ERRORS


{-| A validation message, announced as an alert.
-}
error : List (Attribute msg) -> List (Html msg) -> Html msg
error attrs children =
    Html.div
        (attribute "role" "alert"
            :: attribute "data-slot" "field-error"
            :: class "text-sm font-normal text-destructive"
            :: attrs
        )
        children


{-| Shows a list of messages as an `error`: nothing when the list is empty, the message alone when there is one, and a bulleted list otherwise. Repeated messages are shown once.
-}
errors : List (Attribute msg) -> List String -> Html msg
errors attrs messages =
    case unique messages of
        [] ->
            Html.text ""

        [ message ] ->
            error attrs [ Html.text message ]

        unique_ ->
            error attrs
                [ Html.ul [ class "ml-4 flex list-disc flex-col gap-1" ]
                    (List.map (\message -> Html.li [] [ Html.text message ]) unique_)
                ]


unique : List String -> List String
unique =
    List.foldr
        (\message acc ->
            if List.member message acc then
                acc

            else
                message :: acc
        )
        []



-- GROUPING


{-| A `<fieldset>` for related fields, with a `legend` and optional `description` first.
-}
set : List (Attribute msg) -> List (Html msg) -> Html msg
set attrs children =
    Html.fieldset
        (attribute "data-slot" "field-set"
            :: class "flex flex-col gap-4 has-[>[data-slot=checkbox-group]]:gap-3 has-[>[data-slot=radio-group]]:gap-3"
            :: attrs
        )
        children


{-| The heading of a `set`.
-}
legend : List (Attribute msg) -> List (Html msg) -> Html msg
legend =
    legendWith "legend" "text-base"


{-| A `legend` the size of a label, for a set of checkboxes or radios.
-}
smallLegend : List (Attribute msg) -> List (Html msg) -> Html msg
smallLegend =
    legendWith "label" "text-sm"


legendWith : String -> String -> List (Attribute msg) -> List (Html msg) -> Html msg
legendWith variant classes attrs children =
    Html.legend
        (attribute "data-slot" "field-legend"
            :: attribute "data-variant" variant
            :: class "mb-1.5 font-medium"
            :: class classes
            :: attrs
        )
        children


{-| Spaces out fields, sets and separators. It is a container query root, which `responsive` fields watch.
-}
group : List (Attribute msg) -> List (Html msg) -> Html msg
group attrs children =
    Html.div
        (attribute "data-slot" "field-group"
            :: class "group/field-group @container/field-group flex w-full flex-col gap-5 data-[slot=checkbox-group]:gap-3 *:data-[slot=field-group]:gap-4"
            :: attrs
        )
        children


{-| A line between the items of a `group`. Children, if any, sit in the middle of the line:

    Field.separator [] [ text "Or continue with" ]

-}
separator : List (Attribute msg) -> List (Html msg) -> Html msg
separator attrs children =
    Html.div
        (attribute "data-slot" "field-separator"
            :: attribute "data-content" (boolName (not (List.isEmpty children)))
            :: class "relative -my-2 h-5 text-sm group-data-[variant=outline]/field-group:-mb-2"
            :: attrs
        )
        (List.filterMap identity
            [ Just (Separator.toHtml [ class "absolute inset-0 top-1/2" ] Separator.new)
            , if List.isEmpty children then
                Nothing

              else
                Just
                    (Html.span
                        [ attribute "data-slot" "field-separator-content"
                        , class "relative mx-auto block w-fit bg-background px-2 text-muted-foreground"
                        ]
                        children
                    )
            ]
        )


boolName : Bool -> String
boolName bool =
    if bool then
        "true"

    else
        "false"



-- STATES


{-| Turns the field's text red. Put it on the field and `aria-invalid` on the control.
-}
invalid : Attribute msg
invalid =
    attribute "data-invalid" "true"


{-| Dims the field's label. Put it on the field and `disabled` on the control.
-}
disabled : Attribute msg
disabled =
    attribute "data-disabled" "true"
