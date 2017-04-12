module Lmq.Rest exposing (..)

import Types exposing (Region)
import Lmq.Types exposing (..)
import App.Rest exposing (createApiUrl)
import Http
import Json.Decode exposing (Decoder, int, string, list, nullable)
import Json.Decode.Pipeline exposing (decode, required, optional)


getLandmarkQuestions : Cmd Msg
getLandmarkQuestions =
    let
        url =
            createApiUrl "/quiz/landmarkquestion"

        request =
            Http.get url (list landmarkQuestionDecoder)
    in
        Http.send SetLandmarkQuestions request


landmarkQuestionDecoder : Decoder LandmarkQuestion
landmarkQuestionDecoder =
    decode LandmarkQuestion
        |> required "pk" int
        |> required "question" string
        |> required "original_image" string
        |> required "landmark_drawing" string
        |> required "landmark_regions" (list landmarkRegionDecoder)


landmarkRegionDecoder : Decoder Region
landmarkRegionDecoder =
    decode Region
        |> required "color" string
        |> required "name" string
