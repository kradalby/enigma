module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (type_, checked, name, disabled, value, class, src, id, selected, for, href)
import Http
import Json.Encode
import Json.Decode exposing (Decoder, int, string, list)
import Json.Decode.Pipeline exposing (decode, required)
import List
import List.Extra
import Platform.Cmd exposing (Cmd)
import String
import String.Extra
import Dom
import Task
import Date exposing (Date)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias SpecialCharacter =
    { latin : String, special : String }


spanishSpecialCharacters : List SpecialCharacter
spanishSpecialCharacters =
    [ { special = "á", latin = "a" }
    , { special = "é", latin = "e" }
    , { special = "í", latin = "i" }
    , { special = "ó", latin = "o" }
    , { special = "ú", latin = "u" }
    , { special = "ü", latin = "u" }
    , { special = "ñ", latin = "n" }
    ]


norwegianSpecialCharacters : List SpecialCharacter
norwegianSpecialCharacters =
    [ { special = "æ", latin = "ae" }
    , { special = "ø", latin = "oe" }
    , { special = "å", latin = "aa" }
    , { special = "é", latin = "e" }
    ]


type Language
    = English
    | Spanish
    | Norwegian


availableLanguages : List Language
availableLanguages =
    [ English, Spanish, Norwegian ]


type alias Book =
    { title : String
    , chapters : String
    }


type alias Chapter =
    { chapter : Int
    , words : String
    }


type alias Word =
    { english : String
    , spanish : String
    , norwegian : String
    }


type alias Model =
    { wordList : List Word
    , bookList : List Book
    , chapterList : List Chapter
    , currentWord : Word
    , unAnswered : List Word
    , correct : List Word
    , wrong : List Word
    , fromLanguage : Language
    , toLanguage : Language
    , textInput : String
    , lazy : Bool
    , date : Maybe Date
    }


emptyWord : Word
emptyWord =
    { english = "", spanish = "", norwegian = "" }


init : ( Model, Cmd Msg )
init =
    let
        model =
            { wordList = []
            , bookList = []
            , chapterList = []
            , currentWord = emptyWord
            , unAnswered = []
            , correct = []
            , wrong = []
            , fromLanguage = English
            , toLanguage = Spanish
            , textInput = ""
            , lazy = False
            , date = Nothing
            }
    in
        model ! [ getBooks, now ]


