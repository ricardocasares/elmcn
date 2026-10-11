module Examples.Field exposing (..)

import Html exposing (Html, a, div, span, text)
import Html.Attributes exposing (attribute, checked, class, disabled, for, href, id, name, placeholder, required, rows, type_)
import State exposing (State)
import UI.Button as Button
import UI.Checkbox as Checkbox
import UI.Field as Field
import UI.Input as Input
import UI.RadioGroup as RadioGroup
import UI.Select as Select
import UI.Slider as Slider
import UI.Switch as Switch
import UI.Textarea as Textarea


demo : State -> Html State.Msg
demo state =
    let
        months =
            List.range 1 12
                |> List.map (String.fromInt >> String.padLeft 2 '0')

        years =
            List.range 2024 2029
                |> List.map String.fromInt
    in
    Html.form [ class "w-full max-w-md" ]
        [ Field.group []
            [ Field.set []
                [ Field.legend [] [ text "Payment Method" ]
                , Field.description [] [ text "All transactions are secure and encrypted" ]
                , Field.group []
                    [ Field.view []
                        [ Field.label [ for "checkout-card-name" ] [ text "Name on Card" ]
                        , Input.view [ id "checkout-card-name", placeholder "Evil Rabbit", required True ]
                        ]
                    , Field.view []
                        [ Field.label [ for "checkout-card-number" ] [ text "Card Number" ]
                        , Input.view [ id "checkout-card-number", placeholder "1234 5678 9012 3456", required True ]
                        , Field.description [] [ text "Enter your 16-digit card number" ]
                        ]
                    , div [ class "grid grid-cols-3 gap-4" ]
                        [ Field.view []
                            [ Field.label [ for "checkout-exp-month" ] [ text "Month" ]
                            , Select.new
                                |> Select.id "checkout-exp-month"
                                |> Select.onSelect (State.set "checkout-exp-month")
                                |> Select.placeholder "MM"
                                |> Select.value (State.get "checkout-exp-month" state)
                                |> Select.items (List.map (\month -> Select.item month [ text month ]) months)
                                |> Select.toHtml []
                            ]
                        , Field.view []
                            [ Field.label [ for "checkout-exp-year" ] [ text "Year" ]
                            , Select.new
                                |> Select.id "checkout-exp-year"
                                |> Select.onSelect (State.set "checkout-exp-year")
                                |> Select.placeholder "YYYY"
                                |> Select.value (State.get "checkout-exp-year" state)
                                |> Select.items (List.map (\year -> Select.item year [ text year ]) years)
                                |> Select.toHtml []
                            ]
                        , Field.view []
                            [ Field.label [ for "checkout-cvv" ] [ text "CVV" ]
                            , Input.view [ id "checkout-cvv", placeholder "123", required True ]
                            ]
                        ]
                    ]
                ]
            , Field.separator [] []
            , Field.set []
                [ Field.legend [] [ text "Billing Address" ]
                , Field.description [] [ text "The billing address associated with your payment method" ]
                , Field.group []
                    [ Field.horizontal []
                        [ Checkbox.view [ id "checkout-same-as-shipping", checked True ]
                        , Field.label [ for "checkout-same-as-shipping", class "font-normal" ] [ text "Same as shipping address" ]
                        ]
                    ]
                ]
            , Field.set []
                [ Field.group []
                    [ Field.view []
                        [ Field.label [ for "checkout-comments" ] [ text "Comments" ]
                        , Textarea.view [ id "checkout-comments", placeholder "Add any additional comments", class "resize-none" ]
                        ]
                    ]
                ]
            , Field.horizontal []
                [ Button.new
                    |> Button.text "Submit"
                    |> Button.toHtml [ type_ "submit" ]
                , Button.new
                    |> Button.text "Cancel"
                    |> Button.outline
                    |> Button.toHtml [ type_ "button" ]
                ]
            ]
        ]


{-| The description can go before or after the control.
-}
input : Html msg
input =
    Field.set [ class "w-full max-w-xs" ]
        [ Field.group []
            [ Field.view []
                [ Field.label [ for "field-username" ] [ text "Username" ]
                , Input.view [ id "field-username", placeholder "Max Leiter" ]
                , Field.description [] [ text "Choose a unique username for your account." ]
                ]
            , Field.view []
                [ Field.label [ for "field-password" ] [ text "Password" ]
                , Field.description [] [ text "Must be at least 8 characters long." ]
                , Input.view [ id "field-password", type_ "password", placeholder "••••••••" ]
                ]
            ]
        ]


textarea : Html msg
textarea =
    Field.set [ class "w-full max-w-xs" ]
        [ Field.group []
            [ Field.view []
                [ Field.label [ for "field-feedback" ] [ text "Feedback" ]
                , Textarea.view [ id "field-feedback", placeholder "Your feedback helps us improve...", rows 4 ]
                , Field.description [] [ text "Share your thoughts about our service." ]
                ]
            ]
        ]


