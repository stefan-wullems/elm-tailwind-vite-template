module Router exposing (..)

import Html exposing (..)
import Html.Attributes as Attrs
import Url exposing (Protocol(..), Url)
import Url.Builder as UB
import Url.Parser as UP
import Vendor.Browser
import Vendor.Browser.Navigation as Navigation



{-
   Principles of routing:
   - The url is the source of truth. When it changes, we must accomodate those changes.
   - We take the url at face value. We don't redirect to a `/not-found` route if it is invalid, nor do we fill it with default query parameters.
   - Each page is exactly one level down the router. No nested container stuff. We do this to avoid glue code.
   - We navigate mostly by clicking links and avoid navigating by pushing urls
-}


type Route
    = BadInit
    | Home


type alias Model =
    { route : Maybe Route
    , navKey : Navigation.Key
    }


type Msg
    = UrlChanged Url


onClickedLink : Vendor.Browser.UrlRequest -> Model -> ( Model, Cmd msg )
onClickedLink req model =
    case req of
        Vendor.Browser.Internal url ->
            ( model, Navigation.pushUrl model.navKey (Url.toString url) )

        Vendor.Browser.External href ->
            ( model, Navigation.load href )


init : Url -> Navigation.Key -> ( Model, Cmd msg )
init url navKey =
    ( { route = parseUrl url, navKey = navKey }, Cmd.none )


type alias SimpleUrl =
    { path : List String
    , query : List UB.QueryParameter
    , fragment : Maybe String
    }


replaceUrl : Url -> SimpleUrl -> Url
replaceUrl url simpleUrl =
    let
        query =
            if List.isEmpty simpleUrl.query then
                Nothing

            else
                Just <| String.dropLeft 1 <| UB.toQuery simpleUrl.query

        path =
            "/" ++ String.join "/" simpleUrl.path
    in
    { url | query = query, path = path, fragment = simpleUrl.fragment }


urlFromRoute : Route -> Url
urlFromRoute route =
    case route of
        Home ->
            { path = "/", query = Nothing, fragment = Nothing, protocol = Http, host = "localhost", port_ = Just 8000 }

        BadInit ->
            { path = "/bad-init", query = Nothing, fragment = Nothing, protocol = Http, host = "localhost", port_ = Just 8000 }


onUrlChange : Url -> Model -> ( Model, Cmd msg )
onUrlChange url model =
    update (UrlChanged url) model


parseUrl : Url -> Maybe Route
parseUrl url =
    if Vendor.Browser.isDefaultUrl url then
        Just BadInit

    else
        UP.parse
            (UP.oneOf
                [ UP.map Home UP.top
                ]
            )
            url


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        UrlChanged url ->
            -- call the onRouteChange function of the current page
            ( { model | route = parseUrl url }, Cmd.none )


view : (Msg -> msg) -> Model -> Html msg
view embed model =
    let
        header text =
            Html.div [ Attrs.class "mx-auto pb-6" ]
                [ Html.h1 [ Attrs.class "text-2xl font-semibold text-gray-900" ] [ Html.text text ]
                ]
    in
    case model.route of
        Just Home ->
            header "Hello world"

        Just BadInit ->
            text "Bad init"

        Nothing ->
            text "Not found"
