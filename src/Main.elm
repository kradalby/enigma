module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (type_, checked, name, disabled, value, class, src, id, selected, for, href)
import Http
import Json.Decode exposing (Decoder, int, string, list, nullable)
import Json.Decode.Pipeline exposing (decode, required, optional)
import List
import Platform.Cmd exposing (Cmd)
import Task
import Date exposing (Date)
import Debug


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias MultipleQuestion =
    { pk : Int
    , question : String
    , correct : Int
    , answers :
        List String
    , image : Maybe String
    , video : Maybe String
    }


type alias LandMarkQuestion =
    { pk : Int
    , question : String
    , original_image : String
    , landmark_drawing : String
    , landmark_regions : List LandMarkRegion
    }


type alias LandMarkRegion =
    { color : String
    , name : String
    }


type alias Model =
    { date : Maybe Date
    , questions : List MultipleQuestion
    , unAnsweredQuestions : List MultipleQuestion
    , wrongQuestions : List MultipleQuestion
    , correctQuestions : List MultipleQuestion
    , currentQuestion : Maybe MultipleQuestion
    , showAnswer : Bool
    }


init : ( Model, Cmd Msg )
init =
    let
        _ =
            Debug.log "test"

        model =
            { date = Nothing
            , questions = []
            , unAnsweredQuestions = []
            , wrongQuestions = []
            , correctQuestions = []
            , currentQuestion = Nothing
            , showAnswer = False
            }
    in
        model ! [ getMultipleChoiceQuestions, now ]


type Msg
    = NoOp
    | SetDate Date
    | Correct
    | Wrong
    | NextQuestion
    | ToggleShowAnswer
    | GetMultipleChoiceQuestions
    | SetMultipleChoiceQuestions (Result Http.Error (List MultipleQuestion))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetDate date ->
            ( { model | date = Just date }, Cmd.none )

        ToggleShowAnswer ->
            ( { model | showAnswer = not model.showAnswer }, Cmd.none )

        NextQuestion ->
            ( nextQuestion model, Cmd.none )

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


nextQuestion : Model -> Model
nextQuestion model =
    { model
        | currentQuestion = List.head model.unAnsweredQuestions
        , unAnsweredQuestions =
            case List.tail model.unAnsweredQuestions of
                Nothing ->
                    []

                Just tail ->
                    tail
    }


now : Cmd Msg
now =
    Task.perform SetDate Date.now


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


view : Model -> Html Msg
view model =
    div [ class "wrapper" ]
        [ h1 [] [ text "enigma" ]
        , a [ onClick NextQuestion ] [ text "start" ]
        , a [ onClick GetMultipleChoiceQuestions ] [ text "fetch questions" ]
        , case model.currentQuestion of
            Nothing ->
                p [] [ text "No current question" ]

            Just currentQuestion ->
                viewMultipleChoiceQuestion currentQuestion
        , viewFooter model
        ]


viewMultipleChoiceQuestion : MultipleQuestion -> Html Msg
viewMultipleChoiceQuestion mcq =
    div [ class "multiple-choice-question" ]
        [ h2 [] [ text mcq.question ]
        , case mcq.image of
            Just image ->
                img [ src (base_url ++ image) ] []

            Nothing ->
                p [] []
        , case mcq.video of
            Just video ->
                -- This should be a video tag
                img [ src (base_url ++ video) ] []

            Nothing ->
                p [] []
        , div [ class "multiple-choice-question-alternaltives" ] (viewMultipleChoiceQuestionAlternaltives mcq.answers)
        ]


viewMultipleChoiceQuestionAlternaltives : List String -> List (Html Msg)
viewMultipleChoiceQuestionAlternaltives alternaltives =
    List.map (\alternaltive -> button [] [ text alternaltive ]) alternaltives


viewFooter : Model -> Html Msg
viewFooter model =
    footer [ class "row footer" ]
        [ p [] [ text "Made with ", a [ href "http://elm-lang.org" ] [ text "Elm" ] ]
        , p []
            [ text
                ("Copyright "
                    ++ (toString
                            (case model.date of
                                Nothing ->
                                    1337

                                Just date ->
                                    Date.year date
                            )
                       )
                    ++ " "
                )
            , a [ href "https://kradalby.no" ] [ text "Kristoffer Dalby" ]
            ]
        ]


radio : String -> String -> Bool -> Msg -> Html Msg
radio labelName groupName isSelected msg =
    label []
        [ input [ type_ "radio", checked isSelected, name groupName, onClick msg ] []
        , text labelName
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Utilities
-- Api stuff


base_url : String
base_url =
    "http://localhost:8000"


base_api_url : String
base_api_url =
    "/api"


createApiUrl : String -> String
createApiUrl endpoint =
    base_url ++ base_api_url ++ endpoint ++ "/?format=json"


getMultipleChoiceQuestions : Cmd Msg
getMultipleChoiceQuestions =
    let
        url =
            createApiUrl "/quiz/mcq"

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
