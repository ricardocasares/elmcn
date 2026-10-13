module Examples.MessageScroller exposing (..)

import Browser.Dom
import Html exposing (Html, div, p, span, text)
import Html.Attributes exposing (attribute, class, disabled, id, name, placeholder, readonly, type_, value)
import Html.Events exposing (onClick)
import Html.Keyed
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import Task
import UI.Button as Button
import UI.Card as Card
import UI.DropdownMenu as DropdownMenu
import UI.Empty as Empty
import UI.InputGroup as InputGroup
import UI.MessageScroller as MessageScroller
import UI.Popover as Popover
import UI.Select as Select
import UI.Slider as Slider
import UI.Spinner as Spinner
import UI.Tabs as Tabs
import UI.ToggleGroup as ToggleGroup


demo : State -> Html State.Msg
demo state =
    let
        thread =
            conversation { key = "demo", script = rows "demo" streamingConversation, initial = 0 } state
    in
    frame "Demo is read only. Press send to send messages."
        (Card.new
            |> Card.title [ text "New Chat" ]
            |> Card.description [ text "How can I help you today?" ]
            |> Card.action (resetButton "Reset conversation" (thread.status /= Ready) (reset thread))
            |> Card.content [ class "min-h-0 flex-1 overflow-hidden px-0" ]
                [ if List.isEmpty thread.rows then
                    emptyChat "Morning, shadcn!" "What are we working on today? Press send to start a new conversation"

                  else
                    let
                        scroller =
                            MessageScroller.new
                                |> MessageScroller.id thread.viewport
                                |> MessageScroller.padding "var(--card-spacing)"
                                |> MessageScroller.busy (thread.status /= Ready)
                                |> MessageScroller.items [] (messageRows thread { user = Muted, assistant = Ghost, enter = "slide-up" })
                                |> (if thread.sent then
                                        MessageScroller.holdTurn

                                    else
                                        identity
                                   )
                                |> MessageScroller.endButton (scrollToEndSmoothly thread)
                                |> MessageScroller.onScroll (scrolled thread.key)
                                |> MessageScroller.scrollable thread.edges
                                |> MessageScroller.toHtml []
                    in
                    Html.Keyed.node "div" [ class "size-full" ] [ ( String.fromInt thread.epoch, scroller ) ]
                ]
            |> Card.footer [ class "flex-col gap-2" ]
                [ composer thread { exhausted = "No messages queued. Reset the conversation.", extra = [] } ]
            |> Card.toHtml [ class cardClass ]
        )


{-| A turn is the part of the conversation that starts a new exchange, and an anchor is the row the viewport treats as its start. Mark that row with `anchor`: when a new anchor is added, the viewport moves it near the top, with a peek of the previous turn above it, and the reply fills in below. Toggle the anchor to the assistant's message to see the difference.
-}
anchoring : State -> Html State.Msg
anchoring state =
    let
        role =
            if State.get "anchoring-role" state == Just "assistant" then
                Assistant

            else
                User

        count =
            intAt "anchoring-count" 0 state

        epoch =
            intAt "anchoring-epoch" 0 state

        next =
            List.drop count anchoringScript |> List.head

        -- Changing the anchor starts the transcript over.
        anchorChosen choice =
            if choice == roleName role then
                State.none

            else
                State.batch
                    [ State.set "anchoring-role" choice
                    , State.remove "anchoring-count"
                    , State.set "anchoring-epoch" (String.fromInt (epoch + 1))
                    ]

        -- A row that is added as an anchor is scrolled to; the others wait below it.
        append row =
            State.batch
                [ State.set "anchoring-count" (String.fromInt (count + 1))
                , if row.role == role then
                    State.run (MessageScroller.scrollToEnd MessageScroller.Instant "anchoring-viewport")

                  else
                    State.none
                ]
    in
    frame "Toggle the anchor role, then send messages to compare where turns settle."
        (Card.new
            |> Card.title [ text "Anchoring Turns" ]
            |> Card.description [ text "Choose which role settles near the top edge." ]
            |> Card.action
                (resetButton "Reset anchored turns"
                    (count == 0)
                    (State.batch
                        [ State.remove "anchoring-count"
                        , State.set "anchoring-epoch" (String.fromInt (epoch + 1))
                        ]
                    )
                )
            |> Card.content [ class "min-h-0 flex-1 overflow-hidden px-0" ]
                [ if count == 0 then
                    emptyChat "No anchored messages yet" "Send the first message to see the selected role anchor."

                  else
                    let
                        shown =
                            List.take count anchoringScript

                        scroller =
                            MessageScroller.new
                                |> MessageScroller.id "anchoring-viewport"
                                |> MessageScroller.padding "var(--card-spacing)"
                                |> MessageScroller.items []
                                    (List.indexedMap
                                        (\index row ->
                                            MessageScroller.item row.id
                                                [ class
                                                    (if row.role == User && index == count - 1 then
                                                        "message-enter-slide-up"

                                                     else
                                                        ""
                                                    )
                                                ]
                                                [ viewMessage
                                                    { align = alignOf row.role
                                                    , variant = bubbleOf { user = Muted, assistant = Ghost } row.role
                                                    , text = row.text
                                                    }
                                                ]
                                                |> (if row.role == role then
                                                        MessageScroller.anchor

                                                    else
                                                        identity
                                                   )
                                        )
                                        shown
                                    )
                                |> MessageScroller.holdTurn
                                |> MessageScroller.endButton (State.run (MessageScroller.scrollToEnd MessageScroller.Smooth "anchoring-viewport"))
                                |> MessageScroller.onScroll (scrolled "anchoring")
                                |> MessageScroller.scrollable (edgesOf "anchoring" state)
                                |> MessageScroller.toHtml []
                    in
                    Html.Keyed.node "div" [ class "size-full" ] [ ( String.fromInt epoch, scroller ) ]
                ]
            |> Card.footer []
                [ ToggleGroup.new
                    |> ToggleGroup.onToggle anchorChosen
                    |> ToggleGroup.pressed [ roleName role ]
                    |> ToggleGroup.items
                        [ ToggleGroup.item "user" [ text "User" ]
                            |> ToggleGroup.label "Anchor user messages"
                        , ToggleGroup.item "assistant" [ text "Assistant" ]
                            |> ToggleGroup.label "Anchor assistant messages"
                        ]
                    |> ToggleGroup.toHtml [ attribute "aria-label" "Select scroll anchor role" ]
                , Button.new
                    |> Button.icon (Phosphor.arrowUp Regular |> Phosphor.toHtml [])
                    |> Button.label "Send Message"
                    |> Button.toHtml
                        [ class "ms-auto"
                        , disabled (next == Nothing)
                        , onClick (Maybe.map append next |> Maybe.withDefault State.none)
                        ]
                ]
            |> Card.toHtml [ class cardClass ]
        )


