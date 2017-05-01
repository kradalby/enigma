module Mcq.View exposing (root)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (type_, checked, name, value, class, src, id, href, style, alt)
import Mcq.Types exposing (..)
import App.Rest exposing (base_url)
import Util exposing (onEnter, viewErrorBox, viewProgressbar, percentageOfQuestionsLeft)


root : Mcq.Types.Model -> Html Msg
root model =
    div []
        [ viewError model
        , case model.mode of
            Start ->
                viewStartQuiz model

            Running ->
                case model.currentQuestion of
                    Nothing ->
                        viewStartQuiz model

                    Just currentQuestion ->
                        div []
                            [ viewProgressbar (percentageOfQuestionsLeft model.showAnswer model.currentQuestion model.unAnsweredQuestions model.correctQuestions model.wrongQuestions)
                            , viewMultipleChoiceQuestion
                                currentQuestion
                                model.showAnswer
                            ]

            Result ->
                viewResult model
        ]


viewError : Model -> Html Msg
viewError model =
    div [ class "row" ]
        [ case model.error of
            Nothing ->
                text ""

            Just error ->
                viewErrorBox error
        ]


viewStartQuiz : Model -> Html Msg
viewStartQuiz model =
    div []
        [ h3 [] [ text "How many questions?" ]
        , input
            [ id "wordInput"
            , type_ "number"
            , onInput NumberOfQuestionsInput
            , value model.numberOfQuestionsInputField
            , onEnter (validateNumberOfQuestionsInputFieldAndCreateResponseMsg model)
            ]
            []
        , viewNumberOfQuestionButtons model
        , button
            [ class "btn"
            , onClick (validateNumberOfQuestionsInputFieldAndCreateResponseMsg model)
            ]
            [ text "Start" ]
        ]


viewNumberOfQuestionButtons : Model -> Html Msg
viewNumberOfQuestionButtons model =
    let
        numberOfQuestions =
            (List.length model.questions)

        seperator =
            if numberOfQuestions <= 3 then
                1
            else if numberOfQuestions <= 9 then
                3
            else if numberOfQuestions <= 15 then
                5
            else if numberOfQuestions <= 30 then
                10
            else if numberOfQuestions <= 75 then
                25
            else
                1

        buttonNumbers =
            List.map (\n -> n * seperator) [ 1, 2, 3 ]
    in
        div [ class "row" ] <|
            List.map
                (\n -> button [ class "btn", onClick <| StartQuiz n ] [ text <| toString n ])
                buttonNumbers


validateNumberOfQuestionsInputFieldAndCreateResponseMsg : Model -> Msg
validateNumberOfQuestionsInputFieldAndCreateResponseMsg model =
    case String.toInt model.numberOfQuestionsInputField of
        Err msg ->
            SetError "You did not enter a valid number"

        Ok value ->
            if value <= (List.length model.questions) then
                StartQuiz value
            else
                SetError "We dont have that many questions..."


viewMultipleChoiceQuestion : MultipleQuestion -> Bool -> Html Msg
viewMultipleChoiceQuestion mcq showAnswer =
    div []
        [ h3 [] [ text mcq.question ]
        , div [ class "row" ]
            [ case mcq.image of
                Just image ->
                    img [ class "responsive-img", src (base_url ++ image) ] []

                Nothing ->
                    text ""
            , case mcq.video of
                Just video ->
                    node "video" [ src (base_url ++ video) ] []

                Nothing ->
                    text ""
            ]
        , div [ class "row" ] (viewMultipleChoiceQuestionAlternaltives mcq.answers mcq.correct showAnswer)
        ]


viewMultipleChoiceQuestionAlternaltives : List String -> Int -> Bool -> List (Html Msg)
viewMultipleChoiceQuestionAlternaltives alternaltives correctAnswer showAnswer =
    List.indexedMap
        (\i alternaltive ->
            div [ class "col s12 m6 l3" ]
                [ button
                    [ class
                        (case showAnswer of
                            False ->
                                "btn indigo lighten-5 black-text"

                            True ->
                                (if i == correctAnswer then
                                    "btn green"
                                 else
                                    "btn red"
                                )
                        )
                    , style [ ( "width", "100%" ) ]
                    , (case showAnswer of
                        False ->
                            onClick
                                (if i == correctAnswer then
                                    Correct
                                 else
                                    Wrong
                                )

                        True ->
                            alt ""
                      )
                    ]
                    [ text alternaltive ]
                ]
        )
        alternaltives


viewResult : Model -> Html Msg
viewResult model =
    div []
        [ h3 [] [ text "Results" ]
        , h5 [] [ text ("Answers: " ++ (toString (List.length model.correctQuestions) ++ "/" ++ (toString (List.length model.wrongQuestions)))) ]
        , h5 [] [ text ("points: " ++ (toString ((List.length model.correctQuestions) * 100))) ]
        , h5 [] [ text ("best: " ++ (toString model.score.best)) ]
        , button [ class "btn", onClick (ChangeMode Start) ] [ text "Start new quiz" ]
        ]
