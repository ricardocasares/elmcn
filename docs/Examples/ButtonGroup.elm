module Examples.ButtonGroup exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (attribute, class, dir, disabled, for, id, pattern, placeholder)
import Html.Events exposing (onClick)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import Svg.Attributes
import UI.Button as Button
import UI.ButtonGroup as ButtonGroup
import UI.Field as Field
import UI.Input as Input
import UI.InputGroup as InputGroup
import UI.Popover as Popover
import UI.Select as Select
import UI.Separator as Separator
import UI.Textarea as Textarea


demo : Html msg
demo =
    let
        more =
            Phosphor.dotsThree Regular |> Phosphor.toHtml []
    in
    ButtonGroup.new
        |> ButtonGroup.toHtml []
            [ ButtonGroup.new
                |> ButtonGroup.toHtml [ class "hidden sm:flex" ]
                    [ Button.new
                        |> Button.icon (Phosphor.arrowLeft Regular |> Phosphor.toHtml [])
                        |> Button.label "Go Back"
                        |> Button.outline
                        |> Button.toHtml []
                    ]
            , ButtonGroup.new
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
            , ButtonGroup.new
                |> ButtonGroup.toHtml []
                    [ Button.new
                        |> Button.text "Snooze"
                        |> Button.outline
                        |> Button.toHtml []
                    , Popover.new
                        |> Popover.id "button-group-demo-more"
                        |> Popover.trigger
                            (attribute "aria-label" "More Options"
                                :: (Button.new
                                        |> Button.icon more
                                        |> Button.outline
                                        |> Button.toAttributes
                                   )
                            )
                            [ more ]
                        |> Popover.content
                            (menuGroups
                                [ [ menuItem Phosphor.envelopeOpen "Mark as Read"
                                  , menuItem Phosphor.archive "Archive"
                                  ]
                                , [ menuItem Phosphor.clock "Snooze"
                                  , menuItem Phosphor.calendarPlus "Add to Calendar"
                                  , menuItem Phosphor.listPlus "Add to List"
                                  ]
                                , [ destructiveMenuItem Phosphor.trash "Trash" ]
                                ]
                            )
                        |> Popover.alignEnd
                        |> Popover.toHtml [ class "w-40" ]
                    ]
            ]


{-| Use `vertical` to change the button group layout.
-}
orientation : Html msg
orientation =
    ButtonGroup.new
        |> ButtonGroup.vertical
        |> ButtonGroup.toHtml [ attribute "aria-label" "Media controls", class "h-fit" ]
            [ Button.new
                |> Button.icon (Phosphor.plus Regular |> Phosphor.toHtml [])
                |> Button.label "Increase"
                |> Button.outline
                |> Button.toHtml []
            , Button.new
                |> Button.icon (Phosphor.minus Regular |> Phosphor.toHtml [])
                |> Button.label "Decrease"
                |> Button.outline
                |> Button.toHtml []
            ]


{-| Control the size of buttons using the size functions on individual buttons.
-}
size : Html msg
size =
    div [ class "flex flex-col items-start gap-8" ]
        [ ButtonGroup.new
            |> ButtonGroup.toHtml []
                [ Button.new
                    |> Button.text "Small"
                    |> Button.outline
                    |> Button.small
                    |> Button.toHtml []
                , Button.new
                    |> Button.text "Button"
                    |> Button.outline
                    |> Button.small
                    |> Button.toHtml []
                , Button.new
                    |> Button.text "Group"
                    |> Button.outline
                    |> Button.small
                    |> Button.toHtml []
                , Button.new
                    |> Button.icon (Phosphor.plus Regular |> Phosphor.toHtml [])
                    |> Button.label "Add"
                    |> Button.outline
                    |> Button.small
                    |> Button.toHtml []
                ]
        , ButtonGroup.new
            |> ButtonGroup.toHtml []
                [ Button.new
                    |> Button.text "Default"
                    |> Button.outline
                    |> Button.toHtml []
                , Button.new
                    |> Button.text "Button"
                    |> Button.outline
                    |> Button.toHtml []
                , Button.new
                    |> Button.text "Group"
                    |> Button.outline
                    |> Button.toHtml []
                , Button.new
                    |> Button.icon (Phosphor.plus Regular |> Phosphor.toHtml [])
                    |> Button.label "Add"
                    |> Button.outline
                    |> Button.toHtml []
                ]
        , ButtonGroup.new
            |> ButtonGroup.toHtml []
                [ Button.new
                    |> Button.text "Large"
                    |> Button.outline
                    |> Button.large
                    |> Button.toHtml []
                , Button.new
                    |> Button.text "Button"
                    |> Button.outline
                    |> Button.large
                    |> Button.toHtml []
                , Button.new
                    |> Button.text "Group"
                    |> Button.outline
                    |> Button.large
                    |> Button.toHtml []
                , Button.new
                    |> Button.icon (Phosphor.plus Regular |> Phosphor.toHtml [])
                    |> Button.label "Add"
                    |> Button.outline
                    |> Button.large
                    |> Button.toHtml []
                ]
        ]


