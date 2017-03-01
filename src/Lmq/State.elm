module Lmq.State exposing (init, update, subscriptions)

import Lmq.Types exposing (..)
import Lmq.Rest exposing (getLandmarkQuestions)
import Random
import Random.List exposing (shuffle)
import Time
import Util exposing (delay)


init : ( Model, Cmd Msg )
init =
    let
        model =
            { questions = []
            , mode = Start
            , unAnsweredQuestions =
                []
                -- , wrongQuestions = []
                -- , correctQuestions = []
            , currentQuestion = Nothing
            , showAnswer = False
            , numberOfQuestionsInputField = "0"
            , error = Nothing
            , seed = Random.initialSeed 98657938465945786
            }
    in
        model ! [ getLandmarkQuestions ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleShowAnswer ->
            ( { model | showAnswer = not model.showAnswer }, Cmd.none )

        StartQuiz number ->
            let
                ( shuffeledQuestions, seed ) =
                    Random.step (shuffle model.questions) model.seed

                ( h, t ) =
                    case (List.take number shuffeledQuestions) of
                        [] ->
                            ( Nothing, [] )

                        h :: t ->
                            ( Just h, t )

                -- shuffle model.questions
            in
                ( { model
                    | unAnsweredQuestions = t
                    , currentQuestion =
                        h
                        -- , correctQuestions = []
                        -- , wrongQuestions = []
                    , seed = seed
                    , mode = Running
                  }
                , Cmd.none
                )

        NextQuestion ->
            let
                nextModel =
                    nextQuestion model
            in
                ( nextModel, Cmd.none )

        GetLandmarkQuestions ->
            ( model, getLandmarkQuestions )

        SetLandmarkQuestions (Ok questions) ->
            ( { model | questions = questions }, Cmd.none )

        SetLandmarkQuestions (Err _) ->
            ( model, Cmd.none )

        NumberOfQuestionsInput number ->
            ( { model | numberOfQuestionsInputField = number }, Cmd.none )

        SetError error ->
            ( { model | error = Just error }, (delay (Time.second * 5) <| ClearError) )

        ClearError ->
            ( { model | error = Nothing }, Cmd.none )

        ChangeMode mode ->
            ( { model | mode = mode }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


nextQuestion : Model -> Model
nextQuestion model =
    { model
        | currentQuestion = (List.head model.unAnsweredQuestions)
        , unAnsweredQuestions =
            case List.tail model.unAnsweredQuestions of
                Nothing ->
                    []

                Just tail ->
                    tail
    }
