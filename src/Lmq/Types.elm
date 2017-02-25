module Lmq.Types exposing (..)


type alias LandmarkQuestion =
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
