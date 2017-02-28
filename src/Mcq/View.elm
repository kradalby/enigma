module Mcq.View exposing (root)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (type_, checked, name, disabled, value, class, src, id, selected, for, href)
import Mcq.Types exposing (..)
import App.Rest exposing (base_url)
import Util exposing (onEnter, viewErrorBox)


root : Mcq.Types.Model -> Html Msg
root model =
    div []
        [ viewError model
        , a [ onClick (StartQuiz 1) ] [ text "start" ]
        , a [ onClick NextQuestion ] [ text "next" ]
        , a [ onClick GetMultipleChoiceQuestions ] [ text "fetch questions" ]
        , viewStartQuiz model
        , case model.currentQuestion of
            Nothing ->
                p [] [ text "No current question" ]

            Just currentQuestion ->
                viewMultipleChoiceQuestion currentQuestion
        , viewSessionInformation model
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
        [ input
            [ id "wordInput"
            , type_ "number"
            , onInput NumberOfQuestionsInput
            , value model.numberOfQuestionsInputField
            , onEnter (validateNumberOfQuestionsInputFieldAndCreateResponseMsg model)
            ]
            []
        , button
            [ class "btn"
            , onClick (validateNumberOfQuestionsInputFieldAndCreateResponseMsg model)
            ]
            [ text "Start" ]
        ]


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


viewMultipleChoiceQuestion : MultipleQuestion -> Html Msg
viewMultipleChoiceQuestion mcq =
    div [ class "multiple-choice-question" ]
        [ h2 [] [ text mcq.question ]
        , case mcq.image of
            Just image ->
                img [ src (base_url ++ image) ] []

            Nothing ->
                text ""
        , case mcq.video of
            Just video ->
                node "video" [ src (base_url ++ video) ] []

            Nothing ->
                text ""
        , div [ class "multiple-choice-question-alternaltives" ] (viewMultipleChoiceQuestionAlternaltives mcq.answers mcq.correct)
        ]


viewMultipleChoiceQuestionAlternaltives : List String -> Int -> List (Html Msg)
viewMultipleChoiceQuestionAlternaltives alternaltives correctAnswer =
    List.indexedMap
        (\i alternaltive ->
            button
                [ onClick
                    (if i == correctAnswer then
                        Correct
                     else
                        Wrong
                    )
                ]
                [ text alternaltive ]
        )
        alternaltives


viewSessionInformation : Model -> Html Msg
viewSessionInformation model =
    div [ id "stats" ]
        [ h5 [] [ text ("Correct: " ++ (toString (List.length model.correctQuestions))) ]
        , h5 [] [ text ("Wrong: " ++ (toString (List.length model.wrongQuestions))) ]
        , h5 [] [ text ("Left: " ++ (toString (List.length model.unAnsweredQuestions))) ]
        , h5 [] [ text ("Total: " ++ (toString (List.length model.questions))) ]
        ]
