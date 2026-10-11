module UI.Table exposing (view, caption, header, body, footer, row, head, cell)

{-| A responsive table.

    Table.view []
        [ Table.caption [] [ text "A list of your recent invoices." ]
        , Table.header []
            [ Table.row []
                [ Table.head [] [ text "Invoice" ]
                , Table.head [ class "text-right" ] [ text "Amount" ]
                ]
            ]
        , Table.body []
            [ Table.row []
                [ Table.cell [ class "font-medium" ] [ text "INV001" ]
                , Table.cell [ class "text-right" ] [ text "$250.00" ]
                ]
            ]
        ]

@docs view, caption, header, body, footer, row, head, cell

-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, class)


{-| Renders a `<table>` inside a horizontally scrolling container.
The attributes go on the `<table>`.
-}
view : List (Attribute msg) -> List (Html msg) -> Html msg
view attrs children =
    Html.div [ attribute "data-slot" "table-container", class "relative w-full overflow-x-auto" ]
        [ Html.table (attribute "data-slot" "table" :: class "w-full caption-bottom text-sm" :: attrs) children ]


{-| Shown below the table.
-}
caption : List (Attribute msg) -> List (Html msg) -> Html msg
caption attrs children =
    Html.caption (attribute "data-slot" "table-caption" :: class "mt-4 text-sm text-muted-foreground" :: attrs) children


{-| Renders a `<thead>`.
-}
header : List (Attribute msg) -> List (Html msg) -> Html msg
header attrs children =
    Html.thead (attribute "data-slot" "table-header" :: class "[&_tr]:border-b" :: attrs) children


{-| Renders a `<tbody>`.
-}
body : List (Attribute msg) -> List (Html msg) -> Html msg
body attrs children =
    Html.tbody (attribute "data-slot" "table-body" :: class "[&_tr:last-child]:border-0" :: attrs) children


{-| Renders a `<tfoot>`.
-}
footer : List (Attribute msg) -> List (Html msg) -> Html msg
footer attrs children =
    Html.tfoot
        (attribute "data-slot" "table-footer"
            :: class "border-t bg-muted/50 font-medium [&>tr]:last:border-b-0"
            :: attrs
        )
        children


{-| Renders a `<tr>`. Add `attribute "data-state" "selected"` to highlight it.
-}
row : List (Attribute msg) -> List (Html msg) -> Html msg
row attrs children =
    Html.tr
        (attribute "data-slot" "table-row"
            :: class "border-b transition-colors hover:bg-muted/50 has-aria-expanded:bg-muted/50 data-[state=selected]:bg-muted"
            :: attrs
        )
        children


{-| A header cell, rendered as `<th>`.
-}
head : List (Attribute msg) -> List (Html msg) -> Html msg
head attrs children =
    Html.th
        (attribute "data-slot" "table-head"
            :: class "h-10 px-2 text-left align-middle font-medium whitespace-nowrap text-foreground [&:has([role=checkbox])]:pr-0"
            :: attrs
        )
        children


{-| A data cell, rendered as `<td>`.
-}
cell : List (Attribute msg) -> List (Html msg) -> Html msg
cell attrs children =
    Html.td
        (attribute "data-slot" "table-cell"
            :: class "p-2 align-middle whitespace-nowrap [&:has([role=checkbox])]:pr-0"
            :: attrs
        )
        children
