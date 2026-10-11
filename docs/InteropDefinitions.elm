module InteropDefinitions exposing (Flags, FromElm(..), Theme(..), ToElm(..), interop, themeToString)

import Json.Encode
import TsJson.Decode as TsDecode exposing (Decoder)
import TsJson.Encode as TsEncode exposing (Encoder)


interop :
    { toElm : Decoder ToElm
    , fromElm : Encoder FromElm
    , flags : Decoder Flags
    }
interop =
    { toElm = toElm
    , fromElm = fromElm
    , flags = flags
    }


type Theme
    = Light
    | Dark
    | System


type FromElm
    = SaveTheme Theme
    | CopyToClipboard String


type ToElm
    = SystemThemeChanged Bool


{-| `base` is the path the site is served from, "/elmcn/" on GitHub Pages. `theme` is what the user last chose, if
anything.
-}
type alias Flags =
    { base : String
    , theme : Maybe Theme
    , systemDark : Bool
    }


themeToString : Theme -> String
themeToString theme =
    case theme of
        Light ->
            "light"

        Dark ->
            "dark"

        System ->
            "system"


themeEncoder : Encoder Theme
themeEncoder =
    TsEncode.union
        (\light dark system theme ->
            case theme of
                Light ->
                    light

                Dark ->
                    dark

                System ->
                    system
        )
        |> TsEncode.variantLiteral (Json.Encode.string "light")
        |> TsEncode.variantLiteral (Json.Encode.string "dark")
        |> TsEncode.variantLiteral (Json.Encode.string "system")
        |> TsEncode.buildUnion


fromElm : Encoder FromElm
fromElm =
    TsEncode.union
        (\saveTheme copyToClipboard value ->
            case value of
                SaveTheme theme ->
                    saveTheme theme

                CopyToClipboard text ->
                    copyToClipboard text
        )
        |> TsEncode.variantTagged "saveTheme" themeEncoder
        |> TsEncode.variantTagged "copyToClipboard" TsEncode.string
        |> TsEncode.buildUnion


toElm : Decoder ToElm
toElm =
    TsDecode.discriminatedUnion "tag"
        [ ( "systemThemeChanged", TsDecode.map SystemThemeChanged (TsDecode.field "dark" TsDecode.bool) ) ]


themeDecoder : Decoder Theme
themeDecoder =
    TsDecode.stringUnion [ ( "light", Light ), ( "dark", Dark ), ( "system", System ) ]


flags : Decoder Flags
flags =
    TsDecode.map3 Flags
        (TsDecode.field "base" TsDecode.string)
        (TsDecode.field "theme" (TsDecode.nullable themeDecoder))
        (TsDecode.field "systemDark" TsDecode.bool)
