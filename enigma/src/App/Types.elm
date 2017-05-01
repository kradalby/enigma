module App.Types exposing (..)

import Mcq.Types
import Lmq.Types
import Olq.Types
import Date exposing (Date)


type Msg
    = NoOp
    | SetDate Date
    | McqMsg Mcq.Types.Msg
    | LmqMsg Lmq.Types.Msg
    | OlqMsg Olq.Types.Msg
    | ChangeMode Mode


type alias Global =
    { initialTime : Int
    , date : Maybe Date
    , mode : Mode
    }


type alias Flags =
    { width : Int
    , height : Int
    , currentTime : Int
    }


type alias Model =
    { global : Global
    , mcq : Mcq.Types.Model
    , lmq : Lmq.Types.Model
    , olq : Olq.Types.Model
    }


type Mode
    = Main
    | MultipleChoiceQuestions
    | LandmarkQuestions
    | OutlineQuestions
    | Score
