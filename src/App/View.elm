module App.View exposing (..)

import App.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (type_, checked, name, disabled, value, class, src, id, selected, for, href)
import Date exposing (Date)
import Mcq.View


root : Model -> Html Msg
root model =
    div [ class "wrapper" ]
        [ h1 [] [ text "enigma" ]
        , div [ class "mcq" ] [ Mcq.View.root model.mcq ]
        , viewFooter model
        ]


viewFooter : Model -> Html Msg
viewFooter model =
    footer [ class "row footer" ]
        [ p [] [ text "Made with ", a [ href "http://elm-lang.org" ] [ text "Elm" ] ]
        , p []
            [ text
                ("Copyright "
                    ++ (toString
                            (case model.global.date of
                                Nothing ->
                                    1337

                                Just date ->
                                    Date.year date
                            )
                       )
                    ++ " "
                )
            , a [ href "https://github.com/freboto" ] [ text "Fredrik Borgen Tørnvall" ]
            , text " and "
            , a [ href "https://kradalby.no" ] [ text "Kristoffer Dalby" ]
            ]
        ]
