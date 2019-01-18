module Snackbar exposing (Model, Msg, action, hidden, link, message, update, view)

import Html exposing (Html, a, div, span, text)
import Html.Attributes exposing (class, href, id)
import Html.Events exposing (onClick)
import Process
import Task
import Time exposing (Posix, now, posixToMillis)


type alias WithAction msg =
    { btn : String
    , ref : msg
    }


type alias WithHref =
    { btn : String
    , ref : String
    }


type alias Snack a =
    { a
        | str : String
        , id : Int
    }


type Model msg
    = None
    | Message (Snack {})
    | Href (Snack WithHref)
    | Action (Snack (WithAction msg))


type Msg msg
    = EndDelay Int
    | StartDelay Float Posix


default_id : Int
default_id =
    -1


message : Maybe Float -> String -> ( Model msg, Cmd (Msg msg) )
message millis str =
    ( Message { str = str, id = default_id }, Maybe.map (\ms -> Task.perform (StartDelay ms) Time.now) millis |> Maybe.withDefault Cmd.none )


link : Maybe Float -> String -> String -> String -> ( Model msg, Cmd (Msg msg) )
link millis str btn target =
    ( Href
        { str = str
        , id = default_id
        , btn = btn
        , ref = target
        }
    , Maybe.map (\ms -> Task.perform (StartDelay ms) Time.now) millis |> Maybe.withDefault Cmd.none
    )


action : Maybe Float -> String -> String -> msg -> ( Model msg, Cmd (Msg msg) )
action millis str btn ref =
    ( Action
        { str = str
        , id = default_id
        , btn = btn
        , ref = ref
        }
    , Maybe.map (\ms -> Task.perform (StartDelay ms) Time.now) millis |> Maybe.withDefault Cmd.none
    )


hidden : Model msg
hidden =
    None


unboxId : Model msg -> Int
unboxId model =
    case model of
        Message { id } ->
            id

        Href { id } ->
            id

        Action { id } ->
            id

        _ ->
            0


update : Msg msg -> Model msg -> ( Model msg, Cmd (Msg msg) )
update msg model =
    case msg of
        EndDelay id_to_hide ->
            if unboxId model == id_to_hide then
                ( None, Cmd.none )

            else
                ( model, Cmd.none )

        StartDelay millis ticks ->
            if unboxId model == default_id then
                let
                    id =
                        posixToMillis ticks
                in
                case model of
                    None ->
                        ( model, Cmd.none )

                    Message x ->
                        ( Message { x | id = id }, Task.perform (always <| EndDelay id) <| Process.sleep millis )

                    Href x ->
                        ( Href { x | id = id }, Task.perform (always <| EndDelay id) <| Process.sleep millis )

                    Action x ->
                        ( Action { x | id = id }, Task.perform (always <| EndDelay id) <| Process.sleep millis )

            else
                ( model, Cmd.none )


view : Model msg -> Html msg
view snack =
    case snack of
        Message { str } ->
            div [ class "snackbar fadein" ]
                [ span [] [ text str ]
                ]

        Href { str, btn, ref } ->
            div [ class "snackbar with_button fadein" ]
                [ span [] [ text str ]
                , a [ class "action", href ref ] [ text btn ]
                ]

        Action { str, btn, ref } ->
            div [ class "snackbar with_button fadein" ]
                [ span [] [ text str ]
                , span [ class "action", onClick ref ] [ text btn ]
                ]

        None ->
            div [ class "snackbar hidden" ]
                [ span [] [ text " " ]
                ]