select : State -> Html State.Msg
select state =
    Field.view [ class "w-full max-w-xs" ]
        [ Field.label [ for "field-department" ] [ text "Department" ]
        , Select.new
            |> Select.id "field-department"
            |> Select.onSelect (State.set "field-department")
            |> Select.placeholder "Choose department"
            |> Select.value (State.get "field-department" state)
            |> Select.items
                [ Select.item "engineering" [ text "Engineering" ]
                , Select.item "design" [ text "Design" ]
                , Select.item "marketing" [ text "Marketing" ]
                , Select.item "sales" [ text "Sales" ]
                , Select.item "support" [ text "Customer Support" ]
                , Select.item "hr" [ text "Human Resources" ]
                , Select.item "finance" [ text "Finance" ]
                , Select.item "operations" [ text "Operations" ]
                ]
            |> Select.toHtml []
        , Field.description [] [ text "Select your department or area of work." ]
        ]


{-| A slider has no `id` to label, so the field gets a `title` and the slider an `aria-label`.
-}
slider : State -> Html State.Msg
slider state =
    let
        ( low, high ) =
            State.get "field-price" state
                |> Maybe.map (String.split ",")
                |> Maybe.andThen
                    (\parts ->
                        case List.filterMap String.toFloat parts of
                            [ a, b ] ->
                                Just ( a, b )

                            _ ->
                                Nothing
                    )
                |> Maybe.withDefault ( 200, 800 )

        amount value =
            span [ class "font-medium tabular-nums" ] [ text (String.fromFloat value) ]
    in
    Field.view [ class "w-full max-w-xs" ]
        [ Field.title [] [ text "Price Range" ]
        , Field.description []
            [ text "Set your budget range ($", amount low, text " - ", amount high, text ")." ]
        , Slider.new
            |> Slider.range low high
            |> Slider.onChange (\( a, b ) -> State.set "field-price" (String.fromFloat a ++ "," ++ String.fromFloat b))
            |> Slider.min 0
            |> Slider.max 1000
            |> Slider.step 10
            |> Slider.toHtml [ class "mt-2 w-full", attribute "aria-label" "Price Range" ]
        ]


{-| A `set` groups related fields under a `legend`.
-}
fieldset : Html msg
fieldset =
    Field.set [ class "w-full max-w-sm" ]
        [ Field.legend [] [ text "Address Information" ]
        , Field.description [] [ text "We need your address to deliver your order." ]
        , Field.group []
            [ Field.view []
                [ Field.label [ for "field-street" ] [ text "Street Address" ]
                , Input.view [ id "field-street", placeholder "123 Main St" ]
                ]
            , div [ class "grid grid-cols-2 gap-4" ]
                [ Field.view []
                    [ Field.label [ for "field-city" ] [ text "City" ]
                    , Input.view [ id "field-city", placeholder "New York" ]
                    ]
                , Field.view []
                    [ Field.label [ for "field-zip" ] [ text "Postal Code" ]
                    , Input.view [ id "field-zip", placeholder "90502" ]
                    ]
                ]
            ]
        ]


{-| A `horizontal` field puts the control beside its label. Use `smallLegend` for a set of them.
-}
checkbox : Html msg
checkbox =
    let
        option key label =
            Field.horizontal []
                [ Checkbox.view [ id ("field-finder-" ++ key) ]
                , Field.label [ for ("field-finder-" ++ key), class "font-normal" ] [ text label ]
                ]
    in
    Field.group [ class "w-full max-w-xs" ]
        [ Field.set []
            [ Field.smallLegend [] [ text "Show these items on the desktop" ]
            , Field.description [] [ text "Select the items you want to show on the desktop." ]
            , Field.group [ class "gap-3" ]
                [ option "hard-disks" "Hard disks"
                , option "external-disks" "External disks"
                , option "cds" "CDs, DVDs, and iPods"
                , option "servers" "Connected servers"
                ]
            ]
        , Field.separator [] []
        , Field.horizontal []
            [ Checkbox.view [ id "field-finder-sync", checked True ]
            , Field.content []
                [ Field.label [ for "field-finder-sync" ] [ text "Sync Desktop & Documents folders" ]
                , Field.description [] [ text "Your Desktop & Documents folders are being synced with iCloud Drive. You can access them from other devices." ]
                ]
            ]
        ]


radio : Html msg
radio =
    let
        plan key label =
            Field.horizontal []
                [ RadioGroup.item [ id ("field-plan-" ++ key), name "field-plan", checked (key == "monthly") ]
                , Field.label [ for ("field-plan-" ++ key), class "font-normal" ] [ text label ]
                ]
    in
    Field.set [ class "w-full max-w-xs" ]
        [ Field.smallLegend [] [ text "Subscription Plan" ]
        , Field.description [] [ text "Yearly and lifetime plans offer significant savings." ]
        , RadioGroup.view []
            [ plan "monthly" "Monthly ($9.99/month)"
            , plan "yearly" "Yearly ($99.99/year)"
            , plan "lifetime" "Lifetime ($299.99)"
            ]
        ]


