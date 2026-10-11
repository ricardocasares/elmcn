module Highlight exposing (elm)

import Html exposing (Html, span, text)
import Html.Attributes exposing (class)


type Token
    = Plain String
    | Keyword String
    | Comment String
    | Str String
    | Number String
    | Type String


elm : String -> List (Html msg)
elm source =
    List.map render (tokenize source "" [])


render : Token -> Html msg
render token =
    case token of
        Plain s ->
            text s

        Keyword s ->
            span [ class "text-violet-600 dark:text-violet-400" ] [ text s ]

        Comment s ->
            span [ class "text-muted-foreground italic" ] [ text s ]

        Str s ->
            span [ class "text-emerald-700 dark:text-emerald-400" ] [ text s ]

        Number s ->
            span [ class "text-amber-700 dark:text-amber-400" ] [ text s ]

        Type s ->
            span [ class "text-sky-700 dark:text-sky-400" ] [ text s ]


keywords : List String
keywords =
    [ "let", "in", "if", "then", "else", "case", "of", "type", "alias", "module", "import", "exposing", "as", "where", "port" ]


tokenize : String -> String -> List Token -> List Token
tokenize rest plain acc =
    case String.uncons rest of
        Nothing ->
            List.reverse (flush plain acc)

        Just ( c, tail ) ->
            if String.startsWith "--" rest then
                let
                    ( comment, after ) =
                        splitWhile (\ch -> ch /= '\n') rest
                in
                tokenize after "" (Comment comment :: flush plain acc)

            else if c == '"' then
                let
                    ( string, after ) =
                        takeString tail "\""
                in
                tokenize after "" (Str string :: flush plain acc)

            else if Char.isDigit c then
                let
                    ( number, after ) =
                        splitWhile (\ch -> Char.isDigit ch || ch == '.') rest
                in
                tokenize after "" (Number number :: flush plain acc)

            else if Char.isAlpha c || c == '_' then
                let
                    ( word, after ) =
                        splitWhile (\ch -> Char.isAlphaNum ch || ch == '_') rest
                in
                if List.member word keywords then
                    tokenize after "" (Keyword word :: flush plain acc)

                else if Char.isUpper c then
                    tokenize after "" (Type word :: flush plain acc)

                else
                    tokenize after (plain ++ word) acc

            else
                tokenize tail (plain ++ String.fromChar c) acc


flush : String -> List Token -> List Token
flush plain acc =
    if plain == "" then
        acc

    else
        Plain plain :: acc


splitWhile : (Char -> Bool) -> String -> ( String, String )
splitWhile pred rest =
    splitWhileHelp pred rest ""


splitWhileHelp : (Char -> Bool) -> String -> String -> ( String, String )
splitWhileHelp pred rest taken =
    case String.uncons rest of
        Just ( c, tail ) ->
            if pred c then
                splitWhileHelp pred tail (taken ++ String.fromChar c)

            else
                ( taken, rest )

        Nothing ->
            ( taken, "" )


{-| Reads up to and including the closing quote, skipping escaped characters.
-}
takeString : String -> String -> ( String, String )
takeString rest taken =
    case String.uncons rest of
        Nothing ->
            ( taken, "" )

        Just ( '"', tail ) ->
            ( taken ++ "\"", tail )

        Just ( '\\', tail ) ->
            case String.uncons tail of
                Just ( escaped, after ) ->
                    takeString after (taken ++ "\\" ++ String.fromChar escaped)

                Nothing ->
                    ( taken ++ "\\", "" )

        Just ( c, tail ) ->
            takeString tail (taken ++ String.fromChar c)
