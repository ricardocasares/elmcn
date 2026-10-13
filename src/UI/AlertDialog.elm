module UI.AlertDialog exposing
    ( AlertDialog, Ready, NeedsId, NeedsOpen
    , new
    , id, open
    , media, title, description
    , cancel, action
    , small
    , toHtml
    )

{-| A modal dialog that interrupts the user with important content and expects a response.

An alert dialog is built with `new`, given an `id` and its `open` state, filled in with parts, and rendered with `toHtml`:

    AlertDialog.new
        |> AlertDialog.id "delete-account"
        |> AlertDialog.open model.confirming (SetConfirming False)
        |> AlertDialog.title [ text "Are you absolutely sure?" ]
        |> AlertDialog.description [ text "This action cannot be undone." ]
        |> AlertDialog.cancel
            (Button.new
                |> Button.text "Cancel"
                |> Button.outline
            )
        |> AlertDialog.action DeleteAccount
            (Button.new
                |> Button.text "Continue"
            )
        |> AlertDialog.toHtml []

The open state lives in your model. Open the dialog from any button of your own:

    Button.new
        |> Button.text "Delete account"
        |> Button.outline
        |> Button.toHtml [ onClick (SetConfirming True) ]

The alert dialog is a native `<dialog>` inside `<elmcn-dialog>`, the same small custom element as `Dialog`'s, which opens it when `open` is true, and closes it for real once its exit transition has ended. Import the element once from your JavaScript entry point:

    import "./UI/elmcn-dialog";

The dialog opens in the top layer over a dimmed, blurred overlay: it traps focus, makes the rest of the page inert and stops it scrolling. Unlike a `Dialog`, it has no close button and a tap on the overlay doesn't dismiss it: the user answers with `cancel` or `action`. Escape and `cancel` send the message you gave [`open`](#open), `action` sends its own, and the dialog closes when your model says so.

@docs AlertDialog, Ready, NeedsId, NeedsOpen


# Constructor

@docs new


# Required

`toHtml` won't accept an alert dialog until it has an `id` and its `open` state.

@docs id, open


# Parts

Every part is optional. The header appears when the dialog has `media`, a `title` or a `description`, and the footer when it has a `cancel` or an `action`.

@docs media, title, description


# Response

@docs cancel, action


# Setters

@docs small


# Rendering

@docs toHtml

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class, classList, tabindex)
import Html.Events
import Json.Decode as Decode
import UI.Button as Button exposing (Button)


