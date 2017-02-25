module Mcq.View exposing (root)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (type_, checked, name, disabled, value, class, src, id, selected, for, href)
import Mcq.Types exposing (..)
import App.Rest exposing (base_url)


root : Model -> Html Msg
root model =
    div []
        [ a [ onClick (StartQuiz 1) ] [ text "start" ]
        , a [ onClick NextQuestion ] [ text "next" ]
        , a [ onClick GetMultipleChoiceQuestions ] [ text "fetch questions" ]
        , case model.currentQuestion of
            Nothing ->
                p [] [ text "No current question" ]

            Just currentQuestion ->
                viewMultipleChoiceQuestion currentQuestion
        , viewSessionInformation model
        ]


viewMultipleChoiceQuestion : MultipleQuestion -> Html Msg
viewMultipleChoiceQuestion mcq =
    div [ class "multiple-choice-question" ]
        [ h2 [] [ text mcq.question ]
        , case mcq.image of
            Just image ->
                img [ src (base_url ++ image) ] []

            Nothing ->
                p [] []
        , case mcq.video of
            Just video ->
                -- This should be a video tag
                img [ src (base_url ++ video) ] []

            Nothing ->
                p [] []
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
