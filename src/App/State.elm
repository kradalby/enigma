module App.State exposing (init, update, subscriptions)

import App.Types exposing (..)
import Task
import Mcq.State
import Lmq.State
import Date exposing (Date)


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        derp =
            Debug.log "Flags" flags

        global =
            { initialTime = flags.currentTime
            , date = Nothing
            , mode = Main
            }

        ( mcqModel, mcqCmd ) =
            Mcq.State.init

        ( lmqModel, lmqCmd ) =
            Lmq.State.init flags.currentTime flags.width flags.height

        model =
            { global = global
            , mcq = mcqModel
            , lmq = lmqModel
            }
    in
        model ! [ now, (Cmd.map McqMsg mcqCmd), (Cmd.map LmqMsg lmqCmd) ]


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

            McqMsg mcqMsg ->
                let
                    ( mcqModel, mcqCmd ) =
                        Mcq.State.update mcqMsg model.mcq
                in
                    ( { model | mcq = mcqModel }
                    , Cmd.map McqMsg mcqCmd
                    )

            LmqMsg lmqMsg ->
                let
                    ( lmqModel, lmqCmd ) =
                        Lmq.State.update lmqMsg model.lmq
                in
                    ( { model | lmq = lmqModel }
                    , Cmd.map LmqMsg lmqCmd
                    )

            ChangeMode mode ->
                ( { model | global = { global | mode = mode } }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


now : Cmd Msg
now =
    Task.perform SetDate Date.now
