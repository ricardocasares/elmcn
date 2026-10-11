module Examples.Pagination exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, for, href)
import State exposing (State)
import UI.Label as Label
import UI.Pagination as Pagination
import UI.Select as Select


demo : Html msg
demo =
    Pagination.view []
        [ Pagination.content []
            [ Pagination.item [] [ Pagination.previous [ href "#" ] [] ]
            , Pagination.item [] [ Pagination.link [] [ href "#" ] [ text "1" ] ]
            , Pagination.item [] [ Pagination.link [ Pagination.active ] [ href "#" ] [ text "2" ] ]
            , Pagination.item [] [ Pagination.link [] [ href "#" ] [ text "3" ] ]
            , Pagination.item [] [ Pagination.ellipsis [] ]
            , Pagination.item [] [ Pagination.next [ href "#" ] [] ]
            ]
        ]


{-| Page links alone, without previous and next.
-}
simple : Html msg
simple =
    Pagination.view []
        [ Pagination.content []
            (List.map
                (\page ->
                    Pagination.item []
                        [ Pagination.link
                            (if page == 2 then
                                [ Pagination.active ]

                             else
                                []
                            )
                            [ href "#" ]
                            [ text (String.fromInt page) ]
                        ]
                )
                (List.range 1 5)
            )
        ]


{-| Previous and next beside a rows-per-page select. The `mx-0 w-auto` classes stop the pagination from filling the row.
-}
withSelect : State -> Html State.Msg
withSelect state =
    div [ class "flex w-full items-center justify-between gap-4" ]
        [ div [ class "flex items-center gap-3" ]
            [ Label.view [ for "rows-per-page", class "whitespace-nowrap" ] [ text "Rows per page" ]
            , Select.new
                |> Select.id "rows-per-page"
                |> Select.onSelect (State.set "rows-per-page")
                |> Select.value (Just (State.get "rows-per-page" state |> Maybe.withDefault "25"))
                |> Select.items
                    [ Select.item "10" [ text "10" ]
                    , Select.item "25" [ text "25" ]
                    , Select.item "50" [ text "50" ]
                    , Select.item "100" [ text "100" ]
                    ]
                |> Select.toHtml [ class "w-20" ]
            ]
        , Pagination.view [ class "mx-0 w-auto" ]
            [ Pagination.content []
                [ Pagination.item [] [ Pagination.previous [ href "#" ] [] ]
                , Pagination.item [] [ Pagination.next [ href "#" ] [] ]
                ]
            ]
        ]
