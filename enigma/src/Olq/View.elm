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


viewOutlineQuestion : Model -> OutlineQuestion -> Html Msg
viewOutlineQuestion model olq =
    div [ class "col s12" ]
        ([ h3 [] [ text "" ]
         , viewCanvas model
         , i
            [ class "material-icons small"
            , onClick ToggleZoomMode
            ]
            [ text
                (case model.zoomMode of
                    True ->
                        "mode_edit"

                    False ->
                        "zoom_in"
                )
            ]
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
        touchOptions =
            { stopPropagation = True
            , preventDefault = True
            }

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
                                    case model.zoomMode of
                                        False ->
                                            case model.draw of
                                                False ->
                                                    Canvas.toHtml
                                                        [ Events.onMouseDown MouseDown
                                                        , Events.onTouchStart touchOptions MouseDown
                                                        ]

                                                True ->
                                                    Canvas.toHtml
                                                        [ Events.onMouseMove MouseMove
                                                        , Events.onMouseUp MouseUp
                                                        , Events.onTouchMove touchOptions MouseMove
                                                        , Events.onTouchEnd touchOptions MouseUp
                                                        , Events.onTouchCancel touchOptions MouseUp
                                                        ]

                                        True ->
                                            Canvas.toHtml []

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