{-| In a group chat, the turn boundary is more specific than "the user message". It is often the message that asks the model to respond, or a marker like "Rocky has joined the chat". Because anchoring is role-independent, you can anchor a marker just as easily as a message.
-}
groupChat : State -> Html State.Msg
groupChat state =
    let
        turn =
            State.get "group-turn" state |> Maybe.withDefault "idle"

        epoch =
            intAt "group-epoch" 0 state

        viewParticipant rowId sender content =
            let
                self =
                    sender == "Grace"

                variant =
                    if self then
                        Muted

                    else if String.endsWith "(Agent)" sender then
                        Ghost

                    else
                        Tinted
            in
            MessageScroller.item rowId
                []
                [ if self then
                    viewMessage { align = End, variant = variant, text = content }

                  else
                    viewHeaderMessage { align = Start, variant = variant, sender = sender, text = content }
                ]

        rowsShown =
            [ viewParticipant "group-1" "Grace" "@mary, the astrophage line keeps matching Venus energy output. Can you check my math?"
            , viewParticipant "group-2" "Mary (Agent)" "Yes. Confirmed. The curve points to a microorganism harvesting stellar energy and breeding near carbon dioxide. If @rocky agrees, this is the clue we need."
            , viewParticipant "group-3" "Grace" "ping @rocky"
                |> MessageScroller.anchor
            ]
                ++ (if turn == "idle" then
                        []

                    else
                        [ MessageScroller.item "group-4" [] [ separator "Rocky has joined the chat" ]
                            |> MessageScroller.anchor
                        ]
                   )
                ++ (if turn == "message" then
                        [ viewParticipant "group-5" "Rocky" "Amaze. Astrophage eats light, makes heat, goes to carbon dioxide. Rocky has fuel model. Grace is smart." ]

                    else
                        []
                   )

        scroller =
            MessageScroller.new
                |> MessageScroller.id "group-viewport"
                |> MessageScroller.padding "var(--card-spacing)"
                |> MessageScroller.items [] rowsShown
                |> (if turn == "idle" then
                        identity

                    else
                        MessageScroller.holdTurn
                   )
                |> MessageScroller.endButton (State.run (MessageScroller.scrollToEnd MessageScroller.Smooth "group-viewport"))
                |> MessageScroller.onScroll (scrolled "group")
                |> MessageScroller.scrollable (edgesOf "group" state)
                |> MessageScroller.toHtml []
    in
    frame "When a user joins, a marker is created. Marking it as an anchor makes it the next turn."
        (Card.new
            |> Card.title [ text "Group Chat" ]
            |> Card.description [ text "A group chat with several participants and an assistant. The marker is marked as a turn." ]
            |> Card.action
                (resetButton "Reset conversation"
                    (turn == "idle")
                    (State.batch
                        [ State.set "group-turn" "idle"
                        , State.set "group-epoch" (String.fromInt (epoch + 1))
                        ]
                    )
                )
            |> Card.content [ class "min-h-0 flex-1 overflow-hidden px-0" ]
                [ Html.Keyed.node "div" [ class "size-full" ] [ ( String.fromInt epoch, scroller ) ] ]
            |> Card.footer [ class "flex-col items-center gap-2" ]
                [ Button.new
                    |> Button.text
                        (if turn == "idle" then
                            "Add Rocky"

                         else
                            "Send Message as Rocky"
                        )
                    |> Button.secondary
                    |> Button.toHtml
                        [ class "w-full"
                        , disabled (turn == "message")
                        , onClick
                            (if turn == "idle" then
                                State.batch
                                    [ State.set "group-turn" "marker"
                                    , State.run (MessageScroller.scrollToEnd MessageScroller.Instant "group-viewport")
                                    ]

                             else
                                State.set "group-turn" "message"
                            )
                        ]
                , p [ class "text-xs text-muted-foreground" ]
                    [ text
                        (if turn == "idle" then
                            "This will create a marker and make it the anchor"

                         else
                            "Now send Rocky's reply into the conversation"
                        )
                    ]
                ]
            |> Card.toHtml [ class cardClass ]
        )


{-| `peek` keeps a slice of the previous turn in view above the anchor, so that the reader keeps their context instead of feeling like the conversation restarted on a blank page. Adjust the peek in the footer to see how it affects the conversation.
-}
previousContext : State -> Html State.Msg
previousContext state =
    let
        thread =
            conversation { key = "context", script = rows "context" streamingConversation, initial = 2 } state

        peek =
            floatAt "context-peek" 64 state

        scroller =
            MessageScroller.new
                |> MessageScroller.id thread.viewport
                |> MessageScroller.padding "var(--card-spacing)"
                |> MessageScroller.scrollMargin 24
                |> MessageScroller.peek (round peek)
                |> MessageScroller.busy (thread.status /= Ready)
                |> MessageScroller.items [] (messageRows thread { user = Muted, assistant = Ghost, enter = "slide-up" })
                |> (if thread.sent then
                        MessageScroller.holdTurn

                    else
                        identity
                   )
                |> MessageScroller.endButton (scrollToEndSmoothly thread)
                |> MessageScroller.onScroll (scrolled thread.key)
                |> MessageScroller.scrollable thread.edges
                |> MessageScroller.toHtml []
    in
    frame "Adjust the slider and send. Observe the peek of the previous message."
        (Card.new
            |> Card.title [ text "Keeping Context Visible" ]
            |> Card.description [ text "New turns keep part of the previous reply in view." ]
            |> Card.action
                (resetButton "Reset context example"
                    (thread.status /= Ready)
                    (State.batch [ reset thread, State.remove "context-peek" ])
                )
            |> Card.content [ class "min-h-0 flex-1 overflow-hidden px-0" ]
                [ Html.Keyed.node "div" [ class "size-full" ] [ ( String.fromInt thread.epoch, scroller ) ] ]
            |> Card.footer [ class "flex-col gap-2" ]
                [ composer thread
                    { exhausted = "No messages queued. Reset the context."
                    , extra =
                        [ div [ class "flex w-28 items-center gap-2" ]
                            [ span [ class "text-xs text-muted-foreground tabular-nums" ] [ text (String.fromFloat peek ++ "px") ]
                            , Slider.new
                                |> Slider.value peek
                                |> Slider.onChange (State.set "context-peek" << String.fromFloat)
                                |> Slider.min 64
                                |> Slider.max 128
                                |> Slider.step 1
                                |> (if thread.status /= Ready then
                                        Slider.disabled

                                    else
                                        identity
                                   )
                                |> Slider.toHtml [ attribute "aria-label" "Previous context peek" ]
                            ]
                        ]
                    }
                ]
            |> Card.toHtml [ class cardClass ]
        )


{-| While the reader is at the end of the transcript, the scroller follows a streamed reply as it grows, and scrolling away releases it. The browser does it by itself with scroll anchoring. The example also runs `scrollToEnd` after a chunk when `onScroll` says the reader is at the end and the viewport has fallen behind it, which covers iOS Safari and the first turn of an empty transcript.
-}
streaming : State -> Html State.Msg
streaming state =
    let
        thread =
            conversation { key = "streaming", script = rows "streaming" streamingConversation, initial = 0 } state
    in
    frame "Streaming is simulated. The reader is followed while at the end."
        (Card.new
            |> Card.title [ text "Streaming Messages" ]
            |> Card.description [ text "The scroller follows the live edge of the conversation." ]
            |> Card.action (resetButton "Reset stream" (List.isEmpty thread.rows || thread.status /= Ready) (reset thread))
            |> Card.content [ class "min-h-0 flex-1 overflow-hidden px-0" ]
                [ if List.isEmpty thread.rows then
                    emptyChat "Ready to Stream" "Press send to stream a scripted launch summary."

                  else
                    let
                        scroller =
                            MessageScroller.new
                                |> MessageScroller.id thread.viewport
                                |> MessageScroller.padding "var(--card-spacing)"
                                |> MessageScroller.busy (thread.status /= Ready)
                                |> MessageScroller.items [] (messageRows thread { user = Muted, assistant = Ghost, enter = "slide-up" })
                                |> (if thread.sent then
                                        MessageScroller.holdTurn

                                    else
                                        identity
                                   )
                                |> MessageScroller.endButton (scrollToEndSmoothly thread)
                                |> MessageScroller.onScroll (scrolled thread.key)
                                |> MessageScroller.scrollable thread.edges
                                |> MessageScroller.toHtml []
                    in
                    Html.Keyed.node "div" [ class "size-full" ] [ ( String.fromInt thread.epoch, scroller ) ]
                ]
            |> Card.footer [ class "flex-col gap-2" ]
                [ composer thread { exhausted = "No messages queued. Reset the stream.", extra = [] } ]
            |> Card.toHtml [ class cardClass ]
        )


