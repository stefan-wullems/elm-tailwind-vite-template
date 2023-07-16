-- Copied from https://github.com/choonkeat/elm-element-navigation/pull/1/files


port module Vendor.Browser exposing
    ( Location
    , UrlRequest(..)
    , defaultLocation
    , isDefaultUrl
    , locationDecoder
    , setPageTitle
    , style
    , urlFromLocation
    )

import Html
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode
import Url


type UrlRequest
    = Internal Url.Url
    | External String


{-| maps to properties that we get from window.location or a <a href/> element
...except for `port` vs `port_`
-}
type alias Location =
    { protocol : String
    , host : String
    , port_ : String
    , pathname : String
    , search : String
    , hash : String
    }


locationDecoder : Decoder Location
locationDecoder =
    Decode.succeed Location
        |> Decode.required "protocol" Decode.string
        |> Decode.required "host" Decode.string
        |> Decode.required "port_" Decode.string
        |> Decode.required "pathname" Decode.string
        |> Decode.required "search" Decode.string
        |> Decode.required "hash" Decode.string


{-| used only for default after decoding fails, which should never happen
-}
defaultLocation : Location
defaultLocation =
    { protocol = ""
    , host = ""
    , port_ = ""
    , pathname = ""
    , search = ""
    , hash = ""
    }


isDefaultUrl : Url.Url -> Bool
isDefaultUrl url =
    url == urlFromLocation defaultLocation


{-| the nice thing about `Location` is that it can pass through ports
and be converted into Url.Url plainly
-}
urlFromLocation : Location -> Url.Url
urlFromLocation location =
    let
        nothingIfBlank s =
            case String.trim s of
                "" ->
                    Nothing

                notBlank ->
                    Just notBlank

        chompLeft substr string =
            if String.startsWith substr string then
                String.dropLeft (String.length substr) string

            else
                string
    in
    { protocol =
        if location.protocol == "https:" then
            Url.Https

        else
            Url.Http
    , host = location.host
    , port_ = Maybe.andThen String.toInt (nothingIfBlank location.port_)
    , path = location.pathname
    , query = Maybe.map (chompLeft "?") (nothingIfBlank location.search)
    , fragment = Maybe.map (chompLeft "#") (nothingIfBlank location.hash)
    }


port setPageTitle : String -> Cmd msg


style : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
style attr child =
    Html.div [] [ Html.node "style" attr child ]
