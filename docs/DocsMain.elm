module DocsMain exposing (Model, Msg, Route, main)

import Browser
import Browser.Dom
import Browser.Navigation as Nav
import Component exposing (Component, Entry, Example)
import DocsInteropDefinitions as Interop exposing (Theme)
import DocsInteropPorts
import Generated
import Highlight
import Html exposing (Html, a, aside, code, div, h1, h2, h3, header, li, main_, nav, p, pre, text, ul)
import Html.Attributes exposing (attribute, class, href, id, selected, target, title, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Phosphor exposing (IconWeight(..))
import Process
import Set exposing (Set)
import State exposing (State)
import Task
import UI.Button as Button
import UI.Card as Card
import UI.NativeSelect as NativeSelect
import UI.Table as Table
import Url exposing (Url)


main : Program Decode.Value Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.map GotInterop DocsInteropPorts.toElm
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , route : Route
    , theme : Theme
    , systemDark : Bool
    , copied : Maybe String
    , storageError : Maybe String
    , clipboardError : Maybe String
    , codeShown : Set String
    , state : State
    }


isDark : Model -> Bool
isDark model =
    case model.theme of
        Interop.Light ->
            False

        Interop.Dark ->
            True

        Interop.System ->
            model.systemDark


type Route
    = Home
    | ComponentPage Component
    | NotFound


init : Decode.Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        { theme, systemDark } =
            DocsInteropPorts.decodeFlags flags
                |> Result.withDefault { theme = Nothing, systemDark = False }
    in
    ( { key = key
      , route = routeFromUrl url
      , theme = Maybe.withDefault Interop.System theme
      , systemDark = systemDark
      , copied = Nothing
      , storageError = Nothing
      , clipboardError = Nothing
      , codeShown = Set.empty
      , state = State.init
      }
    , Cmd.none
    )


{-| The site is served from `<base href>`, so the route comes from the last path segment: a component slug, or the
introduction when the path ends in a slash. GitHub Pages serves 404.html, a copy of index.html, for paths it has no file
for, so deep links reach this too.
-}
routeFromUrl : Url -> Route
routeFromUrl url =
    let
        slug =
            url.path
                |> String.split "/"
                |> List.filter (not << String.isEmpty)
                |> List.reverse
                |> List.head
                |> Maybe.withDefault ""
    in
    case List.filter (\c -> c.slug == slug) Generated.components of
        component :: _ ->
            ComponentPage component

        [] ->
            if String.endsWith "/" url.path then
                Home

            else
                NotFound



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | PageSelected String
    | ThemeSelected Theme
    | GotInterop (Result Decode.Error Interop.ToElm)
    | CopyClicked String
    | CopiedReset
    | CodeToggled String Bool
    | StateChanged State.Msg
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
            ( model, Nav.pushUrl model.key slug )

        ThemeSelected theme ->
            ( { model | theme = theme }
            , DocsInteropPorts.fromElm
                (Interop.WriteToLocalStorage
                    { key = "theme"
                    , value = Interop.themeToString theme
                    }
                )
            )

        GotInterop (Ok (Interop.SystemThemeChanged systemDark)) ->
            ( { model | systemDark = systemDark }, Cmd.none )

        GotInterop (Ok (Interop.LocalStorageError error)) ->
            ( { model | storageError = Just (error.key ++ ": " ++ error.message) }, Cmd.none )

        GotInterop (Ok (Interop.ClipboardError message)) ->
            ( { model | copied = Nothing, clipboardError = Just message }, Cmd.none )

        GotInterop (Err _) ->
            ( model, Cmd.none )

        CopyClicked source ->
            ( { model | copied = Just source }
            , Cmd.batch
                [ DocsInteropPorts.fromElm (Interop.CopyToClipboard source)
                , Task.perform (\_ -> CopiedReset) (Process.sleep 1500)
                ]
            )

        CopiedReset ->
            ( { model | copied = Nothing }, Cmd.none )

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

        StateChanged stateMsg ->
            let
                ( state, cmd ) =
                    State.update stateMsg model.state
            in
            ( { model | state = state }, Cmd.map StateChanged cmd )

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
                (if isDark model then
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
                                viewHome model

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
            [ a [ href "./", class "text-lg font-semibold tracking-tight" ] [ text "elmcn" ]
            , div [ class "flex items-center gap-2" ]
                [ Button.new
                    |> Button.icon (Phosphor.githubLogo Regular |> Phosphor.toHtml [])
                    |> Button.label "GitHub"
                    |> Button.ghost
                    |> Button.small
                    |> Button.toAnchor [ href "https://github.com/ricardocasares/elmcn", target "_blank" ]
                , viewThemeSwitcher model.theme
                ]
            ]
        ]