{-| A saved thread can open at the start, at the end, or at the last anchor: the last meaningful turn, like the user's latest message, with the reply below it. A last turn that already fits in the viewport opens at the end. Changing the tab renders a new scroller, which is what applies the opening position again.
-}
openingPosition : State -> Html State.Msg
openingPosition state =
    let
        position =
            State.get "opening-position" state |> Maybe.withDefault "last-anchor"

        epoch =
            intAt "opening-epoch" 0 state

        scroller =
            MessageScroller.new
                |> MessageScroller.id "opening-viewport"
                |> MessageScroller.padding "var(--card-spacing)"
                |> MessageScroller.items []
                    (List.map
                        (\row ->
                            MessageScroller.item row.id
                                []
                                [ viewMessage
                                    { align = alignOf row.role
                                    , variant = bubbleOf { user = Muted, assistant = Ghost } row.role
                                    , text = row.text
                                    }
                                ]
                                |> (if row.role == User then
                                        MessageScroller.anchor

                                    else
                                        identity
                                   )
                        )
                        openingTranscript
                    )
                |> (case position of
                        "start" ->
                            MessageScroller.openAtStart

                        "last-anchor" ->
                            MessageScroller.openAtLastAnchor

                        _ ->
                            identity
                   )
                |> MessageScroller.endButton (State.run (MessageScroller.scrollToEnd MessageScroller.Smooth "opening-viewport"))
                |> MessageScroller.onScroll (scrolled "opening")
                |> MessageScroller.scrollable
                    (if State.get "opening-edges" state == Nothing && position == "start" then
                        { start = False, end = True }

                     else
                        edgesOf "opening" state
                    )
                |> MessageScroller.toHtml []
    in
    frame "Toggle the opening position to see where the transcript starts when you open the thread."
        (Card.new
            |> Card.title [ text "Opening Position" ]
            |> Card.description [ text "Choose where a saved transcript opens." ]
            |> Card.content [ class "min-h-0 flex-1 overflow-hidden px-0" ]
                [ Html.Keyed.node "div" [ class "size-full" ] [ ( String.fromInt epoch, scroller ) ] ]
            |> Card.footer [ class "justify-center" ]
                [ Tabs.new
                    |> Tabs.id "opening-tabs"
                    |> Tabs.onSelect
                        (\choice ->
                            State.batch
                                [ State.set "opening-position" choice
                                , State.remove "opening-edges"
                                , State.set "opening-epoch" (String.fromInt (epoch + 1))
                                ]
                        )
                    |> Tabs.value position
                    |> Tabs.tabs
                        [ Tabs.tab "start" [ text "start" ] []
                        , Tabs.tab "end" [ text "end" ] []
                        , Tabs.tab "last-anchor" [ text "last-anchor" ] []
                        ]
                    |> Tabs.toHtml [ class "w-full [&_[role=tablist]]:w-full" ]
                ]
            |> Card.toHtml [ class cardClass ]
        )


{-| Loading earlier messages should not move the conversation the reader is already looking at. The browser keeps the visible row in place when older rows are added above it. `markPlace` and `restorePlace` do the same where it doesn't, such as in iOS Safari: the first measures a row, the second scrolls it back to where it was once the new rows have rendered.
-}
loadHistory : State -> Html State.Msg
loadHistory state =
    let
        loaded =
            intAt "history-count" 5 state

        epoch =
            intAt "history-epoch" 0 state

        visible =
            List.drop (List.length historyScript - loaded) historyScript

        canLoad =
            loaded < List.length historyScript

        loadHistoryFrom first =
            MessageScroller.markPlace { viewport = "history-viewport", message = first.id }
                |> Task.map
                    (\place ->
                        State.batch
                            [ State.set "history-count" (String.fromInt (List.length historyScript))
                            , State.run (MessageScroller.restorePlace place)
                            ]
                    )
                |> State.attempt

        scroller =
            MessageScroller.new
                |> MessageScroller.id "history-viewport"
                |> MessageScroller.padding "var(--card-spacing)"
                |> MessageScroller.items []
                    (List.map
                        (\row ->
                            MessageScroller.item row.id
                                []
                                [ viewMessage
                                    { align = alignOf row.role
                                    , variant = bubbleOf { user = Muted, assistant = Ghost } row.role
                                    , text = row.text
                                    }
                                ]
                        )
                        visible
                        ++ [ MessageScroller.item "history-end" [] [ separator "End of Conversation" ] ]
                    )
                |> MessageScroller.endButton (State.run (MessageScroller.scrollToEnd MessageScroller.Smooth "history-viewport"))
                |> MessageScroller.onScroll (scrolled "history")
                |> MessageScroller.scrollable (edgesOf "history" state)
                |> MessageScroller.toHtml []
    in
    frame "Click Load History to load the entire conversation."
        (Card.new
            |> Card.title [ text "Load History" ]
            |> Card.description [ text "Prepended messages keep your place." ]
            |> Card.action
                (resetButton "Reset loaded messages"
                    (loaded == 5)
                    (State.batch
                        [ State.remove "history-count"
                        , State.set "history-epoch" (String.fromInt (epoch + 1))
                        ]
                    )
                )
            |> Card.content [ class "min-h-0 flex-1 overflow-hidden px-0" ]
                [ Html.Keyed.node "div" [ class "size-full" ] [ ( String.fromInt epoch, scroller ) ] ]
            |> Card.footer [ class "flex-col items-center gap-2" ]
                [ Button.new
                    |> Button.text
                        (if canLoad then
                            "Load History"

                         else
                            "History Loaded"
                        )
                    |> Button.secondary
                    |> Button.toHtml
                        [ class "w-full"
                        , disabled (not canLoad)
                        , onClick (visible |> List.head |> Maybe.map loadHistoryFrom |> Maybe.withDefault State.none)
                        ]
                , p [ class "text-xs text-muted-foreground" ] [ text "Restore earlier messages while keeping your place." ]
                ]
            |> Card.toHtml [ class cardClass ]
        )


{-| A row can be animated directly. Give the newest row a class that animates opacity, transform or filter when it is added, and keep its `id` and `anchor`. Avoid animating height, margin or padding, which fight the scroller's positioning, and skip the entrance for `prefers-reduced-motion`.
-}
animation : State -> Html State.Msg
animation state =
    let
        thread =
            conversation { key = "animation", script = rows "animation" animationConversation, initial = 0 } state

        preset =
            State.get "animation-preset" state |> Maybe.withDefault "fade"
    in
    frame "Select an animation then click send to see it in action."
        (Card.new
            |> Card.title [ text "Animation" ]
            |> Card.description [ text "Choose how user messages are animated when they are added to the conversation." ]
            |> Card.action (resetButton "Reset animated messages" (List.isEmpty thread.rows || thread.status /= Ready) (reset thread))
            |> Card.content [ class "min-h-0 flex-1 overflow-hidden px-0" ]
                [ if List.isEmpty thread.rows then
                    emptyChat "No Messages Yet" "Click the button below to send the first message."

                  else
                    let
                        scroller =
                            MessageScroller.new
                                |> MessageScroller.id thread.viewport
                                |> MessageScroller.padding "var(--card-spacing)"
                                |> MessageScroller.busy (thread.status /= Ready)
                                |> MessageScroller.items [] (messageRows thread { user = Muted, assistant = Ghost, enter = preset })
                                |> (if thread.sent then
                                        MessageScroller.holdTurn

                                    else
                                        identity
                                   )
                                |> MessageScroller.endButton (scrollToEndSmoothly thread)
                                |> MessageScroller.onScroll (scrolled thread.key)
                                |> MessageScroller.scrollable thread.edges
                                |> MessageScroller.toHtml []
                    in
                    Html.Keyed.node "div" [ class "size-full" ] [ ( String.fromInt thread.epoch, scroller ) ]
                ]
            |> Card.footer []
                [ Select.new
                    |> Select.id "animation-preset"
                    |> Select.onSelect (State.set "animation-preset")
                    |> Select.value (Just preset)
                    |> Select.items
                        [ Select.item "fade" [ text "Fade" ]
                        , Select.item "slide-up" [ text "Slide Up" ]
                        , Select.item "slide-side" [ text "Slide Side" ]
                        , Select.item "pop" [ text "Pop" ]
                        , Select.item "spring-bounce" [ text "Spring Bounce" ]
                        , Select.item "blur-fade" [ text "Blur Fade" ]
                        , Select.item "scale-fade" [ text "Scale Fade" ]
                        ]
                    |> Select.toHtml [ attribute "aria-label" "Animation preset", class "w-40" ]
                , sendButton thread [ class "ms-auto" ]
                ]
            |> Card.toHtml [ class cardClass ]
        )


