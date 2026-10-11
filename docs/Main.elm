module Main exposing (main)

import Browser
import Browser.Dom
import Browser.Navigation as Nav
import Component exposing (Component, Entry, Example)
import Generated
import Highlight
import Html exposing (Html, a, aside, code, div, h1, h2, h3, header, li, main_, nav, p, pre, span, text, ul)
import Html.Attributes exposing (attribute, class, href, id, selected, target, type_, value)
import Html.Events exposing (onClick, onInput)
import Set exposing (Set)
import Task
import UI.Button as Button
import UI.Card as Card
import UI.NativeSelect as NativeSelect
import UI.Table as Table
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , route : Route
    , dark : Bool
    , codeShown : Set String
    }


type Route
    = Home
    | ComponentPage Component
    | NotFound


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key, route = routeFromUrl url, dark = False, codeShown = Set.empty }
    , Cmd.none
    )


routeFromUrl : Url -> Route
routeFromUrl url =
    case url.fragment |> Maybe.withDefault "" |> String.dropLeft 1 of
        "" ->
            Home

        slug ->
            Generated.components
                |> List.filter (\c -> c.slug == slug)
                |> List.head
                |> Maybe.map ComponentPage
                |> Maybe.withDefault NotFound



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | PageSelected String
    | ThemeToggled
    | CodeToggled String Bool
    | Scrolled


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked (Browser.Internal url) ->
            ( model, Nav.pushUrl model.key (Url.toString url) )

        LinkClicked (Browser.External url) ->
            ( model, Nav.load url )

        UrlChanged url ->
            ( { model | route = routeFromUrl url }
            , Task.perform (\_ -> Scrolled) (Browser.Dom.setViewport 0 0)
            )

        PageSelected slug ->
            ( model, Nav.pushUrl model.key ("#/" ++ slug) )

        ThemeToggled ->
            ( { model | dark = not model.dark }, Cmd.none )

        CodeToggled key show ->
            ( { model
                | codeShown =
                    if show then
                        Set.insert key model.codeShown

                    else
                        Set.remove key model.codeShown
              }
            , Cmd.none
            )

        Scrolled ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title =
        case model.route of
            ComponentPage component ->
                component.title ++ " - elmcn"

            _ ->
                "elmcn"
    , body =
        [ div
            [ class
                (if model.dark then
                    "dark"

                 else
                    ""
                )
            ]
            [ div [ class "min-h-screen bg-background text-foreground" ]
                [ viewHeader model
                , div [ class "mx-auto flex max-w-6xl gap-10 px-6" ]
                    [ viewSidebar model.route
                    , main_ [ class "min-w-0 max-w-3xl flex-1 py-10" ]
                        [ viewMobileNav model.route
                        , case model.route of
                            Home ->
                                viewHome

                            ComponentPage component ->
                                viewComponent model component

                            NotFound ->
                                viewNotFound
                        ]
                    ]
                ]
            ]
        ]
    }


viewHeader : Model -> Html Msg
viewHeader model =
    header [ class "sticky top-0 z-10 border-b bg-background/95 backdrop-blur" ]
        [ div [ class "mx-auto flex h-14 max-w-6xl items-center justify-between px-6" ]
            [ a [ href "#/", class "text-lg font-semibold tracking-tight" ] [ text "elmcn" ]
            , div [ class "flex items-center gap-2" ]
                [ a
                    (href "https://github.com/ricardocasares/elmcn"
                        :: target "_blank"
                        :: Button.toAttributes (Button.view "" |> Button.ghost |> Button.small)
                    )
                    [ text "GitHub" ]
                , Button.view
                    (if model.dark then
                        "Light mode"

                     else
                        "Dark mode"
                    )
                    |> Button.outline
                    |> Button.small
                    |> Button.toHtml [ onClick ThemeToggled, id "theme-toggle" ]
                ]
            ]
        ]


viewSidebar : Route -> Html Msg
viewSidebar route =
    aside [ class "sticky top-14 hidden h-[calc(100vh-3.5rem)] w-52 shrink-0 overflow-y-auto py-10 md:block" ]
        [ nav [ class "flex flex-col gap-6" ]
            [ div [ class "flex flex-col gap-1" ]
                [ sidebarHeading "Getting started"
                , sidebarLink (route == Home) "#/" "Introduction"
                ]
            , div [ class "flex flex-col gap-1" ]
                (sidebarHeading "Components"
                    :: List.map
                        (\c ->
                            sidebarLink (isCurrent route c) ("#/" ++ c.slug) c.title
                        )
                        Generated.components
                )
            ]
        ]


