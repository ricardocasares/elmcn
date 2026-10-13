module UI.AlertDialog exposing
    ( AlertDialog, Ready, NeedsId
    , new
    , id
    , trigger, opens, closes
    , media, title, description
    , cancel, action
    , small, onClose
    , toHtml
    )

{-| A modal dialog that interrupts the user with important content and expects a response.

An alert dialog is built with `new`, given an `id` and a `trigger`, filled in with parts, and rendered with `toHtml`:

    AlertDialog.new
        |> AlertDialog.id "delete-account"
        |> AlertDialog.trigger
            (Button.new
                |> Button.text "Show Dialog"
                |> Button.outline
            )
        |> AlertDialog.title [ text "Are you absolutely sure?" ]
        |> AlertDialog.description [ text "This action cannot be undone." ]
        |> AlertDialog.cancel
            (Button.new
                |> Button.text "Cancel"
                |> Button.outline
            )
        |> AlertDialog.action [ onClick DeleteAccount ]
            (Button.new
                |> Button.text "Continue"
            )
        |> AlertDialog.toHtml []

The alert dialog is a native `<dialog>` opened as a modal by its trigger through an invoker command, so it sits in the top layer over a dimmed backdrop, traps focus, makes the rest of the page inert and gives focus back to the trigger, with no JavaScript, ports or component state. Unlike a `Dialog`, it has no close button and a tap on the backdrop doesn't dismiss it: the user answers with `cancel` or `action`, or Escape. The `id` is required because the trigger and the dialog find each other by it.

The open state lives in the browser. Give the dialog `onClose` to be told when it closes, for example to reset a form.

@docs AlertDialog, Ready, NeedsId


# Constructor

@docs new


# Required

`toHtml` won't accept an alert dialog until it has an `id`.

@docs id


# Trigger

@docs trigger, opens, closes


# Parts

Every part is optional. The header appears when the dialog has `media`, a `title` or a `description`, and the footer when it has a `cancel` or an `action`.

@docs media, title, description


# Response

@docs cancel, action


# Setters

@docs small, onClose


# Rendering

@docs toHtml

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, classList, tabindex)
import Html.Events
import Json.Decode as Decode
import UI.Button as Button exposing (Button)


