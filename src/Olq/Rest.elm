module Olq.Rest exposing (..)

import Types exposing (Region)
import Olq.Types exposing (..)
import App.Rest exposing (createApiUrl)
import Http
import Json.Decode exposing (Decoder, int, string, list, nullable)
import Json.Decode.Pipeline exposing (decode, required, optional)


getOutlineQuestions : Cmd Msg
getOutlineQuestions =
    let
        url =
            createApiUrl "/quiz/landmarkquestion"

        request =
            Http.get url (list landmarkQuestionDecoder)
    in
        Http.send SetOutlineQuestions request


landmarkQuestionDecoder : Decoder OutlineQuestion
landmarkQuestionDecoder =
    decode OutlineQuestion
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