isCurrent : Route -> Component -> Bool
isCurrent route component =
    case route of
        ComponentPage current ->
            current.slug == component.slug

        _ ->
            False


sidebarHeading : String -> Html msg
sidebarHeading title =
    p [ class "px-2 pb-1 text-sm font-semibold" ] [ text title ]


sidebarLink : Bool -> String -> String -> Html msg
sidebarLink active url title =
    a
        [ href url
        , class "rounded-md px-2 py-1.5 text-sm text-muted-foreground hover:bg-accent hover:text-accent-foreground"
        , class
            (if active then
                "bg-accent font-medium text-accent-foreground"

             else
                ""
            )
        ]
        [ text title ]


viewMobileNav : Route -> Html Msg
viewMobileNav route =
    let
        current =
            case route of
                ComponentPage component ->
                    component.slug

                _ ->
                    ""
    in
    div [ class "mb-8 md:hidden" ]
        [ NativeSelect.view []
            [ onInput PageSelected, value current, class "w-full" ]
            (NativeSelect.option [ value "", selected (current == "") ] [ text "Introduction" ]
                :: List.map
                    (\c -> NativeSelect.option [ value c.slug, selected (c.slug == current) ] [ text c.title ])
                    Generated.components
            )
        ]



-- PAGES


viewHome : Html Msg
viewHome =
    div [ class "flex flex-col gap-10" ]
        [ pageHeader "Introduction" "shadcn/ui components for Elm, installed with the shadcn CLI."
        , prose
            [ text "Like shadcn/ui, this is not a package. The CLI copies the component source into your project, and from then on the code is yours to read and change."
            ]
        , section "Requirements"
            [ ul [ class "ml-6 list-disc space-y-1 text-sm" ]
                [ li [] [ text "Elm 0.19, with src as a source directory" ]
                , li [] [ text "Tailwind CSS v4" ]
                , li [] [ text "Node.js, to run the shadcn CLI. No components.json is needed." ]
                ]
            ]
        , section "Installation"
            [ prose [ text "Add the theme. It writes src/elmcn.css:" ]
            , shellBlock "npx shadcn@latest add ricardocasares/elmcn/theme"
            , prose [ text "Then import it after Tailwind in your main stylesheet:" ]
            , shellBlock "@import \"tailwindcss\";\n@import \"./elmcn.css\"; /* path relative to this file */"
            , prose [ text "Add components. Each one is written to src/UI/<Name>.elm, along with any components it uses:" ]
            , shellBlock "npx shadcn@latest add ricardocasares/elmcn/button ricardocasares/elmcn/card"
            ]
        , section "Conventions"
            [ prose [ text "Every component takes a List (Attribute msg) like elm/html, and attributes you pass come after the component's own, so they override them. Components with variants or sizes take a list of options first. An empty list gives the defaults, and the last option of a kind wins." ]
            , elmBlock "Button.view \"Default\" |> Button.toHtml []\nButton.view \"Delete\" |> Button.destructive |> Button.large |> Button.toHtml []"
            ]
        , section "Components"
            [ div [ class "grid gap-4 sm:grid-cols-2" ]
                (List.map componentCard Generated.components)
            ]
        ]


componentCard : Component -> Html msg
componentCard component =
    a [ href ("#/" ++ component.slug), class "block" ]
        [ Card.view []
            [ class "h-full transition-colors hover:bg-muted/50" ]
            [ Card.header []
                [ Card.title [] [ text component.title ]
                , Card.description [] [ text component.description ]
                ]
            ]
        ]


viewNotFound : Html msg
viewNotFound =
    div [ class "flex flex-col gap-4" ]
        [ pageHeader "Not found" "There is no page here."
        , a (href "#/" :: Button.toAttributes (Button.view "" |> Button.outline)) [ text "Back to the introduction" ]
        ]


