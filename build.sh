#!/bin/bash
# Baut QuitAll.app (Menüleisten-App ohne Dock-Icon)
set -e
cd "$(dirname "$0")"
swift build -c release
APP=build/QuitAll.app
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS"
cp .build/release/QuitAll "$APP/Contents/MacOS/"
cat > "$APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>QuitAll</string>
<key>CFBundleIdentifier</key><string>local.quitall</string>
<key>CFBundleExecutable</key><string>QuitAll</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>LSUIElement</key><true/>
</dict></plist>
EOF
codesign --force --sign - "$APP"
echo "Fertig: $PWD/$APP"
