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
            , mode = Main
            }

        ( mcqModel, mcqCmd ) =
            Mcq.State.init

        model =
            { global = global
            , mcq = mcqModel
            , lmq = Lmq.State.init
            }
    in
        model ! [ now, (Cmd.map McqMsg mcqCmd) ]


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

            ChangeMode mode ->
                ( { model | global = { global | mode = mode } }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


now : Cmd Msg
now =
    Task.perform SetDate Date.now
