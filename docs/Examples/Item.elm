module Examples.Item exposing (..)

import Html exposing (Html, div, img, span, text)
import Html.Attributes exposing (alt, attribute, class, dir, height, href, rel, src, target, width)
import Phosphor exposing (IconWeight(..))
import Svg.Attributes
import UI.Avatar as Avatar
import UI.Button as Button
import UI.DropdownMenu as DropdownMenu
import UI.Item as Item


demo : Html msg
demo =
    div [ class "flex w-full max-w-md flex-col gap-6" ]
        [ Item.new
            |> Item.title [ text "Basic Item" ]
            |> Item.description [ text "A simple item with title and description." ]
            |> Item.actions
                [ Button.new
                    |> Button.text "Action"
                    |> Button.outline
                    |> Button.small
                    |> Button.toHtml []
                ]
            |> Item.outline
            |> Item.toHtml []
        , Item.new
            |> Item.media [ Phosphor.sealCheck Regular |> Phosphor.toHtml [ Svg.Attributes.class "size-5" ] ]
            |> Item.title [ text "Your profile has been verified." ]
            |> Item.actions [ Phosphor.caretRight Regular |> Phosphor.toHtml [ Svg.Attributes.class "size-4" ] ]
            |> Item.outline
            |> Item.small
            |> Item.toAnchor [ href "#" ]
        ]


{-| `outline` adds a border and `muted` a muted background. Without either the item has neither.
-}
variant : Html msg
variant =
    div [ class "flex w-full max-w-md flex-col gap-6" ]
        [ Item.new
            |> Item.icon (Phosphor.tray Regular |> Phosphor.toHtml [])
            |> Item.title [ text "Default Variant" ]
            |> Item.description [ text "Transparent background with no border." ]
            |> Item.toHtml []
        , Item.new
            |> Item.icon (Phosphor.tray Regular |> Phosphor.toHtml [])
            |> Item.title [ text "Outline Variant" ]
            |> Item.description [ text "Outlined style with a visible border." ]
            |> Item.outline
            |> Item.toHtml []
        , Item.new
            |> Item.icon (Phosphor.tray Regular |> Phosphor.toHtml [])
            |> Item.title [ text "Muted Variant" ]
            |> Item.description [ text "Muted background for secondary content." ]
            |> Item.muted
            |> Item.toHtml []
        ]


{-| The size is `small` or `extraSmall`, or the default when neither is given.
-}
size : Html msg
size =
    div [ class "flex w-full max-w-md flex-col gap-6" ]
        [ Item.new
            |> Item.icon (Phosphor.tray Regular |> Phosphor.toHtml [])
            |> Item.title [ text "Default Size" ]
            |> Item.description [ text "The standard size for most use cases." ]
            |> Item.outline
            |> Item.toHtml []
        , Item.new
            |> Item.icon (Phosphor.tray Regular |> Phosphor.toHtml [])
            |> Item.title [ text "Small Size" ]
            |> Item.description [ text "A compact size for dense layouts." ]
            |> Item.outline
            |> Item.small
            |> Item.toHtml []
        , Item.new
            |> Item.icon (Phosphor.tray Regular |> Phosphor.toHtml [])
            |> Item.title [ text "Extra Small Size" ]
            |> Item.description [ text "The most compact size available." ]
            |> Item.outline
            |> Item.extraSmall
            |> Item.toHtml []
        ]


{-| `icon` shows an icon before the content.
-}
icon : Html msg
icon =
    div [ class "flex w-full max-w-lg flex-col gap-6" ]
        [ Item.new
            |> Item.icon (Phosphor.shieldWarning Regular |> Phosphor.toHtml [])
            |> Item.title [ text "Security Alert" ]
            |> Item.description [ text "New login detected from unknown device." ]
            |> Item.actions
                [ Button.new
                    |> Button.text "Review"
                    |> Button.outline
                    |> Button.small
                    |> Button.toHtml []
                ]
            |> Item.outline
            |> Item.toHtml []
        ]


