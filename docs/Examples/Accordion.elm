module Examples.Accordion exposing (..)

import Html exposing (Html, p, text)
import Html.Attributes exposing (class)
import State exposing (State)
import UI.Accordion as Accordion
import UI.Card as Card


demo : Html msg
demo =
    Accordion.new
        |> Accordion.id "faq"
        |> Accordion.items
            [ Accordion.item [ text "Is it accessible?" ]
                [ text "Yes. It adheres to the WAI-ARIA design pattern." ]
            , Accordion.item [ text "Is it styled?" ]
                [ text "Yes. It comes with default styles that matches the other components' aesthetic." ]
            , Accordion.item [ text "Is it animated?" ]
                [ text "Yes. It's animated by default, but you can disable it if you prefer." ]
            ]
        |> Accordion.toHtml [ class "max-w-lg" ]


{-| With `multiple`, opening an item leaves the others open.
-}
multiple : Html msg
multiple =
    Accordion.new
        |> Accordion.id "multiple"
        |> Accordion.multiple
        |> Accordion.items
            [ Accordion.item [ text "What are the key considerations when implementing a comprehensive enterprise-level authentication system?" ]
                [ text "Implementing a robust enterprise authentication system requires careful consideration of multiple factors. This includes secure password hashing and storage, multi-factor authentication (MFA) implementation, session management, OAuth2 and SSO integration, regular security audits, rate limiting to prevent brute force attacks, and maintaining detailed audit logs. Additionally, you'll need to consider scalability, performance impact, and compliance with relevant data protection regulations such as GDPR or HIPAA." ]
            , Accordion.item [ text "How does modern distributed system architecture handle eventual consistency and data synchronization across multiple regions?" ]
                [ text "Modern distributed systems employ various strategies to maintain data consistency across regions. This often involves using techniques like CRDT (Conflict-Free Replicated Data Types), vector clocks, and gossip protocols. Systems might implement event sourcing patterns, utilize message queues for asynchronous updates, and employ sophisticated conflict resolution strategies. Popular solutions like Amazon's DynamoDB and Google's Spanner demonstrate different approaches to solving these challenges, balancing between consistency, availability, and partition tolerance as described in the CAP theorem." ]
            ]
        |> Accordion.toHtml [ class "max-w-lg" ]


{-| Items can carry their own border and padding, with `gap-2` on the accordion to space them out.
-}
withBorders : Html msg
withBorders =
    Accordion.new
        |> Accordion.id "borders"
        |> Accordion.items
            [ Accordion.item [ text "How does billing work?" ]
                [ text "We offer monthly and annual subscription plans. Billing is charged at the beginning of each cycle, and you can cancel anytime. All plans include automatic backups, 24/7 support, and unlimited team members. There are no hidden fees or setup costs." ]
                |> Accordion.attributes [ class "rounded-lg border px-2.5 text-muted-foreground" ]
            , Accordion.item [ text "Is my data secure?" ]
                [ text "Yes. We use end-to-end encryption, SOC 2 Type II compliance, and regular third-party security audits. All data is encrypted at rest and in transit using industry-standard protocols. We also offer optional two-factor authentication and single sign-on for enterprise customers." ]
                |> Accordion.attributes [ class "rounded-lg border px-2.5 text-muted-foreground" ]
            , Accordion.item [ text "What integrations do you support?" ]
                [ p [] [ text "We integrate with 500+ popular tools including Slack, Zapier, Salesforce, HubSpot, and more. You can also build custom integrations using our REST API and webhooks." ]
                , p [] [ text "Our API documentation includes code examples in 10+ programming languages." ]
                ]
                |> Accordion.attributes [ class "rounded-lg border px-2.5 text-muted-foreground" ]
            ]
        |> Accordion.toHtml [ class "max-w-lg gap-2" ]


