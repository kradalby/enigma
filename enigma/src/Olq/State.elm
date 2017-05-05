module Olq.State exposing (init, update, subscriptions)

import Types exposing (..)
import Olq.Types exposing (..)
import Olq.Rest exposing (getOutlineQuestions)
import Random
import Random.List exposing (shuffle)
import Time
import Util exposing (delay, calculateImageSize, createDrawImage)
import Task
import Canvas
import App.Rest exposing (base_url)
import Canvas exposing (Size, Error, DrawOp(..), DrawImageParams(..), Canvas)
import Canvas.Point exposing (Point)
import Canvas.Point as Point
import Color.Convert
import Color
import LocalStorage


init : Int -> Int -> Int -> ( Model, Cmd Msg )
init initialSeed width height =
    let
        model =
            { answeredQuestions = []
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
            , draw = False
            , zoomMode = True
            , scores = []
            , oneDoubleFingerTap = False
            , zoomInfoModal = False
            , score = initQuestionScore
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
                    , answeredQuestions = []
                    , scores = []
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

                            ( best, newBestCmd ) =
                                if s.best < ((List.sum model.scores)) then
                                    ( List.sum model.scores, Cmd.none )
                                else
                                    ( s.best, Cmd.none )

                            score =
                                { s
                                    | correct =
                                        model.score.correct
                                            + (List.length
                                                (List.filter
                                                    (\n -> n > Types.olqCorrectThreshold)
                                                    model.scores
                                                )
                                              )
                                    , wrong =
                                        model.score.wrong
                                            + (List.length
                                                (List.filter
                                                    (\n -> n < Types.olqCorrectThreshold)
                                                    model.scores
                                                )
                                              )
                                    , best = best
                                }
                        in
                            ( { nextModel | showAnswer = False, mode = Result, score = score }, Cmd.batch [ newBestCmd, (saveToStorage score) ] )

                    _ ->
                        ( { nextModel | showAnswer = False }, Cmd.batch (getListOfLoadImageMessages nextModel.currentQuestion) )

        CalculateScore ->
            ( case model.currentQuestion of
                Nothing ->
                    model

                Just question ->
                    { model
                        | answeredQuestions = question :: model.answeredQuestions
                        , scores = model.scores ++ [ (checkAnswer model) ]
                        , showAnswer = True
                    }
            , (delay (Time.second * showAnswerDelay) <| NextQuestion)
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

        TouchDown points ->
            case points of
                [] ->
                    ( model, Cmd.none )

                point :: [] ->
                    ( { model | draw = True }, Cmd.none )

                point :: tl ->
                    -- ( { model | draw = False, zoomMode = True }, Cmd.none )
                    case model.oneDoubleFingerTap of
                        True ->
                            ( { model
                                | zoomMode = not model.zoomMode
                                , oneDoubleFingerTap = False
                              }
                            , (delay (Time.millisecond * 0) <| ToggleZoomInfoModal)
                            )

                        False ->
                            ( { model | oneDoubleFingerTap = True }
                            , (delay (Time.millisecond * doubleTapDelay) <| SetOneDoubleFingerTap False)
                            )

        TouchUp points ->
            case points of
                [] ->
                    ( model, Cmd.none )

                point :: [] ->
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

                point :: tl ->
                    -- ( { model | draw = False, zoomMode = True }, Cmd.none )
                    case model.oneDoubleFingerTap of
                        True ->
                            ( { model
                                | zoomMode = not model.zoomMode
                                , oneDoubleFingerTap = False
                              }
                            , (delay (Time.millisecond * 0) <| ToggleZoomInfoModal)
                            )

                        False ->
                            ( { model | oneDoubleFingerTap = True }
                            , (delay (Time.millisecond * doubleTapDelay) <| SetOneDoubleFingerTap False)
                            )

        TouchMove points ->
            case points of
                [] ->
                    ( model, Cmd.none )

                point :: [] ->
                    let
                        -- debug =
                        --     Debug.log "Points" points
                        color =
                            getColorFromRegion model

                        newPoints =
                            model.drawData.currentPoints
                                ++ [ point ]

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

                point :: tl ->
                    -- ( { model | draw = False, zoomMode = True }, Cmd.none )
                    case model.oneDoubleFingerTap of
                        True ->
                            ( { model
                                | zoomMode = not model.zoomMode
                                , oneDoubleFingerTap = False
                              }
                            , (delay (Time.millisecond * 0) <| ToggleZoomInfoModal)
                            )

                        False ->
                            ( { model | oneDoubleFingerTap = True }
                            , (delay (Time.millisecond * doubleTapDelay) <| SetOneDoubleFingerTap False)
                            )

        TouchInit points ->
            case points of
                [] ->
                    ( model, Cmd.none )

                point :: [] ->
                    ( { model | draw = True, zoomMode = False }, Cmd.none )

                point :: tl ->
                    ( { model | draw = False, zoomMode = True }, Cmd.none )

        TouchTwoFingerDoubleTap points ->
            case points of
                [] ->
                    ( model, Cmd.none )

                point :: [] ->
                    ( { model | oneDoubleFingerTap = False }, Cmd.none )

                point :: tl ->
                    case model.oneDoubleFingerTap of
                        True ->
                            ( { model
                                | zoomMode = not model.zoomMode
                                , oneDoubleFingerTap = False
                              }
                            , (delay (Time.millisecond * 0) <| ToggleZoomInfoModal)
                            )

                        False ->
                            ( { model | oneDoubleFingerTap = True }
                            , (delay (Time.millisecond * doubleTapDelay) <| SetOneDoubleFingerTap False)
                            )

        SetOneDoubleFingerTap val ->
            ( { model | oneDoubleFingerTap = val }, Cmd.none )

        Clear ->
            ( { model | drawData = initDrawData }, Cmd.none )

        ToggleZoomMode ->
            ( { model | zoomMode = not model.zoomMode }, (delay (Time.millisecond * 0) <| ToggleZoomInfoModal) )

        Undo ->
            case model.drawData.points of
                [] ->
                    ( model, Cmd.none )

                hd :: tl ->
                    let
                        color =
                            getColorFromRegion model

                        lineDrawOps =
                            List.concat
                                (List.map
                                    (\pointList -> pointListToLineOperations pointList)
                                    (tl)
                                )

                        newDrawOps =
                            concatDrawOps color lineDrawOps
                    in
                        ( { model
                            | drawData =
                                { currentPoints = []
                                , drawOps = newDrawOps
                                , points = tl
                                }
                          }
                        , Cmd.none
                        )

        ToggleZoomInfoModal ->
            case model.zoomInfoModal of
                True ->
                    ( { model | zoomInfoModal = False }, Cmd.none )

                False ->
                    ( { model | zoomInfoModal = True }, (delay (Time.millisecond * doubleTapDelay) <| ToggleZoomInfoModal) )

        Noop ->
            ( model, Cmd.none )

        Load string ->
            let
                qs =
                    Types.decodeQuestionScore string
            in
                ( { model | score = qs }, Cmd.none )


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


checkAnswer : Model -> Int
checkAnswer model =
    let
        penalty =
            { upperCorrectPointAmount = 58
            , lowerCorrectPointAmount = 53
            , upperAbsolutePointAmount = 90
            , lowerAbsolutePointAmount = 20
            }

        distance : Point -> Point -> Float
        distance p1 p2 =
            let
                ( x1, y1 ) =
                    Point.toFloats p1

                ( x2, y2 ) =
                    Point.toFloats p2
            in
                sqrt
                    (((x2 - x1) ^ 2) + ((y2 - y1) ^ 2))

        correctPoints =
            (case model.solution of
                Loading ->
                    []

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
                            |> Canvas.batch [ (createDrawImage canvas canvasSize) ]
                            |> Canvas.getPopulatedPoints (Point.fromInts ( 0, 0 )) canvasSize
            )

        submittedPoints =
            (case model.solution of
                Loading ->
                    []

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
                            |> Canvas.batch model.drawData.drawOps
                            |> Canvas.getPopulatedPoints (Point.fromInts ( 0, 0 )) canvasSize
            )

        amountOfCorrectPoints =
            Debug.log "correctPoints length" <| List.length correctPoints

        amountOfSubmittedPoints =
            Debug.log "submittedPoints length" <| List.length submittedPoints

        pointAmountFactor =
            Debug.log "pointAmountFactor" <|
                toFloat (List.length correctPoints)
                    / toFloat (List.length submittedPoints)
                    * 100

        eucleadianScore =
            Debug.log "Euc score" <|
                if pointAmountFactor > penalty.upperAbsolutePointAmount then
                    100
                else if pointAmountFactor < penalty.lowerAbsolutePointAmount then
                    100
                else
                    ((List.foldl
                        (\point1 acc ->
                            (List.foldl
                                (\point2 current ->
                                    let
                                        dist =
                                            distance point1 point2
                                    in
                                        if current > dist then
                                            dist
                                        else
                                            current
                                )
                                900
                                correctPoints
                            )
                                + acc
                        )
                        0.0
                        submittedPoints
                     )
                        / toFloat (List.length submittedPoints)
                    )

        score =
            Debug.log "score" <|
                let
                    p =
                        if (penalty.upperAbsolutePointAmount > pointAmountFactor) && (pointAmountFactor > penalty.upperCorrectPointAmount) then
                            pointAmountFactor - penalty.upperCorrectPointAmount
                        else if (penalty.lowerAbsolutePointAmount < pointAmountFactor) && (pointAmountFactor < penalty.lowerCorrectPointAmount) then
                            penalty.lowerCorrectPointAmount
                        else
                            0

                    tempScore =
                        toFloat Types.pointBase
                            - eucleadianScore
                            - p
                in
                    if tempScore < 0 || tempScore > 100 then
                        0
                    else
                        tempScore
    in
        floor score


getFromStorage : Cmd Msg
getFromStorage =
    LocalStorage.get "enigma-olq"
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
    LocalStorage.set "enigma-olq" (Types.encodeQuestionScore qs)
        |> Task.attempt (always Noop)
