-- Copied from https://github.com/choonkeat/elm-element-navigation/pull/1/files


module Vendor.Browser.Navigation exposing
    ( Key
    , SpaFlags
    , back
    , defaultSpaFlags
    , forward
    , load
    , onUrlChange
    , onUrlRequest
    , pushUrl
    , reload
    , reloadAndSkipCache
    , replaceUrl
    , spaFlags
    , spaFlagsDecoder
    )

import Browser.Navigation
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode
import Url
import Vendor.Browser
import Vendor.Browser.Ports


type Key
    = Key Float


type alias SpaFlags =
    { location : Vendor.Browser.Location
    , navKey : Float
    }


spaFlags : SpaFlags -> { url : Url.Url, navKey : Key }
spaFlags flags =
    { url = Vendor.Browser.urlFromLocation flags.location
    , navKey = Key flags.navKey
    }


spaFlagsDecoder : Decoder SpaFlags
spaFlagsDecoder =
    Decode.succeed SpaFlags
        |> Decode.required "location" Vendor.Browser.locationDecoder
        |> Decode.required "navKey" Decode.float


defaultSpaFlags : SpaFlags
defaultSpaFlags =
    { location = Vendor.Browser.defaultLocation, navKey = 0 }


pushUrl : Key -> String -> Cmd msg
pushUrl (Key k) arg =
    Vendor.Browser.Ports.pushUrl ( k, arg )


replaceUrl : Key -> String -> Cmd msg
replaceUrl (Key k) arg =
    Vendor.Browser.Ports.replaceUrl ( k, arg )


back : Key -> Int -> Cmd msg
back (Key k) arg =
    Vendor.Browser.Ports.back ( k, arg )


forward : Key -> Int -> Cmd msg
forward (Key k) arg =
    Vendor.Browser.Ports.forward ( k, arg )


onUrlChange : (Url.Url -> msg) -> Sub msg
onUrlChange msg =
    Vendor.Browser.Ports.onLocationChange (Vendor.Browser.urlFromLocation >> msg)


onUrlRequest : (Vendor.Browser.UrlRequest -> msg) -> Sub msg
onUrlRequest msg =
    Vendor.Browser.Ports.onLocationRequest
        (\( before, after ) ->
            if
                (before.protocol == after.protocol)
                    && (before.host == after.host)
                    && (before.port_ == after.port_)
            then
                msg (Vendor.Browser.Internal (Vendor.Browser.urlFromLocation after))

            else
                msg (Vendor.Browser.External (Url.toString (Vendor.Browser.urlFromLocation after)))
        )


load : String -> Cmd msg
load =
    Browser.Navigation.load


reload : Cmd msg
reload =
    Browser.Navigation.reload


reloadAndSkipCache : Cmd msg
reloadAndSkipCache =
    Browser.Navigation.reloadAndSkipCache
