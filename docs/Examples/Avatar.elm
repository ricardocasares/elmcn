module Examples.Avatar exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (alt, class, src)
import UI.Avatar as Avatar


demo : Html msg
demo =
    Avatar.view []
        []
        [ Avatar.fallback [] [ text "CN" ]
        , Avatar.image [ src "https://github.com/shadcn.png", alt "@shadcn" ]
        ]


withBadge : Html msg
withBadge =
    Avatar.view [ Avatar.large ]
        []
        [ Avatar.fallback [] [ text "ER" ]
        , Avatar.badge [ class "bg-green-600! dark:bg-green-800!" ] []
        ]


size : Html msg
size =
    div [ class "flex items-center gap-4" ]
        [ Avatar.view [ Avatar.small ] [] [ Avatar.fallback [] [ text "SM" ] ]
        , Avatar.view [] [] [ Avatar.fallback [] [ text "MD" ] ]
        , Avatar.view [ Avatar.large ] [] [ Avatar.fallback [] [ text "LG" ] ]
        ]


group : Html msg
group =
    Avatar.group []
        [ Avatar.view [] [] [ Avatar.fallback [] [ text "AB" ] ]
        , Avatar.view [] [] [ Avatar.fallback [] [ text "CD" ] ]
        , Avatar.view [] [] [ Avatar.fallback [] [ text "EF" ] ]
        , Avatar.groupCount [] [ text "+3" ]
        ]
