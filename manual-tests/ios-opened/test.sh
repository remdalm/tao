#!/usr/bin/env bash
set -euo pipefail

sample_dir=$(cd "$(dirname "$0")" && pwd)
repo_dir=$(cd "$sample_dir/../.." && pwd)
app_bundle="$sample_dir/build/TaoOpenedTest.app"
bundle_id="dev.tao.opened-test"
executable_name="ios_opened_test"

case "$(uname -m)" in
  arm64)
    rust_target="aarch64-apple-ios-sim"
    ;;
  x86_64)
    rust_target="x86_64-apple-ios"
    ;;
  *)
    echo "unsupported macOS architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

rustup target add "$rust_target"
cargo build \
  --manifest-path "$repo_dir/Cargo.toml" \
  --example ios_opened_test \
  --target "$rust_target"

mkdir -p "$app_bundle"
cp "$sample_dir/Info.plist" "$app_bundle/Info.plist"
cp \
  "$repo_dir/target/$rust_target/debug/examples/$executable_name" \
  "$app_bundle/$executable_name"
chmod 755 "$app_bundle/$executable_name"
codesign --force --sign - --timestamp=none "$app_bundle"

xcrun simctl install booted "$app_bundle"
xcrun simctl terminate booted "$bundle_id" >/dev/null 2>&1 || true
xcrun simctl launch booted "$bundle_id"
sleep 2

data_container=$(xcrun simctl get_app_container booted "$bundle_id" data)
log_file="$data_container/tmp/tao-opened-test.log"
sed -n '1,80p' "$log_file"

if grep -Fq 'PANIC' "$log_file"; then
  echo "FAIL: ordinary cold launch panicked" >&2
  exit 1
fi

grep -Fq 'EVENT_LOOP_INIT' "$log_file"
echo "PASS: ordinary cold launch did not panic"
