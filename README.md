# QuitAll

Kleine Menüleisten-App für macOS, um laufende Apps an einem Ort zu beenden – inspiriert von [QuitAll von Amico Apps](https://amicoapps.com/app/quitall/). Eigenständiger Nachbau, kein offizielles Produkt.

## Funktionen

- Liste aller laufenden Apps mit Icon
- Einzelne App beenden, **mehrere Apps per Checkbox auswählen** und gemeinsam beenden oder **alle** beenden
- **⌥ (Option)** gedrückt halten: „Beenden“ wird zu „Erzwingen“ (Force Quit); auch per Rechtsklick
- Auto-Quit: inaktive Apps nach einstellbarer Zeit (5–600 Min.) beenden
- Hintergrund-Apps ein-/ausblenden
- Ausnahmen per Rechtsklick (von „Alle beenden“ und Auto-Quit ausgenommen)
- Optional beim Login starten
- Finder, Dock und QuitAll selbst werden nie beendet

## Voraussetzungen

macOS 13 oder neuer, Xcode bzw. Command Line Tools (Swift 5.9+).

## Installation

```bash
git clone https://github.com/christoschatzigeorgiou/QuitAll.git
cd QuitAll
./install.sh
```

Das Skript baut die App, kopiert sie nach `/Applications/QuitAll.app` und startet sie. Nur bauen (ohne Installation): `./build.sh` → `build/QuitAll.app`.

Die App ist ad-hoc signiert. Wird sie beim ersten Start von Gatekeeper blockiert: Rechtsklick auf die App → „Öffnen“.

## Beim Mac-Start laden

Zahnrad-Symbol im Popover → **„Beim Login starten“** aktivieren. Alternativ: Systemeinstellungen → Allgemein → Anmeldeobjekte. Das funktioniert am zuverlässigsten, wenn die App in `/Applications` liegt.

## Lizenz

MIT
