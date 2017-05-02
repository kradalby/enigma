module App.View exposing (..)

import App.Types exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (type_, checked, name, class, src, id, href, attribute)
import Date exposing (Date)
import Mcq.View
import Lmq.View
import Olq.View


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

                        OutlineQuestions ->
                            div [] [ Html.map OlqMsg (Olq.View.root model.olq) ]

                        Score ->
                            viewScore model
                    ]
                ]
            ]
          -- , viewFooter model
        ]


viewModeMenu : Html Msg
viewModeMenu =
    div []
        [ h4 [ class "center-align" ] [ text "Choose game mode" ]
        , div [ class "row" ]
            [ button [ class "waves-effect waves-light col s12 btn-large", onClick (ChangeMode MultipleChoiceQuestions) ] [ text "Multiple Choice Questions" ]
            ]
        , div [ class "row" ]
            [ button [ class "waves-effect waves-light col s12 btn-large", onClick (ChangeMode LandmarkQuestions) ] [ text "Landmark Questions" ]
            ]
        , div [ class "row" ]
            [ button [ class "waves-effect waves-light col s12 btn-large", onClick (ChangeMode OutlineQuestions) ] [ text "Outline Questions" ]
            ]
        ]


viewScore : Model -> Html Msg
viewScore model =
    div []
        [ div []
            [ table []
                [ tr []
                    [ th []
                        [ text "Game mode" ]
                    , th []
                        [ text "Personal best" ]
                    ]
                , tr []
                    [ td []
                        [ text "Multiple Choice" ]
                    , td []
                        [ text (toString model.mcq.score.best) ]
                    ]
                , tr []
                    [ td []
                        [ text "Landmark" ]
                    , td []
                        [ text (toString model.lmq.score.best) ]
                    ]
                , tr []
                    [ td []
                        [ text "Outline" ]
                    , td []
                        [ text (toString model.olq.score.best) ]
                    ]
                , tr []
                    [ td []
                        [ text "Total" ]
                    , td []
                        [ text
                            (toString
                                (model.mcq.score.best
                                    + model.lmq.score.best
                                    + model.olq.score.best
                                )
                            )
                        ]
                    ]
                ]
            ]
        , div
            []
            [ table []
                [ tr []
                    [ th []
                        [ text "Game mode" ]
                    , th []
                        [ text "Correct" ]
                    , th []
                        [ text "Wrong" ]
                    , th []
                        [ text "Total" ]
                    ]
                , tr []
                    [ td []
                        [ text "Multiple Choice" ]
                    , td []
                        [ text (toString model.mcq.score.correct) ]
                    , td []
                        [ text (toString model.mcq.score.wrong) ]
                    , td []
                        [ text (toString (model.mcq.score.correct + model.mcq.score.wrong)) ]
                    ]
                , tr []
                    [ td []
                        [ text "Landmark" ]
                    , td []
                        [ text (toString model.lmq.score.correct) ]
                    , td []
                        [ text (toString model.lmq.score.wrong) ]
                    , td []
                        [ text (toString (model.lmq.score.correct + model.lmq.score.wrong)) ]
                    ]
                , tr []
                    [ td []
                        [ text "Outline" ]
                    , td []
                        [ text (toString model.olq.score.correct) ]
                    , td []
                        [ text (toString model.olq.score.wrong) ]
                    , td []
                        [ text (toString (model.olq.score.correct + model.olq.score.wrong)) ]
                    ]
                , tr []
                    [ td []
                        [ text "Total" ]
                    , td []
                        [ text
                            (toString
                                (model.mcq.score.correct
                                    + model.lmq.score.correct
                                    + model.olq.score.correct
                                )
                            )
                        ]
                    , td []
                        [ text
                            (toString
                                (model.mcq.score.wrong
                                    + model.lmq.score.wrong
                                    + model.olq.score.wrong
                                )
                            )
                        ]
                    , td []
                        [ text
                            (toString
                                (model.mcq.score.correct
                                    + model.mcq.score.wrong
                                    + model.lmq.score.correct
                                    + model.lmq.score.wrong
                                    + model.olq.score.correct
                                    + model.olq.score.wrong
                                )
                            )
                        ]
                    ]
                ]
            ]
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    header []
        [ nav [ class "blue" ]
            [ div [ class "nav-wrapper container" ]
                [ (case model.global.mode of
                    Main ->
                        text ""

                    _ ->
                        i [ attribute "aria-hidden" "true", class "fa fa-chevron-left", onClick (ChangeMode Main) ]
                            []
                  )
                , a [ id "logo-container", onClick (ChangeMode Main), class "brand-logo center" ] [ text "Enigma" ]
                , a [ onClick (ChangeMode Score), class " right" ] [ text "Score" ]
                  -- , ul [ class "right hide-on-med-and-down" ] [ li [] [ a [] [ text "derp" ] ] ]
                  -- , ul [ class "nav-mobile" ] [ li [] [ a [] [ text "derp" ] ] ]
                  -- , a [ href "#", dataactivates "nav-mobile", class "button-collapse" ] [ i [ class "material-icons" ] [ text "menu" ] ]
                ]
            ]
        ]



{- viewFooter : Model -> Html Msg
   viewFooter model =
       footer [ class "page-footer blue lighten-1" ]
           [ div [ class "container" ] [ div [ class "row" ] [] ]
           , div [ class "footer-copyright" ]
               [ div [ class "container" ]
                   [ p []
                       [ text "Made with ", a [ class "orange-text text-lighten-1", href "http://elm-lang.org" ] [ text "Elm" ] ]
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
                       , a [ href "https://github.com/freboto", class "orange-text text-lighten-1" ] [ text "Fredrik Borgen Tørnvall" ]
                       , text " and "
                       , a [ href "https://kradalby.no", class "orange-text text-lighten-1" ] [ text "Kristoffer Dalby" ]
                       ]
                   ]
               ]
           ]
-}


dataactivates : String -> Html.Attribute Msg
dataactivates =
    attribute "data-activates"
