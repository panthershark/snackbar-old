# Get Started

```
yarn install
yarn run start
```

It should automatically open the browser to the demo. If not, go here `http://localhost:8000`

# How to create a snackbar

According to Materail spec, snackbars should hide themselves. Allowing them to be closed is int he Caution section. We support both options.

To accomplish this and keep consurrent timeouts staight, use the factory functions.

Assume a setup like:
```
import Snackbar

type alias Model = {
  snackbar: Snackbar.Model
}

type Msg = 
  SnackMessage (Snackbar.Msg Msg)
  | CustomAction


update msg model = 
    case msg of 
        SomeAppMessage ->
            let
                ( sb, cmd ) =
                    Snackbar.message (Just 8000) "Hello World!"
            in
            ( { model | snackbar = sb }, Cmd.map SnackMessage cmd )
            
        CustomAction -> 
          (model, doSomething)
```

### Snackbar with no action button

```
Snackbar.message (Just 8000) "I'm a plain message."
```

### Snackbar with anchor for action button

```
Snackbar.link (Just 8000) "I'm a message with a link to a url" "YO" "http://giphy.com"
```

### Snackbar that sends a message to update for action button
In this case, the action_ref is passed to the Snackbar.Msg of `ButtonClick action_ref`. Using this action_ref, an application that could handle multiple actions can distinguish events/intent from different snackbars.

```
Snackbar.action (Just 8000) "I'm a message that triggers an action in the app" "WOAH" CustomAction
```

### Snackbar that shows indefinitely

```
Snackbar.message Nothing "I'm a plain message."
```




# Wanna link it to a project to do integration?

Use symlink (this is what npm link does under the covers)

```
 ln -s /local-path-to/snackbar ./elm-stuff/gitdeps/gitlab.cbancnetwork.com/web/snackbar.git
 ```