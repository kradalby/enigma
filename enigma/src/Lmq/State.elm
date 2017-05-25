module Lmq.State exposing (init, update, subscriptions)

import Types exposing (..)
import Lmq.Types exposing (..)
import Lmq.Rest exposing (getLandmarkQuestions)
import Random
import Random.List exposing (shuffle)
import Time
import Util exposing (delay, calculateImageSize)
import Task
import Canvas
import App.Rest exposing (base_url)
import Canvas exposing (Size, Error, DrawOp(..), DrawImageParams(..), Canvas)
import Canvas.Point exposing (Point)
import Canvas.Point as Point
import Canvas.Pixel as Pixel
import Color.Convert
import Color
import LocalStorage


init : Int -> Int -> Int -> ( Model, Cmd Msg )
init initialSeed width height =
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
            , numberOfQuestionsInputField = ""
            , error = Nothing
            , seed = Random.initialSeed initialSeed
            , image = Loading
            , imageSize = Nothing
            , solution = Loading
            , clickData = initClickData
            , windowWidth = width
            , windowHeight = height
            , score = Types.initQuestionScore
            , showNewHighScore = False
            , imageMode = All
            }
    in
        model ! [ getLandmarkQuestions, getFromStorage ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleShowAnswer ->
            ( { model | showAnswer = not model.showAnswer }, Cmd.none )

        StartQuiz number ->
            let
                ( shuffeledQuestions, seed ) =
                    Random.step (shuffle (getQuestions model)) model.seed

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
                        let
                            s =
                                model.score

                            ( best, newHighScore ) =
                                if s.best < ((List.length model.correctQuestions) * Types.pointBase) then
                                    ( ((List.length model.correctQuestions) * Types.pointBase), True )
                                else
                                    ( s.best, False )

                            score =
                                { s
                                    | correct = model.score.correct + (List.length model.correctQuestions)
                                    , wrong = model.score.wrong + (List.length model.wrongQuestions)
                                    , best = best
                                }
                        in
                            ( { nextModel | showAnswer = False, mode = Result, score = score, showNewHighScore = newHighScore }, Cmd.batch [ (saveToStorage score) ] )

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
            , (delay (Time.second * showAnswerDelay) <| NextQuestion)
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
            , (delay (Time.second * showAnswerDelay) <| NextQuestion)
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
            ( { model | error = Just error }, (delay (Time.second * errorMessageDelay) <| ClearError) )

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

        Noop ->
            ( model, Cmd.none )

        Load string ->
            let
                qs =
                    Types.decodeQuestionScore string
            in
                ( { model | score = qs }, Cmd.none )

        ToggleShowNewHighScore ->
            ( { model | showNewHighScore = not model.showNewHighScore }, Cmd.none )

        ChangeImageMode imageMode ->
            ( { model | imageMode = imageMode }, Cmd.none )


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
                            |> Canvas.batch [ DrawImage canvas (Scaled (Point.fromInts ( 0, 0 )) canvasSize) ]
                            |> Pixel.get point
            )
    in
        if pixelColor == (wrongColor) then
            Wrong
        else
            Correct


getFromStorage : Cmd Msg
getFromStorage =
    LocalStorage.get "enigma-lmq"
        |> Task.attempt
            (\result ->
                case result of
                    Ok v ->
                        Load (Maybe.withDefault "" v)

                    Err _ ->
                        Load ""
            )


saveToStorage : Types.QuestionScore -> Cmd Msg
saveToStorage qs =
    LocalStorage.set "enigma-lmq" (Types.encodeQuestionScore qs)
        |> Task.attempt (always Noop)
