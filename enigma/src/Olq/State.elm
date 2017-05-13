module Olq.State exposing (init, update, subscriptions)

import Types exposing (..)
import Olq.Types exposing (..)
import Olq.Rest exposing (getOutlineQuestions)
import Random
import Random.List exposing (shuffle)
import Time
import Util exposing (delay, calculateImageSize, createDrawImage, distancePoint)
import Task
import Canvas
import App.Rest exposing (base_url)
import Canvas exposing (Size, Error, DrawOp(..), DrawImageParams(..), Canvas)
import Canvas.Point exposing (Point)
import Canvas.Point as Point
import Color.Convert
import Color
import LocalStorage
import Olq.CanvasZoom as CanvasZoom


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
            , zoomMode = False
            , scores = []
            , oneDoubleFingerTap = False
            , zoomInfoModal = False
            , score = initQuestionScore
            , showNewHighScore = False
            , canvasZoomState = CanvasZoom.initialState
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

                            ( best, newHighScore ) =
                                if s.best < ((List.sum model.scores)) then
                                    ( List.sum model.scores, True )
                                else
                                    ( s.best, False )

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
                            ( { nextModel | showAnswer = False, mode = Result, score = score, showNewHighScore = newHighScore }, (saveToStorage score) )

                    _ ->
                        ( { nextModel | showAnswer = False }, Cmd.batch (getListOfLoadImageMessages nextModel.currentQuestion) )

        ShowAnswer ->
            let
                canvasZoomState =
                    model.canvasZoomState

                newCanvasZoomState =
                    { canvasZoomState
                        | scale = { x = 1.0, y = 1.0 }
                        , position = { x = 0.0, y = 0.0 }
                    }

                pointData =
                    model.drawData.currentPointData

                lineDrawOps =
                    List.concat
                        (List.map (\pointData -> calculateDrawOpsFromZoom pointData newCanvasZoomState)
                            (pointData :: model.drawData.allPointData)
                        )

                newDrawOps =
                    concatDrawOps model.color 3 lineDrawOps
            in
                ( case model.currentQuestion of
                    Nothing ->
                        model

                    Just question ->
                        { model
                            | answeredQuestions = question :: model.answeredQuestions
                            , showAnswer = True
                            , canvasZoomState = newCanvasZoomState
                            , drawData =
                                { currentPointData = model.drawData.currentPointData
                                , drawOps = newDrawOps
                                , allPointData = model.drawData.allPointData
                                }
                        }
                , Cmd.batch
                    [ (delay (Time.second * showAnswerDelay) <| NextQuestion)
                    , (delay (Time.millisecond * 600) <| CalculateScore)
                    ]
                )

        CalculateScore ->
            ( { model | scores = model.scores ++ [ (checkAnswer model) ] }, Cmd.none )

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
                    let
                        imageSize =
                            Canvas.getSize canvas

                        canvasSize =
                            calculateImageSize imageSize.width imageSize.height model.windowWidth model.windowHeight

                        canvasZoomState =
                            model.canvasZoomState

                        newCanvasZoomState =
                            { canvasZoomState | imageSize = canvasSize, canvasSize = canvasSize }
                    in
                        ( { model
                            | image = GotCanvas canvas
                            , imageSize = Just (Canvas.getSize canvas)
                            , canvasZoomState = newCanvasZoomState
                          }
                        , Cmd.none
                        )

                Nothing ->
                    ( { model | image = Loading, canvasZoomState = CanvasZoom.initialState }
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

                newCurrentPointData =
                    { position = model.canvasZoomState.position
                    , scale = model.canvasZoomState.scale
                    , points = []
                    }

                newDrawData =
                    { drawData
                        | allPointData = model.drawData.currentPointData :: model.drawData.allPointData
                        , currentPointData = newCurrentPointData
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
                    model.drawData.currentPointData.points ++ [ point ]

                pointData =
                    model.drawData.currentPointData

                newPointData =
                    { pointData | points = newPoints }

                lineDrawOps =
                    List.concat
                        (List.map (\pointData -> calculateDrawOpsFromZoom pointData model.canvasZoomState)
                            (pointData :: model.drawData.allPointData)
                        )

                newDrawOps =
                    concatDrawOps model.color 3 lineDrawOps
            in
                ( { model
                    | drawData =
                        { currentPointData = newPointData
                        , drawOps = newDrawOps
                        , allPointData = model.drawData.allPointData
                        }
                  }
                , Cmd.none
                )

        TouchDown event ->
            case model.zoomMode of
                True ->
                    let
                        canvasZoomState =
                            model.canvasZoomState

                        newCanvasZoomState =
                            { canvasZoomState
                                | last = Nothing
                                , lastZoomScale = Nothing
                            }
                    in
                        ( { model | draw = False, canvasZoomState = newCanvasZoomState }, Cmd.none )

                False ->
                    case event.points of
                        [] ->
                            ( model, Cmd.none )

                        point :: tl ->
                            let
                                drawData =
                                    model.drawData

                                newCurrentPointData =
                                    Debug.log "newCurrentPointData" <|
                                        { position = model.canvasZoomState.position
                                        , scale = model.canvasZoomState.scale
                                        , points = []
                                        }

                                newDrawData =
                                    { drawData
                                        | allPointData =
                                            model.drawData.allPointData
                                                ++ [ model.drawData.currentPointData ]
                                        , currentPointData = newCurrentPointData
                                    }
                            in
                                ( { model | draw = True, drawData = newDrawData }, Cmd.none )

        TouchUp event ->
            case model.zoomMode of
                True ->
                    ( model, Cmd.none )

                False ->
                    case event.points of
                        [] ->
                            ( model, Cmd.none )

                        point :: [] ->
                            ( { model
                                | draw = False
                              }
                            , Cmd.none
                            )

                        point :: tl ->
                            ( { model | draw = False }, Cmd.none )

        TouchMove event ->
            case model.zoomMode of
                True ->
                    case event.targetTouches of
                        [] ->
                            ( model, Cmd.none )

                        h :: [] ->
                            let
                                relativeX =
                                    h.page.x

                                relativeY =
                                    h.page.y

                                newState =
                                    -- Debug.log "doMove" <|
                                    CanvasZoom.doMove model.canvasZoomState relativeX relativeY

                                pointData =
                                    model.drawData.currentPointData

                                lineDrawOps =
                                    List.concat
                                        (List.map (\pointData -> calculateDrawOpsFromZoom pointData newState)
                                            (pointData :: model.drawData.allPointData)
                                        )

                                newDrawOps =
                                    concatDrawOps model.color 3 lineDrawOps
                            in
                                ( { model
                                    | canvasZoomState = newState
                                    , drawData =
                                        { currentPointData = model.drawData.currentPointData
                                        , drawOps = newDrawOps
                                        , allPointData = model.drawData.allPointData
                                        }
                                  }
                                , Cmd.none
                                )

                        h :: h2 :: [] ->
                            let
                                newState =
                                    -- Debug.log "doZoom" <|
                                    CanvasZoom.doZoom <|
                                        CanvasZoom.gesturePinchZoom model.canvasZoomState event.targetTouches

                                pointData =
                                    model.drawData.currentPointData

                                lineDrawOps =
                                    List.concat
                                        (List.map (\pointData -> calculateDrawOpsFromZoom pointData newState)
                                            (pointData :: model.drawData.allPointData)
                                        )

                                newDrawOps =
                                    concatDrawOps model.color 3 lineDrawOps
                            in
                                ( { model
                                    | canvasZoomState = newState
                                    , drawData =
                                        { currentPointData = model.drawData.currentPointData
                                        , drawOps = newDrawOps
                                        , allPointData = model.drawData.allPointData
                                        }
                                  }
                                , Cmd.none
                                )

                        h :: h2 :: t ->
                            ( model, Cmd.none )

                False ->
                    case event.points of
                        [] ->
                            ( model, Cmd.none )

                        point :: [] ->
                            let
                                ( x, y ) =
                                    Point.toFloats point

                                newPoint =
                                    Point.fromFloats
                                        ( x - model.canvasZoomState.position.x
                                        , y - model.canvasZoomState.position.y
                                        )

                                newPoints =
                                    model.drawData.currentPointData.points ++ [ newPoint ]

                                pointData =
                                    model.drawData.currentPointData

                                newPointData =
                                    { pointData | points = newPoints }

                                lineDrawOps =
                                    List.concat
                                        (List.map (\pointData -> calculateDrawOpsFromZoom pointData model.canvasZoomState)
                                            (pointData :: model.drawData.allPointData)
                                        )

                                newDrawOps =
                                    concatDrawOps model.color 3 lineDrawOps
                            in
                                ( { model
                                    | drawData =
                                        { currentPointData = newPointData
                                        , drawOps = newDrawOps
                                        , allPointData = model.drawData.allPointData
                                        }
                                  }
                                , Cmd.none
                                )

                        point :: tl ->
                            ( { model | draw = False }, Cmd.none )

        SetOneDoubleFingerTap val ->
            ( { model | oneDoubleFingerTap = val }, Cmd.none )

        Clear ->
            ( { model | drawData = initDrawData }, Cmd.none )

        ToggleZoomMode ->
            ( { model | zoomMode = not model.zoomMode }, (delay (Time.millisecond * 0) <| ToggleZoomInfoModal) )

        Undo ->
            case model.drawData.allPointData of
                [] ->
                    ( model, Cmd.none )

                hd :: tl ->
                    let
                        lineDrawOps =
                            List.concat
                                (List.map (\pointData -> calculateDrawOpsFromZoom pointData model.canvasZoomState)
                                    (tl)
                                )

                        newDrawOps =
                            concatDrawOps model.color 3 lineDrawOps

                        newCurrentPointData =
                            { position = model.canvasZoomState.position
                            , scale = model.canvasZoomState.scale
                            , points = []
                            }
                    in
                        ( { model
                            | drawData =
                                { currentPointData = newCurrentPointData
                                , drawOps = newDrawOps
                                , allPointData = tl
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

        ToggleShowNewHighScore ->
            ( { model | showNewHighScore = not model.showNewHighScore }, Cmd.none )


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


calculateDrawOpsFromZoom : PointData -> CanvasZoom.State -> List DrawOp
calculateDrawOpsFromZoom pointData zoomState =
    let
        scaleFactorX =
            (/)
                zoomState.scale.x
                pointData.scale.x

        scaleFactorY =
            (/)
                zoomState.scale.y
                pointData.scale.y

        lineDrawOps =
            pointListToLineOperations pointData.points
    in
        [ SetTransform scaleFactorX 0 0 scaleFactorY zoomState.position.x zoomState.position.y ]
            ++ lineDrawOps
            ++ [ SetTransform 1 0 0 1 0 0 ]


pointListToLineOperations : List Point -> List DrawOp
pointListToLineOperations points =
    case points of
        [] ->
            []

        hd :: tl ->
            [ MoveTo hd ] ++ (List.map (\point -> LineTo point) tl)


concatDrawOps : Color.Color -> Float -> List DrawOp -> List DrawOp
concatDrawOps color lineWidth drawOps =
    [ BeginPath
    , LineWidth lineWidth
    , StrokeStyle color
    , LineCap "round"
    ]
        ++ drawOps
        ++ [ Stroke ]


checkAnswer : Model -> Int
checkAnswer model =
    let
        correctPoints =
            (case model.solution of
                Loading ->
                    []

                GotCanvas canvas ->
                    let
                        imageSize =
                            model.canvasZoomState.imageSize

                        aspectRatioWidthHeight =
                            (toFloat imageSize.width) / (toFloat imageSize.height)

                        canvasHeight =
                            100

                        canvasWidth =
                            floor (canvasHeight * aspectRatioWidthHeight)

                        canvasSize =
                            { width = canvasWidth, height = canvasHeight }

                        -- canvasSize =
                        --     calculateImageSize imageSize.width imageSize.height model.windowWidth model.windowHeight
                    in
                        Canvas.initialize canvasSize
                            |> Canvas.batch [ (createDrawImage canvas canvasSize) ]
                            |> Canvas.getPopulatedPoints (Point.fromInts ( 0, 0 )) canvasSize
            )

        submittedPoints =
            -- (List.foldr
            --     (\pointData acc -> pointData.points ++ acc)
            --     []
            --     model.drawData.allPointData
            -- )
            let
                imageSize =
                    model.canvasZoomState.imageSize

                canvasSize =
                    calculateImageSize imageSize.width imageSize.height model.windowWidth model.windowHeight

                lineDrawOps =
                    List.concat
                        (List.map (\pointData -> calculateDrawOpsFromZoom pointData model.canvasZoomState)
                            (model.drawData.currentPointData :: model.drawData.allPointData)
                        )

                newDrawOps =
                    concatDrawOps model.color 1 lineDrawOps

                aspectRatioWidthHeight =
                    (toFloat imageSize.width) / (toFloat imageSize.height)

                canvasHeight =
                    100

                canvasWidth =
                    floor (canvasHeight * aspectRatioWidthHeight)

                canvasSizeScaled =
                    { width = canvasWidth, height = canvasHeight }

                originalCanvas =
                    Canvas.initialize canvasSize
                        |> Canvas.batch newDrawOps
            in
                Canvas.initialize canvasSizeScaled
                    |> Canvas.batch
                        [ DrawImage originalCanvas
                            (Scaled (Point.fromInts ( 0, 0 )) canvasSizeScaled)
                        ]
                    |> Canvas.getPopulatedPoints (Point.fromInts ( 0, 0 )) canvasSize

        amountOfCorrectPoints =
            Debug.log "correctPoints length" <|
                List.length correctPoints

        amountOfSubmittedPoints =
            Debug.log "submittedPoints length" <|
                List.length submittedPoints

        pointAmountFactor =
            Debug.log "pointAmountFactor" <|
                toFloat (List.length correctPoints)
                    / toFloat (List.length submittedPoints)
                    * 100

        eucleadianScore =
            let
                ( temp_acc, temp_min, temp_max ) =
                    Debug.log "acc + max" <|
                        List.foldl
                            (\point1 ( acc, minii, maxii ) ->
                                let
                                    m =
                                        List.foldl
                                            (\point2 mini ->
                                                let
                                                    dist =
                                                        distancePoint point1 point2

                                                    new_mini =
                                                        if mini > dist then
                                                            dist
                                                        else
                                                            mini
                                                in
                                                    new_mini
                                            )
                                            4200
                                            correctPoints

                                    new_acc =
                                        m + acc

                                    new_minii =
                                        if minii > m then
                                            m
                                        else
                                            minii

                                    new_maxii =
                                        if maxii < m then
                                            m
                                        else
                                            maxii
                                in
                                    ( new_acc, new_minii, new_maxii )
                            )
                            ( 0, 4200, 0 )
                            submittedPoints

                eucAvg =
                    Debug.log "Euc average" <|
                        temp_acc
                            / toFloat (List.length submittedPoints)
            in
                eucAvg

        score =
            Debug.log "score" <|
                let
                    y =
                        -10 / 4 * ((-40) + eucleadianScore)
                in
                    if y <= 0 then
                        0
                    else
                        y
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
