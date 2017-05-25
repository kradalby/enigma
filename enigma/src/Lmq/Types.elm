module Lmq.Types exposing (..)

import Http
import Random
import Canvas exposing (DrawOp, Canvas, Error, Size)
import Canvas.Point exposing (Point)
import Color
import Types exposing (Region, canvasSize, wrongColor, Image, QuestionScore)
import Regex


type alias LandmarkQuestion =
    { pk : Int
    , question : String
    , original_image : String
    , landmark_drawing : String
    , landmark_regions : List Region
    }


type alias ClickData =
    { draw : List DrawOp
    , answerMsg : Msg
    , color : Color.Color
    }


initClickData : ClickData
initClickData =
    { draw = [], answerMsg = Wrong, color = wrongColor }


type alias Model =
    { questions : List LandmarkQuestion
    , color : Color.Color
    , mode : Mode
    , unAnsweredQuestions :
        List LandmarkQuestion
    , wrongQuestions : List LandmarkQuestion
    , correctQuestions : List LandmarkQuestion
    , currentQuestion : Maybe LandmarkQuestion
    , showAnswer : Bool
    , numberOfQuestionsInputField : String
    , error : Maybe String
    , seed : Random.Seed
    , image : Image
    , imageSize : Maybe Size
    , solution : Image
    , clickData : ClickData
    , windowWidth : Int
    , windowHeight : Int
    , score : Types.QuestionScore
    , showNewHighScore : Bool
    , imageMode : ImageMode
    }


type Msg
    = ToggleShowAnswer
    | StartQuiz Int
    | NextQuestion
    | Correct
    | Wrong
    | GetLandmarkQuestions
    | SetLandmarkQuestions (Result Http.Error (List LandmarkQuestion))
    | NumberOfQuestionsInput String
    | SetError String
    | ClearError
    | ChangeMode Mode
    | ImageLoaded (Result Error Canvas)
    | SolutionLoaded (Result Error Canvas)
    | CanvasClick Point
    | Noop
    | Load String
    | ToggleShowNewHighScore
    | ChangeImageMode ImageMode


type Mode
    = Start
    | Running
    | Result


type ImageMode
    = All
    | CT
    | MR
    | US


getQuestions : Model -> List LandmarkQuestion
getQuestions model =
    case model.imageMode of
        All ->
            model.questions

        CT ->
            List.filter (\q -> Regex.contains (Regex.regex "CT") q.question) model.questions

        US ->
            List.filter (\q -> Regex.contains (Regex.regex "US") q.question) model.questions

        MR ->
            List.filter (\q -> Regex.contains (Regex.regex "MR") q.question) model.questions
