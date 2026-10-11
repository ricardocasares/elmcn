module Main exposing (main)

import Browser
import Html exposing (Html, a, div, h1, h2, header, main_, p, section, span, text)
import Html.Attributes exposing (alt, attribute, checked, class, dir, disabled, for, href, id, name, placeholder, src, value)
import Html.Events exposing (onCheck, onClick)
import Icons
import Svg.Attributes
import UI.Alert as Alert
import UI.AspectRatio as AspectRatio
import UI.Avatar as Avatar
import UI.Badge as Badge
import UI.Breadcrumb as Breadcrumb
import UI.Button as Button
import UI.Card as Card
import UI.Checkbox as Checkbox
import UI.Empty as Empty
import UI.Icon as Icon
import UI.Input as Input
import UI.Kbd as Kbd
import UI.Label as Label
import UI.NativeSelect as NativeSelect
import UI.Progress as Progress
import UI.RadioGroup as RadioGroup
import UI.Separator as Separator
import UI.Skeleton as Skeleton
import UI.Spinner as Spinner
import UI.Switch as Switch
import UI.Table as Table
import UI.Textarea as Textarea


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { theme : Theme
    , terms : Bool
    , airplaneMode : Bool
    , density : Density
    }


type Theme
    = Light
    | Dark


type Density
    = Default
    | Comfortable
    | Compact


init : Model
init =
    { theme = Light
    , terms = True
    , airplaneMode = False
    , density = Comfortable
    }



-- UPDATE


type Msg
    = ThemeToggled
    | TermsToggled Bool
    | AirplaneModeToggled Bool
    | DensityChosen Density


update : Msg -> Model -> Model
update msg model =
    case msg of
        ThemeToggled ->
            { model
                | theme =
                    case model.theme of
                        Light ->
                            Dark

                        Dark ->
                            Light
            }

        TermsToggled terms ->
            { model | terms = terms }

        AirplaneModeToggled airplaneMode ->
            { model | airplaneMode = airplaneMode }

        DensityChosen density ->
            { model | density = density }



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class
            (case model.theme of
                Light ->
                    ""

                Dark ->
                    "dark"
            )
        ]
        [ div [ class "min-h-screen bg-background text-foreground" ]
            [ header [ class "mx-auto flex max-w-4xl items-center justify-between px-6 pt-10" ]
                [ div []
                    [ h1 [ class "text-3xl font-semibold tracking-tight" ] [ text "elmcn" ]
                    , p [ class "text-muted-foreground" ] [ text "shadcn/ui components for Elm." ]
                    ]
                , Button.view [ Button.outline ]
                    [ onClick ThemeToggled, id "theme-toggle" ]
                    [ text
                        (case model.theme of
                            Light ->
                                "Dark mode"

                            Dark ->
                                "Light mode"
                        )
                    ]
                ]
            , main_ [ class "mx-auto flex max-w-4xl flex-col gap-12 px-6 py-10" ]
                [ section [ class "flex flex-col gap-4" ] [ h2 [ class "text-lg font-semibold tracking-tight" ] [ text "Button" ], buttons ]
                , example "Badge" badges
                , example "Card" card
                , example "Alert" alerts
                , example "Form controls" (formControls model)
                , example "Native select" nativeSelects
                , example "Avatar" avatars
                , example "Breadcrumb" breadcrumb
                , example "Table" table
                , example "Progress, Skeleton, Spinner" loading
                , example "Kbd" kbd
                , example "Separator" separator
                , example "Aspect ratio" aspectRatio
                , example "Empty" empty
                ]
            ]
        ]


example : String -> Html Msg -> Html Msg
example title content =
    section [ class "flex flex-col gap-4" ]
        [ h2 [ class "text-lg font-semibold tracking-tight" ] [ text title ]
        , div [ class "rounded-xl border p-6" ] [ content ]
        ]


