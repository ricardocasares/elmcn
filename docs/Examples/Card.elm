module Examples.Card exposing (..)

import Html exposing (Html, a, div, li, p, span, text, ul)
import Html.Attributes exposing (alt, class, dir, for, href, id, placeholder, src, type_)
import Phosphor exposing (IconWeight(..))
import Svg.Attributes
import UI.Badge as Badge
import UI.Button as Button
import UI.Card as Card
import UI.Input as Input
import UI.Label as Label


demo : Html msg
demo =
    Card.new
        |> Card.title [ text "Login to your account" ]
        |> Card.description [ text "Enter your email below to login to your account" ]
        |> Card.action
            (Button.new
                |> Button.text "Sign Up"
                |> Button.link
                |> Button.toHtml []
            )
        |> Card.content []
            [ div [ class "flex flex-col gap-6" ]
                [ div [ class "grid gap-2" ]
                    [ Label.view [ for "card-email" ] [ text "Email" ]
                    , Input.view [ id "card-email", type_ "email", placeholder "m@example.com" ]
                    ]
                , div [ class "grid gap-2" ]
                    [ div [ class "flex items-center" ]
                        [ Label.view [ for "card-password" ] [ text "Password" ]
                        , a [ href "#", class "ml-auto inline-block text-sm underline-offset-4 hover:underline" ] [ text "Forgot your password?" ]
                        ]
                    , Input.view [ id "card-password", type_ "password" ]
                    ]
                ]
            ]
        |> Card.footer [ class "flex-col gap-2" ]
            [ Button.new
                |> Button.text "Login"
                |> Button.toHtml [ class "w-full" ]
            , Button.new
                |> Button.text "Login with Google"
                |> Button.outline
                |> Button.toHtml [ class "w-full" ]
            ]
        |> Card.toHtml [ class "w-full max-w-sm" ]


{-| `small` tightens the spacing. Pair it with small buttons.
-}
small : Html msg
small =
    let
        item label =
            li [ class "flex gap-2" ]
                [ Phosphor.caretRight Regular |> Phosphor.toHtml [ Svg.Attributes.class "mt-0.5 size-4 shrink-0 text-muted-foreground" ]
                , span [] [ text label ]
                ]
    in
    Card.new
        |> Card.small
        |> Card.title [ text "Scheduled reports" ]
        |> Card.description [ text "Weekly snapshots. No more manual exports." ]
        |> Card.content []
            [ ul [ class "grid gap-2 py-2 text-sm" ]
                [ item "Choose a schedule (daily, or weekly)."
                , item "Send to channels or specific teammates."
                , item "Include charts, tables, and key metrics."
                ]
            ]
        |> Card.footer [ class "flex-col gap-2" ]
            [ Button.new
                |> Button.text "Set up scheduled reports"
                |> Button.small
                |> Button.toHtml [ class "w-full" ]
            , Button.new
                |> Button.text "See what's new"
                |> Button.outline
                |> Button.small
                |> Button.toHtml [ class "w-full" ]
            ]
        |> Card.toHtml [ class "w-full max-w-xs" ]


{-| Override `--card-spacing` on the card to change the gap between and inside its parts at once.
-}
spacing : Html msg
spacing =
    Card.new
        |> Card.title [ text "Roomier card" ]
        |> Card.description [ text "This card uses 24px of spacing instead of the default 16px." ]
        |> Card.action
            (Button.new
                |> Button.text "Sign Up"
                |> Button.link
                |> Button.toHtml []
            )
        |> Card.content []
            [ div [ class "grid gap-2" ]
                [ Label.view [ for "card-spacing-email" ] [ text "Email" ]
                , Input.view [ id "card-spacing-email", type_ "email", placeholder "m@example.com" ]
                ]
            ]
        |> Card.footer []
            [ Button.new
                |> Button.text "Login"
                |> Button.toHtml [ class "w-full" ]
            ]
        |> Card.toHtml [ class "w-full max-w-sm [--card-spacing:--spacing(6)]" ]