{-| Search results, permalinks, outline items and toolbar buttons often need to drive the transcript from outside the message list. `scrollToMessage`, `scrollToEnd` and `scrollToStart` are tasks that find the viewport, and the row, by their `id`.
-}
commands : State -> Html State.Msg
commands state =
    let
        users =
            List.filter (\row -> row.role == User) commandsTranscript

        trimmed content =
            if String.length content > 42 then
                String.left 39 content ++ "..."

            else
                content

        scroller =
            MessageScroller.new
                |> MessageScroller.id "commands-viewport"
                |> MessageScroller.padding "var(--card-spacing)"
                |> MessageScroller.items []
                    (List.map
                        (\row ->
                            MessageScroller.item row.id
                                []
                                [ viewMessage
                                    { align = alignOf row.role
                                    , variant = bubbleOf { user = Muted, assistant = Ghost } row.role
                                    , text = row.text
                                    }
                                ]
                                |> (if row.role == User then
                                        MessageScroller.anchor

                                    else
                                        identity
                                   )
                        )
                        commandsTranscript
                    )
                |> MessageScroller.endButton (State.run (MessageScroller.scrollToEnd MessageScroller.Smooth "commands-viewport"))
                |> MessageScroller.onScroll (scrolled "commands")
                |> MessageScroller.scrollable (edgesOf "commands" state)
                |> MessageScroller.toHtml []
    in
    frame "Use the controls to jump to any message in the conversation."
        (Card.new
            |> Card.title [ text "Commands" ]
            |> Card.description [ text "Drive the transcript from outside." ]
            |> Card.action
                (DropdownMenu.new
                    |> DropdownMenu.id "commands-jump"
                    |> DropdownMenu.trigger
                        (Button.new
                            |> Button.secondary
                            |> Button.toAttributes
                        )
                        [ text "Jump to..." ]
                    |> DropdownMenu.alignEnd
                    |> DropdownMenu.content
                        [ DropdownMenu.group
                            (DropdownMenu.label [ text "Conversations" ]
                                :: List.map
                                    (\row ->
                                        DropdownMenu.item
                                            [ onClick
                                                (State.run
                                                    (MessageScroller.scrollToMessage MessageScroller.Smooth
                                                        { viewport = "commands-viewport"
                                                        , message = row.id
                                                        , margin = 0
                                                        }
                                                    )
                                                )
                                            ]
                                            [ span [ class "line-clamp-1 min-w-0" ] [ text (trimmed row.text) ] ]
                                    )
                                    users
                            )
                        ]
                    |> DropdownMenu.toHtml [ class "w-64" ]
                )
            |> Card.content [ class "min-h-0 flex-1 overflow-hidden px-0" ] [ scroller ]
            |> Card.toHtml [ class cardClass ]
        )


{-| A jump menu for the anchored turns, which keeps 12px above the row it jumps to. shadcn highlights the turn the reader is on with a visibility hook, which needs an `IntersectionObserver`, so the outline doesn't highlight one here.
-}
visibility : State -> Html State.Msg
visibility state =
    let
        users =
            List.filter (\row -> row.role == User) visibilityTranscript

        trimmed content =
            if String.length content > 42 then
                String.left 39 content ++ "..."

            else
                content

        scroller =
            MessageScroller.new
                |> MessageScroller.id "visibility-viewport"
                |> MessageScroller.padding "var(--card-spacing)"
                |> MessageScroller.scrollMargin 12
                |> MessageScroller.items []
                    (List.map
                        (\row ->
                            MessageScroller.item row.id
                                []
                                [ viewMessage
                                    { align = alignOf row.role
                                    , variant = bubbleOf { user = Muted, assistant = Ghost } row.role
                                    , text = row.text
                                    }
                                ]
                                |> (if row.role == User then
                                        MessageScroller.anchor

                                    else
                                        identity
                                   )
                        )
                        visibilityTranscript
                    )
                |> MessageScroller.endButton (State.run (MessageScroller.scrollToEnd MessageScroller.Smooth "visibility-viewport"))
                |> MessageScroller.onScroll (scrolled "visibility")
                |> MessageScroller.scrollable (edgesOf "visibility" state)
                |> MessageScroller.toHtml []
    in
    frame "Open the outline to jump between anchored turns as you read."
        (div [ class "relative mx-auto w-full max-w-sm" ]
            [ Card.new
                |> Card.title [ text "Transcript Outline" ]
                |> Card.description [ text "Jump between the anchored turns." ]
                |> Card.content [ class "min-h-0 flex-1 overflow-hidden px-0" ] [ scroller ]
                |> Card.toHtml [ class "h-140 w-full gap-0 *:data-[slot=card-header]:border-b *:data-[slot=card-header]:pb-(--card-spacing)" ]
            , div [ class "absolute top-1/2 -right-12 -translate-y-1/2 max-sm:right-0" ]
                [ Popover.new
                    |> Popover.id "visibility-outline"
                    |> Popover.trigger
                        [ attribute "aria-label" "Open transcript outline"
                        , class "flex h-9 w-9 flex-col items-center justify-center gap-1 rounded-md transition-colors outline-none focus-visible:ring-3 focus-visible:ring-ring/50"
                        ]
                        (List.map (\_ -> span [ class "h-0.5 w-4 rounded-full bg-muted-foreground/40" ] []) users)
                    |> Popover.left
                    |> Popover.content
                        (List.map
                            (\row ->
                                Html.button
                                    [ type_ "button"
                                    , attribute "popovertarget" "visibility-outline-content"
                                    , attribute "popovertargetaction" "hide"
                                    , class "flex min-h-7 items-center rounded-xl px-2 py-1.5 text-left text-sm transition-colors outline-none hover:bg-accent hover:text-accent-foreground focus-visible:bg-accent focus-visible:text-accent-foreground"
                                    , onClick
                                        (State.run
                                            (MessageScroller.scrollToMessage MessageScroller.Smooth
                                                { viewport = "visibility-viewport"
                                                , message = row.id
                                                , margin = 12
                                                }
                                            )
                                        )
                                    ]
                                    [ span [ class "line-clamp-1 min-w-0" ] [ text (trimmed row.text) ] ]
                            )
                            users
                        )
                    |> Popover.toHtml [ class "w-64 gap-1! rounded-2xl! p-1!" ]
                ]
            ]
        )


{-| `onScroll` reports which edges the viewport can still scroll toward. Being at the start or at the end is the negation, and being scrollable at all is `start || end`. Use it for a status indicator or a custom jump control. The example also passes it back to `scrollable`, which is what the buttons follow in Firefox, and shows `startButton` next to the usual `endButton`.
-}
scrollable : State -> Html State.Msg
scrollable state =
    let
        edges =
            if State.get "scrollable-edges" state == Nothing then
                -- The transcript opens at the start and overflows.
                { start = False, end = True }

            else
                edgesOf "scrollable" state

        status =
            if edges.start && edges.end then
                "You can scroll both ways."

            else if edges.end then
                "You are at the top. You can only scroll down."

            else if edges.start then
                "You are at the bottom. You can only scroll up."

            else
                "All messages fit in the viewport."

        scroller =
            MessageScroller.new
                |> MessageScroller.id "scrollable-viewport"
                |> MessageScroller.padding "var(--card-spacing)"
                |> MessageScroller.gap "calc(var(--spacing) * 4)"
                |> MessageScroller.openAtStart
                |> MessageScroller.items []
                    (List.map
                        (\row ->
                            MessageScroller.item row.id
                                []
                                [ viewMessage
                                    { align = alignOf row.role
                                    , variant = bubbleOf { user = Muted, assistant = Ghost } row.role
                                    , text = row.text
                                    }
                                ]
                                |> (if row.role == User then
                                        MessageScroller.anchor

                                    else
                                        identity
                                   )
                        )
                        scrollableTranscript
                    )
                |> MessageScroller.endButton (State.run (MessageScroller.scrollToEnd MessageScroller.Smooth "scrollable-viewport"))
                |> MessageScroller.startButton (State.run (MessageScroller.scrollToStart MessageScroller.Smooth "scrollable-viewport"))
                |> MessageScroller.onScroll (scrolled "scrollable")
                |> MessageScroller.scrollable edges
                |> MessageScroller.toHtml []
    in
    frame "Scroll the transcript to see the footer update."
        (Card.new
            |> Card.title [ text "Scroll Status" ]
            |> Card.description [ text "Where the reader can go scroll to based on current scroll position." ]
            |> Card.content [ class "min-h-0 flex-1 overflow-hidden px-0" ] [ scroller ]
            |> Card.footer [ class "justify-center text-center text-sm text-muted-foreground" ] [ text status ]
            |> Card.toHtml [ class cardClass ]
        )


