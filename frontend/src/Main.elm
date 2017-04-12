module Main exposing (main)

import Html
import App.State
import App.View
import App.Types exposing (..)


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = App.State.init
        , update = App.State.update
        , subscriptions = App.State.subscriptions
        , view = App.View.root
        }
