module Lmq.View exposing (root)

import Types exposing (..)
import Lmq.Types exposing (..)
import Html exposing (..)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (type_, checked, name, disabled, value, class, src, id, selected, for, href, placeholder, attribute)
import Util exposing (onEnter, viewErrorBox, viewSpinningLoader, viewProgressbar, calculateImageSize, percentageOfQuestionsLeft, createDrawImage, viewNewHighScore)
import Canvas exposing (Size, Error, DrawOp(..), DrawImageParams(..), Canvas)
import Canvas.Events as Events


root : Model -> Html Msg
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
                            , viewLandmarkQuestion model currentQuestion
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
    div [ class "center-align" ]
        [ h4
            []
            [ text "How many questions?" ]
        , input
            [ id "wordInput"
            , placeholder "Enter a number"
            , type_ "number"
            , onInput NumberOfQuestionsInput
            , value model.numberOfQuestionsInputField
            , onEnter (validateNumberOfQuestionsInputFieldAndCreateResponseMsg model)
            ]
            []
        , viewNumberOfQuestionButtons model
        , button
            [ class "btn-large overrideblue"
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
                (\n -> button [ class "btn-large overrideblue", onClick <| StartQuiz n ] [ text <| toString n ])
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


getFirstLandmarkRegionNameFromCurrentQuestion : Model -> String
getFirstLandmarkRegionNameFromCurrentQuestion model =
    case model.currentQuestion of
        Nothing ->
            ""

        Just question ->
            case question.landmark_regions of
                [] ->
                    ""

                hd :: tl ->
                    hd.name


viewLandmarkQuestion : Model -> LandmarkQuestion -> Html Msg
viewLandmarkQuestion model lmq =
    div [ class "col s12 center-align" ]
        [ h5 [] [ text <| "Mark the " ++ (getFirstLandmarkRegionNameFromCurrentQuestion model) ]
        , div [ class "row" ] [ viewCanvas model ]
        , (case model.showAnswer of
            False ->
                button [ class "btn-large overridegreen", onClick model.clickData.answerMsg ] [ i [ attribute "aria-hidden" "true", class "fa fa-paper-plane-o" ] [], text " Submit" ]

            True ->
                button [ class "btn-large disabled" ] [ i [ attribute "aria-hidden" "true", class "fa fa-paper-plane-o" ] [], text " Submit" ]
          )
        ]


viewCanvas : Model -> Html Msg
viewCanvas model =
    let
        drawOps =
            if model.showAnswer then
                case model.solution of
                    Loading ->
                        model.clickData.draw

                    GotCanvas canvas ->
                        let
                            imageSize =
                                case model.imageSize of
                                    Nothing ->
                                        Canvas.getSize canvas

                                    Just size ->
                                        size

                            canvasSize =
                                calculateImageSize imageSize.width imageSize.height model.windowWidth model.windowHeight
                        in
                            (createDrawImage canvas canvasSize) :: model.clickData.draw
            else
                model.clickData.draw
    in
        case model.image of
            GotCanvas canvas ->
                let
                    imageSize =
                        case model.imageSize of
                            Nothing ->
                                Canvas.getSize canvas

                            Just size ->
                                size

                    canvasSize =
                        calculateImageSize imageSize.width imageSize.height model.windowWidth model.windowHeight
                in
                    Canvas.initialize canvasSize
                        |> Canvas.batch
                            ((createDrawImage canvas canvasSize)
                                :: drawOps
                            )
                        |> (case model.showAnswer of
                                False ->
                                    Canvas.toHtml [ Events.onClick CanvasClick ]

                                True ->
                                    Canvas.toHtml []
                           )
                        |> List.singleton
                        |> div []

            Loading ->
                viewSpinningLoader


viewResult : Model -> Html Msg
viewResult model =
    div [ class "center-align" ]
        [ h3 [] [ text "Results" ]
        , case model.showNewHighScore of
            True ->
                viewNewHighScore ((List.length model.correctQuestions) * 100) ToggleShowNewHighScore

            False ->
                text ""
        , h5 [] [ text ("Correct: " ++ (toString (List.length model.correctQuestions))) ]
        , h5 [] [ text ("Wrong: " ++ (toString (List.length model.wrongQuestions))) ]
        , h5 [] [ text ("Score: " ++ (toString ((List.length model.correctQuestions) * 100))) ]
        , div [ class "row" ] []
        , div [ class "row" ] []
        , div [ class "row" ] []
        , div [ class "row" ] []
        , button [ class "btn btn-large s12 overrideblue", onClick (ChangeMode Start) ] [ text "Start new quiz" ]
        ]
