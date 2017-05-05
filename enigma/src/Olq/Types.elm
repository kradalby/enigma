module Olq.Types exposing (..)

import Http
import Random
import Canvas exposing (DrawOp, Canvas, Error, Size)
import Canvas.Point exposing (Point)
import Color exposing (Color)
import Types exposing (Region, canvasSize, wrongColor, Image, QuestionScore)


type alias OutlineQuestion =
    { pk : Int
    , original_image : String
    , outline_drawing : String
    , outline_regions : List Region
    }


type alias DrawData =
    { currentPoints : List Point
    , points : List (List Point)
    , drawOps : List DrawOp
    }


initDrawData : DrawData
initDrawData =
    { currentPoints = []
    , points = []
    , drawOps = []
    }


type alias Model =
    { answeredQuestions : List OutlineQuestion
    , color : Color
    , currentQuestion : Maybe OutlineQuestion
    , drawData : DrawData
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
    , draw : Bool
    , zoomMode : Bool
    , scores : List Int
    , oneDoubleFingerTap : Bool
    , zoomInfoModal : Bool
    , score : QuestionScore
    , showNewHighScore : Bool
    }


type Msg
    = ToggleShowAnswer
    | StartQuiz Int
    | NextQuestion
    | GetOutlineQuestions
    | SetOutlineQuestions (Result Http.Error (List OutlineQuestion))
    | NumberOfQuestionsInput String
    | SetError String
    | ClearError
    | ChangeMode Mode
    | ImageLoaded (Result Error Canvas)
    | SolutionLoaded (Result Error Canvas)
    | MouseDown Point
    | MouseUp Point
    | MouseMove Point
    | TouchDown (List Point)
    | TouchUp (List Point)
    | TouchMove (List Point)
    | TouchInit (List Point)
    | TouchTwoFingerDoubleTap (List Point)
    | SetOneDoubleFingerTap Bool
    | Clear
    | ToggleZoomMode
    | CalculateScore
    | Undo
    | ToggleZoomInfoModal
    | Noop
    | Load String
    | ToggleShowNewHighScore


type Mode
    = Start
    | Running
    | Result
