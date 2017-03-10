module App.Types exposing (..)

import Date exposing (Date)
import Mcq.Types
import Lmq.Types


type Msg
    = NoOp
    | SetDate Date
    | McqMsg Mcq.Types.Msg
    | LmqMsg Lmq.Types.Msg
    | ChangeMode Mode


type alias Global =
    { date : Maybe Date
    , mode : Mode
    }


type alias Model =
    { global : Global
    , mcq : Mcq.Types.Model
    , lmq : Lmq.Types.Model
    }


type Mode
    = Main
    | MultipleChoiceQuestions
    | LandmarkQuestions

