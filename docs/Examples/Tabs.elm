module Examples.Tabs exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, dir)
import Phosphor exposing (IconWeight(..))
import State exposing (State)
import UI.Card as Card
import UI.Tabs as Tabs


demo : State -> Html State.Msg
demo state =
    let
        card title description content =
            Card.new
                |> Card.title [ text title ]
                |> Card.description [ text description ]
                |> Card.content [ class "text-sm text-muted-foreground" ] [ text content ]
                |> Card.toHtml []
    in
    Tabs.new
        |> Tabs.id "tabs-demo"
        |> Tabs.onSelect (State.set "tabs-demo")
        |> Tabs.value (State.get "tabs-demo" state |> Maybe.withDefault "overview")
        |> Tabs.tabs
            [ Tabs.tab "overview"
                [ text "Overview" ]
                [ card "Overview" "View your key metrics and recent project activity. Track progress across all your active projects." "You have 12 active projects and 3 pending tasks." ]
            , Tabs.tab "analytics"
                [ text "Analytics" ]
                [ card "Analytics" "Track performance and user engagement metrics. Monitor trends and identify growth opportunities." "Page views are up 25% compared to last month." ]
            , Tabs.tab "reports"
                [ text "Reports" ]
                [ card "Reports" "Generate and download your detailed reports. Export data in multiple formats for analysis." "You have 5 reports ready and available to export." ]
            , Tabs.tab "settings"
                [ text "Settings" ]
                [ card "Settings" "Manage your account preferences and options. Customize your experience to fit your needs." "Configure notifications, security, and themes." ]
            ]
        |> Tabs.toHtml [ class "w-full max-w-sm" ]


{-| `line` underlines the selected tab instead of raising it. A tab without content has no panel.
-}
line : State -> Html State.Msg
line state =
    Tabs.new
        |> Tabs.id "tabs-line"
        |> Tabs.onSelect (State.set "tabs-line")
        |> Tabs.value (State.get "tabs-line" state |> Maybe.withDefault "overview")
        |> Tabs.line
        |> Tabs.tabs
            [ Tabs.tab "overview" [ text "Overview" ] []
            , Tabs.tab "analytics" [ text "Analytics" ] []
            , Tabs.tab "reports" [ text "Reports" ] []
            ]
        |> Tabs.toHtml []


{-| `vertical` stacks the tabs and puts the panel beside them.
-}
vertical : State -> Html State.Msg
vertical state =
    Tabs.new
        |> Tabs.id "tabs-vertical"
        |> Tabs.onSelect (State.set "tabs-vertical")
        |> Tabs.value (State.get "tabs-vertical" state |> Maybe.withDefault "account")
        |> Tabs.vertical
        |> Tabs.tabs
            [ Tabs.tab "account" [ text "Account" ] [ text "Manage your account preferences and profile information." ]
            , Tabs.tab "password" [ text "Password" ] [ text "Update your password to keep your account secure." ]
            , Tabs.tab "notifications" [ text "Notifications" ] [ text "Configure how you receive notifications and alerts." ]
            ]
        |> Tabs.toHtml [ class "w-full max-w-sm" ]


disabledTab : State -> Html State.Msg
disabledTab state =
    Tabs.new
        |> Tabs.id "tabs-disabled"
        |> Tabs.onSelect (State.set "tabs-disabled")
        |> Tabs.value (State.get "tabs-disabled" state |> Maybe.withDefault "home")
        |> Tabs.tabs
            [ Tabs.tab "home" [ text "Home" ] []
            , Tabs.tab "settings" [ text "Disabled" ] [] |> Tabs.disabled
            ]
        |> Tabs.toHtml []


withIcons : State -> Html State.Msg
withIcons state =
    Tabs.new
        |> Tabs.id "tabs-icons"
        |> Tabs.onSelect (State.set "tabs-icons")
        |> Tabs.value (State.get "tabs-icons" state |> Maybe.withDefault "preview")
        |> Tabs.tabs
            [ Tabs.tab "preview" [ Phosphor.appWindow Regular |> Phosphor.toHtml [], text "Preview" ] []
            , Tabs.tab "code" [ Phosphor.code Regular |> Phosphor.toHtml [], text "Code" ] []
            ]
        |> Tabs.toHtml []


rtl : State -> Html State.Msg
rtl state =
    let
        card title description content =
            Card.new
                |> Card.title [ text title ]
                |> Card.description [ text description ]
                |> Card.content [ class "text-sm text-muted-foreground" ] [ text content ]
                |> Card.toHtml []
    in
    div [ dir "rtl", class "w-full max-w-sm" ]
        [ Tabs.new
            |> Tabs.id "tabs-rtl"
            |> Tabs.onSelect (State.set "tabs-rtl")
            |> Tabs.value (State.get "tabs-rtl" state |> Maybe.withDefault "overview")
            |> Tabs.tabs
                [ Tabs.tab "overview"
                    [ text "نظرة عامة" ]
                    [ card "نظرة عامة" "عرض مقاييسك الرئيسية وأنشطة المشروع الأخيرة. تتبع التقدم عبر جميع مشاريعك النشطة." "لديك ١٢ مشروعًا نشطًا و٣ مهام معلقة." ]
                , Tabs.tab "analytics"
                    [ text "التحليلات" ]
                    [ card "التحليلات" "تتبع مقاييس الأداء ومشاركة المستخدمين. راقب الاتجاهات وحدد فرص النمو." "زادت مشاهدات الصفحة بنسبة ٢٥٪ مقارنة بالشهر الماضي." ]
                , Tabs.tab "reports"
                    [ text "التقارير" ]
                    [ card "التقارير" "إنشاء وتنزيل تقاريرك التفصيلية. تصدير البيانات بتنسيقات متعددة للتحليل." "لديك ٥ تقارير جاهزة ومتاحة للتصدير." ]
                , Tabs.tab "settings"
                    [ text "الإعدادات" ]
                    [ card "الإعدادات" "إدارة تفضيلات حسابك وخياراته. تخصيص تجربتك لتناسب احتياجاتك." "تكوين الإشعارات والأمان والسمات." ]
                ]
            |> Tabs.toHtml [ class "w-full" ]
        ]
