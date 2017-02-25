module Lmq.Rest exposing (..)

import Lmq.Types exposing (..)
import App.Rest exposing (createApiUrl)
import Http
import Json.Decode exposing (Decoder, int, string, list, nullable)
import Json.Decode.Pipeline exposing (decode, required, optional)


getLandmarkQuestions : Cmd Msg
getLandmarkQuestions =
    let
        url =
            createApiUrl "/quiz/mcq_all"

        request =
            Http.get url (list landmarkQuestionDecoder)
    in
        Http.send SetLandmarkQuestions request


landmarkQuestionDecoder : Decoder LandmarkQuestion
landmarkQuestionDecoder =
    decode LandmarkQuestion
        |> required "pk" int
        |> required "question" string
        |> required "correct" int
        |> required "answers" (list string)
        |> optional "image" (nullable string) Nothing
        |> optional "video" (nullable string) Nothing
