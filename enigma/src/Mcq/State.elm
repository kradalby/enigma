module Mcq.State exposing (init, update, subscriptions)

import Mcq.Types exposing (..)
import Mcq.Rest exposing (getMultipleChoiceQuestions)
import Util exposing (delay)
import Time
import Random.List exposing (shuffle)
import Random
import Types exposing (showAnswerDelay, errorMessageDelay)
import LocalStorage
import Task


init : Int -> ( Model, Cmd Msg )
init initialSeed =
    let
        model =
            { questions = []
            , mode = Start
            , unAnsweredQuestions = []
            , wrongQuestions = []
            , correctQuestions = []
            , currentQuestion = Nothing
            , showAnswer = False
            , numberOfQuestionsInputField = ""
            , error = Nothing
            , seed = Random.initialSeed initialSeed
            , score = Types.initQuestionScore
            }
    in
        model ! [ getMultipleChoiceQuestions, getFromStorage ]


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
                        let
                            s =
                                model.score

                            ( best, newBestCmd ) =
                                if s.best < ((List.length model.correctQuestions) * Types.pointBase) then
                                    ( ((List.length model.correctQuestions) * Types.pointBase), Cmd.none )
                                else
                                    ( s.best, Cmd.none )

                            score =
                                { s
                                    | correct = model.score.correct + (List.length model.correctQuestions)
                                    , wrong = model.score.wrong + (List.length model.wrongQuestions)
                                    , best = best
                                }
                        in
                            ( { nextModel | showAnswer = False, mode = Result, score = score }, Cmd.batch [ newBestCmd, (saveToStorage score) ] )

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
            , (delay (Time.second * showAnswerDelay) <| NextQuestion)
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
            , (delay (Time.second * showAnswerDelay) <| NextQuestion)
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
            ( { model | error = Just error }, (delay (Time.second * errorMessageDelay) <| ClearError) )

        ClearError ->
            ( { model | error = Nothing }, Cmd.none )

        ChangeMode mode ->
            ( { model | mode = mode }, Cmd.none )

        Noop ->
            ( model, Cmd.none )

        Load string ->
            let
                qs =
                    Types.decodeQuestionScore string
            in
                ( { model | score = qs }, Cmd.none )


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


getFromStorage : Cmd Msg
getFromStorage =
    LocalStorage.get "enigma-mcq"
        |> Task.attempt
            (\result ->
                case result of
                    Ok v ->
                        Load (Maybe.withDefault "" v)

                    Err _ ->
                        Load ""
            )


saveToStorage : Types.QuestionScore -> Cmd Msg
saveToStorage qs =
    LocalStorage.set "enigma-mcq" (Types.encodeQuestionScore qs)
        |> Task.attempt (always Noop)
