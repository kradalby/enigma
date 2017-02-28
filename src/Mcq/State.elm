module Mcq.State exposing (init, update, subscriptions)

import Mcq.Types exposing (..)
import Mcq.Rest exposing (getMultipleChoiceQuestions)
import Util exposing (delay)
import Time


init : ( Model, Cmd Msg )
init =
    let
        model =
            { questions = []
            , unAnsweredQuestions = []
            , wrongQuestions = []
            , correctQuestions = []
            , currentQuestion = Nothing
            , showAnswer = False
            , numberOfQuestionsInputField = "0"
            , error = Nothing
            }
    in
        model ! [ getMultipleChoiceQuestions ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleShowAnswer ->
            ( { model | showAnswer = not model.showAnswer }, Cmd.none )

        StartQuiz number ->
            ( { model
                | unAnsweredQuestions = model.questions
                , correctQuestions = []
                , wrongQuestions = []
              }
            , Cmd.none
            )

        NextQuestion ->
            let
                nextModel =
                    nextQuestion model
            in
                ( nextModel, Cmd.none )

        Correct ->
            let
                nextModel =
                    nextQuestion model
            in
                ( case model.currentQuestion of
                    Nothing ->
                        nextModel

                    Just question ->
                        { nextModel
                            | correctQuestions = question :: model.correctQuestions
                        }
                , Cmd.none
                )

        Wrong ->
            let
                nextModel =
                    nextQuestion model
            in
                ( case model.currentQuestion of
                    Nothing ->
                        nextModel

                    Just question ->
                        { nextModel
                            | wrongQuestions = question :: model.wrongQuestions
                        }
                , Cmd.none
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