{-| A complete chat: a scripted conversation that streams, a "Thinking..." marker while the request is submitted, and a composer with send and stop buttons.
-}
chat : State -> Html State.Msg
chat state =
    let
        thread =
            conversation { key = "chat", script = rows "chat" chatConversation, initial = 0 } state

        scroller =
            MessageScroller.new
                |> MessageScroller.id thread.viewport
                |> MessageScroller.padding "var(--card-spacing)"
                |> MessageScroller.busy (thread.status /= Ready)
                |> MessageScroller.items []
                    (messageRows thread { user = Default, assistant = Muted, enter = "" }
                        ++ (if thread.status == Submitted then
                                [ MessageScroller.item "chat-thinking"
                                    []
                                    [ marker
                                        [ span [ attribute "data-slot" "marker-icon", attribute "aria-hidden" "true", class "size-4 shrink-0" ] [ Spinner.view [] ]
                                        , span [ attribute "data-slot" "marker-content", class "min-w-0 wrap-break-word" ] [ text "Thinking..." ]
                                        ]
                                    ]
                                ]

                            else
                                []
                           )
                    )
                |> (if thread.sent then
                        MessageScroller.holdTurn

                    else
                        identity
                   )
                |> MessageScroller.endButton (scrollToEndSmoothly thread)
                |> MessageScroller.onScroll (scrolled thread.key)
                |> MessageScroller.scrollable thread.edges
                |> MessageScroller.toHtml []
    in
    div [ class "w-full" ]
        [ Card.new
            |> Card.title [ text "How can I help you today?" ]
            |> Card.description [ text ("Status: " ++ statusName thread.status) ]
            |> Card.content [ class "min-h-0 flex-1 overflow-hidden px-0" ]
                [ Html.Keyed.node "div" [ class "size-full" ] [ ( String.fromInt thread.epoch, scroller ) ] ]
            |> Card.footer []
                [ InputGroup.view []
                    [ InputGroup.textarea
                        [ id "chat-message"
                        , name "message"
                        , placeholder "Ask me anything..."
                        , class "h-10 min-h-10 overflow-y-auto"
                        , value
                            (case ( thread.status, thread.next ) of
                                ( Ready, Just row ) ->
                                    row.text

                                _ ->
                                    ""
                            )
                        , readonly True
                        ]
                    , InputGroup.bottom []
                        [ if thread.status == Ready then
                            sendButton thread [ class "ms-auto" ]

                          else
                            Button.new
                                |> Button.icon (Phosphor.stopCircle Regular |> Phosphor.toHtml [])
                                |> Button.label "Stop"
                                |> Button.ghost
                                |> Button.toHtml [ class "ms-auto", disabled (thread.status /= Streaming), onClick (stop thread) ]
                        ]
                    ]
                ]
            |> Card.toHtml [ class "mx-auto h-140 w-full max-w-sm" ]
        ]



-- THE FRAME OF AN EXAMPLE


{-| The card of every example: a header and a footer with a line between them and the transcript, which runs to both lines.
-}
cardClass : String
cardClass =
    "mx-auto h-140 w-full max-w-sm gap-0 *:data-[slot=card-header]:border-b *:data-[slot=card-header]:pb-(--card-spacing)"


frame : String -> Html msg -> Html msg
frame note card =
    div [ class "relative flex w-full flex-col gap-4" ]
        [ card
        , div [ class "mx-auto max-w-sm px-0.5 text-center text-xs text-balance text-muted-foreground" ] [ text note ]
        ]


emptyChat : String -> String -> Html msg
emptyChat title description =
    Empty.new
        |> Empty.icon (Phosphor.chatCircleDots Regular |> Phosphor.toHtml [])
        |> Empty.title [ text title ]
        |> Empty.description [ text description ]
        |> Empty.toHtml [ class "h-full" ]


resetButton : String -> Bool -> State.Msg -> Html State.Msg
resetButton label isDisabled msg =
    Button.new
        |> Button.icon (Phosphor.arrowClockwise Regular |> Phosphor.toHtml [])
        |> Button.label label
        |> Button.outline
        |> Button.toHtml [ disabled isDisabled, onClick msg ]


{-| The send button of a scripted chat: it sends the next message of the script.
-}
sendButton : Conversation -> List (Html.Attribute State.Msg) -> Html State.Msg
sendButton thread attrs =
    Button.new
        |> Button.icon (Phosphor.arrowUp Regular |> Phosphor.toHtml [])
        |> Button.label "Send"
        |> Button.toHtml
            (disabled (thread.next == Nothing || thread.status /= Ready)
                :: onClick (send thread)
                :: attrs
            )


{-| The composer of the streaming examples: the message that will be sent next, a menu, whatever else the example needs, and the send button.
-}
composer : Conversation -> { exhausted : String, extra : List (Html State.Msg) } -> Html State.Msg
composer thread { exhausted, extra } =
    InputGroup.view []
        [ div [ class "h-14 w-full px-3 py-2.5" ]
            [ span
                [ attribute "data-status" (statusName thread.status)
                , class "line-clamp-2 opacity-60 data-[status=ready]:opacity-100"
                ]
                [ case thread.next of
                    Just row ->
                        text row.text

                    Nothing ->
                        span [ class "text-muted-foreground" ] [ text exhausted ]
                ]
            ]
        , InputGroup.bottom [ class "pt-1" ]
            (addMenu thread.key :: extra ++ [ sendButton thread [ class "ms-auto" ] ])
        ]


addMenu : String -> Html msg
addMenu key =
    DropdownMenu.new
        |> DropdownMenu.id (key ++ "-add")
        |> DropdownMenu.trigger
            (attribute "aria-label" "Add files"
                :: (Button.new
                        |> Button.icon (Phosphor.plus Regular |> Phosphor.toHtml [])
                        |> Button.label "Add files"
                        |> Button.outline
                        |> Button.toAttributes
                   )
            )
            [ Phosphor.plus Regular |> Phosphor.toHtml [] ]
        |> DropdownMenu.top
        |> DropdownMenu.content
            [ DropdownMenu.item [] [ Phosphor.paperclip Regular |> Phosphor.toHtml [], text "Add Photos & Files" ]
            , DropdownMenu.separator
            , DropdownMenu.item [] [ Phosphor.image Regular |> Phosphor.toHtml [], text "Create Image" ]
            , DropdownMenu.item [] [ Phosphor.binoculars Regular |> Phosphor.toHtml [], text "Deep Research" ]
            , DropdownMenu.item [] [ Phosphor.globe Regular |> Phosphor.toHtml [], text "Web Search" ]
            ]
        |> DropdownMenu.toHtml [ class "w-44" ]



-- A SCRIPTED CHAT
--
-- The chats keep their rows in the state: how many of the script are shown, how many
-- words of the last reply are, and what the scroller last reported.


type Role
    = User
    | Assistant


type alias Row =
    { id : String
    , role : Role
    , text : String
    }


type Status
    = Ready
    | Submitted
    | Streaming


type alias Conversation =
    { key : String
    , viewport : String
    , rows : List Row
    , status : Status
    , next : Maybe Row
    , reply : Maybe Row
    , count : Int
    , sent : Bool
    , epoch : Int
    , edges : { start : Bool, end : Bool }
    }


