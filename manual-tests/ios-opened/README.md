# iOS `URLContexts` panic reproduction

This is a headless Tao app for reproducing the ordinary cold-launch panic introduced by PR #1257.
It creates neither a window nor a deep link.

Boot an iOS Simulator, then run:

```sh
./test.sh
```

The script builds and launches the app, prints its log, and checks for:

```text
unexpected NULL returned from -[UISceneConnectionOptions URLContexts]
```