{-| `media` shows anything before the content as is, such as an avatar or an avatar stack.
-}
avatar : Html msg
avatar =
    let
        member name url fallback classes =
            Avatar.new
                |> Avatar.fallback [ text fallback ]
                |> Avatar.img [ src url, alt name ]
                |> Avatar.toHtml [ class classes ]
    in
    div [ class "flex w-full max-w-lg flex-col gap-6" ]
        [ Item.new
            |> Item.media
                [ Avatar.new
                    |> Avatar.fallback [ text "ER" ]
                    |> Avatar.img [ src "https://github.com/evilrabbit.png" ]
                    |> Avatar.toHtml [ class "size-10" ]
                ]
            |> Item.title [ text "Evil Rabbit" ]
            |> Item.description [ text "Last seen 5 months ago" ]
            |> Item.actions
                [ Button.new
                    |> Button.icon (Phosphor.plus Regular |> Phosphor.toHtml [])
                    |> Button.label "Invite"
                    |> Button.outline
                    |> Button.small
                    |> Button.rounded
                    |> Button.toHtml []
                ]
            |> Item.outline
            |> Item.toHtml []
        , Item.new
            |> Item.media
                [ div [ class "flex -space-x-2 *:data-[slot=avatar]:ring-2 *:data-[slot=avatar]:ring-background *:data-[slot=avatar]:grayscale" ]
                    [ member "@shadcn" "https://github.com/shadcn.png" "CN" "hidden sm:flex"
                    , member "@maxleiter" "https://github.com/maxleiter.png" "LR" "hidden sm:flex"
                    , member "@evilrabbit" "https://github.com/evilrabbit.png" "ER" ""
                    ]
                ]
            |> Item.title [ text "No Team Members" ]
            |> Item.description [ text "Invite your team to collaborate on this project." ]
            |> Item.actions
                [ Button.new
                    |> Button.text "Invite"
                    |> Button.outline
                    |> Button.small
                    |> Button.toHtml []
                ]
            |> Item.outline
            |> Item.toHtml []
        ]


{-| `image` shows an image before the content, cropped to a square that shrinks with the item's size. `detail` adds a second column at the end.
-}
image : Html msg
image =
    let
        music =
            [ { title = "Midnight City Lights", artist = "Neon Dreams", album = "Electric Nights", duration = "3:45" }
            , { title = "Coffee Shop Conversations", artist = "The Morning Brew", album = "Urban Stories", duration = "4:05" }
            , { title = "Digital Rain", artist = "Cyber Symphony", album = "Binary Beats", duration = "3:30" }
            ]
    in
    div [ class "flex w-full max-w-md flex-col gap-6" ]
        [ Item.group [ class "gap-4" ]
            (List.map
                (\song ->
                    Item.new
                        |> Item.image [ src ("https://avatar.vercel.sh/" ++ song.title), alt song.title, width 32, height 32, class "object-cover grayscale" ]
                        |> Item.title [ text (song.title ++ " - "), span [ class "text-muted-foreground" ] [ text song.album ] ]
                        |> Item.description [ text song.artist ]
                        |> Item.detail [ text song.duration ]
                        |> Item.outline
                        |> Item.toAnchor [ href "#", attribute "role" "listitem" ]
                )
                music
            )
        ]


{-| `group` lays out related items as a list.
-}
group : Html msg
group =
    let
        people =
            [ { username = "shadcn", avatar = "https://github.com/shadcn.png", email = "shadcn@vercel.com" }
            , { username = "maxleiter", avatar = "https://github.com/maxleiter.png", email = "maxleiter@vercel.com" }
            , { username = "evilrabbit", avatar = "https://github.com/evilrabbit.png", email = "evilrabbit@vercel.com" }
            ]
    in
    Item.group [ class "max-w-sm" ]
        (List.map
            (\person ->
                Item.new
                    |> Item.media
                        [ Avatar.new
                            |> Avatar.fallback [ text (String.left 1 person.username) ]
                            |> Avatar.img [ src person.avatar, class "grayscale" ]
                            |> Avatar.toHtml []
                        ]
                    |> Item.title [ text person.username ]
                    |> Item.description [ text person.email ]
                    |> Item.actions
                        [ Button.new
                            |> Button.icon (Phosphor.plus Regular |> Phosphor.toHtml [])
                            |> Button.label "Add"
                            |> Button.ghost
                            |> Button.rounded
                            |> Button.toHtml []
                        ]
                    |> Item.outline
                    |> Item.toHtml []
            )
            people
        )


