module Mcq.Types exposing (..)

import Http


type alias MultipleQuestion =
    { pk : Int
    , question : String
    , correct : Int
    , answers :
        List String
    , image : Maybe String
    , video : Maybe String
    }


type alias Model =
    { questions : List MultipleQuestion
    , unAnsweredQuestions : List MultipleQuestion
    , wrongQuestions : List MultipleQuestion
    , correctQuestions : List MultipleQuestion
    , currentQuestion : Maybe MultipleQuestion
    , showAnswer : Bool
    }


type Msg
    = ToggleShowAnswer
    | StartQuiz Int
    | NextQuestion
    | Correct
    | Wrong
    | GetMultipleChoiceQuestions
    | SetMultipleChoiceQuestions (Result Http.Error (List MultipleQuestion))
