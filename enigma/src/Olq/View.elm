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
        )
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


viewOutlineQuestion : Model -> OutlineQuestion -> Html Msg
viewOutlineQuestion model olq =
    div [ class "col s12 center-align" ]
        ([ h5 [] [ text "Outline: Tumor " ]
         , viewCanvas model
           --  , div [ class "pup-parent" ]
           --     [
           --     , case model.zoomInfoModal of
           --         True ->
           --             case model.imageSize of
           --                 Nothing ->
           --                     text ""
           --                 Just s ->
           --                     let
           --                         canvasSize =
           --                             calculateImageSize s.width s.height model.windowWidth model.windowHeight
           --                     in
           --                         case model.zoomMode of
           --                             False ->
           --                                 div [ class "pup-draw", style [ ( "height", (toString canvasSize.height) ++ "px" ), ( "width", (toString canvasSize.width) ++ "px" ) ] ] []
           --                             True ->
           --                                 div [ class "pup-zoom", style [ ( "height", (toString canvasSize.height) ++ "px" ), ( "width", (toString canvasSize.width) ++ "px" ) ] ] []
           --         False ->
           --             text ""
           --     ]
         ]
            ++ (case model.showAnswer of
                    False ->
                        [ div [ class "center-align container" ]
                            [ button [ class "btn-large pink col s6 btn-large-no-margin", onClick ToggleZoomMode ]
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
                            , button [ class "btn-large blue col s6 btn-large-no-margin", onClick Undo ] [ i [ attribute "aria-hidden" "true", class "fa fa-undo" ] [], text " Undo" ]
                            , button [ class "btn-large red col s6 btn-large-no-margin", onClick Clear ] [ i [ attribute "aria-hidden" "true", class "fa fa-eraser" ] [], text " Clear" ]
                            ]
                        ]

                    True ->
                        [ div []
                            [ button [ class "btn-large disabled col s6 btn-large-no-margin" ] [ text "Zoom" ]
                            , button [ class "btn-large disabled col s6 btn-large-no-margin" ] [ text "Submit" ]
                            , button [ class "btn-large disabled col s6 btn-large-no-margin" ] [ text "Undo" ]
                            , button [ class "btn-large disabled col s6 btn-large-no-margin" ] [ text "Clear" ]
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

                    doubleClickEventListener =
                        Events.onMultiTouchStart
                            { stopPropagation = model.oneDoubleFingerTap
                            , preventDefault = model.oneDoubleFingerTap
                            }
                            TouchTwoFingerDoubleTap
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
        , h5 [] [ text ("Wrong: " ++ (toString model.scores)) ]
        , div [ class "row" ] []
        , div [ class "row" ] []
        , div [ class "row" ] []
        , div [ class "row" ] []
        , button [ class "btn btn-large s12", onClick (ChangeMode Start) ] [ text "Start new quiz" ]
        ]
