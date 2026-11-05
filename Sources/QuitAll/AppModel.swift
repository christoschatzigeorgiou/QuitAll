import AppKit
import SwiftUI
import ServiceManagement

struct RunningItem: Identifiable {
    let id: pid_t
    let app: NSRunningApplication
    var name: String { app.localizedName ?? app.bundleIdentifier ?? "?" }
    var icon: NSImage? { app.icon }
}

@MainActor
final class AppModel: ObservableObject {
    @Published var items: [RunningItem] = []
    @Published var optionDown = false
    @Published var selection: Set<pid_t> = []

    @AppStorage("showBackground") var showBackground = false {
        didSet { refresh() }
    }
    @AppStorage("autoQuitEnabled") var autoQuitEnabled = false
    @AppStorage("autoQuitMinutes") var autoQuitMinutes = 30
    @AppStorage("excluded") private var excludedRaw = ""

    private var lastActive: [pid_t: Date] = [:]
    private var timer: Timer?
    private var flagsMonitor: Any?

    // Apps that must never be quit by "Quit All" / auto-quit.
    private let protectedIDs: Set<String> = [
        "com.apple.finder", "com.apple.dock", "com.apple.systemuiserver",
        "com.apple.loginwindow", "com.apple.WindowServer"
    ]

    var excluded: Set<String> {
        get { Set(excludedRaw.split(separator: ",").map(String.init)) }
        set { excludedRaw = newValue.sorted().joined(separator: ",") }
    }

    init() {
        refresh()
        let nc = NSWorkspace.shared.notificationCenter
        for n in [NSWorkspace.didLaunchApplicationNotification,
                  NSWorkspace.didTerminateApplicationNotification,
                  NSWorkspace.didActivateApplicationNotification] {
            nc.addObserver(forName: n, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.refresh() }
            }
        }
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.autoQuitTick() }
        }
        flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] e in
            let down = e.modifierFlags.contains(.option)
            Task { @MainActor in self?.optionDown = down }
            return e
        }
    }

    func isProtected(_ app: NSRunningApplication) -> Bool {
        app.processIdentifier == ProcessInfo.processInfo.processIdentifier
            || protectedIDs.contains(app.bundleIdentifier ?? "")
    }

    func refresh() {
        let policies: [NSApplication.ActivationPolicy] = showBackground ? [.regular, .accessory] : [.regular]
        let apps = NSWorkspace.shared.runningApplications.filter {
            policies.contains($0.activationPolicy) && !isProtected($0) && !$0.isTerminated
        }
        if let front = NSWorkspace.shared.frontmostApplication { lastActive[front.processIdentifier] = Date() }
        for a in apps where lastActive[a.processIdentifier] == nil { lastActive[a.processIdentifier] = Date() }
        selection.formIntersection(apps.map { $0.processIdentifier })
        items = apps.map { RunningItem(id: $0.processIdentifier, app: $0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func quit(_ item: RunningItem, force: Bool? = nil) {
        if force ?? optionDown { item.app.forceTerminate() } else { item.app.terminate() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.refresh() }
    }

    func toggleSelected(_ item: RunningItem) {
        if selection.contains(item.id) { selection.remove(item.id) } else { selection.insert(item.id) }
    }

    func quitSelected() {
        for i in items where selection.contains(i.id) { quit(i) }
        selection.removeAll()
    }

    func quitAll() {
        for i in items where !isExcluded(i) { quit(i) }
    }

    func toggleExcluded(_ item: RunningItem) {
        guard let id = item.app.bundleIdentifier else { return }
        var e = excluded
        if e.contains(id) { e.remove(id) } else { e.insert(id) }
        excluded = e
        objectWillChange.send()
    }

    func isExcluded(_ item: RunningItem) -> Bool { excluded.contains(item.app.bundleIdentifier ?? "") }

    private func autoQuitTick() {
        guard autoQuitEnabled else { return }
        refresh()
        let limit = TimeInterval(autoQuitMinutes * 60)
        let front = NSWorkspace.shared.frontmostApplication?.processIdentifier
        for i in items where i.app.activationPolicy == .regular && i.id != front && !isExcluded(i) {
            if Date().timeIntervalSince(lastActive[i.id] ?? Date()) > limit { i.app.terminate() }
        }
    }

    var launchAtLogin: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set {
            try? newValue ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister()
            objectWillChange.send()
        }
    }
}
