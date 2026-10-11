module Examples.Breadcrumb exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (href)
import UI.Breadcrumb as Breadcrumb


demo : Html msg
demo =
    Breadcrumb.new
        |> Breadcrumb.link [ href "#" ] [ text "Home" ]
        |> Breadcrumb.ellipsis
        |> Breadcrumb.link [ href "#" ] [ text "Components" ]
        |> Breadcrumb.page [ text "Breadcrumb" ]
        |> Breadcrumb.toHtml []


{-| A slash instead of the chevron.
-}
customSeparator : Html msg
customSeparator =
    Breadcrumb.new
        |> Breadcrumb.separator (text "/")
        |> Breadcrumb.link [ href "#" ] [ text "Home" ]
        |> Breadcrumb.link [ href "#" ] [ text "Components" ]
        |> Breadcrumb.page [ text "Breadcrumb" ]
        |> Breadcrumb.toHtml []
