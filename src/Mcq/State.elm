module Mcq.State exposing (init, update, subscriptions)

import Mcq.Types exposing (..)
import Mcq.Rest exposing (getMultipleChoiceQuestions)


init : Model
init =
    let
        model =
            { questions = []
            , unAnsweredQuestions = []
            , wrongQuestions = []
            , correctQuestions = []
            , currentQuestion = Nothing
            , showAnswer = False
            }
    in
        model


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
            let
                _ =
                    Debug.log "error"
            in
                ( model, Cmd.none )


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
