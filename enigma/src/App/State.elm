module App.State exposing (init, update, subscriptions)

import App.Types exposing (..)
import Task
import Mcq.State
import Mcq.Types
import Lmq.State
import Lmq.Types
import Olq.State
import Olq.Types
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
                case mode of
                    MultipleChoiceQuestions ->
                        let
                            m =
                                model.mcq

                            newModel =
                                { m | mode = Mcq.Types.Start }
                        in
                            ( { model | global = { global | mode = mode }, mcq = newModel }, Cmd.none )

                    LandmarkQuestions ->
                        let
                            m =
                                model.lmq

                            newModel =
                                { m | mode = Lmq.Types.Start }
                        in
                            ( { model | global = { global | mode = mode }, lmq = newModel }, Cmd.none )

                    OutlineQuestions ->
                        let
                            m =
                                model.olq

                            newModel =
                                { m | mode = Olq.Types.Start }
                        in
                            ( { model | global = { global | mode = mode }, olq = newModel }, Cmd.none )

                    Main ->
                        ( { model | global = { global | mode = mode } }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


now : Cmd Msg
now =
    Task.perform SetDate Date.now