buttons : Html Msg
buttons =
    div [ class "grid gap-4 sm:grid-cols-2" ]
        [ preview "Demo"
            (div [ class "flex flex-wrap items-center gap-2 md:flex-row" ]
                [ Button.view [ Button.outline ] [] [ text "Button" ]
                , Button.view [ Button.outline, Button.icon ] [ attribute "aria-label" "Submit" ] [ Icons.arrowUp [] ]
                ]
            )
        , widePreview "Size"
            (div [ class "flex flex-col items-start gap-8 sm:flex-row" ]
                [ div [ class "flex items-start gap-2" ]
                    [ Button.view [ Button.extraSmall, Button.outline ] [] [ text "Extra Small" ]
                    , Button.view [ Button.iconExtraSmall, Button.outline ] [ attribute "aria-label" "Submit" ] [ Icons.arrowUpRight [] ]
                    ]
                , div [ class "flex items-start gap-2" ]
                    [ Button.view [ Button.small, Button.outline ] [] [ text "Small" ]
                    , Button.view [ Button.iconSmall, Button.outline ] [ attribute "aria-label" "Submit" ] [ Icons.arrowUpRight [] ]
                    ]
                , div [ class "flex items-start gap-2" ]
                    [ Button.view [ Button.outline ] [] [ text "Default" ]
                    , Button.view [ Button.icon, Button.outline ] [ attribute "aria-label" "Submit" ] [ Icons.arrowUpRight [] ]
                    ]
                , div [ class "flex items-start gap-2" ]
                    [ Button.view [ Button.outline, Button.large ] [] [ text "Large" ]
                    , Button.view [ Button.iconLarge, Button.outline ] [ attribute "aria-label" "Submit" ] [ Icons.arrowUpRight [] ]
                    ]
                ]
            )
        , preview "Default" (Button.view [] [] [ text "Button" ])
        , preview "Outline" (Button.view [ Button.outline ] [] [ text "Outline" ])
        , preview "Secondary" (Button.view [ Button.secondary ] [] [ text "Secondary" ])
        , preview "Ghost" (Button.view [ Button.ghost ] [] [ text "Ghost" ])
        , preview "Destructive" (Button.view [ Button.destructive ] [] [ text "Destructive" ])
        , preview "Link" (Button.view [ Button.link ] [] [ text "Link" ])
        , preview "Icon" (Button.view [ Button.outline, Button.icon ] [] [ Icons.circleFadingArrowUp [] ])
        , preview "With Icon"
            (div [ class "flex gap-2" ]
                [ Button.view [ Button.outline ]
                    []
                    [ Icons.gitBranch [ attribute "data-icon" "inline-start" ], text " New Branch" ]
                , Button.view [ Button.outline ]
                    []
                    [ text "Fork", Icons.gitFork [ attribute "data-icon" "inline-end" ] ]
                ]
            )
        , preview "Rounded"
            (div [ class "flex gap-2" ]
                [ Button.view [] [ class "rounded-full!" ] [ text "Get Started" ]
                , Button.view [ Button.outline, Button.icon ] [ class "rounded-full!" ] [ Icons.arrowUp [] ]
                ]
            )
        , preview "Spinner"
            (div [ class "flex gap-2" ]
                [ Button.view [ Button.outline ]
                    [ disabled True ]
                    [ Spinner.view [ attribute "data-icon" "inline-start" ], text "Generating" ]
                , Button.view [ Button.secondary ]
                    [ disabled True ]
                    [ text "Downloading", Spinner.view [ attribute "data-icon" "inline-start" ] ]
                ]
            )
        , preview "As Link"
            (a (href "#" :: Button.attributes [ Button.secondary, Button.small ]) [ text "Login" ])
        , widePreview "RTL"
            (div [ class "flex flex-wrap items-center gap-2 md:flex-row", dir "rtl" ]
                [ Button.view [ Button.outline ] [] [ text "زر" ]
                , Button.view [ Button.destructive ] [] [ text "حذف" ]
                , Button.view [ Button.outline ]
                    []
                    [ text "إرسال "
                    , Icons.arrowRight [ Svg.Attributes.class "rtl:rotate-180", attribute "data-icon" "inline-end" ]
                    ]
                , Button.view [ Button.outline, Button.icon ] [ attribute "aria-label" "Add" ] [ Icons.plus [] ]
                , Button.view [ Button.secondary ]
                    [ disabled True ]
                    [ Spinner.view [ attribute "data-icon" "inline-start" ], text " جاري التحميل" ]
                ]
            )
        ]


preview : String -> Html Msg -> Html Msg
preview =
    previewIn "flex flex-col gap-2"


widePreview : String -> Html Msg -> Html Msg
widePreview =
    previewIn "flex flex-col gap-2 sm:col-span-2"


previewIn : String -> String -> Html Msg -> Html Msg
previewIn layout title content =
    div [ class layout ]
        [ p [ class "text-sm font-medium text-muted-foreground" ] [ text title ]
        , div [ class "flex min-h-32 items-center justify-center rounded-lg border p-6" ] [ content ]
        ]


badges : Html Msg
badges =
    div [ class "flex flex-wrap items-center gap-2" ]
        [ Badge.view [] [] [ text "Badge" ]
        , Badge.view [ Badge.secondary ] [] [ text "Secondary" ]
        , Badge.view [ Badge.destructive ] [] [ text "Destructive" ]
        , Badge.view [ Badge.outline ] [] [ text "Outline" ]
        , Badge.view [ Badge.secondary ] [] [ Icon.check [], text "Verified" ]
        , a (href "#" :: Badge.attributes [ Badge.outline ]) [ text "Link" ]
        ]


