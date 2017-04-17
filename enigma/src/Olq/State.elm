module Olq.State exposing (init, update, subscriptions)

import Types exposing (..)
import Olq.Types exposing (..)
import Olq.Rest exposing (getOutlineQuestions)
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
import Color.Convert
import Color


init : Int -> Int -> Int -> ( Model, Cmd Msg )
init initialSeed width height =
    let
        model =
            { correctQuestions = []
            , color = Color.rgba 192 47 29 1
            , currentQuestion = Nothing
            , drawData = initDrawData
            , error = Nothing
            , image = Loading
            , imageSize = Nothing
            , mode = Start
            , numberOfQuestionsInputField = ""
            , questions = []
            , seed = Random.initialSeed initialSeed
            , showAnswer = False
            , solution = Loading
            , unAnsweredQuestions = []
            , windowHeight = height
            , windowWidth = width
            , wrongQuestions = []
            , draw = False
            }
    in
        model ! [ getOutlineQuestions ]


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
                case nextModel.currentQuestion of
                    Nothing ->
                        ( { nextModel | showAnswer = False, mode = Result }, Cmd.none )

                    _ ->
                        ( { nextModel | showAnswer = False }, Cmd.batch (getListOfLoadImageMessages nextModel.currentQuestion) )

        Correct ->
            ( case model.currentQuestion of
                Nothing ->
                    model

                Just question ->
                    { model
                        | correctQuestions = question :: model.correctQuestions
                        , showAnswer = True
                    }
            , (delay (Time.second * 3) <| NextQuestion)
            )

        Wrong ->
            ( case model.currentQuestion of
                Nothing ->
                    model

                Just question ->
                    { model
                        | wrongQuestions = question :: model.wrongQuestions
                        , showAnswer = True
                    }
            , (delay (Time.second * 3) <| NextQuestion)
            )

        GetOutlineQuestions ->
            ( model, getOutlineQuestions )

        SetOutlineQuestions (Ok questions) ->
            ( { model | questions = questions }, Cmd.none )

        SetOutlineQuestions (Err _) ->
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
                    ( { model
                        | image = GotCanvas canvas
                        , imageSize = Just (Canvas.getSize canvas)
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( { model | image = Loading }
                    , (case model.currentQuestion of
                        Nothing ->
                            Cmd.none

                        Just olq ->
                            loadImage olq.original_image
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

                        Just olq ->
                            loadSolution olq.outline_drawing
                      )
                    )

        MouseDown point ->
            ( { model | draw = True }, Cmd.none )

        MouseUp point ->
            let
                drawData =
                    model.drawData

                newDrawData =
                    { drawData
                        | points = model.drawData.currentPoints :: model.drawData.points
                        , currentPoints = []
                    }
            in
                ( { model
                    | draw = False
                    , drawData = newDrawData
                  }
                , Cmd.none
                )

        MouseMove point ->
            let
                color =
                    getColorFromRegion model

                newPoints =
                    model.drawData.currentPoints ++ [ point ]

                lineDrawOps =
                    List.concat
                        (List.map
                            (\pointList -> pointListToLineOperations pointList)
                            (newPoints :: model.drawData.points)
                        )

                newDrawOps =
                    concatDrawOps color lineDrawOps
            in
                ( { model
                    | drawData =
                        { currentPoints = newPoints
                        , drawOps = newDrawOps
                        , points = model.drawData.points
                        }
                  }
                , Cmd.none
                )

        Touch point ->
            let
                color =
                    getColorFromRegion model

                newPoints =
                    model.drawData.currentPoints ++ [ point ]

                lineDrawOps =
                    List.concat
                        (List.map
                            (\pointList -> pointListToLineOperations pointList)
                            (newPoints :: model.drawData.points)
                        )

                newDrawOps =
                    concatDrawOps color lineDrawOps
            in
                ( { model
                    | drawData =
                        { currentPoints = newPoints
                        , drawOps = newDrawOps
                        , points = model.drawData.points
                        }
                  }
                , Cmd.none
                )

        Clear ->
            ( { model | drawData = initDrawData }, Cmd.none )


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
        , drawData = initDrawData
    }


getListOfLoadImageMessages : Maybe OutlineQuestion -> List (Cmd Msg)
getListOfLoadImageMessages olq =
    [ (case olq of
        Nothing ->
            Cmd.none

        Just question ->
            loadImage question.original_image
      )
    , (case olq of
        Nothing ->
            Cmd.none

        Just question ->
            loadSolution question.outline_drawing
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


getColorFromRegion : Model -> Color.Color
getColorFromRegion model =
    case model.currentQuestion of
        Nothing ->
            model.color

        Just olq ->
            (case List.head olq.outline_regions of
                Nothing ->
                    model.color

                Just region ->
                    (case Color.Convert.hexToColor region.color of
                        Ok color ->
                            color

                        Err errorMsg ->
                            model.color
                    )
            )


pointListToLineOperations : List Point -> List DrawOp
pointListToLineOperations points =
    case points of
        [] ->
            []

        hd :: tl ->
            [ MoveTo hd ] ++ (List.map (\point -> LineTo point) tl)


concatDrawOps : Color.Color -> List DrawOp -> List DrawOp
concatDrawOps color drawOps =
    [ BeginPath
    , LineWidth 3
    , StrokeStyle color
    , LineCap "round"
    ]
        ++ drawOps
        ++ [ Stroke ]


checkAnswer : Model -> Point -> Msg
checkAnswer model point =
    Wrong
