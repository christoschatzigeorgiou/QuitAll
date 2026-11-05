#!/bin/bash
# Baut die App und installiert sie nach /Applications
set -e
cd "$(dirname "$0")"
./build.sh
pid=$(pgrep -x QuitAll || true)
[ -n "$pid" ] && kill "$pid" && sleep 1
rm -rf /Applications/QuitAll.app
cp -R build/QuitAll.app /Applications/QuitAll.app
open /Applications/QuitAll.app
echo "Installiert: /Applications/QuitAll.app"