{-| Nest button groups to create button groups with spacing.
-}
nested : Html msg
nested =
    ButtonGroup.new
        |> ButtonGroup.toHtml []
            [ ButtonGroup.new
                |> ButtonGroup.toHtml []
                    [ Button.new
                        |> Button.icon (Phosphor.plus Regular |> Phosphor.toHtml [])
                        |> Button.label "Add"
                        |> Button.outline
                        |> Button.toHtml []
                    ]
            , ButtonGroup.new
                |> ButtonGroup.toHtml []
                    [ InputGroup.view []
                        [ InputGroup.input [ placeholder "Send a message..." ]
                        , InputGroup.end [] [ Phosphor.waveform Regular |> Phosphor.toHtml [] ]
                        ]
                    ]
            ]


{-| The `separator` visually divides buttons within a group.

Buttons with the `outline` variant do not need a separator since they have a border. For other variants, a separator is recommended to improve the visual hierarchy.

-}
separator : Html msg
separator =
    ButtonGroup.new
        |> ButtonGroup.toHtml []
            [ Button.new
                |> Button.text "Copy"
                |> Button.secondary
                |> Button.small
                |> Button.toHtml []
            , ButtonGroup.separator []
            , Button.new
                |> Button.text "Paste"
                |> Button.secondary
                |> Button.small
                |> Button.toHtml []
            ]


{-| Create a split button group by adding two buttons separated by a `separator`.
-}
split : Html msg
split =
    ButtonGroup.new
        |> ButtonGroup.toHtml []
            [ Button.new
                |> Button.text "Button"
                |> Button.secondary
                |> Button.toHtml []
            , ButtonGroup.separator []
            , Button.new
                |> Button.icon (Phosphor.plus Regular |> Phosphor.toHtml [])
                |> Button.label "Add"
                |> Button.secondary
                |> Button.toHtml []
            ]


{-| Wrap an `Input` with buttons.
-}
input : Html msg
input =
    ButtonGroup.new
        |> ButtonGroup.toHtml []
            [ Input.view [ placeholder "Search..." ]
            , Button.new
                |> Button.icon (Phosphor.magnifyingGlass Regular |> Phosphor.toHtml [])
                |> Button.label "Search"
                |> Button.outline
                |> Button.toHtml []
            ]