{-| The chat of an example, from its state. `initial` rows are shown at first, like a saved transcript, and the script goes on from there. The reply that is streaming is cut to the words revealed so far.
-}
conversation : { key : String, script : List Row, initial : Int } -> State -> Conversation
conversation { key, script, initial } state =
    let
        count =
            clamp 0 (List.length script) (intAt (key ++ "-count") initial state)

        shown =
            List.take count script

        -- Nothing: the reply is complete. A count: the words shown. A negative count:
        -- it was stopped after that many words.
        words =
            State.get (key ++ "-words") state |> Maybe.andThen String.toInt

        ( rowsShown, status ) =
            case ( List.reverse shown, words ) of
                ( last :: before, Just revealed ) ->
                    if last.role == User then
                        ( shown, Submitted )

                    else if revealed < 0 then
                        ( List.reverse (cut (abs revealed) last :: before), Ready )

                    else if revealed < wordCount last.text then
                        ( List.reverse (cut revealed last :: before), Streaming )

                    else
                        ( shown, Ready )

                ( last :: _, Nothing ) ->
                    if last.role == User then
                        ( shown, Submitted )

                    else
                        ( shown, Ready )

                ( [], _ ) ->
                    ( shown, Ready )

        upcoming =
            List.drop count script
    in
    { key = key
    , viewport = key ++ "-viewport"
    , rows = rowsShown
    , status = status
    , next =
        case upcoming of
            row :: _ ->
                if row.role == User then
                    Just row

                else
                    Nothing

            [] ->
                Nothing
    , reply = upcoming |> List.drop 1 |> List.head
    , count = count
    , sent = count > initial
    , epoch = intAt (key ++ "-epoch") 0 state
    , edges = edgesOf key state
    }


cut : Int -> Row -> Row
cut revealed row =
    { row | text = String.split " " row.text |> List.take revealed |> String.join " " }


wordCount : String -> Int
wordCount content =
    List.length (String.split " " content)


{-| Shows the next message of the script and scrolls to it, which puts it at the reading line. A second later the reply starts, a word at a time. After each word the scroller is asked to follow, as long as the reader is at the end.
-}
send : Conversation -> State.Msg
send thread =
    case ( thread.next, thread.status ) of
        ( Just _, Ready ) ->
            State.batch
                [ State.set (thread.key ++ "-count") (String.fromInt (thread.count + 1))
                , State.run (MessageScroller.scrollToEnd MessageScroller.Instant thread.viewport)
                , case thread.reply of
                    Just reply ->
                        State.delay 1000
                            (State.batch
                                [ State.set (thread.key ++ "-count") (String.fromInt (thread.count + 2))
                                , State.set (thread.key ++ "-words") "0"
                                , State.advance
                                    { key = thread.key ++ "-words"
                                    , to = wordCount reply.text
                                    , every = 30
                                    , each = follow thread
                                    }
                                ]
                            )

                    Nothing ->
                        State.none
                ]

        _ ->
            State.none


{-| After a word: if the reader is at the end, and the viewport has fallen behind the end, scroll to it.

The browser keeps up by itself, as long as the transcript has scrolled at least once, so this only does something in the first turn of an empty transcript and in browsers without scroll anchoring. The decision is made once the viewport has been measured, with what `onScroll` has reported by then, because a `scroll` event arrives a frame after the reader has moved, and a scroll that is already on its way would override them.

-}
follow : Conversation -> State.Msg
follow thread =
    State.attempt
        (Browser.Dom.getViewportOf thread.viewport
            |> Task.map
                (\v ->
                    if v.scene.height - v.viewport.y - v.viewport.height > 4 then
                        State.runIf (atEnd thread.key) (MessageScroller.scrollToEnd MessageScroller.Instant thread.viewport)

                    else
                        State.none
                )
        )


{-| Ends the stream where it is: the loop that counts the words stops when the count is no longer what it left.
-}
stop : Conversation -> State.Msg
stop thread =
    State.set (thread.key ++ "-words")
        (String.fromInt
            (negate
                (thread.rows
                    |> List.reverse
                    |> List.head
                    |> Maybe.map (\row -> wordCount row.text)
                    |> Maybe.withDefault 1
                )
            )
        )


reset : Conversation -> State.Msg
reset thread =
    State.batch
        [ State.remove (thread.key ++ "-count")
        , State.remove (thread.key ++ "-words")
        , State.remove (thread.key ++ "-edges")
        , State.set (thread.key ++ "-epoch") (String.fromInt (thread.epoch + 1))
        ]


scrollToEndSmoothly : Conversation -> State.Msg
scrollToEndSmoothly thread =
    State.run (MessageScroller.scrollToEnd MessageScroller.Smooth thread.viewport)


{-| What the scroller last reported through `onScroll`, kept as `"start end"`. Nothing yet means that it can't be scrolled, and the reader is at the end.
-}
edgesOf : String -> State -> { start : Bool, end : Bool }
edgesOf key state =
    let
        edges =
            State.get (key ++ "-edges") state |> Maybe.withDefault "" |> String.words
    in
    { start = List.member "start" edges, end = List.member "end" edges }


scrolled : String -> { start : Bool, end : Bool } -> State.Msg
scrolled key edges =
    State.set (key ++ "-edges")
        (String.join " "
            (List.filterMap identity
                [ if edges.start then
                    Just "start"

                  else
                    Nothing
                , if edges.end then
                    Just "end"

                  else
                    Nothing
                ]
            )
        )


atEnd : String -> State -> Bool
atEnd key state =
    not (edgesOf key state).end


intAt : String -> Int -> State -> Int
intAt key default state =
    State.get key state
        |> Maybe.andThen String.toInt
        |> Maybe.withDefault default


floatAt : String -> Float -> State -> Float
floatAt key default state =
    State.get key state
        |> Maybe.andThen String.toFloat
        |> Maybe.withDefault default


statusName : Status -> String
statusName status =
    case status of
        Ready ->
            "ready"

        Submitted ->
            "submitted"

        Streaming ->
            "streaming"


roleName : Role -> String
roleName role =
    case role of
        User ->
            "user"

        Assistant ->
            "assistant"


alignOf : Role -> Align
alignOf role =
    case role of
        User ->
            End

        Assistant ->
            Start


bubbleOf : { user : Variant, assistant : Variant } -> Role -> Variant
bubbleOf variants role =
    case role of
        User ->
            variants.user

        Assistant ->
            variants.assistant


{-| The rows of a chat as items of the scroller. The user's messages are anchors. The newest row gets the entrance `enter` while it is the last row, which is when it has just been sent.
-}
messageRows : Conversation -> { user : Variant, assistant : Variant, enter : String } -> List (MessageScroller.Item msg)
messageRows thread { user, assistant, enter } =
    List.indexedMap
        (\index row ->
            MessageScroller.item row.id
                [ class
                    (if row.role == User && index == List.length thread.rows - 1 && enter /= "" then
                        "message-enter-" ++ enter

                     else
                        ""
                    )
                ]
                [ viewMessage
                    { align = alignOf row.role
                    , variant = bubbleOf { user = user, assistant = assistant } row.role
                    , text = row.text
                    }
                ]
                |> (if row.role == User then
                        MessageScroller.anchor

                    else
                        identity
                   )
        )
        thread.rows



-- MESSAGES, BUBBLES AND MARKERS
--
-- shadcn's Message, Bubble and Marker, which are separate components upstream.


type Align
    = Start
    | End


type Variant
    = Default
    | Muted
    | Ghost
    | Tinted


viewMessage : { align : Align, variant : Variant, text : String } -> Html msg
viewMessage message =
    messageShell message.align [ bubble message.variant message.text ]


viewHeaderMessage : { align : Align, variant : Variant, sender : String, text : String } -> Html msg
viewHeaderMessage message =
    messageShell message.align
        [ div
            [ attribute "data-slot" "message-header"
            , class "flex max-w-full min-w-0 items-center px-3 text-xs font-medium text-muted-foreground group-has-data-[variant=ghost]/message:px-0"
            ]
            [ text message.sender ]
        , bubble message.variant message.text
        ]


messageShell : Align -> List (Html msg) -> Html msg
messageShell align content =
    div
        [ attribute "data-slot" "message"
        , attribute "data-align"
            (case align of
                Start ->
                    "start"

                End ->
                    "end"
            )
        , class "group/message relative flex w-full min-w-0 gap-2 text-sm data-[align=end]:flex-row-reverse"
        ]
        [ div
            [ attribute "data-slot" "message-content"
            , class "flex w-full min-w-0 flex-col gap-2.5 wrap-break-word group-data-[align=end]/message:*:data-slot:self-end"
            ]
            content
        ]


