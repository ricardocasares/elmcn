module UI.Textarea exposing (view)

{-| Displays a form textarea. It grows with its content.

    Textarea.view [ placeholder "Type your message here.", value model.message, onInput MessageChanged ]

@docs view

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)


{-| Renders a `<textarea>`.
-}
view : List (Attribute msg) -> Html msg
view attrs =
    Html.textarea
        (attribute "data-slot" "textarea"
            :: class "flex field-sizing-content min-h-16 w-full rounded-md border border-input bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 md:text-sm dark:bg-input/30 dark:aria-invalid:ring-destructive/40"
            :: attrs
        )
        []
