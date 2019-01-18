module Snackbar exposing (Model(..), Msg(..), delay, equal, view)

import Html exposing (Html, a, div, span, text)
import Html.Attributes exposing (class, href, id)
import Html.Events exposing (onClick)
import Process
import Task


type Model
    = None
    | Message String
    | Href String String String
    | Action String String String


type Msg
    = ButtonClick String
    | Hide Model


delay : Float -> Model -> Cmd Msg
delay millis sb =
    Task.perform (always <| Hide sb) <| Process.sleep millis


equal : Model -> Model -> Bool
equal m n =
    case ( m, n ) of
        ( None, None ) ->
            True

        ( Message j, Message k ) ->
            j == k

        ( Href a b c, Href x y z ) ->
            a == x && b == y && c == z

        ( Action a b c, Action x y z ) ->
            a == x && b == y && c == z

        ( _, _ ) ->
            False


view : Model -> Html Msg
view snack =
    case snack of
        Message message ->
            div [ class "snackbar fadein" ]
                [ span [] [ text message ]
                ]

        Href message btn_text target_href ->
            div [ class "snackbar with_button fadein" ]
                [ span [] [ text message ]
                , a [ class "action", href target_href ] [ text btn_text ]
                ]

        Action message btn_text tag ->
            div [ class "snackbar with_button fadein" ]
                [ span [] [ text message ]
                , span [ class "action", onClick <| ButtonClick tag ] [ text btn_text ]
                ]

        None ->
            div [ class "snackbar hidden" ]
                [ span [] [ text " " ]
                ]
