module Mcq.Rest exposing (getMultipleChoiceQuestions)

import Mcq.Types exposing (..)
import App.Rest exposing (createApiUrl)
import Http
import Json.Decode exposing (Decoder, int, string, list, nullable)
import Json.Decode.Pipeline exposing (decode, required, optional)


getMultipleChoiceQuestions : Cmd Msg
getMultipleChoiceQuestions =
    let
        url =
            createApiUrl "/quiz/mcq_all"

        request =
            Http.get url (list multipleChoiceQuestionDecoder)
    in
        Http.send SetMultipleChoiceQuestions request


multipleChoiceQuestionDecoder : Decoder MultipleQuestion
multipleChoiceQuestionDecoder =
    decode MultipleQuestion
        |> required "pk" int
        |> required "question" string
        |> required "correct" int
        |> required "answers" (list string)
        |> optional "image" (nullable string) Nothing
        |> optional "video" (nullable string) Nothing
