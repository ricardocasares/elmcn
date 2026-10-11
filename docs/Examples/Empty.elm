module Examples.Empty exposing (..)

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (alt, class, dir, href, placeholder, src)
import Phosphor exposing (IconWeight(..))
import UI.Avatar as Avatar
import UI.Button as Button
import UI.Empty as Empty
import UI.Input as Input


demo : Html msg
demo =
    Empty.new
        |> Empty.icon (Phosphor.folderOpen Regular |> Phosphor.toHtml [])
        |> Empty.title [ text "No projects yet" ]
        |> Empty.description [ text "You haven't created any projects yet. Get started by creating your first project." ]
        |> Empty.content
            [ div [ class "flex gap-2" ]
                [ Button.new
                    |> Button.text "Create project"
                    |> Button.toHtml []
                , Button.new
                    |> Button.text "Import project"
                    |> Button.outline
                    |> Button.toHtml []
                ]
            , Button.new
                |> Button.text "Learn more"
                |> Button.link
                |> Button.small
                |> Button.endIcon (Phosphor.arrowUpRight Regular |> Phosphor.toHtml [])
                |> Button.toAnchor [ href "#", class "text-muted-foreground" ]
            ]
        |> Empty.toHtml []


{-| Add `border` for an outline. The border is dashed by default.
-}
outline : Html msg
outline =
    Empty.new
        |> Empty.icon (Phosphor.cloud Regular |> Phosphor.toHtml [])
        |> Empty.title [ text "Cloud storage empty" ]
        |> Empty.description [ text "Upload files to your cloud storage to access them anywhere." ]
        |> Empty.content
            [ Button.new
                |> Button.text "Upload files"
                |> Button.outline
                |> Button.small
                |> Button.toHtml []
            ]
        |> Empty.toHtml [ class "border" ]


{-| A `bg-*` class gives the empty state a background.
-}
background : Html msg
background =
    Empty.new
        |> Empty.icon (Phosphor.bell Regular |> Phosphor.toHtml [])
        |> Empty.title [ text "No notifications" ]
        |> Empty.description [ text "You're all caught up. New notifications will appear here." ]
        |> Empty.content
            [ Button.new
                |> Button.text "Refresh"
                |> Button.outline
                |> Button.startIcon (Phosphor.arrowsClockwise Regular |> Phosphor.toHtml [])
                |> Button.toHtml []
            ]
        |> Empty.toHtml [ class "h-full bg-muted/30" ]


{-| `media` shows anything above the title as is, such as an avatar.
-}
avatar : Html msg
avatar =
    Empty.new
        |> Empty.media
            [ Avatar.new
                |> Avatar.fallback [ text "LR" ]
                |> Avatar.img [ src "https://github.com/shadcn.png", alt "@shadcn", class "grayscale" ]
                |> Avatar.toHtml [ class "size-12" ]
            ]
        |> Empty.title [ text "User offline" ]
        |> Empty.description [ text "This user is currently offline. You can leave a message to notify them or try again later." ]
        |> Empty.content
            [ Button.new
                |> Button.text "Leave message"
                |> Button.small
                |> Button.toHtml []
            ]
        |> Empty.toHtml []


avatarGroup : Html msg
avatarGroup =
    Empty.new
        |> Empty.media
            [ Avatar.group
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
            ]
        |> Empty.title [ text "No team members" ]
        |> Empty.description [ text "Invite your team to collaborate on this project." ]
        |> Empty.content
            [ Button.new
                |> Button.text "Invite members"
                |> Button.small
                |> Button.startIcon (Phosphor.plus Regular |> Phosphor.toHtml [])
                |> Button.toHtml []
            ]
        |> Empty.toHtml []


{-| The content can hold inputs and links as well as buttons.
-}
withInput : Html msg
withInput =
    Empty.new
        |> Empty.title [ text "404 - Not found" ]
        |> Empty.description [ text "The page you're looking for doesn't exist. Try searching for what you need below." ]
        |> Empty.content
            [ Input.view [ placeholder "Try searching for pages...", class "sm:w-3/4" ]
            , div [ class "text-sm text-muted-foreground" ]
                [ text "Need help? "
                , a [ href "#", class "underline underline-offset-4 hover:text-primary" ] [ text "Contact support" ]
                ]
            ]
        |> Empty.toHtml []


rtl : Html msg
rtl =
    Empty.new
        |> Empty.icon (Phosphor.folderOpen Regular |> Phosphor.toHtml [])
        |> Empty.title [ text "لا توجد مشاريع بعد" ]
        |> Empty.description [ text "لم تقم بإنشاء أي مشاريع بعد. ابدأ بإنشاء مشروعك الأول." ]
        |> Empty.content
            [ div [ class "flex gap-2" ]
                [ Button.new
                    |> Button.text "إنشاء مشروع"
                    |> Button.toHtml []
                , Button.new
                    |> Button.text "استيراد مشروع"
                    |> Button.outline
                    |> Button.toHtml []
                ]
            ]
        |> Empty.toHtml [ dir "rtl" ]