viewThemeSwitcher : Theme -> Html Msg
viewThemeSwitcher current =
    let
        option theme label icon =
            Button.new
                |> Button.icon (icon Regular |> Phosphor.toHtml [])
                |> Button.label label
                |> Button.small
                |> (if theme == current then
                        Button.secondary

                    else
                        Button.ghost
                   )
                |> Button.toHtml
                    [ onClick (ThemeSelected theme)
                    , attribute "aria-pressed"
                        (if theme == current then
                            "true"

                         else
                            "false"
                        )
                    , title label
                    ]
    in
    div [ class "flex items-center gap-0.5 rounded-lg border p-0.5", attribute "role" "group", attribute "aria-label" "Theme" ]
        [ option Interop.Light "Light theme" Phosphor.sun
        , option Interop.Dark "Dark theme" Phosphor.moon
        , option Interop.System "System theme" Phosphor.desktop
        ]


viewSidebar : Route -> Html Msg
viewSidebar route =
    aside [ class "sticky top-14 hidden h-[calc(100vh-3.5rem)] w-52 shrink-0 overflow-y-auto py-10 md:block" ]
        [ nav [ class "flex flex-col gap-6" ]
            [ div [ class "flex flex-col gap-1" ]
                [ sidebarHeading "Getting started"
                , sidebarLink (route == Home) "./" "Introduction"
                ]
            , div [ class "flex flex-col gap-1" ]
                (sidebarHeading "Components"
                    :: List.map
                        (\c ->
                            sidebarLink (isCurrent route c) c.slug c.title
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
        [ NativeSelect.new
            |> NativeSelect.options
                (NativeSelect.option [ value "", selected (current == "") ] [ text "Introduction" ]
                    :: List.map
                        (\c -> NativeSelect.option [ value c.slug, selected (c.slug == current) ] [ text c.title ])
                        Generated.components
                )
            |> NativeSelect.toHtml [ onInput PageSelected, value current, class "w-full" ]
        ]



-- PAGES


viewHome : Model -> Html Msg
viewHome model =
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
            , shellBlock model.copied "npx shadcn@latest add ricardocasares/elmcn/theme"
            , prose [ text "Then import it after Tailwind in your main stylesheet:" ]
            , shellBlock model.copied "@import \"tailwindcss\";\n@import \"./elmcn.css\"; /* path relative to this file */"
            , prose [ text "Add components. Each one is written to src/UI/<Name>.elm, along with any components it uses:" ]
            , shellBlock model.copied "npx shadcn@latest add ricardocasares/elmcn/button ricardocasares/elmcn/card"
            ]
        , section "Starter"
            [ prose [ text "To start a new app, add the starter. It sets up Vite and Tailwind CSS v4 with the theme and the button, and writes index.html, vite.config.ts, elm.json and package.json to the project root, main.ts and app.css to src, a Main.elm that saves the theme to localStorage and copies text to the clipboard, the typed interop modules with their TypeScript types, and a favicon:" ]
            , shellBlock model.copied "npx shadcn@latest add ricardocasares/elmcn/starter --overwrite\nnpm install"
            , prose [ text "Then start Vite. It generates the TypeScript types first:" ]
            , shellBlock model.copied "npm run dev"
            , prose [ text "After changing InteropDefinitions.elm, regenerate the types:" ]
            , shellBlock model.copied "npx elm-ts-interop --output src/Main.elm.d.ts"
            ]
        , section "Conventions"
            [ prose [ text "Every component takes a List (Attribute msg) like elm/html, and attributes you pass come after the component's own, so they override them." ]
            , prose [ text "Components with options or content are builders. Start with new, add content, pipe through setters, and render at the end. The compiler won't let you render until the required content is there." ]
            , elmBlock model.copied "Button.new\n    |> Button.text \"Delete\"\n    |> Button.destructive\n    |> Button.large\n    |> Button.toHtml []\n\nButton.new\n    |> Button.icon trashIcon\n    |> Button.label \"Delete\"\n    |> Button.toHtml [ onClick Delete ]"
            ]
        , section "Components"
            [ div [ class "grid gap-4 sm:grid-cols-2" ]
                (List.map componentCard Generated.components)
            ]
        ]


componentCard : Component -> Html msg
componentCard component =
    a [ href component.slug, class "block" ]
        [ Card.new
            |> Card.title [ text component.title ]
            |> Card.description [ text component.description ]
            |> Card.toHtml [ class "h-full transition-colors hover:bg-muted/50" ]
        ]


viewNotFound : Html msg
viewNotFound =
    div [ class "flex flex-col gap-4" ]
        [ pageHeader "Not found" "There is no page here."
        , Button.new
            |> Button.text "Back to the introduction"
            |> Button.outline
            |> Button.toAnchor [ href "./" ]
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
            ([ shellBlock model.copied ("npx shadcn@latest add ricardocasares/elmcn/" ++ component.slug)
             , prose [ text ("This writes " ++ component.file ++ ", along with any components it uses.") ]
             , prose [ text "It needs these Elm packages:" ]
             , shellBlock model.copied (String.join "\n" (List.map (\p -> "elm install " ++ p) component.packages))
             ]
                ++ (if List.isEmpty component.scripts then
                        []

                    else
                        [ prose [ text "Then import its custom element once from your JavaScript entry point:" ]
                        , shellBlock model.copied (String.join "\n" (List.map (\s -> "import \"" ++ s ++ "\"; // path relative to this file") component.scripts))
                        ]
                   )
            )
        , section "Usage"
            [ elmBlock model.copied ("import " ++ component.module_ ++ " as " ++ String.dropLeft 3 component.module_ ++ "\n\n" ++ component.usage) ]
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
            Button.new
                |> Button.text label
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
            codeBlock model.copied "rounded-none border-0" example.code (Highlight.elm example.code)

          else
            div [ class "flex min-h-40 items-center justify-center overflow-x-auto p-6" ]
                [ Html.map StateChanged (example.view model.state) ]
        ]



-- CODE


elmBlock : Maybe String -> String -> Html Msg
elmBlock copied source =
    codeBlock copied "" source (Highlight.elm source)


shellBlock : Maybe String -> String -> Html Msg
shellBlock copied source =
    codeBlock copied "" source [ text source ]


{-| The copy button asks Elm to copy `source`, and shows "Copied" for a moment after.
-}
codeBlock : Maybe String -> String -> String -> List (Html Msg) -> Html Msg
codeBlock copied extra source children =
    div [ class "relative rounded-lg border bg-muted/40", class extra ]
        [ Html.button
            [ type_ "button"
            , onClick (CopyClicked source)
            , class "absolute top-2 right-2 rounded-md border bg-background px-2 py-1 text-xs text-muted-foreground hover:text-foreground"
            ]
            [ text
                (if copied == Just source then
                    "Copied"

                 else
                    "Copy"
                )
            ]
        , pre [ class "overflow-x-auto p-4 pr-16 font-mono text-[13px] leading-relaxed" ]
            [ code [ class "[font-feature-settings:'ss01']" ] children ]
        ]