{-| An alert dialog being built.

`id` is [`Ready`](#Ready) once the dialog has an [`id`](#id), and `state` once it has its [`open`](#open) state.

-}
type AlertDialog id state msg
    = AlertDialog
        { id : String
        , open : Bool
        , onClose : Maybe msg
        , media : Maybe ( List (Attribute msg), List (Html msg) )
        , title : List (Html msg)
        , description : List (Html msg)
        , cancel : Maybe (List (Attribute msg) -> Html msg)
        , action : Maybe (List (Attribute msg) -> Html msg)
        , size : Size
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


{-| An alert dialog that still needs its [`open`](#open) state before it can be rendered.
-}
type NeedsOpen
    = NeedsOpen



-- CONSTRUCTOR


{-| An empty alert dialog. Give it an [`id`](#id) and its [`open`](#open) state to make it renderable.
-}
new : AlertDialog NeedsId NeedsOpen msg
new =
    AlertDialog
        { id = ""
        , open = False
        , onClose = Nothing
        , media = Nothing
        , title = []
        , description = []
        , cancel = Nothing
        , action = Nothing
        , size = Default
        }



-- REQUIRED


{-| The `id` of the `<elmcn-dialog>`. It must be unique on the page: the title and description are named after it.
-}
id : String -> AlertDialog NeedsId state msg -> AlertDialog Ready state msg
id string (AlertDialog config) =
    AlertDialog { config | id = string }


{-| Whether the dialog is open, and the message it sends when it asks to close: on Escape or the [`cancel`](#cancel) button. The dialog animates in and out whenever the value changes:

    AlertDialog.open model.confirming (SetConfirming False)

-}
open : Bool -> msg -> AlertDialog id NeedsOpen msg -> AlertDialog id Ready msg
open isOpen onClose (AlertDialog config) =
    AlertDialog { config | open = isOpen, onClose = Just onClose }



-- PARTS


{-| An icon or image above the title, in a muted square. From `sm` up, a default-size dialog puts it beside the title and description instead. The attributes come after the styles so they can override them, for example with `class "bg-destructive/10 text-destructive"`.
-}
media : List (Attribute msg) -> List (Html msg) -> AlertDialog id state msg -> AlertDialog id state msg
media attrs children (AlertDialog config) =
    AlertDialog { config | media = Just ( attrs, children ) }


{-| The heading of the dialog, an `<h2>` the dialog is labelled by.
-}
title : List (Html msg) -> AlertDialog id state msg -> AlertDialog id state msg
title children (AlertDialog config) =
    AlertDialog { config | title = children }


{-| Supporting text below the title, a `<p>` the dialog is described by.
-}
description : List (Html msg) -> AlertDialog id state msg -> AlertDialog id state msg
description children (AlertDialog config) =
    AlertDialog { config | description = children }



-- RESPONSE


{-| The button that dismisses the dialog without doing anything. It takes a `Button` without its `toHtml`, and sends the message you gave [`open`](#open) when clicked. Make it `outline` to match shadcn/ui, or `ghost` next to a destructive action:

    AlertDialog.cancel
        (Button.new
            |> Button.text "Cancel"
            |> Button.outline
        )

-}
cancel : Button shape Button.Ready msg -> AlertDialog id state msg -> AlertDialog id state msg
cancel button (AlertDialog config) =
    AlertDialog { config | cancel = Just (\attrs -> Button.toHtml attrs button) }


{-| The button that confirms the dialog. It takes a `Button` without its `toHtml`, and sends the given message when clicked. The dialog stays open until your model closes it, so close it when you handle the message, right away or once the work is done:

    AlertDialog.action DeleteAccount
        (Button.new
            |> Button.text "Delete"
            |> Button.destructive
        )

-}
action : msg -> Button shape Button.Ready msg -> AlertDialog id state msg -> AlertDialog id state msg
action msg button (AlertDialog config) =
    AlertDialog { config | action = Just (\attrs -> Button.toHtml (attrs ++ [ Html.Events.onClick msg ]) button) }



-- SETTERS


{-| A narrower dialog whose header stays centred from `sm` up and whose response buttons share a row, like a system prompt.
-}
small : AlertDialog id state msg -> AlertDialog id state msg
small (AlertDialog config) =
    AlertDialog { config | size = Small }



-- RENDERING


{-| Renders the `<dialog>`. The attributes go on the panel inside it, after the styles, so they can override them. Pass a width such as `class "sm:max-w-md"` to make a default-size dialog wider than `sm:max-w-sm`.
-}
toHtml : List (Attribute msg) -> AlertDialog Ready Ready msg -> Html msg
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

        onClose =
            List.filterMap identity [ config.onClose ]
    in
    Html.node "elmcn-dialog"
        ([ Html.Attributes.id config.id
         , attribute "data-slot" "alert-dialog"
         , class "contents"
         ]
            ++ (if config.open then
                    [ attribute "open" "" ]

                else
                    []
               )
        )
        [ Html.node "dialog"
            ([ attribute "role" "alertdialog"

             -- The dialog fills the viewport and centres the panel over the overlay.
             -- The overlay is an element rather than `::backdrop`, so that it can
             -- transition with the panel.
             , class "fixed inset-0 isolate z-50 m-0 hidden h-full max-h-none w-full max-w-none place-items-center overflow-hidden bg-transparent p-4 outline-none open:grid backdrop:bg-transparent"

             -- The page behind stops scrolling while the dialog is open, keeping
             -- its scrollbar gutter so that nothing shifts.
             , class "[html:has(&:modal)]:overflow-hidden [html:has(&:modal)]:[scrollbar-gutter:stable]"

             -- On iOS the page behind is dimmed and blurred by a filter on the root
             -- instead of by the overlay, which iOS Safari would cut off at its
             -- floating toolbar. See `UI.Dialog` for why only there.
             , class "supports-[-webkit-touch-callout:none]:[html:has(&:modal)]:transition-[filter] supports-[-webkit-touch-callout:none]:[html:has(&:modal)]:duration-300 supports-[-webkit-touch-callout:none]:[html:has(&:modal)]:ease-[ease] supports-[-webkit-touch-callout:none]:[html:has(elmcn-dialog[open]>&:modal)]:[filter:blur(var(--blur-xs))_brightness(0.9)]"
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
            [ -- An alert dialog expects an answer, so a tap on the overlay does nothing.
              Html.div
                [ attribute "data-slot" "alert-dialog-overlay"
                , attribute "aria-hidden" "true"
                , class "absolute inset-0 select-none not-supports-[-webkit-touch-callout:none]:bg-black/10"

                -- In while its own `<elmcn-dialog>` is `open`, from `@starting-style`,
                -- and out once it isn't, before the element closes the dialog. Plain
                -- properties, because Safari ignores `@starting-style` values set
                -- through variables. Transparent on iOS, where the root's filter dims
                -- the page instead.
                , class "opacity-0 transition-[opacity,backdrop-filter] duration-300 ease-[ease] [elmcn-dialog[open]>dialog>&]:opacity-100 starting:[elmcn-dialog[open]>dialog>&]:opacity-0 not-supports-[-webkit-touch-callout:none]:[backdrop-filter:blur(0)] not-supports-[-webkit-touch-callout:none]:[elmcn-dialog[open]>dialog>&]:[backdrop-filter:blur(var(--blur-xs))] not-supports-[-webkit-touch-callout:none]:starting:[elmcn-dialog[open]>dialog>&]:[backdrop-filter:blur(0)]"

                -- An alert dialog opened from another dialog doesn't dim the page twice.
                , class "[elmcn-dialog_elmcn-dialog>dialog>&]:bg-transparent [elmcn-dialog_elmcn-dialog[open]>dialog>&]:[backdrop-filter:none]"
                ]
                []
            , Html.div
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

                 -- Fades and zooms like the overlay.
                 , class "opacity-0 [scale:0.95] transition-[opacity,scale] duration-300 ease-[ease] [elmcn-dialog[open]>dialog>&]:opacity-100 [elmcn-dialog[open]>dialog>&]:[scale:1] starting:[elmcn-dialog[open]>dialog>&]:opacity-0 starting:[elmcn-dialog[open]>dialog>&]:[scale:0.95]"
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
                                    [ Maybe.map (\toButton -> toButton (attribute "data-slot" "alert-dialog-cancel" :: tabindex 0 :: List.map Html.Events.onClick onClose)) config.cancel
                                    , Maybe.map (\toButton -> toButton [ attribute "data-slot" "alert-dialog-action", tabindex 0 ]) config.action
                                    ]
                                )
                            )

                      else
                        Nothing
                    ]
                )
            ]
        ]


{-| Escape asks the dialog to close, caught on `keydown` before it becomes a `cancel` that would close the dialog without its exit transition, and stopped at the topmost dialog. The back gesture on Android still goes through `cancel`, and when the browser closes the dialog on its own, `close` is reported while `<elmcn-dialog>` is still `open`. See `UI.Dialog` for the details.
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
