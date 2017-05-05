module Olq.View exposing (root)

import Types exposing (..)
import Olq.Types exposing (..)
import Html exposing (..)
import Html.Events exposing (onInput, onClick)
import Html.Attributes
    exposing
        ( type_
        , checked
        , name
        , disabled
        , value
        , class
        , src
        , id
        , selected
        , for
        , href
        , attribute
        , style
        , placeholder
        )
import Util
    exposing
        ( onEnter
        , viewErrorBox
        , viewSpinningLoader
        , viewProgressbar
        , percentageOfQuestionsLeft
        , calculateImageSize
        , createDrawImage
        , viewNewHighScore
        )
import Canvas exposing (Size, Error, DrawOp(..), DrawImageParams(..), Canvas)
import Canvas.Events as Events
import Canvas.Point as Point
import Color


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
                            [ viewProgressbar (percentageOfQuestionsLeft model.showAnswer model.currentQuestion model.unAnsweredQuestions model.answeredQuestions [])
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
            [ class "btn-large"
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
                (\n -> button [ class "btn-large", onClick <| StartQuiz n ] [ text <| toString n ])
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


getFirstOutlineRegionNameFromCurrentQuestion : Model -> String
getFirstOutlineRegionNameFromCurrentQuestion model =
    case model.currentQuestion of
        Nothing ->
            ""

        Just question ->
            case question.outline_regions of
                [] ->
                    ""

                hd :: tl ->
                    hd.name


viewOutlineQuestion : Model -> OutlineQuestion -> Html Msg
viewOutlineQuestion model olq =
    div [ class "col s12 center-align" ]
        ([ h5 [] [ text <| "Outline: " ++ (getFirstOutlineRegionNameFromCurrentQuestion model) ]
         , viewCanvas model
         ]
            ++ (case model.showAnswer of
                    False ->
                        [ div [ class "center-align container" ]
                            [ button [ class "btn-large overridepink col s6 btn-large-no-margin", onClick ToggleZoomMode ]
                                (case model.zoomMode of
                                    False ->
                                        [ i [ attribute "aria-hidden" "true", class "fa fa-search" ]
                                            []
                                        , text " Zoom off"
                                        ]

                                    True ->
                                        [ i [ attribute "aria-hidden" "true", class "fa fa-search" ]
                                            []
                                        , text " Zoom on"
                                        ]
                                )
                            , button [ class "btn-large col s6 btn-large-no-margin", onClick CalculateScore ] [ i [ attribute "aria-hidden" "true", class "fa fa-paper-plane-o" ] [], text " Submit" ]
                            , button [ class "btn-large overrideblue col s6 btn-large-no-margin", onClick Undo ] [ i [ attribute "aria-hidden" "true", class "fa fa-undo" ] [], text " Undo" ]
                            , button [ class "btn-large overridered col s6 btn-large-no-margin", onClick Clear ] [ i [ attribute "aria-hidden" "true", class "fa fa-eraser" ] [], text " Clear" ]
                            ]
                        ]

                    True ->
                        [ div [ class "center-align container" ]
                            [ button [ class "btn-large disabled col s6 btn-large-no-margin" ] [ i [ attribute "aria-hidden" "true", class "fa fa-search" ] [], text " Zoom on" ]
                            , button [ class "btn-large disabled col s6 btn-large-no-margin" ] [ i [ attribute "aria-hidden" "true", class "fa fa-paper-plane-o" ] [], text " Submit" ]
                            , button [ class "btn-large disabled col s6 btn-large-no-margin" ] [ i [ attribute "aria-hidden" "true", class "fa fa-undo" ] [], text " Undo" ]
                            , button [ class "btn-large disabled col s6 btn-large-no-margin" ] [ i [ attribute "aria-hidden" "true", class "fa fa-eraser" ] [], text " Clear" ]
                            ]
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
            (if model.showAnswer then
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
            )
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

                    doubleClickEventListener =
                        Events.onMultiTouchStart
                            { stopPropagation = model.oneDoubleFingerTap
                            , preventDefault = model.oneDoubleFingerTap
                            }
                            TouchTwoFingerDoubleTap

                    zoomModeChangeDrawOps =
                        case model.zoomInfoModal of
                            True ->
                                case model.zoomMode of
                                    True ->
                                        modeTextOnCanvas "Zoom mode" canvasSize

                                    False ->
                                        modeTextOnCanvas "Draw mode" canvasSize

                            False ->
                                []
                in
                    Canvas.initialize canvasSize
                        |> Canvas.batch
                            ((createDrawImage canvas canvasSize)
                                :: drawOps
                                ++ zoomModeChangeDrawOps
                            )
                        |> (case model.showAnswer of
                                False ->
                                    case model.zoomMode of
                                        False ->
                                            case model.draw of
                                                False ->
                                                    Canvas.toHtml
                                                        [ doubleClickEventListener
                                                        , Events.onMouseDown MouseDown
                                                        , Events.onMultiTouchStart touchOptions TouchDown
                                                        ]

                                                True ->
                                                    Canvas.toHtml
                                                        [ doubleClickEventListener
                                                        , Events.onMouseMove MouseMove
                                                        , Events.onMouseUp MouseUp
                                                        , Events.onMultiTouchMove touchOptions TouchMove
                                                        , Events.onMultiTouchEnd touchOptions TouchUp
                                                        , Events.onMultiTouchCancel touchOptions TouchUp
                                                        ]

                                        True ->
                                            Canvas.toHtml
                                                [ doubleClickEventListener
                                                ]

                                True ->
                                    Canvas.toHtml []
                           )

            Loading ->
                viewSpinningLoader


viewResult : Model -> Html Msg
viewResult model =
    div [ class "center-align" ]
        [ h3 [] [ text "Results" ]
        , case model.showNewHighScore of
            True ->
                viewNewHighScore (List.sum model.scores) ToggleShowNewHighScore

            False ->
                text ""
        , h5 [] [ text ("Correct: " ++ (toString (List.length (List.filter (\s -> s > Types.olqCorrectThreshold) model.scores)))) ]
        , h5 [] [ text ("Wrong: " ++ (toString (List.length (List.filter (\s -> s < Types.olqCorrectThreshold) model.scores)))) ]
        , h5 [] [ text ("Score: " ++ (toString (List.sum model.scores))) ]
        , div [ class "row" ] []
        , div [ class "row" ] []
        , div [ class "row" ] []
        , div [ class "row" ] []
        , button [ class "btn btn-large s12", onClick (ChangeMode Start) ] [ text "Start new quiz" ]
        ]


modeTextOnCanvas : String -> Size -> List DrawOp
modeTextOnCanvas message size =
    let
        drawopSettings =
            [ Font "20px Arial"
            , FillStyle (Color.rgba 255 255 255 1)
            ]

        drawops =
            List.foldl
                (\y acc ->
                    (List.foldl
                        (\x acc2 ->
                            if (x % 150 == 0) && (y % 50 == 0) then
                                FillText message (Point.fromInts ( x, y )) :: acc2
                            else
                                acc2
                        )
                        []
                        (List.range 0 size.width)
                    )
                        ++ acc
                )
                []
                (List.range 0 size.height)
    in
        drawopSettings ++ drawops
