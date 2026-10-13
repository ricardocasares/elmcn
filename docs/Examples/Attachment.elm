module Examples.Attachment exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (alt, attribute, class, href, rel, src, target)
import Phosphor exposing (IconWeight(..))
import UI.Attachment as Attachment
import UI.Button as Button
import UI.Dialog as Dialog
import UI.Spinner as Spinner


demo : Html msg
demo =
    div [ class "mx-auto flex w-full max-w-sm flex-col gap-3" ]
        [ Attachment.group []
            [ Attachment.new
                |> Attachment.title "workspace.png"
                |> Attachment.description "PNG · 820 KB"
                |> Attachment.image [ src "https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=900&auto=format&fit=crop&q=80", alt "Workspace" ]
                |> Attachment.vertical
                |> Attachment.toHtml []
            , Attachment.new
                |> Attachment.title "desk-reference.jpg"
                |> Attachment.description "JPG · 1.1 MB"
                |> Attachment.image [ src "https://images.unsplash.com/photo-1497215728101-856f4ea42174?w=900&auto=format&fit=crop&q=80", alt "Desk" ]
                |> Attachment.vertical
                |> Attachment.toHtml []
            , Attachment.new
                |> Attachment.title "office-reference.jpg"
                |> Attachment.description "JPG · 940 KB"
                |> Attachment.image [ src "https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=900&auto=format&fit=crop&q=80", alt "Office" ]
                |> Attachment.vertical
                |> Attachment.toHtml []
            ]
        , Attachment.new
            |> Attachment.title "sales-dashboard.pdf"
            |> Attachment.description "Uploading · 64%"
            |> Attachment.icon (Spinner.view [])
            |> Attachment.uploading
            |> Attachment.actions
                [ Button.new
                    |> Button.icon (Phosphor.x Regular |> Phosphor.toHtml [])
                    |> Button.label "Cancel upload"
                    |> Attachment.action []
                ]
            |> Attachment.toHtml [ class "w-full" ]
        , Attachment.new
            |> Attachment.title "message-renderer.tsx"
            |> Attachment.description "TypeScript · 12 KB"
            |> Attachment.icon (Phosphor.fileCode Regular |> Phosphor.toHtml [])
            |> Attachment.actions
                [ Button.new
                    |> Button.icon (Phosphor.x Regular |> Phosphor.toHtml [])
                    |> Button.label "Remove message-renderer.tsx"
                    |> Attachment.action []
                ]
            |> Attachment.toHtml [ class "w-full" ]
        ]


{-| Use `image` for an image preview and `vertical` to stack the media above the content. `link` makes the whole attachment open the image.
-}
image : Html msg
image =
    div [ class "mx-auto w-full max-w-sm" ]
        [ Attachment.group [ class "w-full" ]
            (List.map
                (\( name, meta, ( url, description ) ) ->
                    Attachment.new
                        |> Attachment.title name
                        |> Attachment.description meta
                        |> Attachment.image [ src url, alt description ]
                        |> Attachment.vertical
                        |> Attachment.actions
                            [ Button.new
                                |> Button.icon (Phosphor.x Regular |> Phosphor.toHtml [])
                                |> Button.label ("Remove " ++ name)
                                |> Attachment.action []
                            ]
                        |> Attachment.link [ href url, target "_blank", rel "noreferrer", attribute "aria-label" ("Open " ++ name) ]
                        |> Attachment.toHtml []
                )
                [ ( "workspace.png", "PNG · 820 KB", ( "https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=900&auto=format&fit=crop&q=80", "Workspace" ) )
                , ( "desk-reference.jpg", "JPG · 1.1 MB", ( "https://images.unsplash.com/photo-1497215728101-856f4ea42174?w=900&auto=format&fit=crop&q=80", "Desk" ) )
                , ( "office-reference.jpg", "JPG · 940 KB", ( "https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=900&auto=format&fit=crop&q=80", "Office" ) )
                ]
            )
        ]


