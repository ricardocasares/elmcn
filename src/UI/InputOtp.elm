module UI.InputOtp exposing
    ( InputOtp, NeedsValue, NeedsHandler, NeedsGroup, Ready, Slots, NoGroups, HasGroups
    , new
    , value, onChange
    , group, separator
    , digits, letters, alphanumeric
    , disabled, invalid
    , toHtml
    )

{-| Accessible one-time password component with copy-paste functionality.

An input OTP is built with `new`, given a `value`, an `onChange` handler and at least one `group` of slots, and rendered with `toHtml`:

    InputOtp.new
        |> InputOtp.value model.code
        |> InputOtp.onChange CodeChanged
        |> InputOtp.group [] 3
        |> InputOtp.separator []
        |> InputOtp.group [] 3
        |> InputOtp.digits
        |> InputOtp.toHtml [ id "otp" ]

The value lives in your model and `onChange` tells you when it changes. An input OTP needs a value before it can take a handler, and a handler and a group before it can be rendered. Groups and separators are laid out in the order you add them, and the number of slots in all the groups together is the maximum length of the code.

Behind the slots there is a single native `<input>`, stretched over them and made invisible. That is why pasting, SMS autofill (`autocomplete="one-time-code"`), the mobile keyboard and forms all work with no JavaScript, ports or component state. The slots only show what the input holds. The caret is always at the end of the code, and the active slot is highlighted while the input has focus.

@docs InputOtp, NeedsValue, NeedsHandler, NeedsGroup, Ready, Slots, NoGroups, HasGroups


# Constructor

@docs new


# Value

@docs value, onChange


# Layout

@docs group, separator


# Characters

By default any character is accepted. These setters restrict it, and the last one wins.

@docs digits, letters, alphanumeric


# Setters

@docs disabled, invalid


# Rendering

@docs toHtml

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)
import Html.Events
import Json.Decode as Decode


