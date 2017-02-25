module App.State exposing (init, update, subscriptions)

import App.Types exposing (..)
import Task
import Mcq.State
import Lmq.State
import Date exposing (Date)


init : ( Model, Cmd Msg )
init =
    let
        global =
            { date = Nothing
            }

        model =
            { global = global
            , mcq = Mcq.State.init
            , lmq = Lmq.State.init
            }
    in
        model ! [ now ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        { global } =
            model
    in
        case msg of
            NoOp ->
                ( model, Cmd.none )

            SetDate date ->
                ( { model | global = { global | date = Just date } }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


now : Cmd Msg
now =
    Task.perform SetDate Date.now
