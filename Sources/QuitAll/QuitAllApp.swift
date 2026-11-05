import SwiftUI

@main
struct QuitAllApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        MenuBarExtra("QuitAll", systemImage: "power.circle") {
            ContentView().environmentObject(model)
        }
        .menuBarExtraStyle(.window)
    }
}

struct ContentView: View {
    @EnvironmentObject var model: AppModel
    @StateObject private var ui = Flag()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Laufende Apps (\(model.items.count))").font(.headline)
                Spacer()
                Button { ui.on.toggle() } label: { Image(systemName: "gearshape") }
                    .buttonStyle(.borderless)
            }
            .padding(10)
            Divider()

            if ui.on {
                SettingsView().environmentObject(model)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(model.items) { item in AppRow(item: item) }
                    }
                }
                .frame(height: min(CGFloat(model.items.count) * 36 + 4, 420))
                Divider()
                HStack {
                    Text("⌥ = erzwingen")
                        .font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Button(model.optionDown ? "Auswahl erzwingen" : "Auswahl beenden") {
                        model.quitSelected()
                    }
                    .disabled(model.selection.isEmpty)
                    Button(model.optionDown ? "Alle erzwingen" : "Alle beenden") {
                        model.quitAll()
                    }
                }
                .padding(10)
            }
            Divider()
            Button("QuitAll schließen") { NSApplication.shared.terminate(nil) }
                .buttonStyle(.borderless).padding(8)
        }
        .frame(width: 340)
    }
}

struct AppRow: View {
    @EnvironmentObject var model: AppModel
    let item: RunningItem
    @StateObject private var h = Flag()

    var body: some View {
        HStack(spacing: 8) {
            Toggle("", isOn: Binding(get: { model.selection.contains(item.id) },
                                     set: { _ in model.toggleSelected(item) }))
                .toggleStyle(.checkbox).labelsHidden()
            if let icon = item.icon {
                Image(nsImage: icon).resizable().frame(width: 24, height: 24)
            }
            Text(item.name).lineLimit(1)
            if model.isExcluded(item) {
                Image(systemName: "lock.fill").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button(model.optionDown ? "Erzwingen" : "Beenden") { model.quit(item) }
                .tint(model.optionDown ? .red : nil)
        }
        .padding(.horizontal, 10).padding(.vertical, 4)
        .background(h.on ? Color.primary.opacity(0.07) : .clear)
        .onHover { h.on = $0 }
        .contextMenu {
            Button(model.isExcluded(item) ? "Von Ausnahmen entfernen" : "Von „Alle beenden“ ausnehmen") {
                model.toggleExcluded(item)
            }
            Button("Beenden erzwingen") { model.quit(item, force: true) }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        Form {
            Toggle("Hintergrund-Apps anzeigen", isOn: $model.showBackground)
            Toggle("Inaktive Apps automatisch beenden", isOn: $model.autoQuitEnabled)
            Stepper("Nach \(model.autoQuitMinutes) Min. Inaktivität",
                    value: $model.autoQuitMinutes, in: 5...600, step: 5)
                .disabled(!model.autoQuitEnabled)
            Toggle("Beim Login starten", isOn: Binding(
                get: { model.launchAtLogin }, set: { model.launchAtLogin = $0 }))
            Text("Rechtsklick auf eine App: von „Alle beenden“ und Auto-Quit ausnehmen.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(12)
    }
}

final class Flag: ObservableObject { @Published var on = false }
