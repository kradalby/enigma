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
        , (case model.global.mode of
            Main ->
                viewFooter model

            _ ->
                text ""
          )
        ]


viewModeMenu : Html Msg
viewModeMenu =
    div []
        [ h4
            [ class "center-align " ]
            [ span [] [ text "C" ]
            , span [] [ text "h" ]
            , span [] [ text "o" ]
            , span [] [ text "o" ]
            , span [] [ text "s" ]
            , span [] [ text "e" ]
            , span [] [ text " " ]
            , span [] [ text "g" ]
            , span [] [ text "a" ]
            , span [] [ text "m" ]
            , span [] [ text "e" ]
            , span [] [ text " " ]
            , span [] [ text "m" ]
            , span [] [ text "o" ]
            , span [] [ text "d" ]
            , span [] [ text "e" ]
            , span [] [ text "!" ]
            ]
        , hr [] []
        , div [ class "row" ] []
        , div [ class "row" ] []
        , div [ class "card hoverable main-button-color add-pointer", onClick (ChangeMode MultipleChoiceQuestions) ]
            [ div [ class "card-content white-text" ] [ div [ class "card-title" ] [ p [ class "center-align" ] [ text "Multiple Choice Questions" ] ] ] ]
        , div [ class "card hoverable main-button-color add-pointer", onClick (ChangeMode LandmarkQuestions) ]
            [ div [ class "card-content white-text" ] [ div [ class "card-title" ] [ p [ class "center-align" ] [ text "Landmark Questions" ] ] ] ]
        , div [ class "card hoverable main-button-color add-pointer", onClick (ChangeMode OutlineQuestions) ]
            [ div [ class "card-content white-text" ] [ div [ class "card-title" ] [ p [ class "center-align" ] [ text "Outline Questions" ] ] ] ]
          {- [ h4 [ class "center-align" ] [ text "Choose game mode" ]
             , div [ class "row" ]
                 [ button [ class "waves-effect waves-light col s12 btn-large", onClick (ChangeMode MultipleChoiceQuestions) ] [ text "Multiple Choice Questions" ]
                 ]
             , div [ class "row" ]
                 [ button [ class "waves-effect waves-light col s12 btn-large", onClick (ChangeMode LandmarkQuestions) ] [ text "Landmark Questions" ]
                 ]
             , div [ class "row" ]
                 [ button [ class "waves-effect waves-light col s12 btn-large", onClick (ChangeMode OutlineQuestions) ] [ text "Outline Questions" ]
                 ]
          -}
        ]


viewFooter : Model -> Html Msg
viewFooter model =
    footer [ class "page-footer grey lighten-2" ]
        [ div [ class "container" ] [ div [ class "row" ] [] ]
        , div [ class "footer-copyright" ]
            [ div [ class "container center-align" ]
                [ p [ class "text-color text-size" ] [ text "Please take the time to answer our ", a [ href "https://goo.gl/forms/8F67T2z8XC0P1c362" ] [ text "Survey" ] ]
                ]
            ]
        ]



{- div [ class "footer center-align " ]
   [ a [ class "center-align", href "https://goo.gl/forms/8F67T2z8XC0P1c362" ] [ h5 [] [ text "Questionnaire" ] ] ]
-}


viewScore : Model -> Html Msg
viewScore model =
    div []
        [ div []
            [ table [ class "striped" ]
                [ thead []
                    [ tr []
                        [ th []
                            [ text "Game mode" ]
                        , th [ class "table-align-right" ]
                            [ text "Personal best" ]
                        ]
                    ]
                , tbody
                    []
                    [ tr []
                        [ td []
                            [ text "Multiple Choice" ]
                        , td [ class "table-align-right" ]
                            [ text (toString model.mcq.score.best) ]
                        ]
                    , tr []
                        [ td []
                            [ text "Landmark" ]
                        , td [ class "table-align-right" ]
                            [ text (toString model.lmq.score.best) ]
                        ]
                    , tr []
                        [ td []
                            [ text "Outline" ]
                        , td [ class "table-align-right" ]
                            [ text (toString model.olq.score.best) ]
                        ]
                    , tr []
                        [ th []
                            [ text "Total" ]
                        , th [ class "table-align-right" ]
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
            ]
        , hr [] []
        , div [] []
        , div
            []
            [ table [ class "striped" ]
                [ thead []
                    [ tr []
                        [ th []
                            [ text "Game mode" ]
                        , th [ class "table-align-right" ]
                            [ text "Correct" ]
                        , th [ class "table-align-right" ]
                            [ text "Wrong" ]
                        , th [ class "table-align-right" ]
                            [ text "Total" ]
                        ]
                    ]
                , tbody []
                    [ tr []
                        [ td []
                            [ text "Multiple Choice" ]
                        , td [ class "table-align-right" ]
                            [ text (toString model.mcq.score.correct) ]
                        , td [ class "table-align-right" ]
                            [ text (toString model.mcq.score.wrong) ]
                        , td [ class "table-align-right" ]
                            [ text (toString (model.mcq.score.correct + model.mcq.score.wrong)) ]
                        ]
                    , tr []
                        [ td []
                            [ text "Landmark" ]
                        , td [ class "table-align-right" ]
                            [ text (toString model.lmq.score.correct) ]
                        , td [ class "table-align-right" ]
                            [ text (toString model.lmq.score.wrong) ]
                        , td [ class "table-align-right" ]
                            [ text (toString (model.lmq.score.correct + model.lmq.score.wrong)) ]
                        ]
                    , tr []
                        [ td []
                            [ text "Outline" ]
                        , td [ class "table-align-right" ]
                            [ text (toString model.olq.score.correct) ]
                        , td [ class "table-align-right" ]
                            [ text (toString model.olq.score.wrong) ]
                        , td [ class "table-align-right" ]
                            [ text (toString (model.olq.score.correct + model.olq.score.wrong)) ]
                        ]
                    , tr []
                        [ th []
                            [ text "Total" ]
                        , th [ class "table-align-right" ]
                            [ text
                                (toString
                                    (model.mcq.score.correct
                                        + model.lmq.score.correct
                                        + model.olq.score.correct
                                    )
                                )
                            ]
                        , th [ class "table-align-right" ]
                            [ text
                                (toString
                                    (model.mcq.score.wrong
                                        + model.lmq.score.wrong
                                        + model.olq.score.wrong
                                    )
                                )
                            ]
                        , th [ class "table-align-right" ]
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
            , hr [] []
            ]
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    header []
        [ nav [ class "nav-bar-color" ]
            [ div [ class "nav-wrapper container" ]
                [ (case model.global.mode of
                    Main ->
                        text ""

                    _ ->
                        i [ attribute "aria-hidden" "true", class "fa fa-chevron-left add-pointer", onClick (ChangeMode Main) ]
                            []
                  )
                , a [ id "logo-container", onClick (ChangeMode Main), class "brand-logo center add-pointer" ] [ text "Enigma" ]
                , a [ onClick (ChangeMode Score), class " right add-pointer" ] [ text "Score" ]
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
