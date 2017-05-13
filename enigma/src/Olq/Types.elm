module Olq.Types exposing (..)

import Http
import Random
import Canvas exposing (DrawOp, Canvas, Error, Size)
import Canvas.Point exposing (Point)
import Canvas.Events exposing (Touch)
import Color exposing (Color)
import Types exposing (Region, canvasSize, wrongColor, Image, QuestionScore)
import Olq.CanvasZoom as CanvasZoom


type alias OutlineQuestion =
    { pk : Int
    , original_image : String
    , outline_drawing : String
    , outline_regions : List Region
    }


type alias PointData =
    { position : { x : Float, y : Float }
    , scale : { x : Float, y : Float }
    , points : List Point
    }


type alias DrawData =
    { currentPointData : PointData
    , allPointData : List PointData
    , drawOps : List DrawOp
    }


initDrawData : DrawData
initDrawData =
    { currentPointData =
        { position = { x = 0.0, y = 0.0 }
        , scale =
            { x = 1.0
            , y = 1.0
            }
        , points = []
        }
    , allPointData = []
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
    , canvasZoomState : CanvasZoom.State
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
    | TouchDown { targetTouches : List Touch, points : List Point }
    | TouchUp { targetTouches : List Touch, points : List Point }
    | TouchMove { targetTouches : List Touch, points : List Point }
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