{-| The state reflects the upload lifecycle. `uploading` and `processing` shimmer the title, and `error` switches to a destructive treatment. The default state is done.
-}
states : Html msg
states =
    div [ class "mx-auto flex w-full max-w-sm flex-col gap-2" ]
        [ Attachment.new
            |> Attachment.title "selected-file.pdf"
            |> Attachment.description "Ready to upload"
            |> Attachment.icon (Phosphor.clock Regular |> Phosphor.toHtml [])
            |> Attachment.idle
            |> Attachment.actions
                [ Button.new
                    |> Button.icon (Phosphor.x Regular |> Phosphor.toHtml [])
                    |> Button.label "Remove selected-file.pdf"
                    |> Attachment.action []
                ]
            |> Attachment.toHtml [ class "w-full" ]
        , Attachment.new
            |> Attachment.title "design-system.zip"
            |> Attachment.description "Uploading · 64%"
            |> Attachment.icon (Spinner.view [])
            |> Attachment.uploading
            |> Attachment.actions
                [ Button.new
                    |> Button.icon (Phosphor.x Regular |> Phosphor.toHtml [])
                    |> Button.label "Cancel upload"
                    |> Attachment.action []
                ]
            |> Attachment.toHtml [ class "w-full" ]
        , Attachment.new
            |> Attachment.title "market-research.pdf"
            |> Attachment.description "Processing document"
            |> Attachment.icon (Phosphor.fileText Regular |> Phosphor.toHtml [])
            |> Attachment.processing
            |> Attachment.actions
                [ Button.new
                    |> Button.icon (Phosphor.x Regular |> Phosphor.toHtml [])
                    |> Button.label "Remove market-research.pdf"
                    |> Attachment.action []
                ]
            |> Attachment.toHtml [ class "w-full" ]
        , Attachment.new
            |> Attachment.title "financial-model.xlsx"
            |> Attachment.description "Upload failed. Try again."
            |> Attachment.icon (Phosphor.fileX Regular |> Phosphor.toHtml [])
            |> Attachment.error
            |> Attachment.actions
                [ Button.new
                    |> Button.icon (Phosphor.arrowClockwise Regular |> Phosphor.toHtml [])
                    |> Button.label "Retry upload"
                    |> Attachment.action []
                , Button.new
                    |> Button.icon (Phosphor.x Regular |> Phosphor.toHtml [])
                    |> Button.label "Remove financial-model.xlsx"
                    |> Attachment.action []
                ]
            |> Attachment.toHtml [ class "w-full" ]
        , Attachment.new
            |> Attachment.title "uploaded-report.pdf"
            |> Attachment.description "Uploaded · 1.8 MB"
            |> Attachment.icon (Phosphor.check Regular |> Phosphor.toHtml [])
            |> Attachment.actions
                [ Button.new
                    |> Button.icon (Phosphor.x Regular |> Phosphor.toHtml [])
                    |> Button.label "Remove uploaded-report.pdf"
                    |> Attachment.action []
                ]
            |> Attachment.toHtml [ class "w-full" ]
        ]


{-| The default size is the largest. `small` and `extraSmall` tighten the padding, the media and the text.
-}
sizes : Html msg
sizes =
    div [ class "mx-auto flex w-full max-w-sm flex-col gap-3" ]
        [ Attachment.new
            |> Attachment.title "Default attachment"
            |> Attachment.description "PDF · 2.4 MB"
            |> Attachment.icon (Phosphor.fileText Regular |> Phosphor.toHtml [])
            |> Attachment.toHtml [ class "w-full" ]
        , Attachment.new
            |> Attachment.title "Small attachment"
            |> Attachment.description "PDF · 2.4 MB"
            |> Attachment.icon (Phosphor.fileText Regular |> Phosphor.toHtml [])
            |> Attachment.small
            |> Attachment.toHtml [ class "w-full" ]
        , Attachment.new
            |> Attachment.title "Extra small attachment"
            |> Attachment.icon (Phosphor.fileText Regular |> Phosphor.toHtml [])
            |> Attachment.extraSmall
            |> Attachment.toHtml [ class "w-full" ]
        ]