switch : Html msg
switch =
    Field.horizontal [ class "w-fit" ]
        [ Field.label [ for "field-2fa" ] [ text "Multi-factor authentication" ]
        , Switch.new
            |> Switch.toHtml [ id "field-2fa" ]
        ]


{-| A `label` around a `horizontal` field makes the whole box clickable and highlights it when its control is checked.
-}
choiceCard : Html msg
choiceCard =
    let
        card key label description =
            Field.label [ for ("field-env-" ++ key) ]
                [ Field.horizontal []
                    [ Field.content []
                        [ Field.title [] [ text label ]
                        , Field.description [] [ text description ]
                        ]
                    , RadioGroup.item [ id ("field-env-" ++ key), name "field-env", checked (key == "kubernetes") ]
                    ]
                ]
    in
    Field.group [ class "w-full max-w-xs" ]
        [ Field.set []
            [ Field.smallLegend [] [ text "Compute Environment" ]
            , Field.description [] [ text "Select the compute environment for your cluster." ]
            , RadioGroup.view []
                [ card "kubernetes" "Kubernetes" "Run GPU workloads on a K8s cluster."
                , card "vm" "Virtual Machine" "Access a cluster to run GPU workloads."
                ]
            ]
        ]


{-| A `separator` divides a `group`. A `group` of checkboxes marked `data-slot="checkbox-group"` is packed tighter.
-}
fieldGroup : Html msg
fieldGroup =
    let
        option key label attrs =
            Field.horizontal []
                [ Checkbox.view (id ("field-notify-" ++ key) :: attrs)
                , Field.label [ for ("field-notify-" ++ key), class "font-normal" ] [ text label ]
                ]
    in
    Field.group [ class "w-full max-w-xs" ]
        [ Field.set []
            [ Field.label [] [ text "Responses" ]
            , Field.description [] [ text "Get notified when ChatGPT responds to requests that take time, like research or image generation." ]
            , Field.group [ attribute "data-slot" "checkbox-group" ]
                [ option "push" "Push notifications" [ checked True, disabled True ] ]
            ]
        , Field.separator [] []
        , Field.set []
            [ Field.label [] [ text "Tasks" ]
            , Field.description []
                [ text "Get notified when tasks you've created have updates. "
                , a [ href "#" ] [ text "Manage tasks" ]
                ]
            , Field.group [ attribute "data-slot" "checkbox-group" ]
                [ option "push-tasks" "Push notifications" []
                , option "email-tasks" "Email notifications" []
                ]
            ]
        ]


{-| A `responsive` field stacks when the enclosing `group` is narrow and goes side by side from `md` up. Resize the window to see it change.
-}
responsive : Html msg
responsive =
    Html.form [ class "w-full max-w-lg" ]
        [ Field.set []
            [ Field.legend [] [ text "Profile" ]
            , Field.description [] [ text "Fill in your profile information." ]
            , Field.group []
                [ Field.responsive []
                    [ Field.content []
                        [ Field.label [ for "field-profile-name" ] [ text "Name" ]
                        , Field.description [] [ text "Provide your full name for identification" ]
                        ]
                    , Input.view [ id "field-profile-name", placeholder "Evil Rabbit", required True ]
                    ]
                , Field.responsive []
                    [ Button.new
                        |> Button.text "Submit"
                        |> Button.toHtml [ type_ "submit" ]
                    , Button.new
                        |> Button.text "Cancel"
                        |> Button.outline
                        |> Button.toHtml [ type_ "button" ]
                    ]
                ]
            ]
        ]


{-| Mark the field `invalid` and the control `aria-invalid`, then show the message with `error`. `errors` takes a list and renders it as one line or as bullets.
-}
validation : Html msg
validation =
    Field.group [ class "w-full max-w-xs" ]
        [ Field.view [ Field.invalid ]
            [ Field.label [ for "field-invalid-email" ] [ text "Email" ]
            , Input.view [ id "field-invalid-email", type_ "email", attribute "aria-invalid" "true" ]
            , Field.error [] [ text "Enter a valid email address." ]
            ]
        , Field.view [ Field.invalid ]
            [ Field.label [ for "field-invalid-password" ] [ text "Password" ]
            , Input.view [ id "field-invalid-password", type_ "password", attribute "aria-invalid" "true" ]
            , Field.errors [] [ "Must be at least 8 characters long.", "Must contain a number." ]
            ]
        ]


{-| `disabled` on the field dims the label to match a disabled control.
-}
disabledField : Html msg
disabledField =
    Field.view [ Field.disabled, class "w-full max-w-xs" ]
        [ Field.label [ for "field-disabled" ] [ text "Email" ]
        , Input.view [ id "field-disabled", placeholder "Cannot edit", disabled True ]
        , Field.description [] [ text "This field is currently disabled." ]
        ]