{-| An alert dialog being built.

`id` is [`Ready`](#Ready) once the dialog has an [`id`](#id).

-}
type AlertDialog id msg
    = AlertDialog
        { id : String
        , trigger : Maybe (List (Attribute msg) -> Html msg)
        , media : Maybe ( List (Attribute msg), List (Html msg) )
        , title : List (Html msg)
        , description : List (Html msg)
        , cancel : Maybe (List (Attribute msg) -> Html msg)
        , action : Maybe (List (Attribute msg) -> Html msg)
        , size : Size
        , onClose : Maybe msg
        }


type Size
    = Default
    | Small


{-| The alert dialog can be rendered.
-}
type Ready
    = Ready


{-| An alert dialog that still needs an [`id`](#id) before it can be rendered.
-}
type NeedsId
    = NeedsId



-- CONSTRUCTOR


{-| An empty alert dialog. Give it an [`id`](#id) to make it renderable.
-}
new : AlertDialog NeedsId msg
new =
    AlertDialog
        { id = ""
        , trigger = Nothing
        , media = Nothing
        , title = []
        , description = []
        , cancel = Nothing
        , action = Nothing
        , size = Default
        , onClose = Nothing
        }



-- REQUIRED


{-| The `id` of the `<dialog>`. It must be unique on the page: the trigger and the response buttons point at it, and the title and description are named after it.
-}
id : String -> AlertDialog NeedsId msg -> AlertDialog Ready msg
id string (AlertDialog config) =
    AlertDialog { config | id = string }



-- TRIGGER


{-| The button that opens the dialog, rendered right before it. It takes a `Button` without its `toHtml`, and renders it with the [`opens`](#opens) attributes for this dialog:

    AlertDialog.trigger
        (Button.new
            |> Button.text "Delete Chat"
            |> Button.destructive
        )

For a trigger elsewhere on the page, or one that isn't a `Button`, use `opens` directly instead.

-}
trigger : Button shape Button.Ready msg -> AlertDialog id msg -> AlertDialog id msg
trigger button (AlertDialog config) =
    AlertDialog { config | trigger = Just (\attrs -> Button.toHtml attrs button) }


{-| The attributes that make a `<button>` open the dialog with the given `id` as a modal, for a trigger that isn't rendered next to the dialog:

    Button.new
        |> Button.text "Delete"
        |> Button.toHtml (AlertDialog.opens "delete-account")

-}
opens : String -> List (Attribute msg)
opens dialogId =
    [ attribute "commandfor" dialogId
    , attribute "command" "show-modal"
    ]


{-| The attributes that make a `<button>` close the dialog with the given `id`, for a response that isn't a [`cancel`](#cancel) or an [`action`](#action):

    Button.new
        |> Button.text "Later"
        |> Button.ghost
        |> Button.toHtml (AlertDialog.closes "delete-account")

-}
closes : String -> List (Attribute msg)
closes dialogId =
    [ attribute "commandfor" dialogId
    , attribute "command" "close"
    ]



-- PARTS


{-| An icon or image above the title, in a muted square. From `sm` up, a default-size dialog puts it beside the title and description instead. The attributes come after the styles so they can override them, for example with `class "bg-destructive/10 text-destructive"`.
-}
media : List (Attribute msg) -> List (Html msg) -> AlertDialog id msg -> AlertDialog id msg
media attrs children (AlertDialog config) =
    AlertDialog { config | media = Just ( attrs, children ) }


{-| The heading of the dialog, an `<h2>` the dialog is labelled by.
-}
title : List (Html msg) -> AlertDialog id msg -> AlertDialog id msg
title children (AlertDialog config) =
    AlertDialog { config | title = children }


{-| Supporting text below the title, a `<p>` the dialog is described by.
-}
description : List (Html msg) -> AlertDialog id msg -> AlertDialog id msg
description children (AlertDialog config) =
    AlertDialog { config | description = children }



-- RESPONSE


{-| The button that dismisses the dialog without doing anything. It takes a `Button` without its `toHtml`, and renders it with the [`closes`](#closes) attributes for this dialog. Make it `outline` to match shadcn/ui, or `ghost` next to a destructive action:

    AlertDialog.cancel
        (Button.new
            |> Button.text "Cancel"
            |> Button.outline
        )

-}
cancel : Button shape Button.Ready msg -> AlertDialog id msg -> AlertDialog id msg
cancel button (AlertDialog config) =
    AlertDialog { config | cancel = Just (\attrs -> Button.toHtml attrs button) }


{-| The button that confirms the dialog. It takes a `Button` without its `toHtml`, and renders it with the [`closes`](#closes) attributes for this dialog followed by the given attributes, so pass `onClick` to be told the user confirmed:

    AlertDialog.action [ onClick DeleteAccount ]
        (Button.new
            |> Button.text "Delete"
            |> Button.destructive
        )

-}
action : List (Attribute msg) -> Button shape Button.Ready msg -> AlertDialog id msg -> AlertDialog id msg
action attrs button (AlertDialog config) =
    AlertDialog { config | action = Just (\closing -> Button.toHtml (closing ++ attrs) button) }



-- SETTERS


{-| A narrower dialog whose header stays centred from `sm` up and whose response buttons share a row, like a system prompt.
-}
small : AlertDialog id msg -> AlertDialog id msg
small (AlertDialog config) =
    AlertDialog { config | size = Small }


{-| Sent when the dialog closes, however it was closed.
-}
onClose : msg -> AlertDialog id msg -> AlertDialog id msg
onClose msg (AlertDialog config) =
    AlertDialog { config | onClose = Just msg }



-- RENDERING


{-| Renders the trigger, if any, followed by the `<dialog>`. The attributes go on the panel inside it, after the styles, so they can override them. Pass a width such as `class "sm:max-w-md"` to make a default-size dialog wider than `sm:max-w-sm`.
-}
toHtml : List (Attribute msg) -> AlertDialog Ready msg -> Html msg
toHtml attrs (AlertDialog config) =
    let
        titleId =
            config.id ++ "-title"

        descriptionId =
            config.id ++ "-description"

        hasMedia =
            isJust config.media

        hasHeader =
            hasMedia || not (List.isEmpty config.title && List.isEmpty config.description)

        hasFooter =
            isJust config.cancel || isJust config.action

        isDefault =
            config.size == Default
    in
    Html.span
        [ attribute "data-slot" "alert-dialog", class "contents" ]
        (List.filterMap identity
            [ Maybe.map (\toButton -> toButton (attribute "data-slot" "alert-dialog-trigger" :: opens config.id)) config.trigger
            , Just
                (Html.node "dialog"
                    ([ Html.Attributes.id config.id
                     , attribute "role" "alertdialog"

                     -- Escape closes the dialog, but a click outside doesn't: an alert
                     -- dialog expects an answer.
                     , attribute "closedby" "closerequest"

                     -- The dialog fills the viewport and centres the panel in it.
                     , class "fixed inset-0 isolate z-50 m-0 hidden h-full max-h-none w-full max-w-none place-items-center overflow-hidden bg-transparent p-4 outline-none open:grid"

                     -- The page behind stops scrolling while the dialog is modal, keeping
                     -- its scrollbar gutter so that nothing shifts.
                     , class "[html:has(&:modal)]:overflow-hidden [html:has(&:modal)]:[scrollbar-gutter:stable]"

                     -- The `display` and `overlay` changes wait for the panel's fade out.
                     , class "transition-[display,overlay] duration-100 transition-discrete"
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
                    )
                    [ Html.div
                        ([ attribute "data-slot" "alert-dialog-content"
                         , attribute "data-size"
                            (if isDefault then
                                "default"

                             else
                                "sm"
                            )
                         , class "relative grid w-full max-w-xs max-h-full gap-4 rounded-xl bg-popover p-4 text-popover-foreground ring-1 ring-foreground/10 outline-none"

                         -- The width from `sm` up comes from a variable so that a `sm:max-w-*`
                         -- class passed to `toHtml` wins: Tailwind puts `max-w-(--…)` before
                         -- every other `max-w-*`.
                         , classList [ ( "sm:max-w-(--alert-dialog-width) [--alert-dialog-width:var(--container-sm)]", isDefault ) ]

                         -- Fades and zooms in from `@starting-style`, and out while the
                         -- dialog's `display` and `overlay` changes wait for the transition.
                         , class "scale-95 opacity-0 transition-[opacity,scale] duration-100 ease-out in-[[open]]:scale-100 in-[[open]]:opacity-100 starting:in-[[open]]:scale-95 starting:in-[[open]]:opacity-0"
                         ]
                            ++ attrs
                        )
                        (List.filterMap identity
                            [ if hasHeader then
                                Just
                                    (Html.div
                                        [ attribute "data-slot" "alert-dialog-header"
                                        , class "grid place-items-center gap-1.5 text-center"
                                        , class
                                            (case ( hasMedia, isDefault ) of
                                                ( False, _ ) ->
                                                    "grid-rows-[auto_1fr]"

                                                ( True, False ) ->
                                                    "grid-rows-[auto_auto_1fr] gap-x-4"

                                                ( True, True ) ->
                                                    "grid-rows-[auto_auto_1fr] gap-x-4 sm:grid-rows-[auto_1fr]"
                                            )
                                        , classList [ ( "sm:place-items-start sm:text-left", isDefault ) ]
                                        ]
                                        (List.filterMap identity
                                            [ Maybe.map (viewMedia isDefault) config.media
                                            , if List.isEmpty config.title then
                                                Nothing

                                              else
                                                Just
                                                    (Html.h2
                                                        [ Html.Attributes.id titleId
                                                        , attribute "data-slot" "alert-dialog-title"
                                                        , class "text-base font-medium"
                                                        , classList [ ( "sm:col-start-2", hasMedia && isDefault ) ]
                                                        ]
                                                        config.title
                                                    )
                                            , if List.isEmpty config.description then
                                                Nothing

                                              else
                                                Just
                                                    (Html.p
                                                        [ Html.Attributes.id descriptionId
                                                        , attribute "data-slot" "alert-dialog-description"
                                                        , class "text-sm text-balance text-muted-foreground md:text-pretty *:[a]:underline *:[a]:underline-offset-3 *:[a]:hover:text-foreground"
                                                        ]
                                                        config.description
                                                    )
                                            ]
                                        )
                                    )

                              else
                                Nothing
                            , if hasFooter then
                                Just
                                    (Html.div
                                        [ attribute "data-slot" "alert-dialog-footer"
                                        , class "-mx-4 -mb-4 gap-2 rounded-b-xl border-t bg-muted/50 p-4"
                                        , class
                                            (if isDefault then
                                                "flex flex-col-reverse sm:flex-row sm:justify-end"

                                             else
                                                "grid grid-cols-2"
                                            )
                                        ]
                                        -- Safari only tabs to buttons with an explicit `tabindex`.
                                        (List.filterMap identity
                                            [ Maybe.map (\toButton -> toButton (attribute "data-slot" "alert-dialog-cancel" :: tabindex 0 :: closes config.id)) config.cancel
                                            , Maybe.map (\toButton -> toButton (attribute "data-slot" "alert-dialog-action" :: tabindex 0 :: closes config.id)) config.action
                                            ]
                                        )
                                    )

                              else
                                Nothing
                            ]
                        )
                    ]
                )
            ]
        )


viewMedia : Bool -> ( List (Attribute msg), List (Html msg) ) -> Html msg
viewMedia isDefault ( attrs, children ) =
    Html.div
        ([ attribute "data-slot" "alert-dialog-media"

         -- The background comes from a variable so that a `bg-*` class passed to
         -- `media` wins: Tailwind puts `bg-(--…)` before every other `bg-*`.
         , class "mb-2 inline-flex size-10 items-center justify-center rounded-md bg-(--alert-dialog-media-bg) [--alert-dialog-media-bg:var(--muted)] *:[svg:not([class*='size-'])]:size-6"
         , classList [ ( "sm:row-span-2", isDefault ) ]
         ]
            ++ attrs
        )
        children


isJust : Maybe a -> Bool
isJust maybe =
    case maybe of
        Just _ ->
            True

        Nothing ->
            False