{-| Wrap an `InputGroup` to create complex input layouts.
-}
inputGroup : State -> Html State.Msg
inputGroup state =
    let
        voiceEnabled =
            State.get "button-group-voice" state == Just "true"
    in
    ButtonGroup.new
        |> ButtonGroup.toHtml [ class "[--radius:9999rem]" ]
            [ ButtonGroup.new
                |> ButtonGroup.toHtml []
                    [ Button.new
                        |> Button.icon (Phosphor.plus Regular |> Phosphor.toHtml [])
                        |> Button.label "Add"
                        |> Button.outline
                        |> Button.toHtml []
                    ]
            , ButtonGroup.new
                |> ButtonGroup.toHtml []
                    [ InputGroup.view []
                        [ InputGroup.input
                            [ placeholder
                                (if voiceEnabled then
                                    "Record and send audio..."

                                 else
                                    "Send a message..."
                                )
                            , disabled voiceEnabled
                            ]
                        , InputGroup.end []
                            [ InputGroup.button
                                |> Button.icon (Phosphor.waveform Regular |> Phosphor.toHtml [])
                                |> Button.label "Voice Mode"
                                |> Button.extraSmall
                                |> Button.toHtml
                                    [ onClick (State.set "button-group-voice" (boolean (not voiceEnabled)))
                                    , attribute "aria-pressed" (boolean voiceEnabled)
                                    , attribute "data-active" (boolean voiceEnabled)
                                    , class "data-[active=true]:bg-orange-100 data-[active=true]:text-orange-700 dark:data-[active=true]:bg-orange-800 dark:data-[active=true]:text-orange-100"
                                    ]
                            ]
                        ]
                    ]
            ]


{-| Create a split button group with a menu. The menu is a `Popover` here, as there is no dropdown menu yet.
-}
dropdownMenu : Html msg
dropdownMenu =
    ButtonGroup.new
        |> ButtonGroup.toHtml []
            [ Button.new
                |> Button.text "Follow"
                |> Button.outline
                |> Button.toHtml []
            , Popover.new
                |> Popover.id "button-group-follow-more"
                |> Popover.trigger
                    (attribute "aria-label" "More Options"
                        :: class "ps-2!"
                        :: (Button.new
                                |> Button.outline
                                |> Button.toAttributes
                           )
                    )
                    [ Phosphor.caretDown Regular |> Phosphor.toHtml [] ]
                |> Popover.content
                    (menuGroups
                        [ [ menuItem Phosphor.speakerSlash "Mute Conversation"
                          , menuItem Phosphor.check "Mark as Read"
                          , menuItem Phosphor.warning "Report Conversation"
                          , menuItem Phosphor.userMinus "Block User"
                          , menuItem Phosphor.share "Share Conversation"
                          , menuItem Phosphor.copy "Copy Conversation"
                          ]
                        , [ destructiveMenuItem Phosphor.trash "Delete Conversation" ]
                        ]
                    )
                |> Popover.alignEnd
                |> Popover.toHtml [ class "w-44" ]
            ]


{-| Pair with a `Select`.
-}
select : State -> Html State.Msg
select state =
    let
        currency =
            State.get "button-group-currency" state |> Maybe.withDefault "$"
    in
    ButtonGroup.new
        |> ButtonGroup.toHtml []
            [ ButtonGroup.new
                |> ButtonGroup.toHtml []
                    [ Select.new
                        |> Select.id "button-group-currency"
                        |> Select.onSelect (State.set "button-group-currency")
                        |> Select.value (Just currency)
                        |> Select.alignToEdge
                        |> Select.items
                            [ Select.item "$" [ text "$" ]
                            , Select.item "€" [ text "€" ]
                            , Select.item "£" [ text "£" ]
                            ]
                        |> Select.toHtml [ class "font-mono", attribute "aria-label" "Currency" ]
                    , Input.view [ placeholder "10.00", pattern "[0-9]*" ]
                    ]
            , ButtonGroup.new
                |> ButtonGroup.toHtml []
                    [ Button.new
                        |> Button.icon (Phosphor.arrowRight Regular |> Phosphor.toHtml [])
                        |> Button.label "Send"
                        |> Button.outline
                        |> Button.toHtml []
                    ]
            ]


{-| Use with a `Popover`.
-}
popover : Html msg
popover =
    ButtonGroup.new
        |> ButtonGroup.toHtml []
            [ Button.new
                |> Button.text "Copilot"
                |> Button.startIcon (Phosphor.robot Regular |> Phosphor.toHtml [])
                |> Button.outline
                |> Button.toHtml []
            , Popover.new
                |> Popover.id "button-group-copilot"
                |> Popover.trigger
                    (attribute "aria-label" "Open Popover"
                        :: (Button.new
                                |> Button.icon (Phosphor.caretDown Regular |> Phosphor.toHtml [])
                                |> Button.outline
                                |> Button.toAttributes
                           )
                    )
                    [ Phosphor.caretDown Regular |> Phosphor.toHtml [] ]
                |> Popover.title [ text "Start a new task with Copilot" ]
                |> Popover.description [ text "Describe your task in natural language." ]
                |> Popover.content
                    [ Field.view []
                        [ Field.label [ for "button-group-task", class "sr-only" ] [ text "Task Description" ]
                        , Textarea.view [ id "button-group-task", placeholder "I need to...", class "resize-none" ]
                        , Field.description [] [ text "Copilot will open a pull request for review." ]
                        ]
                    ]
                |> Popover.alignEnd
                |> Popover.toHtml [ class "rounded-xl text-sm" ]
            ]


