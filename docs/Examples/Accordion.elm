module Examples.Accordion exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, dir)
import UI.Accordion as Accordion
import UI.Card as Card


demo : Html msg
demo =
    Accordion.new
        |> Accordion.id "demo"
        |> Accordion.items
            [ Accordion.item [ text "What are your shipping options?" ]
                [ text "We offer standard (5-7 days), express (2-3 days), and overnight shipping. Free shipping on international orders." ]
                |> Accordion.open
            , Accordion.item [ text "What is your return policy?" ]
                [ text "Returns accepted within 30 days. Items must be unused and in original packaging. Refunds processed within 5-7 business days." ]
            , Accordion.item [ text "How can I contact customer support?" ]
                [ text "Reach us via email, live chat, or phone. We respond within 24 hours during business days." ]
            ]
        |> Accordion.toHtml [ class "max-w-lg" ]


{-| A basic accordion that shows one item at a time. The first item is `open` by default.
-}
basic : Html msg
basic =
    Accordion.new
        |> Accordion.id "basic"
        |> Accordion.items
            [ Accordion.item [ text "How do I reset my password?" ]
                [ text "Click on 'Forgot Password' on the login page, enter your email address, and we'll send you a link to reset your password. The link will expire in 24 hours." ]
                |> Accordion.open
            , Accordion.item [ text "Can I change my subscription plan?" ]
                [ text "Yes, you can upgrade or downgrade your plan at any time from your account settings. Changes will be reflected in your next billing cycle." ]
            , Accordion.item [ text "What payment methods do you accept?" ]
                [ text "We accept all major credit cards, PayPal, and bank transfers. All payments are processed securely through our payment partners." ]
            ]
        |> Accordion.toHtml [ class "max-w-lg" ]


{-| Use `multiple` to allow multiple items to be open at the same time.
-}
multiple : Html msg
multiple =
    Accordion.new
        |> Accordion.id "multiple"
        |> Accordion.multiple
        |> Accordion.items
            [ Accordion.item [ text "Notification Settings" ]
                [ text "Manage how you receive notifications. You can enable email alerts for updates or push notifications for mobile devices." ]
                |> Accordion.open
            , Accordion.item [ text "Privacy & Security" ]
                [ text "Control your privacy settings and security preferences. Enable two-factor authentication, manage connected devices, review active sessions, and configure data sharing preferences. You can also download your data or delete your account." ]
            , Accordion.item [ text "Billing & Subscription" ]
                [ text "View your current plan, payment history, and upcoming invoices. Update your payment method, change your subscription tier, or cancel your subscription." ]
            ]
        |> Accordion.toHtml [ class "max-w-lg" ]


{-| Use `disabled` on an item to disable individual items.
-}
disabled : Html msg
disabled =
    Accordion.new
        |> Accordion.id "disabled"
        |> Accordion.items
            [ Accordion.item [ text "Can I access my account history?" ]
                [ text "Yes, you can view your complete account history including all transactions, plan changes, and support tickets in the Account History section of your dashboard." ]
            , Accordion.item [ text "Premium feature information" ]
                [ text "This section contains information about premium features. Upgrade your plan to access this content." ]
                |> Accordion.disabled
            , Accordion.item [ text "How do I update my email address?" ]
                [ text "You can update your email address in your account settings. You'll receive a verification email at your new address to confirm the change." ]
            ]
        |> Accordion.toHtml [ class "max-w-lg" ]


{-| Add `border` to the accordion and `px-4` to the items to add borders around the items. Items already draw a divider between each other.
-}
borders : Html msg
borders =
    Accordion.new
        |> Accordion.id "borders"
        |> Accordion.items
            [ Accordion.item [ text "How does billing work?" ]
                [ text "We offer monthly and annual subscription plans. Billing is charged at the beginning of each cycle, and you can cancel anytime. All plans include automatic backups, 24/7 support, and unlimited team members." ]
                |> Accordion.open
                |> Accordion.attributes [ class "px-4" ]
            , Accordion.item [ text "Is my data secure?" ]
                [ text "Yes. We use end-to-end encryption, SOC 2 Type II compliance, and regular third-party security audits. All data is encrypted at rest and in transit using industry-standard protocols." ]
                |> Accordion.attributes [ class "px-4" ]
            , Accordion.item [ text "What integrations do you support?" ]
                [ text "We integrate with 500+ popular tools including Slack, Zapier, Salesforce, HubSpot, and more. You can also build custom integrations using our REST API and webhooks." ]
                |> Accordion.attributes [ class "px-4" ]
            ]
        |> Accordion.toHtml [ class "max-w-lg rounded-lg border" ]


{-| Wrap the accordion in a `Card`.
-}
card : Html msg
card =
    Card.new
        |> Card.title [ text "Subscription & Billing" ]
        |> Card.description [ text "Common questions about your account, plans, payments and cancellations." ]
        |> Card.content []
            [ Accordion.new
                |> Accordion.id "card"
                |> Accordion.items
                    [ Accordion.item [ text "What subscription plans do you offer?" ]
                        [ text "We offer three subscription tiers: Starter ($9/month), Professional ($29/month), and Enterprise ($99/month). Each plan includes increasing storage limits, API access, priority support, and team collaboration features." ]
                        |> Accordion.open
                    , Accordion.item [ text "How does billing work?" ]
                        [ text "Billing occurs automatically at the start of each billing cycle. We accept all major credit cards, PayPal, and ACH transfers for enterprise customers. You'll receive an invoice via email after each payment." ]
                    , Accordion.item [ text "How do I cancel my subscription?" ]
                        [ text "You can cancel your subscription anytime from your account settings. There are no cancellation fees or penalties. Your access will continue until the end of your current billing period." ]
                    ]
                |> Accordion.toHtml []
            ]
        |> Card.toHtml [ class "w-full max-w-sm" ]


{-| Set `dir="rtl"` on a parent element for right-to-left languages.
-}
rtl : Html msg
rtl =
    div [ dir "rtl", class "w-full max-w-md" ]
        [ Accordion.new
            |> Accordion.id "rtl"
            |> Accordion.items
                [ Accordion.item [ text "كيف يمكنني إعادة تعيين كلمة المرور؟" ]
                    [ text "انقر على 'نسيت كلمة المرور' في صفحة تسجيل الدخول، أدخل عنوان بريدك الإلكتروني، وسنرسل لك رابطًا لإعادة تعيين كلمة المرور. سينتهي صلاحية الرابط خلال 24 ساعة." ]
                    |> Accordion.open
                , Accordion.item [ text "هل يمكنني تغيير خطة الاشتراك الخاصة بي؟" ]
                    [ text "نعم، يمكنك ترقية أو تخفيض خطتك في أي وقت من إعدادات حسابك. ستظهر التغييرات في دورة الفوترة التالية." ]
                , Accordion.item [ text "ما هي طرق الدفع التي تقبلونها؟" ]
                    [ text "نقبل جميع بطاقات الائتمان الرئيسية و PayPal والتحويلات المصرفية. تتم معالجة جميع المدفوعات بأمان من خلال شركاء الدفع لدينا." ]
                ]
            |> Accordion.toHtml []
        ]
