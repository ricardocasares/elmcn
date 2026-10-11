module Examples.Avatar exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (alt, class, dir, src)
import Phosphor exposing (IconWeight(..))
import UI.Avatar as Avatar


demo : Html msg
demo =
    div [ class "flex flex-row flex-wrap items-center gap-6 md:gap-12" ]
        [ Avatar.new
            |> Avatar.fallback [ text "CN" ]
            |> Avatar.img [ src "https://github.com/shadcn.png", alt "@shadcn", class "grayscale" ]
            |> Avatar.toHtml []
        , Avatar.new
            |> Avatar.fallback [ text "ER" ]
            |> Avatar.img [ src "https://github.com/evilrabbit.png", alt "@evilrabbit" ]
            |> Avatar.badge [ class "bg-green-600! dark:bg-green-800!" ] []
            |> Avatar.toHtml []
        , Avatar.group
            (Avatar.new
                |> Avatar.fallback [ text "CN" ]
                |> Avatar.img [ src "https://github.com/shadcn.png", alt "@shadcn" ]
            )
            [ Avatar.new |> Avatar.fallback [ text "LR" ] |> Avatar.img [ src "https://github.com/maxleiter.png", alt "@maxleiter" ]
            , Avatar.new |> Avatar.fallback [ text "ER" ] |> Avatar.img [ src "https://github.com/evilrabbit.png", alt "@evilrabbit" ]
            ]
            |> Avatar.groupCount [ text "+3" ]
            |> Avatar.toHtml [ class "grayscale" ]
        ]


{-| A basic avatar with an image and a fallback.
-}
basic : Html msg
basic =
    Avatar.new
        |> Avatar.fallback [ text "CN" ]
        |> Avatar.img [ src "https://github.com/shadcn.png", alt "@shadcn", class "grayscale" ]
        |> Avatar.toHtml []


{-| `badge` adds a status dot at the bottom right. Its attributes can override the color.
-}
badge : Html msg
badge =
    Avatar.new
        |> Avatar.fallback [ text "CN" ]
        |> Avatar.img [ src "https://github.com/shadcn.png", alt "@shadcn" ]
        |> Avatar.badge [ class "bg-green-600! dark:bg-green-800!" ] []
        |> Avatar.toHtml []


{-| A badge can hold an icon.
-}
badgeWithIcon : Html msg
badgeWithIcon =
    Avatar.new
        |> Avatar.fallback [ text "PP" ]
        |> Avatar.img [ src "https://github.com/pranathip.png", alt "@pranathip" ]
        |> Avatar.badge [] [ Phosphor.plus Regular |> Phosphor.toHtml [] ]
        |> Avatar.toHtml [ class "grayscale" ]


{-| `group` stacks avatars so they overlap.
-}
group : Html msg
group =
    Avatar.group
        (Avatar.new
            |> Avatar.fallback [ text "CN" ]
            |> Avatar.img [ src "https://github.com/shadcn.png", alt "@shadcn" ]
        )
        [ Avatar.new
            |> Avatar.fallback [ text "LR" ]
            |> Avatar.img [ src "https://github.com/maxleiter.png", alt "@maxleiter" ]
        , Avatar.new
            |> Avatar.fallback [ text "ER" ]
            |> Avatar.img [ src "https://github.com/evilrabbit.png", alt "@evilrabbit" ]
        ]
        |> Avatar.toHtml [ class "grayscale" ]


{-| `groupCount` shows how many more there are.
-}
groupCount : Html msg
groupCount =
    Avatar.group
        (Avatar.new
            |> Avatar.fallback [ text "CN" ]
            |> Avatar.img [ src "https://github.com/shadcn.png", alt "@shadcn" ]
        )
        [ Avatar.new
            |> Avatar.fallback [ text "LR" ]
            |> Avatar.img [ src "https://github.com/maxleiter.png", alt "@maxleiter" ]
        , Avatar.new
            |> Avatar.fallback [ text "ER" ]
            |> Avatar.img [ src "https://github.com/evilrabbit.png", alt "@evilrabbit" ]
        ]
        |> Avatar.groupCount [ text "+3" ]
        |> Avatar.toHtml [ class "grayscale" ]


{-| The count can hold an icon.
-}
groupWithIcon : Html msg
groupWithIcon =
    Avatar.group
        (Avatar.new
            |> Avatar.fallback [ text "CN" ]
            |> Avatar.img [ src "https://github.com/shadcn.png", alt "@shadcn" ]
        )
        [ Avatar.new
            |> Avatar.fallback [ text "LR" ]
            |> Avatar.img [ src "https://github.com/maxleiter.png", alt "@maxleiter" ]
        , Avatar.new
            |> Avatar.fallback [ text "ER" ]
            |> Avatar.img [ src "https://github.com/evilrabbit.png", alt "@evilrabbit" ]
        ]
        |> Avatar.groupCount [ Phosphor.plus Regular |> Phosphor.toHtml [] ]
        |> Avatar.toHtml [ class "grayscale" ]


{-| `small` and `large` change the size. The default is medium.
-}
sizes : Html msg
sizes =
    div [ class "flex flex-wrap items-center gap-2 grayscale" ]
        [ Avatar.new
            |> Avatar.fallback [ text "CN" ]
            |> Avatar.img [ src "https://github.com/shadcn.png", alt "@shadcn" ]
            |> Avatar.small
            |> Avatar.toHtml []
        , Avatar.new
            |> Avatar.fallback [ text "CN" ]
            |> Avatar.img [ src "https://github.com/shadcn.png", alt "@shadcn" ]
            |> Avatar.toHtml []
        , Avatar.new
            |> Avatar.fallback [ text "CN" ]
            |> Avatar.img [ src "https://github.com/shadcn.png", alt "@shadcn" ]
            |> Avatar.large
            |> Avatar.toHtml []
        ]


rtl : Html msg
rtl =
    div [ class "flex flex-row flex-wrap items-center gap-6 md:gap-12", dir "rtl" ]
        [ Avatar.new
            |> Avatar.fallback [ text "CN" ]
            |> Avatar.img [ src "https://github.com/shadcn.png", alt "@shadcn", class "grayscale" ]
            |> Avatar.toHtml []
        , Avatar.new
            |> Avatar.fallback [ text "ER" ]
            |> Avatar.img [ src "https://github.com/evilrabbit.png", alt "@evilrabbit" ]
            |> Avatar.badge [ class "bg-green-600! dark:bg-green-800!" ] []
            |> Avatar.toHtml []
        , Avatar.group
            (Avatar.new
                |> Avatar.fallback [ text "CN" ]
                |> Avatar.img [ src "https://github.com/shadcn.png", alt "@shadcn" ]
            )
            [ Avatar.new
                |> Avatar.fallback [ text "LR" ]
                |> Avatar.img [ src "https://github.com/maxleiter.png", alt "@maxleiter" ]
            , Avatar.new
                |> Avatar.fallback [ text "ER" ]
                |> Avatar.img [ src "https://github.com/evilrabbit.png", alt "@evilrabbit" ]
            ]
            |> Avatar.groupCount [ text "+٣" ]
            |> Avatar.toHtml [ class "grayscale" ]
        ]
