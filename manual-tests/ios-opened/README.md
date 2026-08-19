# iOS `URLContexts` panic regression test

This headless Tao app checks the ordinary cold-launch path changed by PR #1257. It creates neither
a window nor a deep link.

Boot an iOS Simulator, then run:

```sh
./test.sh
```

Without the defensive connection-options handling, it panics with:

```text
unexpected NULL returned from -[UISceneConnectionOptions URLContexts]
```

The script fails if that panic occurs and passes after the fix.
