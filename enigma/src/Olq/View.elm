module Olq.View exposing (root)

import Types exposing (..)
import Olq.Types exposing (..)
import Html exposing (..)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (type_, checked, name, disabled, value, class, src, id, selected, for, href)
import Util exposing (onEnter, viewErrorBox, viewSpinningLoader, viewProgressbar, percentageOfQuestionsLeft, calculateImageSize, createDrawImage)
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
                            , viewOutlineQuestion model currentQuestion
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


viewOutlineQuestion : Model -> OutlineQuestion -> Html Msg
viewOutlineQuestion model olq =
    div [ class "col s12" ]
        ([ h3 [] [ text "" ]
         , viewCanvas model
         ]
            ++ (case model.showAnswer of
                    False ->
                        [ button [ class "btn", onClick Wrong ] [ text "Submit" ]
                        , button [ class "btn red", onClick Clear ] [ text "Clear" ]
                        ]

                    True ->
                        [ button [ class "btn disabled" ] [ text "Submit" ]
                        , button [ class "btn disabled" ] [ text "Clear" ]
                        ]
               )
        )


viewCanvas : Model -> Html Msg
viewCanvas model =
    let
        drawOps =
            if model.showAnswer then
                case model.solution of
                    Loading ->
                        model.drawData.drawOps

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
                            (createDrawImage canvas canvasSize) :: model.drawData.drawOps
            else
                model.drawData.drawOps
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
                                    case model.draw of
                                        False ->
                                            Canvas.toHtml
                                                [ Events.onMouseDown MouseDown
                                                , Events.onTouchStart Olq.Types.Touch
                                                , Events.onTouchMove Olq.Types.Touch
                                                , Events.onTouchEnd Olq.Types.Touch
                                                , Events.onTouchCancel Olq.Types.Touch
                                                ]

                                        True ->
                                            Canvas.toHtml
                                                [ Events.onMouseMove MouseMove
                                                , Events.onMouseUp MouseUp
                                                ]

                                True ->
                                    Canvas.toHtml []
                           )

            Loading ->
                viewSpinningLoader


viewResult : Model -> Html Msg
viewResult model =
    div []
        [ h3 [] [ text "Results" ]
        , h5 [] [ text ("Correct: " ++ (toString (List.length model.correctQuestions))) ]
        , h5 [] [ text ("Wrong: " ++ (toString (List.length model.wrongQuestions))) ]
        , button [ class "btn", onClick (ChangeMode Start) ] [ text "Start new quiz" ]
        ]