{-| `header` adds a full-width row above the content. `footer` does the same below it.
-}
header : Html msg
header =
    let
        models =
            [ { name = "v0-1.5-sm", description = "Everyday tasks and UI generation.", image = "https://images.unsplash.com/photo-1650804068570-7fb2e3dbf888?q=80&w=640&auto=format&fit=crop" }
            , { name = "v0-1.5-lg", description = "Advanced thinking or reasoning.", image = "https://images.unsplash.com/photo-1610280777472-54133d004c8c?q=80&w=640&auto=format&fit=crop" }
            , { name = "v0-2.0-mini", description = "Open Source model for everyone.", image = "https://images.unsplash.com/photo-1602146057681-08560aee8cde?q=80&w=640&auto=format&fit=crop" }
            ]
    in
    div [ class "flex w-full max-w-xl flex-col gap-6" ]
        [ Item.group [ class "grid grid-cols-3 gap-4" ]
            (List.map
                (\model ->
                    Item.new
                        |> Item.header
                            [ img [ src model.image, alt model.name, width 128, height 128, class "aspect-square w-full rounded-sm object-cover" ] []
                            ]
                        |> Item.title [ text model.name ]
                        |> Item.description [ text model.description ]
                        |> Item.outline
                        |> Item.toHtml []
                )
                models
            )
        ]


{-| `toAnchor` renders the item as a link. The hover and focus states apply to the anchor.
-}
link : Html msg
link =
    div [ class "flex w-full max-w-md flex-col gap-4" ]
        [ Item.new
            |> Item.title [ text "Visit our documentation" ]
            |> Item.description [ text "Learn how to get started with our components." ]
            |> Item.actions [ Phosphor.caretRight Regular |> Phosphor.toHtml [ Svg.Attributes.class "size-4" ] ]
            |> Item.toAnchor [ href "#" ]
        , Item.new
            |> Item.title [ text "External resource" ]
            |> Item.description [ text "Opens in a new tab with security attributes." ]
            |> Item.actions [ Phosphor.arrowSquareOut Regular |> Phosphor.toHtml [ Svg.Attributes.class "size-4" ] ]
            |> Item.outline
            |> Item.toAnchor [ href "#", target "_blank", rel "noopener noreferrer" ]
        ]


{-| An `extraSmall` item fits inside a dropdown menu item, which drops its padding. The `leading-none` on the description is set from the item, since `description` takes no attributes.
-}
dropdown : Html msg
dropdown =
    let
        people =
            [ { username = "shadcn", avatar = "https://github.com/shadcn.png", email = "shadcn@vercel.com" }
            , { username = "maxleiter", avatar = "https://github.com/maxleiter.png", email = "maxleiter@vercel.com" }
            , { username = "evilrabbit", avatar = "https://github.com/evilrabbit.png", email = "evilrabbit@vercel.com" }
            ]
    in
    DropdownMenu.new
        |> DropdownMenu.id "item-dropdown"
        |> DropdownMenu.trigger
            (Button.new
                |> Button.outline
                |> Button.toAttributes
            )
            [ text "Select ", Phosphor.caretDown Regular |> Phosphor.toHtml [] ]
        |> DropdownMenu.content
            [ DropdownMenu.group
                (List.map
                    (\person ->
                        DropdownMenu.item
                            []
                            [ Item.new
                                |> Item.media
                                    [ Avatar.new
                                        |> Avatar.fallback [ text (String.left 1 person.username) ]
                                        |> Avatar.img [ src person.avatar, class "grayscale" ]
                                        |> Avatar.toHtml [ class "size-[--spacing(6.5)]" ]
                                    ]
                                |> Item.title [ text person.username ]
                                |> Item.description [ text person.email ]
                                |> Item.extraSmall
                                |> Item.toHtml [ class "w-full p-2 [&_[data-slot=item-description]]:leading-none" ]
                            ]
                    )
                    people
                )
            ]
        |> DropdownMenu.alignEnd
        |> DropdownMenu.toHtml [ class "w-48" ]


{-| Set `dir="rtl"` on a parent element for right-to-left languages.
-}
rtl : Html msg
rtl =
    div [ class "flex w-full max-w-md flex-col gap-6", dir "rtl" ]
        [ Item.new
            |> Item.title [ text "عنصر أساسي" ]
            |> Item.description [ text "عنصر بسيط يحتوي على عنوان ووصف." ]
            |> Item.actions
                [ Button.new
                    |> Button.text "إجراء"
                    |> Button.outline
                    |> Button.small
                    |> Button.toHtml []
                ]
            |> Item.outline
            |> Item.toHtml [ dir "rtl" ]
        , Item.new
            |> Item.media [ Phosphor.sealCheck Regular |> Phosphor.toHtml [ Svg.Attributes.class "size-5" ] ]
            |> Item.title [ text "تم التحقق من ملفك الشخصي." ]
            |> Item.actions [ Phosphor.caretRight Regular |> Phosphor.toHtml [ Svg.Attributes.class "size-4" ] ]
            |> Item.outline
            |> Item.small
            |> Item.toAnchor [ href "#", dir "rtl" ]
        ]