card : Html Msg
card =
    Card.view [ class "w-full max-w-sm" ]
        [ Card.header []
            [ Card.title [] [ text "Login to your account" ]
            , Card.description [] [ text "Enter your email below to login to your account" ]
            , Card.action [] [ Button.view [ Button.link ] [] [ text "Sign Up" ] ]
            ]
        , Card.content []
            [ div [ class "flex flex-col gap-6" ]
                [ div [ class "grid gap-2" ]
                    [ Label.view [ for "email" ] [ text "Email" ]
                    , Input.view [ id "email", Html.Attributes.type_ "email", placeholder "m@example.com" ]
                    ]
                , div [ class "grid gap-2" ]
                    [ Label.view [ for "password" ] [ text "Password" ]
                    , Input.view [ id "password", Html.Attributes.type_ "password" ]
                    ]
                ]
            ]
        , Card.footer [ class "flex-col gap-2" ]
            [ Button.view [] [ class "w-full" ] [ text "Login" ]
            , Button.view [ Button.outline ] [ class "w-full" ] [ text "Login with Google" ]
            ]
        ]


alerts : Html Msg
alerts =
    div [ class "grid gap-4" ]
        [ Alert.view []
            []
            [ Icon.check []
            , Alert.title [] [ text "Success! Your changes have been saved" ]
            , Alert.description [] [ text "This is an alert with icon, title and description." ]
            ]
        , Alert.view [ Alert.destructive ]
            []
            [ Alert.title [] [ text "Unable to process your payment." ]
            , Alert.description [] [ p [] [ text "Please verify your billing information and try again." ] ]
            ]
        ]


formControls : Model -> Html Msg
formControls model =
    div [ class "grid gap-8 sm:grid-cols-2" ]
        [ div [ class "flex flex-col gap-6" ]
            [ div [ class "grid gap-2" ]
                [ Label.view [ for "name" ] [ text "Name" ]
                , Input.view [ id "name", placeholder "Ada Lovelace" ]
                ]
            , div [ class "grid gap-2" ]
                [ Label.view [ for "invalid" ] [ text "Invalid" ]
                , Input.view [ id "invalid", value "not-an-email", attribute "aria-invalid" "true" ]
                ]
            , Input.view [ disabled True, placeholder "Disabled" ]
            , Textarea.view [ placeholder "Type your message here." ]
            ]
        , div [ class "flex flex-col gap-6" ]
            [ Label.view []
                [ Checkbox.view [ checked model.terms, onCheck TermsToggled ]
                , text "Accept terms and conditions"
                ]
            , Label.view [] [ Checkbox.view [ disabled True ], text "Disabled" ]
            , Label.view []
                [ Switch.view [] [ checked model.airplaneMode, onCheck AirplaneModeToggled ]
                , text "Airplane mode"
                ]
            , Label.view [] [ Switch.view [ Switch.small ] [ checked True ], text "Small switch" ]
            , RadioGroup.view []
                [ radio model Default "Default"
                , radio model Comfortable "Comfortable"
                , radio model Compact "Compact"
                ]
            ]
        ]


radio : Model -> Density -> String -> Html Msg
radio model density label =
    Label.view [ class "gap-3 font-normal" ]
        [ RadioGroup.item [ name "density", checked (model.density == density), onClick (DensityChosen density) ]
        , text label
        ]


nativeSelects : Html Msg
nativeSelects =
    div [ class "flex flex-wrap items-center gap-4" ]
        [ NativeSelect.view []
            []
            [ NativeSelect.option [ value "" ] [ text "Select status" ]
            , NativeSelect.option [ value "todo" ] [ text "Todo" ]
            , NativeSelect.option [ value "in-progress" ] [ text "In Progress" ]
            , NativeSelect.option [ value "done" ] [ text "Done" ]
            ]
        , NativeSelect.view [ NativeSelect.small ]
            []
            [ NativeSelect.optionGroup [ attribute "label" "Engineering" ]
                [ NativeSelect.option [] [ text "Frontend" ]
                , NativeSelect.option [] [ text "Backend" ]
                ]
            ]
        ]


avatars : Html Msg
avatars =
    div [ class "flex flex-wrap items-center gap-6" ]
        [ Avatar.view []
            []
            [ Avatar.fallback [] [ text "CN" ]
            , Avatar.image [ src "https://github.com/shadcn.png", alt "@shadcn" ]
            ]
        , Avatar.view [ Avatar.large ]
            []
            [ Avatar.fallback [] [ text "ER" ]
            , Avatar.badge [ class "bg-green-600! dark:bg-green-800!" ] []
            ]
        , Avatar.view [ Avatar.small ] [] [ Avatar.fallback [] [ text "SM" ] ]
        , Avatar.group []
            [ Avatar.view [] [] [ Avatar.fallback [] [ text "AB" ] ]
            , Avatar.view [] [] [ Avatar.fallback [] [ text "CD" ] ]
            , Avatar.view [] [] [ Avatar.fallback [] [ text "EF" ] ]
            , Avatar.groupCount [] [ text "+3" ]
            ]
        ]