type Msg
    = NoOp
    | Input String
    | Correct
    | Wrong
    | NextWord
    | ChangeFromLanguage Language
    | ChangeToLanguage Language
    | ToggleLazy
    | GetBooks
    | NewBooks (Result Http.Error (List Book))
    | GetChapters Book
    | NewChapters (Result Http.Error (List Chapter))
    | GetWords Chapter
    | NewWords (Result Http.Error (List Word))
    | SetDate Date
    | FocusResult (Result Dom.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Input newInput ->
            ( { model | textInput = newInput }, Cmd.none )

        ChangeFromLanguage newFromLanguage ->
            ( { model | fromLanguage = newFromLanguage }, Cmd.none )

        ChangeToLanguage newToLanguage ->
            ( { model | toLanguage = newToLanguage }, Cmd.none )

        ToggleLazy ->
            ( { model | lazy = not model.lazy }, Cmd.none )

        Correct ->
            let
                nextWordModel =
                    nextWord model
            in
                ( { nextWordModel
                    | correct = model.currentWord :: model.correct
                    , textInput = ""
                  }
                , Cmd.none
                )

        Wrong ->
            let
                nextWordModel =
                    nextWord model
            in
                ( { nextWordModel
                    | wrong = model.currentWord :: model.wrong
                    , textInput = ""
                  }
                , Cmd.none
                )

        NextWord ->
            ( (nextWord model), Cmd.none )

        GetBooks ->
            ( model, getBooks )

        NewBooks (Ok books) ->
            ( { model | bookList = books }, Cmd.none )

        NewBooks (Err _) ->
            ( model, Cmd.none )

        GetChapters book ->
            ( model, getChapters book )

        NewChapters (Ok chapters) ->
            ( { model | chapterList = chapters }, Cmd.none )

        NewChapters (Err _) ->
            ( model, Cmd.none )

        GetWords chapter ->
            ( model, Cmd.batch [ getWords chapter, Dom.focus "wordInput" |> Task.attempt FocusResult ] )

        NewWords (Ok words) ->
            ( (nextWord { model | wordList = words, unAnswered = words }), Cmd.none )

        NewWords (Err _) ->
            ( model, Cmd.none )

        SetDate date ->
            ( { model | date = Just date }, Cmd.none )

        FocusResult result ->
            ( model, Cmd.none )


nextWord : Model -> Model
nextWord model =
    { model
        | currentWord =
            case List.head model.unAnswered of
                Nothing ->
                    emptyWord

                Just head ->
                    head
        , unAnswered =
            case List.tail model.unAnswered of
                Nothing ->
                    []

                Just tail ->
                    tail
    }


isEmptyWord : Word -> Bool
isEmptyWord word =
    word == emptyWord


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


targetValueLanguageDecoder : Json.Decode.Decoder Language
targetValueLanguageDecoder =
    Html.Events.targetValue
        |> Json.Decode.andThen
            (\val ->
                case val of
                    "English" ->
                        Json.Decode.succeed English

                    "Spanish" ->
                        Json.Decode.succeed Spanish

                    "Norwegian" ->
                        Json.Decode.succeed Norwegian

                    _ ->
                        Json.Decode.fail ("Invalid Role: " ++ val)
            )


view : Model -> Html Msg
view model =
    div [ class "wrapper" ]
        [ div [ class "container" ]
            [ div [ class "row row-white" ] [ div [ id "logo" ] [ img [ src "assets/glossary_logo.svg" ] [] ] ]
            , div [ class "row row-yellow" ]
                [ div [ id "language" ]
                    [ select [ name "fromLanguage", on "change" (Json.Decode.map ChangeFromLanguage targetValueLanguageDecoder) ]
                        (List.map
                            (\language -> languageOption (toString language) (language == model.fromLanguage))
                            availableLanguages
                        )
                    , i [ class "fa fa-long-arrow-right fa-2" ] []
                    , select [ name "toLanguage", on "change" (Json.Decode.map ChangeToLanguage targetValueLanguageDecoder) ]
                        (List.map
                            (\language -> languageOption (toString language) (language == model.toLanguage))
                            availableLanguages
                        )
                    ]
                ]
            , div [ class "row row-green" ]
                [ div [ id "translate" ]
                    [ h2 [ id "currentWord" ]
                        [ case (isEmptyWord model.currentWord) of
                            False ->
                                text (fromWord model)

                            True ->
                                text "No wordlist selected"
                        ]
                    , input
                        [ id "wordInput"
                        , type_ "text"
                        , onInput Input
                        , value model.textInput
                        , case (isEmptyWord model.currentWord) of
                            False ->
                                onEnter (checkInputWord model)

                            True ->
                                disabled True
                        ]
                        []
                    , div [] [ input [ type_ "checkbox", onClick (ToggleLazy), checked model.lazy, id "lazy", name "lazy" ] [], label [ for "lazy" ] [ text "Lazy" ] ]
                    ]
                ]
            , div [ class "row row-orange" ]
                [ viewSessionInformation model ]
            , div [ class "row row-light-pink" ]
                [ viewBooks model.bookList ]
            , div [ class "row row-pink" ]
                [ viewChapters model.chapterList ]
            , viewFooter model
            ]
        ]


now : Cmd Msg
now =
    Task.perform SetDate Date.now


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


viewSessionInformation : Model -> Html Msg
viewSessionInformation model =
    div [ id "stats" ]
        [ h5 [] [ text ("Correct: " ++ (toString (List.length model.correct))) ]
        , h5 [] [ text ("Wrong: " ++ (toString (List.length model.wrong))) ]
        , h5 [] [ text ("Left: " ++ (toString (List.length model.unAnswered))) ]
        , h5 [] [ text ("Total: " ++ (toString (List.length model.wordList))) ]
        ]


viewBooks : List Book -> Html Msg
viewBooks books =
    div [ id "books" ]
        [ case List.length books of
            0 ->
                div [] [ h3 [] [ text "No books available" ] ]

            _ ->
                div []
                    [ h3 [] [ text "Select book: " ]
                    , div [] (List.map (\book -> viewBook book) books)
                    ]
        ]


viewBook : Book -> Html Msg
viewBook book =
    div [ class "book", onClick (GetChapters book) ]
        [ h4 [] [ text book.title ]
        ]


viewChapters : List Chapter -> Html Msg
viewChapters chapters =
    div [ id "chapters" ]
        [ case List.length chapters of
            0 ->
                div [] [ h3 [] [ text "No book has been selected" ] ]

            _ ->
                div []
                    [ h3 [] [ text "Select chapter: " ]
                    , div [] (List.map (\chapter -> viewChapter chapter) chapters)
                    ]
        ]


viewChapter : Chapter -> Html Msg
viewChapter chapter =
    div [ class "chapter", onClick (GetWords chapter) ]
        [ h4 [] [ text ("Chapter " ++ toString chapter.chapter) ]
        ]


getSpecialCharactersByLanguage : Language -> List SpecialCharacter
getSpecialCharactersByLanguage language =
    case language of
        English ->
            []

        Spanish ->
            spanishSpecialCharacters

        Norwegian ->
            norwegianSpecialCharacters


getSpecialCharactersFromModel : Model -> List SpecialCharacter
getSpecialCharactersFromModel model =
    getSpecialCharactersByLanguage model.toLanguage


getWordByLanguage : Language -> Word -> String
getWordByLanguage language word =
    case language of
        English ->
            word.english

        Spanish ->
            word.spanish

        Norwegian ->
            word.norwegian


fromWord : Model -> String
fromWord model =
    getWordByLanguage model.fromLanguage model.currentWord


toWord : Model -> String
toWord model =
    getWordByLanguage model.toLanguage model.currentWord


checkInputWord : Model -> Msg
checkInputWord model =
    let
        correctWord =
            toWord model

        inputWord =
            String.toLower model.textInput
    in
        case model.lazy of
            False ->
                if correctWord == inputWord then
                    Correct
                else
                    Wrong

            True ->
                let
                    specialCharacters =
                        getSpecialCharactersFromModel model

                    correctWordWithoutSpecial =
                        removeSpecialCharacters correctWord specialCharacters

                    inputWordWithoutSpecial =
                        removeSpecialCharacters inputWord specialCharacters
                in
                    if correctWordWithoutSpecial == inputWordWithoutSpecial then
                        Correct
                    else
                        Wrong


languageOption : String -> Bool -> Html Msg
languageOption language isSelected =
    option [ value language, selected isSelected ] [ text language ]


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


findWord : String -> List Word -> Maybe Word
findWord input wordList =
    List.Extra.find (\word -> input == word.spanish || input == word.english) wordList


removeSpecialCharacters : String -> List SpecialCharacter -> String
removeSpecialCharacters input list =
    case list of
        [] ->
            input

        first :: rest ->
            removeSpecialCharacters (String.Extra.replace first.special first.latin input) rest



-- Api stuff


base_url : String
base_url =
    "/api"


createApiUrl : String -> String
createApiUrl endpoint =
    base_url ++ endpoint ++ ".json"


getBooks : Cmd Msg
getBooks =
    let
        url =
            createApiUrl "/book"

        request =
            Http.get url (list bookDecoder)
    in
        Http.send NewBooks request


bookDecoder : Decoder Book
bookDecoder =
    decode Book
        |> required "title" string
        |> required "chapters" string


getChapters : Book -> Cmd Msg
getChapters book =
    let
        url =
            createApiUrl book.chapters

        request =
            Http.get url (list chapterDecoder)
    in
        Http.send NewChapters request


chapterDecoder : Decoder Chapter
chapterDecoder =
    decode Chapter
        |> required "chapter" int
        |> required "words" string


getWords : Chapter -> Cmd Msg
getWords chapter =
    let
        url =
            createApiUrl chapter.words

        request =
            Http.get url (list wordDecoder)
    in
        Http.send NewWords request


wordDecoder : Decoder Word
wordDecoder =
    decode Word
        |> required "english" string
        |> required "spanish" string
        |> required "norwegian" string
