module Examples.Drawer exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (checked, class, for, id, name, type_, value)
import Html.Events exposing (onClick)
import State exposing (State)
import UI.Badge as Badge
import UI.Button as Button
import UI.Dialog as Dialog
import UI.Drawer as Drawer
import UI.Field as Field
import UI.Input as Input
import UI.Label as Label
import UI.RadioGroup as RadioGroup


demo : State -> Html State.Msg
demo state =
    let
        deliveryTimes =
            [ { slot = "asap", label = "Standard delivery", desc = "25–35 min · Driver assigned now", badge = Just "Fastest" }
            , { slot = "5-00", label = "5:00 PM – 5:15 PM", desc = "Prep starts at 4:45 PM", badge = Nothing }
            , { slot = "5-30", label = "5:30 PM – 5:45 PM", desc = "Good if you're heading home", badge = Nothing }
            , { slot = "6-00", label = "6:00 PM – 6:15 PM", desc = "Most popular · High demand", badge = Nothing }
            , { slot = "6-30", label = "6:30 PM – 6:45 PM", desc = "Last slot before kitchen closes", badge = Nothing }
            ]

        viewTime { slot, label, desc, badge } =
            Field.label [ for ("delivery-" ++ slot) ]
                [ Field.horizontal []
                    [ Field.content []
                        [ Field.title [ class "flex items-center gap-2" ]
                            (text label
                                :: (case badge of
                                        Just name ->
                                            [ Badge.new
                                                |> Badge.text name
                                                |> Badge.secondary
                                                |> Badge.toHtml []
                                            ]

                                        Nothing ->
                                            []
                                   )
                            )
                        , Field.description [] [ text desc ]
                        ]
                    , RadioGroup.item [ id ("delivery-" ++ slot), name "delivery", value slot, checked (slot == "asap") ]
                    ]
                ]
    in
    Drawer.new
        |> Drawer.id "delivery"
        |> Drawer.nonModal
        |> Drawer.trigger
            (Button.new
                |> Button.text "Open Drawer"
                |> Button.secondary
            )
        |> Drawer.right
        |> Drawer.downOnMobile
        |> Drawer.swipeable (State.drawer state) State.drawerMsg
        |> Drawer.title [ text "Pick a delivery time" ]
        |> Drawer.description [ text "We'll prepare your order as soon as possible." ]
        |> Drawer.content
            [ div [ class "flex-1 scroll-fade overflow-y-auto p-4" ]
                [ RadioGroup.view [ class "gap-2" ] (List.map viewTime deliveryTimes) ]
            ]
        |> Drawer.footer []
            [ Button.new
                |> Button.text "Confirm Delivery Time"
                |> Button.toHtml (class "h-[34px]" :: Drawer.closes "delivery")
            , Button.new
                |> Button.text "Cancel"
                |> Button.outline
                |> Button.toHtml (Drawer.closes "delivery")
            ]
        |> Drawer.toHtml []


{-| Use `up`, `right`, `down` or `left` to set the side of the drawer.
-}
sides : Html msg
sides =
    Drawer.new
        |> Drawer.id "sides"
        |> Drawer.trigger
            (Button.new
                |> Button.text "Open Left Drawer"
                |> Button.secondary
            )
        |> Drawer.left
        |> Drawer.title [ text "Move Goal" ]
        |> Drawer.description [ text "Set your daily activity goal." ]
        |> Drawer.content
            [ div [ class "flex-1 p-4" ]
                [ div [ class "size-full rounded-2xl bg-muted" ] [] ]
            ]
        |> Drawer.footer []
            [ Button.new
                |> Button.text "Close"
                |> Button.toHtml (Drawer.closes "sides")
            ]
        |> Drawer.toHtml []


