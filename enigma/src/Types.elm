module Types exposing (..)

import Color
import Canvas exposing (Canvas, Size)
import Json.Encode as Encode
import Json.Decode as Decode


type alias Region =
    { color : String
    , name : String
    }


canvasSize : Size
canvasSize =
    (Size 601 606)


wrongColor : Color.Color
wrongColor =
    Color.rgba 0 0 0 0


pointBase : Int
pointBase =
    100


errorMessageDelay : Float
errorMessageDelay =
    5


showAnswerDelay : Float
showAnswerDelay =
    3


doubleTapDelay : Float
doubleTapDelay =
    700


initQuestionScore : QuestionScore
initQuestionScore =
    { correct = 0
    , wrong = 0
    , best = 0
    }


type alias QuestionScore =
    { correct : Int
    , wrong : Int
    , best : Int
    }


encodeQuestionScore : QuestionScore -> String
encodeQuestionScore qs =
    Encode.encode 0
        (Encode.object
            [ ( "correct", (Encode.int qs.correct) )
            , ( "wrong", (Encode.int qs.wrong) )
            , ( "best", (Encode.int qs.best) )
            ]
        )


decodeQuestionScore : String -> QuestionScore
decodeQuestionScore str =
    let
        toQS correct wrong best =
            { correct = correct, wrong = wrong, best = best }

        questionScoreDecoder =
            Decode.map3 toQS
                (Decode.field "correct" Decode.int)
                (Decode.field "wrong" Decode.int)
                (Decode.field "best" Decode.int)
    in
        Result.withDefault initQuestionScore (Decode.decodeString questionScoreDecoder str)


type Image
    = Loading
    | GotCanvas Canvas
