module Lmq.View exposing (root)

import Lmq.Types exposing (..)
import Html exposing (..)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (type_, checked, name, disabled, value, class, src, id, selected, for, href)
import Util exposing (onEnter, viewErrorBox, viewSpinningLoader, viewProgressbar)
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
                        viewLandmarkQuestion model currentQuestion

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


viewLandmarkQuestion : Model -> LandmarkQuestion -> Html Msg
viewLandmarkQuestion model lmq =
    div [ class "landmark-question" ]
        [ h3 [] [ text lmq.question ]
        , viewCanvas model
        , button [ class "btn", onClick model.clickData.answerMsg ] [ text "Submit" ]
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
                        (createDrawImage canvas) :: model.clickData.draw
            else
                model.clickData.draw
    in
        case model.image of
            GotCanvas canvas ->
                Canvas.initialize canvasSize
                    |> Canvas.batch
                        ((createDrawImage canvas)
                            :: drawOps
                        )
                    |> Canvas.toHtml [ Events.onClick CanvasClick ]
                    |> List.singleton
                    |> div []

            Loading ->
                viewSpinningLoader


createDrawImage : Canvas -> Canvas.DrawOp
createDrawImage canvas =
    DrawImage canvas (Scaled (Point.fromInts ( 0, 0 )) canvasSize)