{-| An input OTP being built.

`status` is [`NeedsValue`](#NeedsValue) after `new`, [`NeedsHandler`](#NeedsHandler) once it has a [`value`](#value), [`NeedsGroup`](#NeedsGroup) once it also has an [`onChange`](#onChange) handler, and [`Ready`](#Ready) once it has a [`group`](#group).

-}
type InputOtp status msg
    = InputOtp
        { value : String
        , onChange : Maybe (String -> msg)
        , layout : List (Part msg)
        , characters : Characters
        , disabled : Bool
        , invalid : Bool
        }


{-| An input OTP that still needs a [`value`](#value).
-}
type NeedsValue
    = NeedsValue


{-| An input OTP that still needs an [`onChange`](#onChange) handler.
-}
type NeedsHandler
    = NeedsHandler


{-| An input OTP that has a value and a handler, and needs a [`group`](#group) before it can be rendered.
-}
type alias NeedsGroup =
    Slots NoGroups


{-| The input OTP can be rendered.
-}
type alias Ready =
    Slots HasGroups


{-| The status of an input OTP that has a value and a handler. `hasGroups` says whether it has a [`group`](#group) yet, which lets `group` be called any number of times but `toHtml` only after the first.
-}
type Slots hasGroups
    = Slots


{-| There is no [`group`](#group) yet.
-}
type NoGroups
    = NoGroups


{-| There is at least one [`group`](#group).
-}
type HasGroups
    = HasGroups


type Part msg
    = Group (List (Attribute msg)) Int
    | Separator (List (Attribute msg))


type Characters
    = AnyCharacter
    | Digits
    | Letters
    | Alphanumeric



-- CONSTRUCTOR


{-| An empty input OTP that accepts any character. Give it a [`value`](#value), an [`onChange`](#onChange) handler and a [`group`](#group) to make it renderable.
-}
new : InputOtp NeedsValue msg
new =
    InputOtp
        { value = ""
        , onChange = Nothing
        , layout = []
        , characters = AnyCharacter
        , disabled = False
        , invalid = False
        }



-- VALUE


{-| The code typed so far. Anything past the last slot is cut off.
-}
value : String -> InputOtp NeedsValue msg -> InputOtp NeedsHandler msg
value v (InputOtp config) =
    InputOtp { config | value = v }


{-| Called with the new code whenever it changes: typing, deleting and pasting. Characters the input doesn't accept are already removed, and the code is never longer than the number of slots.
-}
onChange : (String -> msg) -> InputOtp NeedsHandler msg -> InputOtp NeedsGroup msg
onChange toMsg (InputOtp config) =
    InputOtp
        { value = config.value
        , onChange = Just toMsg
        , layout = config.layout
        , characters = config.characters
        , disabled = config.disabled
        , invalid = config.invalid
        }



-- LAYOUT


{-| A group of slots that sit together in one bordered row, such as `group [] 3`. Add as many as you like; the slots are filled in the order of the groups.

The attributes go on the group after its own, so they can restyle its slots: `class "*:data-[slot=input-otp-slot]:h-12"`.

-}
group : List (Attribute msg) -> Int -> InputOtp (Slots groups) msg -> InputOtp Ready msg
group attrs size (InputOtp config) =
    InputOtp
        { value = config.value
        , onChange = config.onChange
        , layout = config.layout ++ [ Group attrs (Basics.max 0 size) ]
        , characters = config.characters
        , disabled = config.disabled
        , invalid = config.invalid
        }


{-| A dash between two groups. It can only follow a [`group`](#group). The attributes go on the separator.
-}
separator : List (Attribute msg) -> InputOtp Ready msg -> InputOtp Ready msg
separator attrs (InputOtp config) =
    InputOtp { config | layout = config.layout ++ [ Separator attrs ] }



-- CHARACTERS


{-| Only accepts the digits 0 to 9 and shows the numeric keyboard.
-}
digits : InputOtp status msg -> InputOtp status msg
digits (InputOtp config) =
    InputOtp { config | characters = Digits }


{-| Only accepts the letters a to z, either case.
-}
letters : InputOtp status msg -> InputOtp status msg
letters (InputOtp config) =
    InputOtp { config | characters = Letters }


{-| Only accepts letters and digits.
-}
alphanumeric : InputOtp status msg -> InputOtp status msg
alphanumeric (InputOtp config) =
    InputOtp { config | characters = Alphanumeric }



-- SETTERS


{-| Dims the input OTP and stops it from taking focus or input.
-}
disabled : InputOtp status msg -> InputOtp status msg
disabled (InputOtp config) =
    InputOtp { config | disabled = True }


{-| Marks the input and every slot `aria-invalid`, which gives the groups the destructive border and ring.
-}
invalid : InputOtp status msg -> InputOtp status msg
invalid (InputOtp config) =
    InputOtp { config | invalid = True }



-- RENDERING


{-| Renders the input OTP.

The attributes go on the `<input>`, after its own, as they do upstream: that is where `id` (for a label's `for`), `name`, `required`, `autofocus` and `aria-describedby` belong.

-}
toHtml : List (Attribute msg) -> InputOtp Ready msg -> Html msg
toHtml attrs (InputOtp config) =
    let
        total =
            List.foldl
                (\part sum ->
                    case part of
                        Group _ size ->
                            sum + size

                        Separator _ ->
                            sum
                )
                0
                config.layout

        current =
            String.left total config.value

        accepts =
            characterTest config.characters

        sanitize string =
            String.filter accepts string |> String.left total

        -- The slot that takes the next character. When the code is full it stays on the last slot.
        activeIndex =
            Basics.min (String.length current) (total - 1)

        ( parts, _ ) =
            List.foldl
                (\part ( rendered, start ) ->
                    case part of
                        Group groupAttrs size ->
                            ( rendered ++ [ viewGroup config.invalid current activeIndex start groupAttrs size ]
                            , start + size
                            )

                        Separator separatorAttrs ->
                            ( rendered ++ [ viewSeparator separatorAttrs ], start )
                )
                ( [], 0 )
                config.layout

        events =
            case config.onChange of
                Just toMsg ->
                    Html.Events.onInput (sanitize >> toMsg)
                        :: (case config.characters of
                                AnyCharacter ->
                                    []

                                _ ->
                                    -- Rejecting a keystroke at the source keeps the input's own text in
                                    -- step with the model: when the model value doesn't change, Elm
                                    -- wouldn't touch the DOM value and the stray character would stay.
                                    -- Paste carries no `data` and is cleaned up by the input handler.
                                    [ Html.Events.preventDefaultOn "beforeinput" (rejectDecoder accepts (toMsg current)) ]
                           )

                Nothing ->
                    []
    in
    Html.div
        [ attribute "data-input-otp-container" ""
        , attribute "translate" "no"
        , class "group/input-otp relative flex items-center gap-2 has-disabled:opacity-50 pointer-events-none select-none"
        ]
        (parts
            ++ [ Html.div [ class "pointer-events-none absolute inset-0" ]
                    [ Html.input
                        ([ attribute "data-slot" "input-otp"
                         , attribute "data-input-otp" ""
                         , Html.Attributes.type_ "text"
                         , attribute "autocomplete" "one-time-code"
                         , Html.Attributes.spellcheck False
                         , attribute "inputmode" (inputMode config.characters)
                         , Html.Attributes.maxlength total
                         , Html.Attributes.value current
                         , Html.Attributes.disabled config.disabled
                         , class "absolute inset-0 flex h-full w-full cursor-text border-0 bg-transparent text-left font-mono text-base leading-none tracking-[-.5em] text-transparent caret-transparent opacity-100 shadow-none outline-none pointer-events-auto tabular-nums selection:bg-transparent selection:text-transparent disabled:cursor-not-allowed"
                         , class "autofill:bg-transparent autofill:text-transparent autofill:shadow-[inset_0_0_0_1000px_transparent] autofill:[-webkit-text-fill-color:transparent]"

                         -- The library's iOS tweak, which keeps the invisible text lined up with the slots.
                         , class "supports-[-webkit-touch-callout:none]:-left-px supports-[-webkit-touch-callout:none]:right-px supports-[-webkit-touch-callout:none]:font-thin supports-[-webkit-touch-callout:none]:tracking-[-.6em]"
                         ]
                            ++ patternAttribute config.characters
                            ++ (if config.invalid then
                                    [ attribute "aria-invalid" "true" ]

                                else
                                    []
                               )
                            ++ events
                            ++ attrs
                        )
                        []
                    ]
               ]
        )


characterTest : Characters -> Char -> Bool
characterTest characters =
    case characters of
        AnyCharacter ->
            always True

        Digits ->
            Char.isDigit

        Letters ->
            Char.isAlpha

        Alphanumeric ->
            Char.isAlphaNum


inputMode : Characters -> String
inputMode characters =
    case characters of
        Letters ->
            "text"

        Alphanumeric ->
            "text"

        _ ->
            "numeric"


patternAttribute : Characters -> List (Attribute msg)
patternAttribute characters =
    case characters of
        AnyCharacter ->
            []

        Digits ->
            [ attribute "pattern" "[0-9]*" ]

        Letters ->
            [ attribute "pattern" "[a-zA-Z]*" ]

        Alphanumeric ->
            [ attribute "pattern" "[a-zA-Z0-9]*" ]


{-| Succeeds, with the message and `True` to prevent the default, when the text about to be
inserted has a character that isn't accepted. Fails, leaving the event alone, otherwise.
-}
rejectDecoder : (Char -> Bool) -> msg -> Decode.Decoder ( msg, Bool )
rejectDecoder accepts msg =
    Decode.field "data" (Decode.nullable Decode.string)
        |> Decode.andThen
            (\data ->
                case data of
                    Just text ->
                        if String.all accepts text then
                            Decode.fail "Accepted."

                        else
                            Decode.succeed ( msg, True )

                    Nothing ->
                        Decode.fail "No inserted text."
            )


viewGroup : Bool -> String -> Int -> Int -> List (Attribute msg) -> Int -> Html msg
viewGroup isInvalid current activeIndex start attrs size =
    Html.div
        (attribute "data-slot" "input-otp-group"
            :: class "flex items-center rounded-lg has-aria-invalid:border-destructive has-aria-invalid:ring-3 has-aria-invalid:ring-destructive/20 dark:has-aria-invalid:ring-destructive/40"
            :: attrs
        )
        (List.range start (start + size - 1)
            |> List.map (viewSlot isInvalid current activeIndex)
        )


{-| Nova's slot classes, except that each `data-[active=true]:` variant also needs the input
to have focus. Upstream only marks a slot active while the input is focused, and here the
active slot is marked all the time, because Elm doesn't track focus.

Nova's `border-r`, `first:rounded-l-lg`, `first:border-l` and `last:rounded-r-lg` are the
logical `border-e`, `first:rounded-s-lg`, `first:border-s` and `last:rounded-e-lg`, which are
the same in left-to-right text and follow the direction in right-to-left text.

-}
viewSlot : Bool -> String -> Int -> Int -> Html msg
viewSlot isInvalid current activeIndex index =
    let
        char =
            String.slice index (index + 1) current

        active =
            index == activeIndex
    in
    Html.div
        ([ attribute "data-slot" "input-otp-slot"
         , attribute "data-active"
            (if active then
                "true"

             else
                "false"
            )
         , class "relative flex items-center justify-center size-8 border-y border-e border-input text-sm outline-none transition-all first:rounded-s-lg first:border-s last:rounded-e-lg dark:bg-input/30 aria-invalid:border-destructive"
         , class "group-focus-within/input-otp:data-[active=true]:z-10 group-focus-within/input-otp:data-[active=true]:border-ring group-focus-within/input-otp:data-[active=true]:ring-3 group-focus-within/input-otp:data-[active=true]:ring-ring/50"
         , class "group-focus-within/input-otp:data-[active=true]:aria-invalid:border-destructive group-focus-within/input-otp:data-[active=true]:aria-invalid:ring-destructive/20 dark:group-focus-within/input-otp:data-[active=true]:aria-invalid:ring-destructive/40"
         ]
            ++ (if isInvalid then
                    [ attribute "aria-invalid" "true" ]

                else
                    []
               )
        )
        (Html.text char
            :: (if active && char == "" then
                    [ Html.div [ class "pointer-events-none absolute inset-0 hidden items-center justify-center group-focus-within/input-otp:flex" ]
                        [ Html.div [ class "h-4 w-px animate-caret-blink bg-foreground duration-1000" ] [] ]
                    ]

                else
                    []
               )
        )


viewSeparator : List (Attribute msg) -> Html msg
viewSeparator attrs =
    Html.div
        (attribute "data-slot" "input-otp-separator"
            :: attribute "role" "separator"
            :: class "flex items-center [&_svg:not([class*='size-'])]:size-4"
            :: attrs
        )
        [ -- Lucide's minus, drawn with CSS so that no icon package is needed: a 2/24 stroke
          -- from 5 to 19 with round caps, so 16/24 of the icon wide.
          Html.span [ attribute "aria-hidden" "true", class "flex size-4 items-center justify-center" ]
            [ Html.span [ class "h-[1.333px] w-[10.667px] rounded-full bg-current" ] [] ]
        ]
