module Lmq.State exposing (init, update, subscriptions)

import Lmq.Types exposing (..)
import Lmq.Rest exposing (getLandmarkQuestions)
import Random
import Random.List exposing (shuffle)
import Time
import Util exposing (delay)
import Task
import Canvas
import App.Rest exposing (base_url)
import Canvas exposing (Size, Error, DrawOp(..), DrawImageParams(..), Canvas)
import Canvas.Point exposing (Point)
import Canvas.Point as Point
import Canvas.Pixel as Pixel
import Color.Convert
import Color


init : ( Model, Cmd Msg )
init =
    let
        model =
            { questions = []
            , mode = Start
            , unAnsweredQuestions =
                []
            , wrongQuestions = []
            , correctQuestions = []
            , currentQuestion = Nothing
            , showAnswer = False
            , numberOfQuestionsInputField = "0"
            , error = Nothing
            , seed = Random.initialSeed 986579348465945786
            , image = Loading
            , solution = Loading
            , clickData = initClickData
            }
    in
        model ! [ getLandmarkQuestions ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleShowAnswer ->
            ( { model | showAnswer = not model.showAnswer }, Cmd.none )

        StartQuiz number ->
            let
                ( shuffeledQuestions, seed ) =
                    Random.step (shuffle model.questions) model.seed

                ( h, t ) =
                    case (List.take number shuffeledQuestions) of
                        [] ->
                            ( Nothing, [] )

                        h :: t ->
                            ( Just h, t )
            in
                ( { model
                    | unAnsweredQuestions = t
                    , currentQuestion =
                        h
                    , correctQuestions = []
                    , wrongQuestions = []
                    , seed = seed
                    , mode = Running
                  }
                , Cmd.batch (getListOfLoadImageMessages h)
                )

        NextQuestion ->
            let
                nextModel =
                    nextQuestion model
            in
                ( nextModel, Cmd.none )

        Correct ->
            let
                nextModel =
                    nextQuestion model
            in
                ( case model.currentQuestion of
                    Nothing ->
                        nextModel

                    Just question ->
                        { nextModel
                            | correctQuestions = question :: model.correctQuestions
                        }
                , Cmd.batch (getListOfLoadImageMessages nextModel.currentQuestion)
                )

        Wrong ->
            let
                nextModel =
                    nextQuestion model
            in
                ( case model.currentQuestion of
                    Nothing ->
                        nextModel

                    Just question ->
                        { nextModel
                            | wrongQuestions = question :: model.wrongQuestions
                        }
                , Cmd.batch (getListOfLoadImageMessages nextModel.currentQuestion)
                )

        GetLandmarkQuestions ->
            ( model, getLandmarkQuestions )

        SetLandmarkQuestions (Ok questions) ->
            ( { model | questions = questions }, Cmd.none )

        SetLandmarkQuestions (Err _) ->
            ( model, Cmd.none )

        NumberOfQuestionsInput number ->
            ( { model | numberOfQuestionsInputField = number }, Cmd.none )

        SetError error ->
            ( { model | error = Just error }, (delay (Time.second * 5) <| ClearError) )

        ClearError ->
            ( { model | error = Nothing }, Cmd.none )

        ChangeMode mode ->
            ( { model | mode = mode }, Cmd.none )

        ImageLoaded result ->
            case Result.toMaybe result of
                Just canvas ->
                    ( { model | image = GotCanvas canvas }
                    , Cmd.none
                    )

                Nothing ->
                    ( { model | image = Loading }
                    , (case model.currentQuestion of
                        Nothing ->
                            Cmd.none

                        Just lmq ->
                            loadImage lmq.original_image
                      )
                    )

        SolutionLoaded result ->
            case Result.toMaybe result of
                Just canvas ->
                    ( { model | solution = GotCanvas canvas }
                    , Cmd.none
                    )

                Nothing ->
                    ( { model | solution = Loading }
                    , (case model.currentQuestion of
                        Nothing ->
                            Cmd.none

                        Just lmq ->
                            loadSolution lmq.landmark_drawing
                      )
                    )

        CanvasClick position ->
            let
                color =
                    getColorFromRegion model

                ( p0, p1, p2, p3 ) =
                    getCoordinatesForCross position

                answerMsg =
                    Debug.log "Color"
                        (checkAnswer
                            model
                            position
                        )

                newDraw =
                    [ BeginPath
                    , LineWidth 5
                    , StrokeStyle color
                    , LineCap "round"
                    , MoveTo p0
                    , LineTo p1
                    , MoveTo p2
                    , LineTo p3
                    , Stroke
                    ]

                clickData =
                    { draw = newDraw
                    , color = color
                    , answerMsg = answerMsg
                    }
            in
                ( { model | clickData = clickData }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


nextQuestion : Model -> Model
nextQuestion model =
    { model
        | currentQuestion = (List.head model.unAnsweredQuestions)
        , unAnsweredQuestions =
            case List.tail model.unAnsweredQuestions of
                Nothing ->
                    []

                Just tail ->
                    tail
        , clickData = initClickData
    }


getListOfLoadImageMessages : Maybe LandmarkQuestion -> List (Cmd Msg)
getListOfLoadImageMessages lmq =
    [ (case lmq of
        Nothing ->
            Cmd.none

        Just question ->
            loadImage question.original_image
      )
    , (case lmq of
        Nothing ->
            Cmd.none

        Just question ->
            loadSolution question.landmark_drawing
      )
    ]


loadImage : String -> Cmd Msg
loadImage image_url =
    Task.attempt
        ImageLoaded
        (Canvas.loadImage (base_url ++ image_url))


loadSolution : String -> Cmd Msg
loadSolution image_url =
    Task.attempt
        SolutionLoaded
        (Canvas.loadImage (base_url ++ image_url))


getCoordinatesForCross : Point -> ( Point, Point, Point, Point )
getCoordinatesForCross point =
    let
        size =
            10

        ( x, y ) =
            Point.toInts point

        p0 =
            Point.fromInts ( x - size, y - size )

        p1 =
            Point.fromInts ( x + size, y + size )

        p2 =
            Point.fromInts ( x - size, y + size )

        p3 =
            Point.fromInts ( x + size, y - size )
    in
        ( p0, p1, p2, p3 )


getColorFromRegion : Model -> Color.Color
getColorFromRegion model =
    case model.currentQuestion of
        Nothing ->
            wrongColor

        Just lmq ->
            (case List.head lmq.landmark_regions of
                Nothing ->
                    wrongColor

                Just region ->
                    (case Color.Convert.hexToColor region.color of
                        Ok color ->
                            color

                        Err errorMsg ->
                            wrongColor
                    )
            )


checkAnswer : Model -> Point -> Msg
checkAnswer model point =
    let
        pixelColor =
            (case model.solution of
                Loading ->
                    wrongColor

                GotCanvas canvas ->
                    Canvas.initialize canvasSize
                        |> Canvas.batch [ DrawImage canvas (Scaled (Point.fromInts ( 0, 0 )) canvasSize) ]
                        |> Pixel.get point
            )
    in
        if pixelColor == (wrongColor) then
            Wrong
        else
            Correct
