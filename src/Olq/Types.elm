module Olq.Types exposing (..)

import Http
import Random
import Canvas exposing (DrawOp, Canvas, Error, Size)
import Canvas.Point exposing (Point)
import Color
import Types exposing (Region, canvasSize, wrongColor, Image)


type alias OutlineQuestion =
    { pk : Int
    , original_image : String
    , outline_drawing : String
    , outline_regions : List Region
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
    { clickData : ClickData
    , correctQuestions : List OutlineQuestion
    , currentQuestion : Maybe OutlineQuestion
    , error : Maybe String
    , image : Image
    , imageSize : Maybe Size
    , mode : Mode
    , numberOfQuestionsInputField : String
    , questions : List OutlineQuestion
    , seed : Random.Seed
    , showAnswer : Bool
    , solution : Image
    , unAnsweredQuestions : List OutlineQuestion
    , windowHeight : Int
    , windowWidth : Int
    , wrongQuestions : List OutlineQuestion
    }


type Msg
    = ToggleShowAnswer
    | StartQuiz Int
    | NextQuestion
    | Correct
    | Wrong
    | GetOutlineQuestions
    | SetOutlineQuestions (Result Http.Error (List OutlineQuestion))
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