rtl : Html msg
rtl =
    let
        more =
            Phosphor.dotsThree Regular |> Phosphor.toHtml []
    in
    div [ dir "rtl" ]
        [ ButtonGroup.new
            |> ButtonGroup.toHtml []
                [ ButtonGroup.new
                    |> ButtonGroup.toHtml [ class "hidden sm:flex" ]
                        [ Button.new
                            |> Button.icon (Phosphor.arrowLeft Regular |> Phosphor.toHtml [ Svg.Attributes.class "rtl:rotate-180" ])
                            |> Button.label "Go Back"
                            |> Button.outline
                            |> Button.toHtml []
                        ]
                , ButtonGroup.new
                    |> ButtonGroup.toHtml []
                        [ Button.new
                            |> Button.text "أرشفة"
                            |> Button.outline
                            |> Button.toHtml []
                        , Button.new
                            |> Button.text "تقرير"
                            |> Button.outline
                            |> Button.toHtml []
                        ]
                , ButtonGroup.new
                    |> ButtonGroup.toHtml []
                        [ Button.new
                            |> Button.text "تأجيل"
                            |> Button.outline
                            |> Button.toHtml []
                        , Popover.new
                            |> Popover.id "button-group-rtl-more"
                            |> Popover.trigger
                                (attribute "aria-label" "More Options"
                                    :: (Button.new
                                            |> Button.icon more
                                            |> Button.outline
                                            |> Button.toAttributes
                                       )
                                )
                                [ more ]
                            |> Popover.content
                                (menuGroups
                                    [ [ menuItem Phosphor.envelopeOpen "وضع علامة كمقروء"
                                      , menuItem Phosphor.archive "أرشفة"
                                      ]
                                    , [ menuItem Phosphor.clock "تأجيل"
                                      , menuItem Phosphor.calendarPlus "إضافة إلى التقويم"
                                      , menuItem Phosphor.listPlus "إضافة إلى القائمة"
                                      ]
                                    , [ destructiveMenuItem Phosphor.trash "سلة المهملات" ]
                                    ]
                                )
                            |> Popover.alignStart
                            |> Popover.toHtml [ class "w-40", dir "rtl" ]
                        ]
                ]
        ]



-- HELPERS


{-| Groups of menu items divided by separators, for a popover standing in for a dropdown menu.
-}
menuGroups : List (List (Html msg)) -> List (Html msg)
menuGroups groups =
    groups
        |> List.map (div [ class "flex flex-col" ])
        |> List.intersperse
            (Separator.new
                |> Separator.toHtml [ class "-mx-2.5 w-auto" ]
            )


menuItem : Phosphor.Icon -> String -> Html msg
menuItem icon label =
    Button.new
        |> Button.text label
        |> Button.startIcon (icon Regular |> Phosphor.toHtml [])
        |> Button.ghost
        |> Button.small
        |> Button.toHtml [ class "w-full justify-start font-normal" ]


destructiveMenuItem : Phosphor.Icon -> String -> Html msg
destructiveMenuItem icon label =
    Button.new
        |> Button.text label
        |> Button.startIcon (icon Regular |> Phosphor.toHtml [])
        |> Button.ghost
        |> Button.small
        |> Button.toHtml [ class "w-full justify-start font-normal text-destructive hover:text-destructive [&_svg]:text-destructive" ]


boolean : Bool -> String
boolean bool =
    if bool then
        "true"

    else
        "false"