bubble : Variant -> String -> Html msg
bubble variant content =
    div
        [ attribute "data-slot" "bubble"
        , attribute "data-variant"
            (case variant of
                Default ->
                    "default"

                Muted ->
                    "muted"

                Ghost ->
                    "ghost"

                Tinted ->
                    "tinted"
            )
        , class "group/bubble relative flex w-fit max-w-[80%] min-w-0 flex-col gap-1 data-[variant=ghost]:max-w-full group-data-[align=end]/message:self-end"
        , class
            (case variant of
                Default ->
                    "*:data-[slot=bubble-content]:bg-primary *:data-[slot=bubble-content]:text-primary-foreground"

                Muted ->
                    "*:data-[slot=bubble-content]:bg-muted"

                Ghost ->
                    "*:data-[slot=bubble-content]:rounded-none *:data-[slot=bubble-content]:bg-transparent *:data-[slot=bubble-content]:p-0"

                Tinted ->
                    "*:data-[slot=bubble-content]:bg-[oklch(from_var(--primary)_0.93_calc(c*0.4)_h)] *:data-[slot=bubble-content]:text-foreground dark:*:data-[slot=bubble-content]:bg-[oklch(from_var(--primary)_0.3_calc(c*0.4)_h)]"
            )
        ]
        [ div
            [ attribute "data-slot" "bubble-content"
            , class "w-fit max-w-full min-w-0 space-y-2 overflow-hidden rounded-xl border border-transparent px-3 py-2 text-sm leading-relaxed wrap-break-word"
            ]
            (content
                |> String.split "\n\n"
                |> List.map String.trim
                |> List.filter (not << String.isEmpty)
                |> List.map (\paragraph -> p [ class "whitespace-pre-wrap" ] [ text paragraph ])
            )
        ]


{-| A line with a label in the middle, such as "End of Conversation".
-}
separator : String -> Html msg
separator label =
    div
        [ attribute "data-slot" "marker"
        , attribute "data-variant" "separator"
        , class "group/marker relative flex min-h-4 w-full items-center gap-2 text-left text-sm text-muted-foreground before:mr-1 before:h-px before:min-w-0 before:flex-1 before:bg-border after:ml-1 after:h-px after:min-w-0 after:flex-1 after:bg-border"
        ]
        [ span [ attribute "data-slot" "marker-content", class "min-w-0 flex-none text-center wrap-break-word" ] [ text label ] ]


{-| A status line with an icon, such as the spinner of "Thinking...".
-}
marker : List (Html msg) -> Html msg
marker content =
    div
        [ attribute "data-slot" "marker"
        , attribute "data-variant" "default"
        , attribute "role" "status"
        , class "group/marker relative flex min-h-4 w-full items-center gap-2 text-left text-sm text-muted-foreground [&_svg:not([class*='size-'])]:size-4"
        ]
        content



-- THE CONVERSATIONS


rows : String -> List ( Role, String ) -> List Row
rows prefix exchanges =
    List.indexedMap
        (\index ( role, content ) ->
            { id = prefix ++ "-" ++ String.fromInt (index + 1), role = role, text = content }
        )
        exchanges


streamingConversation : List ( Role, String )
streamingConversation =
    [ ( User, "I'm building a chat for our app and the scroll behavior is driving me nuts. Every time the AI streams a reply, the whole thread jumps around." )
    , ( Assistant, "That's the classic streaming scroll problem. Wrap your message list in `MessageScroller` and turn on `autoScroll` — the viewport pins to the bottom as tokens arrive, so users always see the latest text land in place.\n\nThe important part: it only auto-scrolls while the reader is already at the bottom. The moment they scroll up to read something earlier, auto-scroll backs off and their position is preserved. You get smooth streaming without fighting the user's intent." )
    , ( User, "Okay, but when someone sends a new message the view still feels jarring — like the whole conversation reloads from the top." )
    , ( Assistant, "MessageScrollerItem fixes that with turn anchoring. Set `scrollAnchor` on the turn that should settle near the top instead of blindly snapping to the document bottom.\n\nIt also leaves a small peek of the previous exchange visible above the anchor, so context isn't lost. The reply starts in view without that disorienting jump you get from a plain overflow container." )
    , ( User, "And if they've scrolled up to re-read an older answer? I don't want to yank them back down." )
    , ( Assistant, "You won't. Auto-scroll only runs when the viewport is already pinned to the bottom, so scrolling up is a deliberate opt-out — their place in the thread stays put even as new tokens keep arriving below.\n\nWhen there is content they haven't seen yet, `MessageScrollerButton` appears at the bottom of the viewport. One tap jumps them back to the newest message and re-engages auto-scroll. Same pattern as Slack or iMessage: quiet when you're caught up, helpful when you're not." )
    , ( User, "Last one — does this work with assistive tech?" )
    , ( Assistant, "`MessageScrollerContent` sets `role=\"log\"` and `aria-relevant=\"additions\"` by default, so screen readers announce new messages as they stream in.\n\nThe scroll button is a real `<button>` with an sr-only label, and it's removed from the tab order when you're already at the bottom — no ghost focus stops." )
    ]


animationConversation : List ( Role, String )
animationConversation =
    [ ( User, "Can user messages pop in like iMessage without breaking anchoring?" )
    , ( Assistant, "Yes. Animate the user row with transform and opacity, and let the assistant response stream normally below it.\n\nThat keeps the row measurement predictable while still giving the newly sent bubble a more tactile entrance." )
    , ( User, "What makes the animation feel more like iMessage?" )
    , ( Assistant, "Use a quick spring from the trailing edge: a little scale, a small upward move, and no layout animation.\n\nThe bubble feels tactile, but the measured row stays predictable, so anchoring and auto-scroll do not have to fight a changing layout." )
    , ( User, "Can I switch between presets while testing the same thread?" )
    , ( Assistant, "Yes. Keep the conversation in place while you change the preset, then send the next message to compare the new entrance against the same context.\n\nThat makes it easier to judge the difference between a subtle fade, a snappy pop, and a more dramatic 3D tilt without rebuilding the scenario each time." )
    ]


anchoringScript : List Row
anchoringScript =
    [ { id = "anchor-1-user", role = User, text = "Can you show me how anchoring behaves when a new prompt starts the turn?" }
    , { id = "anchor-1-assistant", role = Assistant, text = "Append the user prompt first, then append the assistant response. With User selected, the prompt settles near the top and the assistant response fills in below it." }
    , { id = "anchor-2-user", role = User, text = "What changes when assistant messages are the anchor?" }
    , { id = "anchor-2-assistant", role = Assistant, text = "Now each assistant response is the item `MessageScroller` keeps in view. This is useful when the reply is the moment you want readers to land on after each turn." }
    , { id = "anchor-3-user", role = User, text = "Can I switch roles and keep adding turns?" }
    , { id = "anchor-3-assistant", role = Assistant, text = "Yes. The next appended message with the selected role becomes the anchor, so you can compare user and assistant anchoring without resetting the demo." }
    ]


openingTranscript : List Row
openingTranscript =
    [ { id = "open-1", role = User, text = "This is the first message the user sent in the conversation." }
    , { id = "open-2", role = Assistant, text = "Workspace creation rose 8%, but first invite completion only rose 2%." }
    , { id = "open-3", role = User, text = "This is the last message the user sent in the conversation." }
    , { id = "open-4", role = Assistant, text = "Start with the invite step. Teams are creating workspaces but waiting to add collaborators.\n\nRecommended follow-up:\n\n1. Compare invite drop-off by account size.\n2. Check whether users who skip invites still return within 24 hours.\n3. Review the empty-state copy on the first project screen.\n4. Segment activation by template, since template users may not need invites right away.\n\nIf that pattern holds, the next experiment should make collaboration useful earlier instead of prompting for invites harder." }
    ]