{-| Use `swipeHandle` to render a swipe handle, and `swipeable` to let a swipe drag the drawer. Swipe it past halfway, or flick it toward the edge, to close it, or let go sooner and it settles back.
-}
swipeHandle : State -> Html State.Msg
swipeHandle state =
    Drawer.new
        |> Drawer.id "swipe-handle"
        |> Drawer.trigger
            (Button.new
                |> Button.text "Open Drawer"
                |> Button.secondary
            )
        |> Drawer.swipeable (State.drawer state) State.drawerMsg
        |> Drawer.title [ text "Drawer" ]
        |> Drawer.description [ text "Drawer with a swipe handle." ]
        |> Drawer.content
            [ div [ class "flex-1 p-4" ]
                [ div [ class "h-80 w-full rounded-2xl bg-muted" ] [] ]
            ]
        |> Drawer.footer []
            [ Button.new
                |> Button.text "Close"
                |> Button.toHtml (Drawer.closes "swipe-handle")
            ]
        |> Drawer.toHtml []


{-| Open drawers from inside another drawer. Parent drawers stay open and stack behind the frontmost drawer.
-}
nested : State -> Html State.Msg
nested state =
    let
        placeholder =
            div [ class "flex-1 p-4" ]
                [ div [ class "bg-muted max-md:aspect-video max-md:w-full md:size-full" ] [] ]

        close drawerId =
            Button.new
                |> Button.text "Close"
                |> Button.outline
                |> Button.toHtml (Drawer.closes drawerId)

        opener label =
            Button.new
                |> Button.text label
                |> Button.outline
    in
    Drawer.new
        |> Drawer.id "nested-1"
        |> Drawer.trigger
            (Button.new
                |> Button.text "Open Drawer"
                |> Button.secondary
            )
        |> Drawer.right
        |> Drawer.downOnMobile
        |> Drawer.swipeable (State.drawer state) State.drawerMsg
        |> Drawer.title [ text "Drawer" ]
        |> Drawer.description [ text "Open another drawer from the same direction." ]
        |> Drawer.content [ placeholder ]
        |> Drawer.footer []
            [ Drawer.new
                |> Drawer.id "nested-2"
                |> Drawer.trigger (opener "Open Nested Drawer")
                |> Drawer.right
                |> Drawer.downOnMobile
                |> Drawer.swipeable (State.drawer state) State.drawerMsg
                |> Drawer.title [ text "Nested Drawer" ]
                |> Drawer.description [ text "The parent drawer stays mounted behind this one." ]
                |> Drawer.content [ placeholder ]
                |> Drawer.footer []
                    [ Drawer.new
                        |> Drawer.id "nested-3"
                        |> Drawer.trigger (opener "Open Third Drawer")
                        |> Drawer.right
                        |> Drawer.downOnMobile
                        |> Drawer.title [ text "Third Drawer" ]
                        |> Drawer.description [ text "Two drawers are stacked behind this one." ]
                        |> Drawer.content [ placeholder ]
                        |> Drawer.footer []
                            [ Drawer.new
                                |> Drawer.id "nested-4"
                                |> Drawer.trigger (opener "Open Fourth Drawer")
                                |> Drawer.right
                                |> Drawer.downOnMobile
                                |> Drawer.title [ text "Fourth Drawer" ]
                                |> Drawer.description [ text "This is the frontmost drawer in the stack." ]
                                |> Drawer.content [ placeholder ]
                                |> Drawer.footer [] [ close "nested-4" ]
                                |> Drawer.toHtml []
                            , close "nested-3"
                            ]
                        |> Drawer.toHtml []
                    , close "nested-2"
                    ]
                |> Drawer.toHtml []
            , close "nested-1"
            ]
        |> Drawer.toHtml []


