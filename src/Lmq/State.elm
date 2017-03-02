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
import Canvas.Events as Events
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
                -- , wrongQuestions = []
                -- , correctQuestions = []
            , currentQuestion = Nothing
            , showAnswer = False
            , numberOfQuestionsInputField = "0"
            , error = Nothing
            , seed = Random.initialSeed 986579348465945786
            , image = Loading
            , solution = Loading
            , draw = []
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

                -- shuffle model.questions
            in
                ( { model
                    | unAnsweredQuestions = t
                    , currentQuestion =
                        h
                        -- , correctQuestions = []
                        -- , wrongQuestions = []
                    , seed = seed
                    , mode = Running
                  }
                , Cmd.batch
                    [ (case h of
                        Nothing ->
                            Cmd.none

                        Just question ->
                            loadImage question.original_image
                      )
                    , if model.showAnswer then
                        (case h of
                            Nothing ->
                                Cmd.none

                            Just question ->
                                loadSolution question.landmark_drawing
                        )
                      else
                        Cmd.none
                    ]
                )

        NextQuestion ->
            let
                nextModel =
                    nextQuestion model
            in
                ( nextModel, Cmd.none )

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
                    (case model.currentQuestion of
                        Nothing ->
                            Color.rgb 0 0 0

                        Just lmq ->
                            (case List.head lmq.landmark_regions of
                                Nothing ->
                                    Color.rgb 0 0 0

                                Just region ->
                                    (case Color.Convert.hexToColor region.color of
                                        Ok color ->
                                            color

                                        Err errorMsg ->
                                            Color.rgb 0 0 0
                                    )
                            )
                    )

                ( x, y ) =
                    Point.toInts position

                p0 =
                    Point.fromInts ( x - 10, y - 10 )

                p1 =
                    Point.fromInts ( x + 10, y + 10 )

                p2 =
                    Point.fromInts ( x - 10, y + 10 )

                p3 =
                    Point.fromInts ( x + 10, y - 10 )

                newDraw =
                    [ BeginPath
                    , LineWidth 5
                    , StrokeStyle color
                    , LineCap "round"
                    , MoveTo p0
                    , LineTo p1
                    , Stroke
                    , BeginPath
                    , LineWidth 5
                    , LineCap "round"
                    , MoveTo p2
                    , LineTo p3
                    , Stroke
                    ]
            in
                ( { model | draw = newDraw }, Cmd.none )


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
    }


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