historyScript : List Row
historyScript =
    rows "history"
        [ ( User, "Can you summarize the incident channel?" )
        , ( Assistant, "The first alert was a delayed export job. It started backing up around 09:42 UTC and triggered the warning once the retry queue crossed the threshold.\n\nNo customer-facing checkout paths were affected, but exports for larger workspaces were running about 12 minutes behind." )
        , ( User, "Was checkout affected?" )
        , ( Assistant, "No checkout errors were reported. Payment authorization, order creation, and confirmation emails stayed inside their normal latency bands.\n\nThe only elevated metric was export queue depth, which maps to analytics downloads instead of checkout." )
        , ( User, "What changed in the last deploy?" )
        , ( Assistant, "Only the export queue worker changed. The deploy moved large CSV jobs onto the shared retry policy, which made each failed attempt hold a worker slot longer than before.\n\nThe app deploy did not include checkout, pricing, or billing API changes." )
        , ( User, "Do we need to roll back?" )
        , ( Assistant, "Not yet. Queue depth is recovering after we reduced retry concurrency, and the oldest pending job is now under five minutes old.\n\nKeep rollback ready if the queue starts climbing again, but the current trend points toward recovery." )
        , ( User, "Keep watching for customer-visible issues." )
        , ( Assistant, "I will watch the queue and support tags for another 15 minutes. I am tracking export failures, delayed download requests, and any support thread that mentions missing reports.\n\nIf those stay quiet through the next batch window, we can close this as an internal degradation." )
        ]


commandsTranscript : List Row
commandsTranscript =
    [ { id = "command-activation", role = User, text = "We're seeing activation dip after workspace creation. Can you help me find the likely step?" }
    , { id = "command-activation-reply", role = Assistant, text = "The sharpest drop is between creating the workspace and inviting the first teammate.\n\nWorkspace creation is still healthy, but the invite step is where users pause. That suggests the product is asking for collaboration before the user has enough confidence in the workspace." }
    , { id = "command-compare", role = User, text = "What should I compare before we change the onboarding flow?" }
    , { id = "command-compare-reply", role = Assistant, text = "Compare three cohorts:\n\n1. Users who choose a template before inviting teammates.\n2. Users who start from a blank workspace.\n3. Users who skip invites and return within 24 hours.\n\nIf template users invite faster, the fix is probably better first-run guidance rather than a louder invite prompt." }
    , { id = "command-experiment", role = User, text = "Can you turn that into an experiment?" }
    , { id = "command-experiment-reply", role = Assistant, text = "Yes. Create a variant that shows a short checklist after workspace creation:\n\n- Pick a template.\n- Add one project detail.\n- Invite a teammate when the workspace has context.\n\nMeasure first invite completion, 24-hour return rate, and whether teams create a second project." }
    , { id = "command-risk", role = User, text = "What's the risk if we delay the invite prompt?" }
    , { id = "command-risk-reply", role = Assistant, text = "The main risk is reducing team creation for accounts that already know who they want to invite.\n\nTo protect that path, keep the invite action visible in the header and only change the primary empty-state guidance. That gives confident teams a direct route without forcing uncertain users through the invite step too early." }
    ]


visibilityTranscript : List Row
visibilityTranscript =
    [ { id = "vis-brief", role = User, text = "Review the incident handoff and tell me what to read first." }
    , { id = "vis-brief-reply", role = Assistant, text = "Start with the summary and the impact section. The regression affected the upload queue, but the recovery path completed for every queued job." }
    , { id = "vis-impact", role = User, text = "What was the customer impact?" }
    , { id = "vis-impact-reply", role = Assistant, text = "Impact was limited to delayed processing.\n\nNo records were dropped, and the reconciliation worker confirmed each retry batch. Support saw confusion from two customers, but there were no checkout or billing errors." }
    , { id = "vis-actions", role = User, text = "What actions are open?" }
    , { id = "vis-actions-reply", role = Assistant, text = "Keep the retry window enabled until the next deploy, then add a queue-depth alert as the long-term fix.\n\nThe alert should fire on sustained queue growth, not a single short spike." }
    , { id = "vis-checklist", role = User, text = "Give me the follow-up checklist." }
    , { id = "vis-checklist-reply", role = Assistant, text = "After that, compare the queue recovery graph with the deploy timeline so the handoff shows exactly when processing returned to baseline. That makes it easier for support and engineering to answer the same customer questions without re-reading the whole incident thread.\n\nI would also add a short owner note beside each follow-up item. The checklist is small, but ownership keeps the retry-window decision, alert tuning, and support macro from drifting into separate follow-up conversations.\n\nKeep the retry window enabled until the next deploy, then add a queue-depth alert as the long-term fix.\n\nThe alert should fire on sustained queue growth, not a single short spike." }
    ]


scrollableTranscript : List Row
scrollableTranscript =
    List.range 1 12
        |> List.map
            (\number ->
                if modBy 2 number == 1 then
                    { id = "scrollable-" ++ String.fromInt number
                    , role = User
                    , text = "Review scroll checkpoint " ++ String.fromInt number ++ "."
                    }

                else
                    { id = "scrollable-" ++ String.fromInt number
                    , role = Assistant
                    , text = "Checkpoint " ++ String.fromInt number ++ " is synced. The scrollable hook updates as the viewport moves.\n\nWhen the reader is at the first message, the footer should only point them down. Once they move into the middle of the transcript, it should explain that both directions are available.\n\nAt the latest message, the footer should switch again and only point them back up."
                    }
            )


chatConversation : List ( Role, String )
chatConversation =
    [ ( User, "Hello there!" )
    , ( Assistant, "Hey, how's it going?" )
    , ( User, "I'm prototyping an AI chat surface for our product docs.\n\nCan you sketch a sensible component breakdown and call out anything I'd regret baking into v1?" )
    , ( Assistant, "## Recommended layout\n\nTreat the chat as three layers so scrolling and the composer never fight each other:\n\n| Layer | Responsibility |\n| --- | --- |\n| **Shell** | Card or page frame, title, status indicator |\n| **Transcript** | `overflow-y-auto` message list |\n| **Composer** | Input group, send, stop |\n\n### Message rendering\n\n- **User messages**: right-aligned, muted background, `max-w-[80%]`.\n- **Assistant messages**: full width within the column; use `whitespace-pre-wrap` for text.\n\n### Suggested component split\n\n```tsx\n<ChatCard>\n  <ChatHeader status={status} />\n  <ChatTranscript messages={messages} />\n  <ChatComposer onSubmit={sendMessage} onStop={stop} />\n</ChatCard>\n```\n\n### v1 pitfalls to avoid\n\n1. **Inlining transport logic in the UI** — keep scripted/demo transport beside your example, not inside shared components.\n2. **Fixed transcript height without `overflow-hidden`** — parent must clip, child must scroll, or the composer jumps.\n3. **Not giving the scroller a ref or auto-scroll flag** — long replies should stay pinned to the bottom unless the user scrolls up.\n\n### Practical next step\n\nStart with plain `whitespace-pre-wrap` text to validate spacing and scroll behavior. Once the transcript feels right, you can swap assistant text rendering to a richer renderer if you need it.\n\nWant me to walk through auto-scroll vs. manual scroll-to-bottom next?" )
    , ( User, "What about message spacing when one reply is short and the next is really long?" )
    , ( Assistant, "Good question. The scroll container should own vertical rhythm, not individual bubbles.\n\nUse a consistent `gap` on the message list (something like `gap-4` or `gap-6`) so short and long messages sit on the same grid. For assistant replies that span many paragraphs, keep everything in one bubble rather than splitting on every line break — otherwise the transcript feels choppy when you're skimming.\n\nWhen a long reply streams in, pin the viewport to the bottom with `MessageScroller autoScroll` until the user scrolls up. If they've scrolled away, show a scroll-to-bottom affordance instead of yanking them back mid-read.\n\nThat's usually enough for v1. Fancy diff animations or per-paragraph fade-ins can wait until you've validated that the base scroll + composer layout holds up on real devices." )
    , ( User, "Thanks, that helps." )
    , ( Assistant, "Happy to help — send another message when you're ready to keep stepping through the demo." )
    ]
