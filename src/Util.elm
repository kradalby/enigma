module Util exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Decode exposing (Decoder, int, string, list, nullable)
import Process
import Time exposing (..)
import Task


-- Listen for enter


onEnter : msg -> Attribute msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.Decode.succeed msg
            else
                Json.Decode.fail "not ENTER"
    in
        on "keydown" (Json.Decode.andThen isEnter keyCode)


radio : String -> String -> Bool -> msg -> Html msg
radio labelName groupName isSelected msg =
    label []
        [ input [ type_ "radio", checked isSelected, name groupName, onClick msg ] []
        , text labelName
        ]


delay : Time -> msg -> Cmd msg
delay time msg =
    Process.sleep time
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


viewErrorBox : String -> Html msg
viewErrorBox errorString =
    div [ class "card-panel red lighten-1" ]
        [ span [ class "bold" ] [ text "Error: " ]
        , text errorString
        ]


viewSpinningLoader : Html msg
viewSpinningLoader =
    div [ class "preloader-wrapper active" ]
        [ div [ class "spinner-layer spinner-blue" ]
            [ div [ class "circle-clipper left" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "gap-patch" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "circle-clipper right" ]
                [ div [ class "circle" ]
                    []
                ]
            ]
        , div [ class "spinner-layer spinner-red" ]
            [ div [ class "circle-clipper left" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "gap-patch" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "circle-clipper right" ]
                [ div [ class "circle" ]
                    []
                ]
            ]
        , div [ class "spinner-layer spinner-yellow" ]
            [ div [ class "circle-clipper left" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "gap-patch" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "circle-clipper right" ]
                [ div [ class "circle" ]
                    []
                ]
            ]
        , div [ class "spinner-layer spinner-green" ]
            [ div [ class "circle-clipper left" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "gap-patch" ]
                [ div [ class "circle" ]
                    []
                ]
            , div [ class "circle-clipper right" ]
                [ div [ class "circle" ]
                    []
                ]
            ]
        ]


viewProgressbar : Int -> Html msg
viewProgressbar percentage =
    div [ class "progress" ]
        [ div [ class "determinate", attribute "style" ("width: " ++ (toString percentage) ++ "%") ]
            []
        ]
