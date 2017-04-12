module Lmq.View exposing (root)

import Types exposing (..)
import Lmq.Types exposing (..)
import Html exposing (..)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (type_, checked, name, disabled, value, class, src, id, selected, for, href)
import Util exposing (onEnter, viewErrorBox, viewSpinningLoader, viewProgressbar, calculateImageSize)
import Canvas exposing (Size, Error, DrawOp(..), DrawImageParams(..), Canvas)
import Canvas.Point exposing (Point)
import Canvas.Point as Point
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
                            [ viewProgressbar (percentageOfQuestionsLeft model)
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
    div []
        [ h3
            []
            [ text "How many questions?" ]
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


viewLandmarkQuestion : Model -> LandmarkQuestion -> Html Msg
viewLandmarkQuestion model lmq =
    div [ class "col s12" ]
        [ h3 [] [ text lmq.question ]
        , div [ class "row" ] [ viewCanvas model ]
        , (case model.showAnswer of
            False ->
                button [ class "btn", onClick model.clickData.answerMsg ] [ text "Submit" ]

            True ->
                button [ class "btn disabled" ] [ text "Submit" ]
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

                            derp =
                                Debug.log "canvasSize solution" canvasSize
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

                    derp =
                        Debug.log "canvasSize image" canvasSize
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


createDrawImage : Canvas -> Size -> Canvas.DrawOp
createDrawImage canvas canvasSize =
    DrawImage canvas (Scaled (Point.fromInts ( 0, 0 )) canvasSize)


viewResult : Model -> Html Msg
viewResult model =
    div []
        [ h3 [] [ text "Results" ]
        , h5 [] [ text ("Correct: " ++ (toString (List.length model.correctQuestions))) ]
        , h5 [] [ text ("Wrong: " ++ (toString (List.length model.wrongQuestions))) ]
        , button [ class "btn", onClick (ChangeMode Start) ] [ text "Start new quiz" ]
        ]


percentageOfQuestionsLeft : Model -> Float
percentageOfQuestionsLeft model =
    let
        current =
            case model.currentQuestion of
                Nothing ->
                    0

                Just _ ->
                    1

        unAnswered =
            case model.showAnswer of
                False ->
                    toFloat (List.length model.unAnsweredQuestions)

                True ->
                    toFloat (List.length model.unAnsweredQuestions - 1)

        correct =
            case model.showAnswer of
                False ->
                    toFloat (List.length model.correctQuestions)

                True ->
                    toFloat (List.length model.correctQuestions)

        wrong =
            case model.showAnswer of
                False ->
                    toFloat (List.length model.wrongQuestions)

                True ->
                    toFloat (List.length model.wrongQuestions)
    in
        (100 * ((correct + wrong) / (unAnswered + correct + wrong + current)))
