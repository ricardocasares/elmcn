module UI.Dialog exposing
    ( Dialog, Ready, NeedsId, NeedsOpen
    , new
    , id, open
    , title, description, content, footer
    , modal, hideCloseButton
    , toHtml
    )

{-| A window overlaid on either the primary window or another dialog window, rendering the content underneath inert.

A dialog is built with `new`, given an `id` and its `open` state, filled in with parts, and rendered with `toHtml`:

    Dialog.new
        |> Dialog.id "edit-profile"
        |> Dialog.open model.editing (SetEditing False)
        |> Dialog.title [ text "Edit profile" ]
        |> Dialog.description [ text "Make changes to your profile here." ]
        |> Dialog.content [ text "…" ]
        |> Dialog.footer []
            [ Button.new
                |> Button.text "Cancel"
                |> Button.outline
                |> Button.toHtml [ onClick (SetEditing False) ]
            , Button.new
                |> Button.text "Save changes"
                |> Button.toHtml [ onClick Save ]
            ]
        |> Dialog.toHtml []

The open state lives in your model. Open the dialog from any button of your own:

    Button.new
        |> Button.text "Edit profile"
        |> Button.outline
        |> Button.toHtml [ onClick (SetEditing True) ]

The dialog is a native `<dialog>` inside `<elmcn-dialog>`, a small custom element that opens it when `open` is true, and closes it for real once its exit transition has ended, so it fades and zooms the same way in every browser. Import the element once from your JavaScript entry point:

    import "./elmcn-dialog";

The dialog opens in the top layer over a dimmed, blurred overlay: it traps focus, makes the rest of the page inert and stops it scrolling. Escape, a tap on the overlay and the close button send the message you gave [`open`](#open), and the dialog closes when your model says so. A [`modal`](#modal) dialog ignores taps on the overlay.

@docs Dialog, Ready, NeedsId, NeedsOpen


# Constructor

@docs new


# Required

`toHtml` won't accept a dialog until it has an `id` and its `open` state.

@docs id, open


# Parts

Every part is optional. The header appears when the dialog has a `title` or a `description`, and the footer is separated by a border on a muted background. A close button sits in the top-right corner unless `hideCloseButton` removes it.

@docs title, description, content, footer


# Setters

@docs modal, hideCloseButton


# Rendering

@docs toHtml

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, tabindex)
import Html.Events
import Json.Decode as Decode
import UI.Button as Button


{-| A dialog being built.

`id` is [`Ready`](#Ready) once the dialog has an [`id`](#id), and `state` once it has its [`open`](#open) state.

-}
type Dialog id state msg
    = Dialog
        { id : String
        , open : Bool
        , onClose : Maybe msg
        , title : List (Html msg)
        , description : List (Html msg)
        , content : List (Html msg)
        , footer : Maybe ( List (Attribute msg), List (Html msg) )
        , closeButton : Bool
        , modal : Bool
        }


{-| The dialog can be rendered.
-}
type Ready
    = Ready


{-| A dialog that still needs an [`id`](#id) before it can be rendered.
-}
type NeedsId
    = NeedsId


{-| A dialog that still needs its [`open`](#open) state before it can be rendered.
-}
type NeedsOpen
    = NeedsOpen



-- CONSTRUCTOR


{-| An empty dialog. Give it an [`id`](#id) and its [`open`](#open) state to make it renderable.
-}
new : Dialog NeedsId NeedsOpen msg
new =
    Dialog
        { id = ""
        , open = False
        , onClose = Nothing
        , title = []
        , description = []
        , content = []
        , footer = Nothing
        , closeButton = True
        , modal = False
        }



-- REQUIRED


{-| The `id` of the `<elmcn-dialog>`. It must be unique on the page: the title and description are named after it.
-}
id : String -> Dialog NeedsId state msg -> Dialog Ready state msg
id string (Dialog config) =
    Dialog { config | id = string }


{-| Whether the dialog is open, and the message it sends when it asks to close: on Escape, a tap on the overlay or the close button. The dialog animates in and out whenever the value changes:

    Dialog.open model.editing (SetEditing False)

-}
open : Bool -> msg -> Dialog id NeedsOpen msg -> Dialog id Ready msg
open isOpen onClose (Dialog config) =
    Dialog { config | open = isOpen, onClose = Just onClose }



-- PARTS


{-| The heading of the dialog, an `<h2>` the dialog is labelled by.
-}
title : List (Html msg) -> Dialog id state msg -> Dialog id state msg
title children (Dialog config) =
    Dialog { config | title = children }


{-| Supporting text below the title, a `<p>` the dialog is described by.
-}
description : List (Html msg) -> Dialog id state msg -> Dialog id state msg
description children (Dialog config) =
    Dialog { config | description = children }


{-| The body of the dialog, between the header and the footer. Each child is a row of the dialog's grid, spaced like the header and footer. For content taller than the viewport, give it `class "max-h-[70vh] overflow-y-auto -mx-4 px-4"` to scroll it inside the dialog.
-}
content : List (Html msg) -> Dialog id state msg -> Dialog id state msg
content children (Dialog config) =
    Dialog { config | content = children }


{-| The bottom of the dialog, with its buttons stacked on small screens and in a row pushed right from `sm` up. The attributes come after the styles so they can override them.
-}
footer : List (Attribute msg) -> List (Html msg) -> Dialog id state msg -> Dialog id state msg
footer attrs children (Dialog config) =
    Dialog { config | footer = Just ( attrs, children ) }



-- SETTERS


{-| Keeps the dialog open when the overlay is tapped, for a dialog that shouldn't be dismissed by accident, such as a form with unsaved changes. Escape and the close button still ask it to close.
-}
modal : Dialog id state msg -> Dialog id state msg
modal (Dialog config) =
    Dialog { config | modal = True }


{-| Removes the close button from the top-right corner. Escape and a tap on the overlay still ask the dialog to close; give the footer a button for an explicit way out.
-}
hideCloseButton : Dialog id state msg -> Dialog id state msg
hideCloseButton (Dialog config) =
    Dialog { config | closeButton = False }



-- RENDERING


{-| Renders the `<dialog>`. The attributes go on the panel inside it, after the styles, so they can override them. Pass a width such as `class "sm:max-w-md"` to make it wider than the default `sm:max-w-sm`.
-}
toHtml : List (Attribute msg) -> Dialog Ready Ready msg -> Html msg
toHtml attrs (Dialog config) =
    let
        titleId =
            config.id ++ "-title"

        descriptionId =
            config.id ++ "-description"

        hasHeader =
            not (List.isEmpty config.title && List.isEmpty config.description)

        onClose =
            List.filterMap identity [ config.onClose ]
    in
    Html.node "elmcn-dialog"
        ([ Html.Attributes.id config.id
         , attribute "data-slot" "dialog"
         , class "contents"
         ]
            ++ (if config.open then
                    [ attribute "open" "" ]

                else
                    []
               )
        )
        [ Html.node "dialog"
            ([ -- The dialog fills the viewport and centres the panel over the overlay.
               -- The overlay is an element rather than `::backdrop`, so that it can
               -- take clicks and transition with the panel.
               class "fixed inset-0 isolate z-50 m-0 hidden h-full max-h-none w-full max-w-none place-items-center overflow-hidden bg-transparent p-4 outline-none open:grid backdrop:bg-transparent"

             -- The page behind stops scrolling while the dialog is open, keeping
             -- its scrollbar gutter so that nothing shifts.
             , class "[html:has(&:modal)]:overflow-hidden [html:has(&:modal)]:[scrollbar-gutter:stable]"
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
                ++ List.concatMap closeRequests onClose
            )
            [ Html.div
                ([ attribute "data-slot" "dialog-overlay"
                 , attribute "aria-hidden" "true"
                 , class "absolute inset-0 bg-black/10 select-none"

                 -- In while its own `<elmcn-dialog>` is `open`, not any ancestor, so that
                 -- a nested dialog closes while its parent stays open. From
                 -- `@starting-style`, and out once it isn't, before the element
                 -- closes the dialog. Plain properties, because Safari ignores
                 -- `@starting-style` values set through variables.
                 , class "opacity-0 [backdrop-filter:blur(0)] transition-[opacity,backdrop-filter] duration-300 ease-[ease] [elmcn-dialog[open]>dialog>&]:opacity-100 [elmcn-dialog[open]>dialog>&]:[backdrop-filter:blur(var(--blur-xs))] starting:[elmcn-dialog[open]>dialog>&]:opacity-0 starting:[elmcn-dialog[open]>dialog>&]:[backdrop-filter:blur(0)]"

                 -- A nested dialog doesn't dim the page twice, like Base UI, which leaves
                 -- out its backdrop. Its overlay still takes the taps that close it.
                 , class "[elmcn-dialog_elmcn-dialog>dialog>&]:bg-transparent [elmcn-dialog_elmcn-dialog[open]>dialog>&]:[backdrop-filter:none]"
                 ]
                    ++ (if config.modal then
                            []

                        else
                            List.map Html.Events.onClick onClose
                       )
                )
                []
            , Html.div
                ([ attribute "data-slot" "dialog-content"

                 -- The width from `sm` up comes from a variable so that a `sm:max-w-*`
                 -- class passed to `toHtml` wins: Tailwind puts `max-w-(--…)` before
                 -- every other `max-w-*`.
                 , class "relative grid w-full max-h-full gap-4 rounded-xl bg-popover p-4 text-sm text-popover-foreground ring-1 ring-foreground/10 outline-none sm:max-w-(--dialog-width) [--dialog-width:var(--container-sm)]"

                 -- Fades and zooms like the overlay.
                 , class "opacity-0 [scale:0.95] transition-[opacity,scale] duration-300 ease-[ease] [elmcn-dialog[open]>dialog>&]:opacity-100 [elmcn-dialog[open]>dialog>&]:[scale:1] starting:[elmcn-dialog[open]>dialog>&]:opacity-0 starting:[elmcn-dialog[open]>dialog>&]:[scale:0.95]"
                 ]
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
                            Just (viewCloseButton onClose)

                          else
                            Nothing
                        ]
                )
            ]
        ]


{-| Escape asks the dialog to close. It is caught on `keydown`, whose default is the browser's close request: the `cancel` event, which would close the dialog at once, without the exit transition, whenever the browser won't let it be prevented. Chrome only lets a page prevent one `cancel` per click, so a second Escape in a row, such as one that closes a nested dialog's parent, would skip the transition. The `keydown` stops at the topmost dialog, so that it doesn't also close the ones it is nested in.

The back gesture on Android still goes through `cancel`. When the browser closes the dialog on its own, `close` is reported too, but only while `<elmcn-dialog>` is still `open`: when the model closed it, the model knows.

-}
closeRequests : msg -> List (Attribute msg)
closeRequests msg =
    [ Html.Events.custom "keydown"
        (Decode.field "key" Decode.string
            |> Decode.andThen
                (\key ->
                    if key == "Escape" then
                        Decode.succeed { message = msg, stopPropagation = True, preventDefault = True }

                    else
                        Decode.fail key
                )
        )
    , Html.Events.preventDefaultOn "cancel" (Decode.succeed ( msg, True ))
    , Html.Events.on "close"
        (Decode.at [ "target", "parentElement", "attributes", "open" ] Decode.value
            |> Decode.map (\_ -> msg)
        )
    ]


viewFooter : ( List (Attribute msg), List (Html msg) ) -> Html msg
viewFooter ( attrs, children ) =
    Html.div
        ([ attribute "data-slot" "dialog-footer"
         , class "-mx-4 -mb-4 flex flex-col-reverse gap-2 rounded-b-xl border-t bg-muted/50 p-4 sm:flex-row sm:justify-end"
         ]
            ++ attrs
        )
        children


viewCloseButton : List msg -> Html msg
viewCloseButton onClose =
    Button.new
        |> Button.icon
            (Html.span
                [ attribute "aria-hidden" "true"
                , class "relative flex size-4 items-center justify-center"
                ]
                [ Html.span [ class "absolute h-[1.333px] w-[12.667px] rotate-45 rounded-full bg-current" ] []
                , Html.span [ class "absolute h-[1.333px] w-[12.667px] -rotate-45 rounded-full bg-current" ] []
                ]
            )
        |> Button.label "Close"
        |> Button.ghost
        |> Button.small
        |> Button.toHtml
            (attribute "data-slot" "dialog-close"
                :: class "absolute top-2 end-2"
                -- Safari only tabs to buttons with an explicit `tabindex`.
                :: tabindex 0
                :: List.map Html.Events.onClick onClose
            )
