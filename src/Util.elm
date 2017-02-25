module Util exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Decode exposing (Decoder, int, string, list, nullable)


type Msg
    = NoOp



-- Listen for enter


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.Decode.succeed msg
            else
                Json.Decode.fail "not ENTER"
    in
        on "keydown" (Json.Decode.andThen isEnter keyCode)


radio : String -> String -> Bool -> Msg -> Html Msg
radio labelName groupName isSelected msg =
    label []
        [ input [ type_ "radio", checked isSelected, name groupName, onClick msg ] []
        , text labelName
        ]
