module Mcq.View exposing (root)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (type_, checked, name, value, class, src, id, href, style)
import Mcq.Types exposing (..)
import App.Rest exposing (base_url)
import Util exposing (onEnter, viewErrorBox, viewProgressbar)


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
                            [ viewProgressbar (percentageOfQuestionsLeft model)
                            , viewMultipleChoiceQuestion
                                currentQuestion
                            ]

            Result ->
                text "result"
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
        , div [ class "row" ] (viewMultipleChoiceQuestionAlternaltives mcq.answers mcq.correct)
        ]


viewMultipleChoiceQuestionAlternaltives : List String -> Int -> List (Html Msg)
viewMultipleChoiceQuestionAlternaltives alternaltives correctAnswer =
    List.indexedMap
        (\i alternaltive ->
            div [ class "col s12 m6 l3" ]
                [ button
                    [ class "btn indigo lighten-5 black-text"
                    , style [ ( "width", "100%" ) ]
                    , onClick
                        (if i == correctAnswer then
                            Correct
                         else
                            Wrong
                        )
                    ]
                    [ text alternaltive ]
                ]
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


percentageOfQuestionsLeft : Model -> Float
percentageOfQuestionsLeft model =
    let
        unAnswered =
            toFloat (List.length model.unAnsweredQuestions) + 1

        correct =
            toFloat (List.length model.correctQuestions)

        wrong =
            toFloat (List.length model.wrongQuestions)
    in
        100 - (100 * (unAnswered / (unAnswered + correct + wrong)))
