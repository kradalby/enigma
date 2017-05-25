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
            createApiUrl "/quiz/outlinequestion"

        request =
            Http.get url (list outlineQuestionDecoder)
    in
        Http.send SetOutlineQuestions request


outlineQuestionDecoder : Decoder OutlineQuestion
outlineQuestionDecoder =
    decode OutlineQuestion
        |> required "pk" int
        |> required "question" string
        |> required "original_image" string
        |> required "outline_drawing" string
        |> required "outline_regions" (list outlineRegionDecoder)


outlineRegionDecoder : Decoder Region
outlineRegionDecoder =
    decode Region
        |> required "color" string
        |> required "name" string
