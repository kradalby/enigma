module Lmq.Types exposing (..)

import Http
import Random


type alias LandmarkQuestion =
    { pk : Int
    , question : String
    , original_image : String
    , landmark_drawing : String
    , landmark_regions : List LandmarkRegion
    }


type alias LandmarkRegion =
    { color : String
    , name : String
    }


type alias Model =
    { questions : List LandmarkQuestion
    , mode : Mode
    , unAnsweredQuestions :
        List LandmarkQuestion
        -- , wrongQuestions : List LandmarkQuestion
        -- , correctQuestions : List LandmarkQuestion
    , currentQuestion : Maybe LandmarkQuestion
    , showAnswer : Bool
    , numberOfQuestionsInputField : String
    , error : Maybe String
    , seed : Random.Seed
    }


type Msg
    = ToggleShowAnswer
    | StartQuiz Int
    | NextQuestion
    | GetLandmarkQuestions
    | SetLandmarkQuestions (Result Http.Error (List LandmarkQuestion))
    | NumberOfQuestionsInput String
    | SetError String
    | ClearError
    | ChangeMode Mode


type Mode
    = Start
    | Running
    | Result
