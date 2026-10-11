module Examples.Table exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (attribute, class)
import UI.Table as Table


demo : Html msg
demo =
    let
        invoices =
            [ ( "INV001", "Paid", "$250.00" )
            , ( "INV002", "Pending", "$150.00" )
            , ( "INV003", "Unpaid", "$350.00" )
            ]
    in
    Table.view []
        [ Table.caption [] [ text "A list of your recent invoices." ]
        , Table.header []
            [ Table.row []
                [ Table.head [ class "w-[100px]" ] [ text "Invoice" ]
                , Table.head [] [ text "Status" ]
                , Table.head [ class "text-right" ] [ text "Amount" ]
                ]
            ]
        , Table.body []
            (List.map
                (\( invoice, status, amount ) ->
                    Table.row []
                        [ Table.cell [ class "font-medium" ] [ text invoice ]
                        , Table.cell [] [ text status ]
                        , Table.cell [ class "text-right" ] [ text amount ]
                        ]
                )
                invoices
            )
        , Table.footer []
            [ Table.row []
                [ Table.cell [ attribute "colspan" "2" ] [ text "Total" ]
                , Table.cell [ class "text-right" ] [ text "$750.00" ]
                ]
            ]
        ]