breadcrumb : Html Msg
breadcrumb =
    Breadcrumb.view []
        [ Breadcrumb.list []
            [ Breadcrumb.item [] [ Breadcrumb.link [ href "#" ] [ text "Home" ] ]
            , Breadcrumb.separator [] []
            , Breadcrumb.item [] [ Breadcrumb.ellipsis [] ]
            , Breadcrumb.separator [] []
            , Breadcrumb.item [] [ Breadcrumb.link [ href "#" ] [ text "Components" ] ]
            , Breadcrumb.separator [] []
            , Breadcrumb.item [] [ Breadcrumb.page [] [ text "Breadcrumb" ] ]
            ]
        ]


table : Html Msg
table =
    let
        invoices =
            [ ( "INV001", "Paid", "$250.00" )
            , ( "INV002", "Pending", "$150.00" )
            , ( "INV003", "Unpaid", "$350.00" )
            ]
    in
    Table.view []
        [ Table.caption [] [ text "A list of your recent invoices." ]
        , Table.header []
            [ Table.row []
                [ Table.head [ class "w-[100px]" ] [ text "Invoice" ]
                , Table.head [] [ text "Status" ]
                , Table.head [ class "text-right" ] [ text "Amount" ]
                ]
            ]
        , Table.body []
            (List.map
                (\( invoice, status, amount ) ->
                    Table.row []
                        [ Table.cell [ class "font-medium" ] [ text invoice ]
                        , Table.cell [] [ text status ]
                        , Table.cell [ class "text-right" ] [ text amount ]
                        ]
                )
                invoices
            )
        , Table.footer []
            [ Table.row []
                [ Table.cell [ attribute "colspan" "2" ] [ text "Total" ]
                , Table.cell [ class "text-right" ] [ text "$750.00" ]
                ]
            ]
        ]


loading : Html Msg
loading =
    div [ class "flex flex-col gap-6" ]
        [ Progress.view 60 [ class "w-[60%]" ]
        , div [ class "flex items-center gap-4" ]
            [ Skeleton.view [ class "size-12 rounded-full!" ]
            , div [ class "space-y-2" ]
                [ Skeleton.view [ class "h-4 w-[250px]" ]
                , Skeleton.view [ class "h-4 w-[200px]" ]
                ]
            ]
        , div [ class "flex items-center gap-4" ]
            [ Spinner.view []
            , Spinner.view [ Svg.Attributes.class "size-6" ]
            , Spinner.view [ Svg.Attributes.class "size-8" ]
            ]
        ]


kbd : Html Msg
kbd =
    div [ class "flex flex-col items-center gap-4" ]
        [ Kbd.group []
            [ Kbd.view [] [ text "⌘" ]
            , Kbd.view [] [ text "⇧" ]
            , Kbd.view [] [ text "⌥" ]
            , Kbd.view [] [ text "⌃" ]
            ]
        , Kbd.group []
            [ Kbd.view [] [ text "Ctrl" ]
            , span [] [ text "+" ]
            , Kbd.view [] [ text "B" ]
            ]
        ]


separator : Html Msg
separator =
    div []
        [ div [ class "space-y-1" ]
            [ p [ class "text-sm leading-none font-medium" ] [ text "Radix Primitives" ]
            , p [ class "text-sm text-muted-foreground" ] [ text "An open-source UI component library." ]
            ]
        , Separator.view [] [ class "my-4" ]
        , div [ class "flex h-5 items-center space-x-4 text-sm" ]
            [ div [] [ text "Blog" ]
            , Separator.view [ Separator.vertical ] []
            , div [] [ text "Docs" ]
            , Separator.view [ Separator.vertical ] []
            , div [] [ text "Source" ]
            ]
        ]


aspectRatio : Html Msg
aspectRatio =
    AspectRatio.view (16 / 9)
        [ class "w-full max-w-md rounded-lg bg-muted" ]
        [ div [ class "flex size-full items-center justify-center text-muted-foreground" ] [ text "16 / 9" ] ]


empty : Html Msg
empty =
    Empty.view [ class "border" ]
        [ Empty.header []
            [ Empty.media [ Empty.icon ] [] [ Icon.ellipsis [] ]
            , Empty.title [] [ text "No projects yet" ]
            , Empty.description [] [ text "You haven't created any projects yet. Get started by creating your first project." ]
            ]
        , Empty.content []
            [ div [ class "flex gap-2" ]
                [ Button.view [] [] [ text "Create project" ]
                , Button.view [ Button.outline ] [] [ text "Import project" ]
                ]
            ]
        ]
