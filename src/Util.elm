module Util exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Decode exposing (Decoder, int, string, list, nullable)
import Process
import Time exposing (..)
import Task
import Canvas exposing (Size, Error, DrawOp(..), DrawImageParams(..), Canvas)
import Canvas.Point exposing (Point)
import Canvas.Point as Point


-- Listen for enter


onEnter : msg -> Attribute msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.Decode.succeed msg
            else
                Json.Decode.fail "not ENTER"
    in
        on "keydown" (Json.Decode.andThen isEnter keyCode)


radio : String -> String -> Bool -> msg -> Html msg
radio labelName groupName isSelected msg =
    label []
        [ input [ type_ "radio", checked isSelected, name groupName, onClick msg ] []
        , text labelName
        ]


delay : Time -> msg -> Cmd msg
delay time msg =
    Process.sleep time
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


viewErrorBox : String -> Html msg
viewErrorBox errorString =
    div [ class "card-panel red lighten-1" ]
        [ span [ class "bold" ] [ text "Error: " ]
        , text errorString
        ]


viewSpinningLoader : Html msg
viewSpinningLoader =
    div [ class "preloader-wrapper active" ]
        [ div [ class "spinner-layer spinner-blue" ]
            [ div [ class "circle-clipper left" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "gap-patch" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "circle-clipper right" ]
                [ div [ class "circle" ]
                    []
                ]
            ]
        , div [ class "spinner-layer spinner-red" ]
            [ div [ class "circle-clipper left" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "gap-patch" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "circle-clipper right" ]
                [ div [ class "circle" ]
                    []
                ]
            ]
        , div [ class "spinner-layer spinner-yellow" ]
            [ div [ class "circle-clipper left" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "gap-patch" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "circle-clipper right" ]
                [ div [ class "circle" ]
                    []
                ]
            ]
        , div [ class "spinner-layer spinner-green" ]
            [ div [ class "circle-clipper left" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "gap-patch" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "circle-clipper right" ]
                [ div [ class "circle" ]
                    []
                ]
            ]
        ]


viewProgressbar : Float -> Html msg
viewProgressbar percentage =
    div [ class "progress" ]
        [ div [ class "determinate", attribute "style" ("width: " ++ (toString percentage) ++ "%") ]
            []
        ]


calculateImageSize : Int -> Int -> Int -> Int -> Size
calculateImageSize imageWidth imageHeight windowWidth windowHeight =
    let
        aspectRatioWidthHeight =
            (toFloat imageWidth) / (toFloat imageHeight)

        aspectRatioHeightWidth =
            (toFloat imageHeight) / (toFloat imageWidth)

        ( canvasHeight, canvasWidth ) =
            if windowWidth > windowHeight then
                let
                    canvasHeight =
                        Basics.min (toFloat imageHeight) ((toFloat windowHeight) * 0.53)

                    canvasWidth =
                        canvasHeight * aspectRatioWidthHeight
                in
                    ( canvasHeight, canvasWidth )
            else
                let
                    canvasWidth =
                        Basics.min (toFloat imageWidth) ((toFloat windowWidth) * 0.9)

                    canvasHeight =
                        canvasWidth * aspectRatioHeightWidth
                in
                    ( canvasHeight, canvasWidth )
    in
        Size (round canvasWidth) (round canvasHeight)


createDrawImage : Canvas -> Size -> Canvas.DrawOp
createDrawImage canvas canvasSize =
    DrawImage canvas (Scaled (Point.fromInts ( 0, 0 )) canvasSize)


percentageOfQuestionsLeft : Bool -> Maybe a -> List a -> List a -> List a -> Float
percentageOfQuestionsLeft showAnswer currentQuestion unAnsweredQuestions correctQuestions wrongQuestions =
    let
        current =
            case currentQuestion of
                Nothing ->
                    0

                Just _ ->
                    1

        unAnswered =
            case showAnswer of
                False ->
                    toFloat (List.length unAnsweredQuestions)

                True ->
                    toFloat (List.length unAnsweredQuestions - 1)

        correct =
            case showAnswer of
                False ->
                    toFloat (List.length correctQuestions)

                True ->
                    toFloat (List.length correctQuestions)

        wrong =
            case showAnswer of
                False ->
                    toFloat (List.length wrongQuestions)

                True ->
                    toFloat (List.length wrongQuestions)
    in
        (100 * ((correct + wrong) / (unAnswered + correct + wrong + current)))
