module Olq.CanvasZoom exposing (..)

import Canvas exposing (Size)
import Util exposing (distance)
import Canvas.Events exposing (Touch)


type alias State =
    { canvasSize : Size
    , imageSize : Size
    , lastZoomScale : Maybe Float
    , last : Maybe { x : Float, y : Float }
    , position : { x : Float, y : Float }
    , scale : { x : Float, y : Float }
    , init : Bool
    , zoom : Maybe Float
    }


initialState : State
initialState =
    { canvasSize = { width = 0, height = 0 }
    , imageSize = { width = 0, height = 0 }
    , position = { x = 0, y = 0 }
    , scale = { x = 1.0, y = 1.0 }
    , lastZoomScale = Nothing
    , last = Nothing
    , init = False
    , zoom = Nothing
    }


gesturePinchZoom : State -> List Touch -> State
gesturePinchZoom state touches =
    case touches of
        [] ->
            { state | zoom = Nothing }

        _ :: [] ->
            { state | zoom = Nothing }

        h :: h2 :: _ ->
            let
                zoomScale =
                    distance ( h.page.x, h.page.y ) ( h2.page.x, h2.page.y )
            in
                case state.lastZoomScale of
                    Nothing ->
                        { state | zoom = Nothing, lastZoomScale = Just zoomScale }

                    Just lzs ->
                        { state | zoom = Just (zoomScale - lzs), lastZoomScale = Just zoomScale }


doZoom : State -> State
doZoom state =
    case state.zoom of
        Nothing ->
            state

        Just z ->
            let
                currentScale =
                    state.scale.x

                newScale =
                    state.scale.x + z / 100

                deltaScale =
                    newScale - currentScale

                currentWidth =
                    toFloat state.imageSize.width * state.scale.x

                currentHeight =
                    toFloat state.imageSize.height * state.scale.y

                deltaWidth =
                    toFloat state.imageSize.width * deltaScale

                deltaHeight =
                    toFloat state.imageSize.height * deltaScale

                canvasMiddelX =
                    toFloat state.canvasSize.width / 2

                canvasMiddelY =
                    toFloat state.canvasSize.height / 2

                xonmap =
                    (-state.position.x) + canvasMiddelX

                yonmap =
                    (-state.position.y) + canvasMiddelY

                coefX =
                    (-xonmap) / (currentWidth)

                coefY =
                    (-yonmap) / (currentHeight)

                newWidth =
                    currentWidth + deltaWidth

                newHeight =
                    currentHeight + deltaHeight

                newPosX =
                    let
                        temp =
                            state.position.x + deltaWidth * coefX
                    in
                        if (temp > 0) then
                            if (newHeight < toFloat state.canvasSize.width) then
                                toFloat state.canvasSize.width - newWidth
                            else
                                0
                        else if ((temp + newWidth) < toFloat state.canvasSize.width) then
                            toFloat state.canvasSize.width - newWidth
                        else
                            temp

                newPosY =
                    let
                        temp =
                            state.position.y + deltaHeight * coefY
                    in
                        if (temp > 0) then
                            if (newHeight < toFloat state.canvasSize.height) then
                                toFloat state.canvasSize.height - newHeight
                            else
                                0
                        else if ((temp + newHeight) < toFloat state.canvasSize.height) then
                            toFloat state.canvasSize.height - newHeight
                        else
                            temp
            in
                if (newWidth < toFloat state.canvasSize.height) then
                    state
                else if (newHeight < toFloat state.canvasSize.height) then
                    state
                else
                    { state | scale = { x = newScale, y = newScale }, position = { x = newPosX, y = newPosY } }


doMove : State -> Float -> Float -> State
doMove state relativeX relativeY =
    case state.last of
        Nothing ->
            { state | last = Just { x = relativeX, y = relativeY } }

        Just l ->
            let
                deltaX =
                    relativeX - l.x

                deltaY =
                    relativeY - l.y

                currentWidth =
                    toFloat state.imageSize.width * state.scale.x

                currentHeight =
                    toFloat state.imageSize.height * state.scale.y

                newPosX =
                    let
                        temp =
                            state.position.x + deltaX
                    in
                        if (temp > 0) then
                            0
                        else if ((temp + currentWidth) < toFloat state.canvasSize.width) then
                            toFloat state.canvasSize.width - currentWidth
                        else
                            temp

                newPosY =
                    let
                        temp =
                            state.position.y + deltaY
                    in
                        if (temp > 0) then
                            0
                        else if ((temp + currentHeight) < toFloat state.canvasSize.height) then
                            toFloat state.canvasSize.height - currentHeight
                        else
                            temp
            in
                { state | last = Just { x = relativeX, y = relativeY }, position = { x = newPosX, y = newPosY } }