viewComponent : Model -> Component -> Html Msg
viewComponent model component =
    let
        ( hero, rest ) =
            List.partition (\e -> e.id == "demo") component.examples
    in
    div [ class "flex flex-col gap-10" ]
        [ pageHeader component.title component.description
        , div [ class "flex flex-col gap-10" ]
            (List.map (\e -> exampleBox model component e) hero)
        , section "Installation"
            ([ shellBlock ("npx shadcn@latest add ricardocasares/elmcn/" ++ component.slug)
             , prose [ text ("This writes " ++ component.file ++ ", along with any components it uses.") ]
             ]
                ++ (if List.isEmpty component.packages then
                        []

                    else
                        [ prose [ text "It also needs these Elm packages:" ]
                        , shellBlock (String.join "\n" (List.map (\p -> "elm install " ++ p) component.packages))
                        ]
                   )
            )
        , section "Usage"
            [ elmBlock ("import " ++ component.module_ ++ " as " ++ String.dropLeft 3 component.module_ ++ "\n\n" ++ component.usage) ]
        , if List.isEmpty rest then
            text ""

          else
            section "Examples"
                (List.map
                    (\e ->
                        div [ id (component.slug ++ "-" ++ e.id), class "flex flex-col gap-3" ]
                            [ h3 [ class "text-base font-semibold tracking-tight" ] [ text e.title ]
                            , if e.description == "" then
                                text ""

                              else
                                prose (inline e.description)
                            , exampleBox model component e
                            ]
                    )
                    rest
                )
        , section "API"
            [ viewApi component.api ]
        ]


pageHeader : String -> String -> Html msg
pageHeader title description =
    div [ class "flex flex-col gap-2" ]
        [ h1 [ class "text-4xl font-bold tracking-tight" ] [ text title ]
        , p [ class "text-lg text-muted-foreground" ] [ text description ]
        ]


section : String -> List (Html msg) -> Html msg
section title children =
    Html.section [ class "flex flex-col gap-4" ]
        (h2 [ class "border-b pb-2 text-2xl font-semibold tracking-tight" ] [ text title ]
            :: children
        )


prose : List (Html msg) -> Html msg
prose children =
    p [ class "text-sm leading-relaxed text-muted-foreground" ] children


{-| Renders `backticked` spans as inline code.
-}
inline : String -> List (Html msg)
inline source =
    source
        |> String.split "`"
        |> List.indexedMap
            (\i part ->
                if modBy 2 i == 1 then
                    code [ class "rounded bg-muted px-1.5 py-0.5 font-mono text-xs text-foreground" ] [ text part ]

                else
                    text part
            )


viewApi : List Entry -> Html msg
viewApi entries =
    Table.view []
        [ Table.header []
            [ Table.row []
                [ Table.head [] [ text "Name" ]
                , Table.head [] [ text "Type" ]
                , Table.head [] [ text "Description" ]
                ]
            ]
        , Table.body []
            (List.map
                (\entry ->
                    Table.row []
                        [ Table.cell [ class "align-top font-mono text-xs font-medium" ] [ text entry.name ]
                        , Table.cell [ class "font-mono text-xs whitespace-normal! text-muted-foreground" ] [ text entry.signature ]
                        , Table.cell [ class "align-top whitespace-normal!" ] (inline entry.description)
                        ]
                )
                entries
            )
        ]



-- EXAMPLES


{-| A live preview with a tab for the code that produced it.
-}
exampleBox : Model -> Component -> Example -> Html Msg
exampleBox model component example =
    let
        key =
            component.slug ++ "/" ++ example.id

        showCode =
            Set.member key model.codeShown

        tab label active show =
            Button.view label
                |> Button.small
                |> (if active then
                        Button.secondary

                    else
                        Button.ghost
                   )
                |> Button.toHtml [ onClick (CodeToggled key show) ]
    in
    div [ class "overflow-hidden rounded-xl border" ]
        [ div [ class "flex gap-1 border-b p-2" ]
            [ tab "Preview" (not showCode) False
            , tab "Code" showCode True
            ]
        , if showCode then
            codeBlock "rounded-none border-0" (Highlight.elm example.code)

          else
            div [ class "flex min-h-40 items-center justify-center overflow-x-auto p-6" ]
                [ Html.map never example.view ]
        ]



-- CODE


elmBlock : String -> Html msg
elmBlock source =
    codeBlock "" (Highlight.elm source)


shellBlock : String -> Html msg
shellBlock source =
    codeBlock "" [ text source ]


{-| The copy button is wired up by a click listener in index.html, which reads the text of the `pre`.
-}
codeBlock : String -> List (Html msg) -> Html msg
codeBlock extra children =
    div [ class "group relative rounded-lg border bg-muted/40", class extra ]
        [ Html.button
            [ type_ "button"
            , attribute "data-copy" ""
            , class "group absolute top-2 right-2 rounded-md border bg-background px-2 py-1 text-xs text-muted-foreground hover:text-foreground"
            ]
            [ span [ class "group-data-[copied]:hidden" ] [ text "Copy" ]
            , span [ class "hidden group-data-[copied]:inline" ] [ text "Copied" ]
            ]
        , pre [ class "overflow-x-auto p-4 pr-16 font-mono text-[13px] leading-relaxed" ]
            [ code [ class "[font-feature-settings:'ss01']" ] children ]
        ]