{-| `group` lays attachments out in a horizontally scrollable, snapping row with an edge fade.
-}
group : Html msg
group =
    div [ class "mx-auto w-full max-w-sm" ]
        [ Attachment.group [ class "w-full" ]
            [ Attachment.new
                |> Attachment.title "briefing-notes.pdf"
                |> Attachment.description "PDF · 1.4 MB"
                |> Attachment.icon (Phosphor.fileText Regular |> Phosphor.toHtml [])
                |> Attachment.actions
                    [ Button.new
                        |> Button.icon (Phosphor.x Regular |> Phosphor.toHtml [])
                        |> Button.label "Remove briefing-notes.pdf"
                        |> Attachment.action []
                    ]
                |> Attachment.toHtml [ class "w-64" ]
            , Attachment.new
                |> Attachment.title "workspace.png"
                |> Attachment.description "PNG · 820 KB"
                |> Attachment.image [ src "https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=900&auto=format&fit=crop&q=80", alt "workspace.png" ]
                |> Attachment.actions
                    [ Button.new
                        |> Button.icon (Phosphor.x Regular |> Phosphor.toHtml [])
                        |> Button.label "Remove workspace.png"
                        |> Attachment.action []
                    ]
                |> Attachment.toHtml [ class "w-64" ]
            , Attachment.new
                |> Attachment.title "customers.csv"
                |> Attachment.description "CSV · 18 KB"
                |> Attachment.icon (Phosphor.table Regular |> Phosphor.toHtml [])
                |> Attachment.actions
                    [ Button.new
                        |> Button.icon (Phosphor.x Regular |> Phosphor.toHtml [])
                        |> Button.label "Remove customers.csv"
                        |> Attachment.action []
                    ]
                |> Attachment.toHtml [ class "w-64" ]
            , Attachment.new
                |> Attachment.title "renderer.tsx"
                |> Attachment.description "TSX · 12 KB"
                |> Attachment.icon (Phosphor.fileCode Regular |> Phosphor.toHtml [])
                |> Attachment.actions
                    [ Button.new
                        |> Button.icon (Phosphor.x Regular |> Phosphor.toHtml [])
                        |> Button.label "Remove renderer.tsx"
                        |> Attachment.action []
                    ]
                |> Attachment.toHtml [ class "w-64" ]
            ]
        ]


{-| `button` with `Dialog.opens` makes the whole attachment open a dialog. The trigger fills the attachment behind the actions, so the actions stay independently clickable.
-}
trigger : Html msg
trigger =
    div [ class "mx-auto w-full max-w-sm" ]
        [ Attachment.new
            |> Attachment.title "research-summary.pdf"
            |> Attachment.description "Open preview dialog"
            |> Attachment.icon (Phosphor.fileMagnifyingGlass Regular |> Phosphor.toHtml [])
            |> Attachment.actions
                [ Button.new
                    |> Button.icon (Phosphor.copy Regular |> Phosphor.toHtml [])
                    |> Button.label "Copy link"
                    |> Attachment.action []
                , Button.new
                    |> Button.icon (Phosphor.x Regular |> Phosphor.toHtml [])
                    |> Button.label "Remove research-summary.pdf"
                    |> Attachment.action []
                ]
            |> Attachment.button (attribute "aria-label" "Preview research-summary.pdf" :: Dialog.opens "attachment-preview")
            |> Attachment.toHtml [ class "w-full" ]
        , Dialog.new
            |> Dialog.id "attachment-preview"
            |> Dialog.title [ text "research-summary.pdf" ]
            |> Dialog.description [ text "The attachment trigger fills the card and opens the dialog, while the actions stay independently clickable above it." ]
            |> Dialog.toHtml [ class "sm:max-w-md" ]
        ]