{-| An accordion with `multiple` and an item rendered `open` inside a card.
-}
inCard : Html msg
inCard =
    Card.new
        |> Card.title [ text "Subscription & Billing" ]
        |> Card.description [ text "Common questions about your account, plans, and payments" ]
        |> Card.content []
            [ Accordion.new
                |> Accordion.id "billing"
                |> Accordion.multiple
                |> Accordion.items
                    [ Accordion.item [ text "What subscription plans do you offer?" ]
                        [ p [] [ text "We offer three tiers: Starter ($9/month), Professional ($29/month), and Enterprise (custom pricing). Each plan includes different features and usage limits to match your needs." ]
                        , p [] [ text "All plans come with a 14-day free trial, no credit card required. You can upgrade, downgrade, or cancel at any time." ]
                        ]
                        |> Accordion.open
                    , Accordion.item [ text "How does billing and payment work?" ]
                        [ p [] [ text "Billing occurs automatically at the start of each billing cycle. We accept all major credit cards, PayPal, and ACH transfers for enterprise customers." ]
                        , p [] [ text "You'll receive an invoice via email after each payment. You can update your payment method or billing information anytime in your account settings." ]
                        ]
                    , Accordion.item [ text "Can I upgrade or downgrade my plan?" ]
                        [ p [] [ text "Yes, you can change your plan at any time. When upgrading, you'll be charged a prorated amount for the remainder of your billing cycle and immediately gain access to new features." ]
                        , p [] [ text "When downgrading, the change takes effect at the end of your current billing period, and you'll retain access to premium features until then." ]
                        ]
                    , Accordion.item [ text "How do I cancel my subscription?" ]
                        [ p [] [ text "You can cancel your subscription anytime from your account settings. There are no cancellation fees or penalties. Your access will continue until the end of your current billing period." ]
                        , p [] [ text "After cancellation, your data is retained for 30 days in case you want to reactivate." ]
                        ]
                    ]
                |> Accordion.toHtml []
            ]
        |> Card.toHtml [ class "w-full max-w-lg gap-4" ]


{-| A `disabled` item is dimmed and can't be opened. The items here are inset and highlighted while open.
-}
withDisabled : Html msg
withDisabled =
    Accordion.new
        |> Accordion.id "disabled"
        |> Accordion.items
            [ Accordion.item [ text "Can I access my account history?" ]
                [ text "Yes, you can view your complete account history including all transactions, plan changes, and support tickets in the Account History section of your dashboard." ]
                |> Accordion.attributes [ class "p-1 px-3.5 open:bg-muted/50" ]
            , Accordion.item [ text "Premium feature information" ]
                [ text "This section contains information about premium features. Upgrade your plan to access this content." ]
                |> Accordion.disabled
                |> Accordion.attributes [ class "p-1 px-3.5 open:bg-muted/50" ]
            , Accordion.item [ text "How do I update my email address?" ]
                [ text "You can update your email address in your account settings. You'll receive a verification email at your new address to confirm the change." ]
                |> Accordion.attributes [ class "p-1 px-3.5 open:bg-muted/50" ]
            ]
        |> Accordion.toHtml [ class "max-w-lg overflow-hidden rounded-lg border" ]


{-| `onToggle` reports when the user opens or closes an item, and `open` renders it from your model.
-}
controlled : State -> Html State.Msg
controlled state =
    let
        isOpen key =
            State.get key state == Just "open"

        toggle key =
            \opened ->
                State.set key
                    (if opened then
                        "open"

                     else
                        "closed"
                    )

        section key trigger content =
            Accordion.item [ text trigger ] [ text content ]
                |> Accordion.onToggle (toggle key)
                |> (if isOpen key then
                        Accordion.open

                    else
                        identity
                   )
    in
    Accordion.new
        |> Accordion.id "controlled"
        |> Accordion.items
            [ section "accordion-shipping" "How long does shipping take?" "Orders ship within two business days and arrive in three to five."
            , section "accordion-returns" "What is the return policy?" "Returns are free within 30 days of delivery."
            ]
        |> Accordion.toHtml [ class "max-w-lg" ]