{-| Use `nonModal` to allow interaction with the rest of the page while the drawer is open. It then only closes from a button with the `hides` attributes, not on a press outside.
-}
nonModal : Html msg
nonModal =
    Drawer.new
        |> Drawer.id "non-modal"
        |> Drawer.trigger
            (Button.new
                |> Button.text "Non Modal"
                |> Button.outline
            )
        |> Drawer.nonModal
        |> Drawer.right
        |> Drawer.title [ text "Non Modal Drawer" ]
        |> Drawer.content
            [ div [ class "flex-1 p-4" ]
                [ div [ class "size-full rounded-2xl bg-muted" ] [] ]
            ]
        |> Drawer.footer []
            [ Button.new
                |> Button.text "Close"
                |> Button.toHtml (Drawer.hides "non-modal")
            ]
        |> Drawer.toHtml []


{-| Use `snapPoints` to snap a drawer to preset heights when a swipe ends. Numbers up to `1` are fractions of the viewport height, bigger ones are pixels. The drawer opens at the first one, and a swipe from the smallest one toward the edge closes it.
-}
snapPoints : State -> Html State.Msg
snapPoints state =
    Drawer.new
        |> Drawer.id "snap-points"
        |> Drawer.trigger
            (Button.new
                |> Button.text "Open Snap Drawer"
                |> Button.outline
            )
        |> Drawer.snapPoints [ 496, 1 ]
        |> Drawer.swipeable (State.drawer state) State.drawerMsg
        |> Drawer.title [ text "Snap points" ]
        |> Drawer.description [ text "Drag the drawer to snap between a compact peek and a near full-height view." ]
        |> Drawer.content
            [ div [ class "flex-1 p-4" ]
                [ div [ class "h-80 w-full rounded-2xl bg-muted" ] [] ]
            ]
        |> Drawer.footer []
            [ Button.new
                |> Button.text "Close"
                |> Button.toHtml (Drawer.closes "snap-points")
            ]
        |> Drawer.toHtml []


{-| Combine a `Dialog` and a `Drawer` to make a responsive dialog: a `Dialog` from `md` up, a `Drawer` below it.
-}
responsive : State -> Html State.Msg
responsive state =
    let
        profileForm prefix attrs =
            Html.form (class "grid items-start gap-6" :: attrs)
                [ div [ class "grid gap-3" ]
                    [ Label.view [ for (prefix ++ "-email") ] [ text "Email" ]
                    , Input.view [ type_ "email", id (prefix ++ "-email"), value "shadcn@example.com" ]
                    ]
                , div [ class "grid gap-3" ]
                    [ Label.view [ for (prefix ++ "-username") ] [ text "Username" ]
                    , Input.view [ id (prefix ++ "-username"), value "@shadcn" ]
                    ]
                , Button.new
                    |> Button.text "Save changes"
                    |> Button.toHtml [ type_ "submit" ]
                ]
    in
    div []
        [ div [ class "max-md:hidden md:contents" ]
            [ Button.new
                |> Button.text "Edit Profile"
                |> Button.outline
                |> Button.toHtml [ onClick (State.set "responsive-dialog" "open") ]
            , Dialog.new
                |> Dialog.id "responsive-dialog"
                |> Dialog.open (State.get "responsive-dialog" state == Just "open") (State.set "responsive-dialog" "closed")
                |> Dialog.title [ text "Edit profile" ]
                |> Dialog.description [ text "Make changes to your profile here. Click save when you're done." ]
                |> Dialog.content [ profileForm "responsive-dialog" [] ]
                |> Dialog.toHtml [ class "sm:max-w-[425px]" ]
            ]
        , div [ class "md:hidden" ]
            [ Drawer.new
                |> Drawer.id "responsive-drawer"
                |> Drawer.trigger
                    (Button.new
                        |> Button.text "Edit Profile"
                        |> Button.outline
                    )
                |> Drawer.title [ text "Edit profile" ]
                |> Drawer.description [ text "Make changes to your profile here. Click save when you're done." ]
                |> Drawer.content [ profileForm "responsive-drawer" [ class "p-4" ] ]
                |> Drawer.toHtml []
            ]
        ]
