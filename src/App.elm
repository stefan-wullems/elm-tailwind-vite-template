module App exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attrs
import Json.Decode as Decode exposing (Decoder, Value)
import Json.Decode.Pipeline as Decode
import Router
import Url exposing (Url)
import Vendor.Browser exposing (UrlRequest)
import Vendor.Browser.Navigation as Navigation


main : Program Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always subscriptions
        }


type alias Flags =
    { spaFlags : Navigation.SpaFlags
    }


type alias Model =
    { routerModel : Router.Model
    }


type Msg
    = UrlChanged Url
    | ClickedLink UrlRequest
    | RouterMsg Router.Msg


init : Value -> ( Model, Cmd Msg )
init flagsValue =
    let
        { url, navKey } =
            case Decode.decodeValue decodeFlags flagsValue of
                Ok flags ->
                    Navigation.spaFlags flags.spaFlags

                Err _ ->
                    Navigation.spaFlags Navigation.defaultSpaFlags

        ( routerModel, routerCmd ) =
            Router.init url navKey
    in
    ( { routerModel = routerModel }
    , routerCmd
    )


decodeFlags : Decoder Flags
decodeFlags =
    Decode.succeed Flags
        |> Decode.required "spaFlags" Navigation.spaFlagsDecoder


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Navigation.onUrlRequest ClickedLink
        , Navigation.onUrlChange UrlChanged
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink req ->
            Router.onClickedLink req model.routerModel
                |> Tuple.mapFirst (\newRouterModel -> { model | routerModel = newRouterModel })

        UrlChanged url ->
            Router.onUrlChange url model.routerModel
                |> Tuple.mapFirst (\newRouterModel -> { model | routerModel = newRouterModel })

        RouterMsg msg_ ->
            Router.update
                msg_
                model.routerModel
                |> Tuple.mapFirst (\newRouterModel -> { model | routerModel = newRouterModel })


view : Model -> Html Msg
view model =
    Html.div [ Attrs.class "bg-gray-100 flex h-full" ]
        [ Html.div
            [ Attrs.class "flex flex-col flex-1 overflow-hidden" ]
            [ Html.main_
                [ Attrs.class "flex-1 overflow-y-scroll flex flex-col min-w-0 h-full lg:order-last" ]
                [ Router.view RouterMsg model.routerModel
                ]
            ]
        ]
