module Mcq.Types exposing (..)

import Http
import Random
import Types


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
    , mode : Mode
    , unAnsweredQuestions : List MultipleQuestion
    , wrongQuestions : List MultipleQuestion
    , correctQuestions : List MultipleQuestion
    , currentQuestion : Maybe MultipleQuestion
    , showAnswer : Bool
    , numberOfQuestionsInputField : String
    , error : Maybe String
    , seed : Random.Seed
    , score : Types.QuestionScore
    , showNewHighScore : Bool
    }


type Msg
    = ToggleShowAnswer
    | StartQuiz Int
    | NextQuestion
    | Correct
    | Wrong
    | GetMultipleChoiceQuestions
    | SetMultipleChoiceQuestions (Result Http.Error (List MultipleQuestion))
    | NumberOfQuestionsInput String
    | SetError String
    | ClearError
    | ChangeMode Mode
    | Noop
    | Load String
    | ToggleShowNewHighScore


type Mode
    = Start
    | Running
    | Result
