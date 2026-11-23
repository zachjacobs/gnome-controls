#!/bin/sh
set -eu
cd "$(dirname "$0")"
app="$HOME/Applications/Chrome Profile Chooser.app"
build=$(mktemp -d)
trap 'rm -rf "$build"' EXIT
bundle="$build/Chrome Profile Chooser.app"
mkdir -p "$bundle/Contents/MacOS"
xcrun swiftc -O -target "$(uname -m)-apple-macos12.0" main.swift -o "$bundle/Contents/MacOS/chooser"
cp Info.plist "$bundle/Contents/"
plutil -lint "$bundle/Contents/Info.plist"
codesign --force --sign - "$bundle"
mkdir -p "$HOME/Applications"
ditto "$bundle" "$app"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app"
echo "In System Settings, search for Default web browser and select Chrome Profile Chooser."
