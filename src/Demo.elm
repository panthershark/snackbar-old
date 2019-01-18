module Demo exposing (main)

import Browser
import Html exposing (Html, button, div, p, text)
import Html.Attributes exposing (id)
import Html.Events exposing (onClick)
import Snackbar


type Msg
    = Snackage
    | Snacklink
    | Snaction1
    | Snaction2
    | SnackMessage (Snackbar.Msg Msg)
    | EchoAction String


type alias Model =
    { snackbar : Snackbar.Model Msg
    , alert : Maybe String
    }


init : {} -> ( Model, Cmd Msg )
init _ =
    ( { snackbar = Snackbar.hidden, alert = Nothing }, Cmd.none )


sbDelay : Maybe Float
sbDelay =
    Just 8000


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Snackage ->
            let
                ( sb, cmd ) =
                    Snackbar.message sbDelay "Snackbars should make themselves disappear. This one has an 8 second delay."
            in
            ( { model | snackbar = sb, alert = Nothing }, Cmd.map SnackMessage cmd )

        Snacklink ->
            let
                ( sb, cmd ) =
                    Snackbar.link sbDelay "Link snackbars show a button which navigates to a new address" "DOGS" "http://omfgdogs.com"
            in
            ( { model | snackbar = sb, alert = Nothing }, Cmd.map SnackMessage cmd )

        Snaction1 ->
            let
                ( sb, cmd ) =
                    Snackbar.action sbDelay "Action snackbars allow update to process Msgs" "TRY ME" (EchoAction "try me button")
            in
            ( { model | snackbar = sb, alert = Nothing }, Cmd.map SnackMessage cmd )

        Snaction2 ->
            let
                ( sb, cmd ) =
                    Snackbar.action sbDelay "Action snackbars allow update to process Msgs. They send a key to the update dn so you can tell which action was trigger." "YO!" (EchoAction "yo button")
            in
            ( { model | snackbar = sb, alert = Nothing }, Cmd.map SnackMessage cmd )

        EchoAction str ->
            ( { model | alert = Just <| str ++ " was clicked" }, Cmd.none )

        SnackMessage submsg ->
            let
                ( sb, cmd ) =
                    Snackbar.update submsg model.snackbar
            in
            ( { model | snackbar = sb }, Cmd.map SnackMessage cmd )


view : Model -> Html Msg
view { snackbar, alert } =
    div [ id "root" ]
        [ button [ onClick Snackage ] [ text "Snack Message" ]
        , button [ onClick Snacklink ] [ text "Snack Href" ]
        , button [ onClick Snaction1 ] [ text "Snack Action 1" ]
        , button [ onClick Snaction2 ] [ text "Snack Action 2" ]
        , p [] [ text (Maybe.withDefault "" alert) ]
        , Snackbar.view snackbar
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program {} Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
