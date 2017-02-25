module App.State exposing (init, update, subscriptions)

import App.Types exposing (..)
import Task
import Date exposing (Date)


init : ( Model, Cmd Msg )
init =
    let
        model =
            { date = Nothing
            }
    in
        model ! [ now ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetDate date ->
            ( { model | date = Just date }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


now : Cmd Msg
now =
    Task.perform SetDate Date.now