{-| Negative margins of `--card-spacing` let content run edge to edge, and `-mb-(--card-spacing)` on the content closes the gap above the footer.
-}
edgeToEdge : Html msg
edgeToEdge =
    Card.new
        |> Card.title [ text "Terms of Service" ]
        |> Card.description [ text "Review the terms before accepting the agreement." ]
        |> Card.content [ class "-mb-(--card-spacing)" ]
            [ div [ class "-mx-(--card-spacing) max-h-48 space-y-4 overflow-y-scroll border-t bg-muted/50 px-(--card-spacing) py-4 text-sm leading-relaxed" ]
                [ p [] [ text "These terms govern your use of the workspace, including access to shared documents, project files, and collaboration tools." ]
                , p [] [ text "You are responsible for the content you upload and for ensuring that your team has the appropriate permissions to view or edit it." ]
                , p [] [ text "We may update features or limits as the service evolves. When those changes materially affect your workflow, we will notify your workspace administrators." ]
                , p [] [ text "By continuing, you agree to keep your account credentials secure and to follow your organization's acceptable use policies." ]
                ]
            ]
        |> Card.footer [ class "justify-end gap-2" ]
            [ Button.new
                |> Button.text "Decline"
                |> Button.outline
                |> Button.toHtml []
            , Button.new
                |> Button.text "Accept"
                |> Button.toHtml []
            ]
        |> Card.toHtml [ class "w-full max-w-sm" ]


{-| `image` places a cover image above the header, flush with the card's edges.
-}
image : Html msg
image =
    Card.new
        |> Card.image [ src "https://avatar.vercel.sh/shadcn1", alt "Event cover", class "brightness-60 grayscale dark:brightness-40" ]
        |> Card.action
            (Badge.new
                |> Badge.text "Featured"
                |> Badge.secondary
                |> Badge.toHtml []
            )
        |> Card.title [ text "Design systems meetup" ]
        |> Card.description [ text "A practical talk on component APIs, accessibility, and shipping faster." ]
        |> Card.footer []
            [ Button.new
                |> Button.text "View Event"
                |> Button.toHtml [ class "w-full" ]
            ]
        |> Card.toHtml [ class "w-full max-w-sm" ]


rtl : Html msg
rtl =
    Card.new
        |> Card.title [ text "تسجيل الدخول إلى حسابك" ]
        |> Card.description [ text "أدخل بريدك الإلكتروني أدناه لتسجيل الدخول إلى حسابك" ]
        |> Card.action
            (Button.new
                |> Button.text "إنشاء حساب"
                |> Button.link
                |> Button.toHtml []
            )
        |> Card.content []
            [ div [ class "flex flex-col gap-6" ]
                [ div [ class "grid gap-2" ]
                    [ Label.view [ for "card-rtl-email" ] [ text "البريد الإلكتروني" ]
                    , Input.view [ id "card-rtl-email", type_ "email", placeholder "m@example.com" ]
                    ]
                , div [ class "grid gap-2" ]
                    [ div [ class "flex items-center" ]
                        [ Label.view [ for "card-rtl-password" ] [ text "كلمة المرور" ]
                        , a [ href "#", class "ms-auto inline-block text-sm underline-offset-4 hover:underline" ] [ text "نسيت كلمة المرور؟" ]
                        ]
                    , Input.view [ id "card-rtl-password", type_ "password" ]
                    ]
                ]
            ]
        |> Card.footer [ class "flex-col gap-2" ]
            [ Button.new
                |> Button.text "تسجيل الدخول"
                |> Button.toHtml [ class "w-full" ]
            , Button.new
                |> Button.text "تسجيل الدخول باستخدام Google"
                |> Button.outline
                |> Button.toHtml [ class "w-full" ]
            ]
        |> Card.toHtml [ class "w-full max-w-sm", dir "rtl" ]
