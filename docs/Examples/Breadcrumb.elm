module Examples.Breadcrumb exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (href)
import UI.Breadcrumb as Breadcrumb


demo : Html msg
demo =
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
