module Demo exposing (main)

import Browser
import Html exposing (Html, button, div, p, text)
import Html.Attributes exposing (id)
import Html.Events exposing (onClick)
import Snackbar


type Msg
    = UpdateSnackbar Snackbar.Model
    | SnackMessage Snackbar.Msg


type alias Model =
    { snackbar : Snackbar.Model
    , alert : Maybe String
    }


init : {} -> ( Model, Cmd Msg )
init _ =
    ( { snackbar = Snackbar.None, alert = Nothing }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateSnackbar sb ->
            ( { model | snackbar = sb, alert = Nothing }, Cmd.map SnackMessage <| Snackbar.delay 8000 sb )

        SnackMessage (Snackbar.ButtonClick action_id) ->
            ( { model | snackbar = Snackbar.None, alert = Just <| action_id ++ " was clicked" }, Cmd.none )

        SnackMessage (Snackbar.Hide sb_to_hide) ->
            if Snackbar.equal model.snackbar sb_to_hide then
                ( { model | snackbar = Snackbar.None }, Cmd.none )

            else
                ( model, Cmd.none )


view : Model -> Html Msg
view { snackbar, alert } =
    div [ id "root" ]
        [ button [ onClick <| UpdateSnackbar <| Snackbar.Message "Message only snackbars are used to notify someone. They should make themselves disappear" ] [ text "Snack Message" ]
        , button [ onClick <| UpdateSnackbar <| Snackbar.Href "Href snackbars show a button which navigates to a new address" "DOGS" "http://omfgdogs.com" ] [ text "Snack Href" ]
        , button [ onClick <| UpdateSnackbar <| Snackbar.Action "Action snackbars allow update to process Msgs" "TRY ME" "try me button" ] [ text "Snack Action 1" ]
        , button [ onClick <| UpdateSnackbar <| Snackbar.Action "Action snackbars allow update to process Msgs. They send a key to the update dn so you can tell which action was trigger." "YO!" "yo button" ] [ text "Snack Action 2" ]
        , p [] [ text (Maybe.withDefault "" alert) ]
        , Snackbar.view snackbar
            |> Html.map SnackMessage
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
