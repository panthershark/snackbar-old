module Snackbar exposing (AutoHide(..), Msg, Snackbar, action, hidden, link, message, update, view, visible)

import Html exposing (Html, a, div, span, text)
import Html.Attributes exposing (class, href)
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



{-
   The Snackbar model
-}


type Snackbar msg
    = None
    | Message (Snack {})
    | Href (Snack WithHref)
    | Action (Snack (WithAction msg))



{-
   The Snackbar msgs
-}


type Msg msg
    = EndDelay Int
    | StartDelay Float Posix


default_id : Int
default_id =
    -1



{-
   There are 3 options for auto-hide.

   ShowForever: Don't issue a timeout Cmd. Snackbar will show until programmatically hidden
   CustomDelay: Set your own value. ex: hide after 6s `Snackbar.CustomDelay 6000`
   DefaultDelay: Use a default value for auto-hiding the snackbar. actions have longer delay so users have time to click.
     - `Snackbar.action` default hides after 10s
     - `Snackbar.link` default hides after 10s
-}


type AutoHide
    = ShowForever
    | DefaultDelay
    | CustomDelay Float


delayCmd : Float -> Cmd (Msg msg)
delayCmd ms =
    Task.perform (StartDelay ms) Time.now



{-
   Show a snackbar with only a message.
-}


message : AutoHide -> String -> ( Snackbar msg, Cmd (Msg msg) )
message delay str =
    ( Message { str = str, id = default_id }
    , case delay of
        ShowForever ->
            Cmd.none

        DefaultDelay ->
            delayCmd 4000

        CustomDelay ms ->
            delayCmd ms
    )



{-
   Show a snackbar with a link to another url
-}


link : AutoHide -> String -> String -> String -> ( Snackbar msg, Cmd (Msg msg) )
link delay str btn target =
    ( Href
        { str = str
        , id = default_id
        , btn = btn
        , ref = target
        }
    , case delay of
        ShowForever ->
            Cmd.none

        DefaultDelay ->
            delayCmd 10000

        CustomDelay ms ->
            delayCmd ms
    )



{-
   Show a snackbar with a button that issues a msg
-}


action : AutoHide -> String -> String -> msg -> ( Snackbar msg, Cmd (Msg msg) )
action delay str btn ref =
    ( Action
        { str = str
        , id = default_id
        , btn = btn
        , ref = ref
        }
    , case delay of
        ShowForever ->
            Cmd.none

        DefaultDelay ->
            delayCmd 10000

        CustomDelay ms ->
            delayCmd ms
    )



{--
Hide the snackbar
--}


hidden : Snackbar msg
hidden =
    None


unboxId : Snackbar msg -> Int
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



{-
   Tells if the snackbar currently visible.
-}


visible : Snackbar msg -> Bool
visible mod =
    case mod of
        None ->
            False

        _ ->
            True



{-
    Update function for mapping into your app's update

   type Msg =
       nackMessage (Snackbar.Msg Msg)


   SnackMessage submsg ->
         let
             ( sb, cmd ) =
                 Snackbar.update submsg model.snackbar
         in
         ( { model | snackbar = sb }, Cmd.map SnackMessage cmd )
-}


update : Msg msg -> Snackbar msg -> ( Snackbar msg, Cmd (Msg msg) )
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



{-
   Render a snackbar. Typical usage:

   Html.map SnackMessage <| Snackbar.view model.snackbar
-}


view : Snackbar msg -> Html msg
view snack =
    case snack of
        Message { str } ->
            div [ class "snackbar sb_message" ]
                [ span [] [ text str ]
                ]

        Href { str, btn, ref } ->
            div [ class "snackbar sb_with_action" ]
                [ span [] [ text str ]
                , a [ class "sb_action", href ref ] [ text btn ]
                ]

        Action { str, btn, ref } ->
            div [ class "snackbar sb_with_action" ]
                [ span [] [ text str ]
                , span [ class "sb_action", onClick ref ] [ text btn ]
                ]

        None ->
            div [ class "snackbar sb_hidden" ]
                [ span [] [ text " " ]
                ]
