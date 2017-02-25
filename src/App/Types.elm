module App.Types exposing (..)

import Date exposing (Date)
import Mcq.Types
import Lmq.Types


type Msg
    = NoOp
    | SetDate Date


type alias Global =
    { date : Maybe Date
    }


type alias Model =
    { global : Global
    , mcq : Mcq.Types.Model
    , lmq : Lmq.Types.Model
    }
