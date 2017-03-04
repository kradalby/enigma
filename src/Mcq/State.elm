module Mcq.State exposing (init, update, subscriptions)

import Mcq.Types exposing (..)
import Mcq.Rest exposing (getMultipleChoiceQuestions)
import Util exposing (delay)
import Time
import Random.List exposing (shuffle)
import Random


init : ( Model, Cmd Msg )
init =
    let
        model =
            { questions = []
            , mode = Start
            , unAnsweredQuestions = []
            , wrongQuestions = []
            , correctQuestions = []
            , currentQuestion = Nothing
            , showAnswer = False
            , numberOfQuestionsInputField = "0"
            , error = Nothing
            , seed = Random.initialSeed 583345035
            }
    in
        model ! [ getMultipleChoiceQuestions ]


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
                    , currentQuestion = h
                    , correctQuestions = []
                    , wrongQuestions = []
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
                case nextModel.currentQuestion of
                    Nothing ->
                        ( { nextModel | showAnswer = False, mode = Result }, Cmd.none )

                    _ ->
                        ( { nextModel | showAnswer = False }, Cmd.none )

        Correct ->
            ( case model.currentQuestion of
                Nothing ->
                    model

                Just question ->
                    { model
                        | correctQuestions = question :: model.correctQuestions
                        , showAnswer = True
                    }
            , (delay (Time.second * 3) <| NextQuestion)
            )

        Wrong ->
            ( case model.currentQuestion of
                Nothing ->
                    model

                Just question ->
                    { model
                        | wrongQuestions = question :: model.wrongQuestions
                        , showAnswer = True
                    }
            , (delay (Time.second * 3) <| NextQuestion)
            )

        GetMultipleChoiceQuestions ->
            ( model, getMultipleChoiceQuestions )

        SetMultipleChoiceQuestions (Ok questions) ->
            ( { model | questions = questions }, Cmd.none )

        SetMultipleChoiceQuestions (Err _) ->
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
