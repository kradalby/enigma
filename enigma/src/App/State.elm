module App.State exposing (init, update, subscriptions)

import App.Types exposing (..)
import Task
import Mcq.State
import Lmq.State
import Olq.State
import Date exposing (Date)


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        global =
            { initialTime = flags.currentTime
            , date = Nothing
            , mode = Main
            }

        ( mcqModel, mcqCmd ) =
            Mcq.State.init flags.currentTime

        ( lmqModel, lmqCmd ) =
            Lmq.State.init flags.currentTime flags.width flags.height

        ( olqModel, olqCmd ) =
            Olq.State.init flags.currentTime flags.width flags.height

        model =
            { global = global
            , mcq = mcqModel
            , lmq = lmqModel
            , olq = olqModel
            }
    in
        model ! [ now, (Cmd.map McqMsg mcqCmd), (Cmd.map LmqMsg lmqCmd), (Cmd.map OlqMsg olqCmd) ]


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

            OlqMsg olqMsg ->
                let
                    ( olqModel, olqCmd ) =
                        Olq.State.update olqMsg model.olq
                in
                    ( { model | olq = olqModel }
                    , Cmd.map OlqMsg olqCmd
                    )

            ChangeMode mode ->
                ( { model | global = { global | mode = mode } }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


now : Cmd Msg
now =
    Task.perform SetDate Date.now
