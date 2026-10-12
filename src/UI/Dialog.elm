module UI.Dialog exposing
    ( Dialog, Ready, NeedsId
    , new
    , id
    , trigger, opens, closes
    , title, description, content, footer
    , hideCloseButton, onClose
    , toHtml
    )

{-| A window overlaid on either the primary window or another dialog window, rendering the content underneath inert.

A dialog is built with `new`, given an `id` and a `trigger`, filled in with parts, and rendered with `toHtml`:

    Dialog.new
        |> Dialog.id "edit-profile"
        |> Dialog.trigger
            (Button.new
                |> Button.text "Edit profile"
                |> Button.outline
            )
        |> Dialog.title [ text "Edit profile" ]
        |> Dialog.description [ text "Make changes to your profile here." ]
        |> Dialog.content [ text "…" ]
        |> Dialog.footer []
            [ Button.new
                |> Button.text "Cancel"
                |> Button.outline
                |> Button.toHtml (Dialog.closes "edit-profile")
            , Button.new
                |> Button.text "Save changes"
                |> Button.toHtml [ onClick Save ]
            ]
        |> Dialog.toHtml []

The dialog is a native `<dialog>` opened as a modal by its trigger through an invoker command, so it sits in the top layer over a dimmed backdrop, traps focus, makes the rest of the page inert, closes on Escape, a click on the backdrop or any button with the [`closes`](#closes) attributes, and gives focus back to the trigger, with no JavaScript, ports or component state. The `id` is required because the trigger and the dialog find each other by it.

The open state lives in the browser. Give the dialog `onClose` to be told when it closes, for example to reset a form.

@docs Dialog, Ready, NeedsId


# Constructor

@docs new


# Required

`toHtml` won't accept a dialog until it has an `id`.

@docs id


# Trigger

@docs trigger, opens, closes


# Parts

Every part is optional. The header appears when the dialog has a `title` or a `description`, and the footer is separated by a border on a muted background. A close button sits in the top-right corner unless `hideCloseButton` removes it.

@docs title, description, content, footer


# Setters

@docs hideCloseButton, onClose


# Rendering

@docs toHtml

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)
import Html.Events
import Json.Decode as Decode
import UI.Button as Button exposing (Button)


{-| A dialog being built.

`id` is [`Ready`](#Ready) once the dialog has an [`id`](#id).

-}
type Dialog id msg
    = Dialog
        { id : String
        , trigger : Maybe (List (Attribute msg) -> Html msg)
        , title : List (Html msg)
        , description : List (Html msg)
        , content : List (Html msg)
        , footer : Maybe ( List (Attribute msg), List (Html msg) )
        , closeButton : Bool
        , onClose : Maybe msg
        }


{-| The dialog can be rendered.
-}
type Ready
    = Ready


{-| A dialog that still needs an [`id`](#id) before it can be rendered.
-}
type NeedsId
    = NeedsId



-- CONSTRUCTOR


{-| An empty dialog. Give it an [`id`](#id) to make it renderable.
-}
new : Dialog NeedsId msg
new =
    Dialog
        { id = ""
        , trigger = Nothing
        , title = []
        , description = []
        , content = []
        , footer = Nothing
        , closeButton = True
        , onClose = Nothing
        }



-- REQUIRED


{-| The `id` of the `<dialog>`. It must be unique on the page: the trigger and the close buttons point at it, and the title and description are named after it.
-}
id : String -> Dialog NeedsId msg -> Dialog Ready msg
id string (Dialog config) =
    Dialog { config | id = string }



-- TRIGGER


{-| The button that opens the dialog, rendered right before it. It takes a `Button` without its `toHtml`, and renders it with the [`opens`](#opens) attributes for this dialog:

    Dialog.trigger
        (Button.new
            |> Button.text "Edit profile"
            |> Button.outline
        )

For a trigger elsewhere on the page, or one that isn't a `Button`, use `opens` directly instead.

-}
trigger : Button shape Button.Ready msg -> Dialog id msg -> Dialog id msg
trigger button (Dialog config) =
    Dialog { config | trigger = Just (\attrs -> Button.toHtml attrs button) }


{-| The attributes that make a `<button>` open the dialog with the given `id` as a modal, for a trigger that isn't rendered next to the dialog:

    Button.new
        |> Button.text "Edit profile"
        |> Button.toHtml (Dialog.opens "edit-profile")

-}
opens : String -> List (Attribute msg)
opens dialogId =
    [ attribute "commandfor" dialogId
    , attribute "command" "show-modal"
    ]


{-| The attributes that make a `<button>` close the dialog with the given `id`, for a Cancel or Close button in the footer:

    Button.new
        |> Button.text "Cancel"
        |> Button.outline
        |> Button.toHtml (Dialog.closes "edit-profile")

-}
closes : String -> List (Attribute msg)
closes dialogId =
    [ attribute "commandfor" dialogId
    , attribute "command" "close"
    ]



-- PARTS


{-| The heading of the dialog, an `<h2>` the dialog is labelled by.
-}
title : List (Html msg) -> Dialog id msg -> Dialog id msg
title children (Dialog config) =
    Dialog { config | title = children }


{-| Supporting text below the title, a `<p>` the dialog is described by.
-}
description : List (Html msg) -> Dialog id msg -> Dialog id msg
description children (Dialog config) =
    Dialog { config | description = children }


{-| The body of the dialog, between the header and the footer. Each child is a row of the dialog's grid, spaced like the header and footer. For content taller than the viewport, give it `class "max-h-[70vh] overflow-y-auto -mx-4 px-4"` to scroll it inside the dialog.
-}
content : List (Html msg) -> Dialog id msg -> Dialog id msg
content children (Dialog config) =
    Dialog { config | content = children }


{-| The bottom of the dialog, with its buttons stacked on small screens and in a row pushed right from `sm` up. The attributes come after the styles so they can override them.
-}
footer : List (Attribute msg) -> List (Html msg) -> Dialog id msg -> Dialog id msg
footer attrs children (Dialog config) =
    Dialog { config | footer = Just ( attrs, children ) }



-- SETTERS


{-| Removes the close button from the top-right corner. Give the footer a button with the [`closes`](#closes) attributes instead, or leave Escape as the only way out.
-}
hideCloseButton : Dialog id msg -> Dialog id msg
hideCloseButton (Dialog config) =
    Dialog { config | closeButton = False }


{-| Sent when the dialog closes, however it was closed.
-}
onClose : msg -> Dialog id msg -> Dialog id msg
onClose msg (Dialog config) =
    Dialog { config | onClose = Just msg }



-- RENDERING


{-| Renders the trigger, if any, followed by the `<dialog>` with the given attributes after the styles, so they can override them. Pass a width such as `class "sm:max-w-md"` to make it wider than the default `sm:max-w-sm`.
-}
toHtml : List (Attribute msg) -> Dialog Ready msg -> Html msg
toHtml attrs (Dialog config) =
    let
        titleId =
            config.id ++ "-title"

        descriptionId =
            config.id ++ "-description"

        hasHeader =
            not (List.isEmpty config.title && List.isEmpty config.description)
    in
    Html.span
        [ attribute "data-slot" "dialog", class "contents" ]
        (List.filterMap identity
            [ Maybe.map (\toButton -> toButton (attribute "data-slot" "dialog-trigger" :: opens config.id)) config.trigger
            , Just
                (Html.node "dialog"
                    ([ Html.Attributes.id config.id
                     , attribute "data-slot" "dialog-content"

                     -- A click on the backdrop closes the dialog where supported.
                     , attribute "closedby" "any"

                     -- The width from `sm` up comes from a variable so that a `sm:max-w-*`
                     -- class passed to `toHtml` wins: Tailwind puts `max-w-(--…)` before
                     -- every other `max-w-*`.
                     , class "fixed inset-0 isolate z-50 m-auto hidden w-full max-w-[calc(100%-2rem)] gap-4 rounded-xl border-0 bg-popover p-4 text-sm text-popover-foreground ring-1 ring-foreground/10 outline-none open:grid sm:max-w-(--dialog-width) [--dialog-width:var(--container-sm)]"

                     -- Fades and zooms in from `@starting-style`, and out while the
                     -- `display` and `overlay` changes wait for the transition to end.
                     , class "scale-95 opacity-0 transition-[opacity,scale,display,overlay] duration-100 ease-out transition-discrete open:scale-100 open:opacity-100 starting:open:scale-95 starting:open:opacity-0"
                     , class "backdrop:bg-black/10 backdrop:opacity-0 backdrop:backdrop-blur-xs backdrop:transition-opacity backdrop:duration-100 backdrop:ease-out open:backdrop:opacity-100 starting:open:backdrop:opacity-0"
                     ]
                        ++ (if List.isEmpty config.title then
                                []

                            else
                                [ attribute "aria-labelledby" titleId ]
                           )
                        ++ (if List.isEmpty config.description then
                                []

                            else
                                [ attribute "aria-describedby" descriptionId ]
                           )
                        ++ (case config.onClose of
                                Just msg ->
                                    [ Html.Events.on "close" (Decode.succeed msg) ]

                                Nothing ->
                                    []
                           )
                        ++ attrs
                    )
                    (List.filterMap identity
                        [ if hasHeader then
                            Just
                                (Html.div
                                    [ attribute "data-slot" "dialog-header"
                                    , class "flex flex-col gap-2"
                                    ]
                                    (List.filterMap identity
                                        [ if List.isEmpty config.title then
                                            Nothing

                                          else
                                            Just
                                                (Html.h2
                                                    [ Html.Attributes.id titleId
                                                    , attribute "data-slot" "dialog-title"
                                                    , class "text-base leading-none font-medium"
                                                    ]
                                                    config.title
                                                )
                                        , if List.isEmpty config.description then
                                            Nothing

                                          else
                                            Just
                                                (Html.p
                                                    [ Html.Attributes.id descriptionId
                                                    , attribute "data-slot" "dialog-description"
                                                    , class "text-sm text-muted-foreground *:[a]:underline *:[a]:underline-offset-3 *:[a]:hover:text-foreground"
                                                    ]
                                                    config.description
                                                )
                                        ]
                                    )
                                )

                          else
                            Nothing
                        ]
                        ++ config.content
                        ++ List.filterMap identity
                            [ Maybe.map viewFooter config.footer
                            , if config.closeButton then
                                Just (viewCloseButton config.id)

                              else
                                Nothing
                            ]
                    )
                )
            ]
        )


viewFooter : ( List (Attribute msg), List (Html msg) ) -> Html msg
viewFooter ( attrs, children ) =
    Html.div
        ([ attribute "data-slot" "dialog-footer"
         , class "-mx-4 -mb-4 flex flex-col-reverse gap-2 rounded-b-xl border-t bg-muted/50 p-4 sm:flex-row sm:justify-end"
         ]
            ++ attrs
        )
        children


viewCloseButton : String -> Html msg
viewCloseButton dialogId =
    Button.new
        |> Button.icon
            (Html.span
                [ attribute "aria-hidden" "true"
                , class "relative flex size-4 items-center justify-center"
                ]
                [ Html.span [ class "absolute h-[1.5px] w-3.5 rotate-45 rounded-full bg-current" ] []
                , Html.span [ class "absolute h-[1.5px] w-3.5 -rotate-45 rounded-full bg-current" ] []
                ]
            )
        |> Button.label "Close"
        |> Button.ghost
        |> Button.small
        |> Button.toHtml
            (attribute "data-slot" "dialog-close"
                :: class "absolute top-2 right-2"
                :: closes dialogId
            )
