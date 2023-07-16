-- Copied from https://github.com/choonkeat/elm-element-navigation/pull/1/files


port module Vendor.Browser.Ports exposing
    ( back
    , forward
    , onLocationChange
    , onLocationRequest
    , pushUrl
    , replaceUrl
    )

import Vendor.Browser exposing (Location)


port pushUrl : ( Float, String ) -> Cmd msg


port replaceUrl : ( Float, String ) -> Cmd msg


port back : ( Float, Int ) -> Cmd msg


port forward : ( Float, Int ) -> Cmd msg


port onLocationChange : (Location -> msg) -> Sub msg


port onLocationRequest : (( Location, Location ) -> msg) -> Sub msg
