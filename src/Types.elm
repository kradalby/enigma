module Types exposing (..)

import Color
import Canvas exposing (Size)


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


type Image
    = Loading
    | GotCanvas Canvas
