module App.View exposing (..)

import App.Types exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (type_, checked, name, class, src, id, href, attribute)
import Date exposing (Date)
import Mcq.View
import Lmq.View


root : Model -> Html Msg
root model =
    body []
        [ viewHeader model
        , main_ []
            [ div [ class "container" ]
                [ div [ class "row" ]
                    [ case model.global.mode of
                        Main ->
                            viewModeMenu

                        MultipleChoiceQuestions ->
                            div [] [ Html.map McqMsg (Mcq.View.root model.mcq) ]

                        LandmarkQuestions ->
                            div [] [ Html.map LmqMsg (Lmq.View.root model.lmq) ]
                    ]
                ]
            ]
        , viewFooter model
        ]


viewModeMenu : Html Msg
viewModeMenu =
    div []
        [ h4 [] [ text "Choose game" ]
        , button [ class "btn waves-effect waves-light", onClick (ChangeMode MultipleChoiceQuestions) ] [ text "Multiple Choice Questions" ]
        , button [ class "btn waves-effect waves-light", onClick (ChangeMode LandmarkQuestions) ] [ text "Landmark Questions" ]
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    header []
        [ nav [ class "light-blue lighten-1" ]
            [ div [ class "nav-wrapper container" ]
                [ a [ id "logo-container", onClick (ChangeMode Main), class "brand-logo" ] [ text "Enigma" ]

                -- , ul [ class "right hide-on-med-and-down" ] [ li [] [ a [] [ text "derp" ] ] ]
                -- , ul [ class "nav-mobile" ] [ li [] [ a [] [ text "derp" ] ] ]
                -- , a [ href "#", dataactivates "nav-mobile", class "button-collapse" ] [ i [ class "material-icons" ] [ text "menu" ] ]
                ]
            ]
        ]


viewFooter : Model -> Html Msg
viewFooter model =
    footer [ class "page-footer orange" ]
        [ div [ class "container" ] [ div [ class "row" ] [] ]
        , div [ class "footer-copyright" ]
            [ div [ class "container" ]
                [ p []
                    [ text "Made with ", a [ class "orange-text text-lighten-3", href "http://elm-lang.org" ] [ text "Elm" ] ]
                , p
                    []
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
                    , a [ href "https://github.com/freboto", class "orange-text text-lighten-3" ] [ text "Fredrik Borgen Tørnvall" ]
                    , text " and "
                    , a [ href "https://kradalby.no", class "orange-text text-lighten-3" ] [ text "Kristoffer Dalby" ]
                    ]
                ]
            ]
        ]


dataactivates : String -> Html.Attribute Msg
dataactivates =
    attribute "data-activates"
