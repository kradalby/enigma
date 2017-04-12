module Lmq.Types exposing (..)

import Http
import Random
import Canvas exposing (DrawOp, Canvas, Error, Size)
import Canvas.Point exposing (Point)
import Color
import Types exposing (Region, canvasSize, wrongColor, Image)


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


type Mode
    = Start
    | Running
    | Result