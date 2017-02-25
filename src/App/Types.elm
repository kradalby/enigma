module App.Types exposing (..)

import Date exposing (Date)


type Msg
    = NoOp
    | SetDate Date


type alias Model =
    { date : Maybe Date
    }
