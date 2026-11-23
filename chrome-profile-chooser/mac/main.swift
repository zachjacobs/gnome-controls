import AppKit
import SwiftUI

struct Profile: Decodable {
    let name: String
    let user_name: String?
}

struct ChromeState: Decodable {
    struct Profiles: Decodable {
        let info_cache: [String: Profile]
    }
    let profile: Profiles
}

struct ProfileRow: View {
    let profile: Profile
    let directory: String
    let tint: Color
    let select: () -> Void
    @State private var hovering = false

    var body: some View {
        let account = profile.user_name.flatMap { $0.isEmpty ? nil : $0 } ?? directory
        Button(action: select) {
            HStack(spacing: 14) {
                Text(String(account.prefix(1)).uppercased())
                    .font(.headline).foregroundColor(tint)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(tint.opacity(0.16)))
                VStack(alignment: .leading, spacing: 3) {
                    Text(profile.name).font(.headline)
                    Text(account).font(.subheadline).foregroundColor(Color(white: 0.76))
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.secondary)
            }
            .padding(.horizontal, 14).frame(height: 64)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(white: hovering ? 0.26 : 0.20)))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(hovering ? 0.36 : 0.10)))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }
}

final class Chooser: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var windows: [NSWindow] = []

    func windowWillClose(_ notification: Notification) {
        if let closing = notification.object as? NSWindow {
            windows.removeAll { $0 === closing }
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        let links = urls.filter { url in
            ["http", "https"].contains(url.scheme?.lowercased() ?? "") ||
                (url.isFileURL && ["html", "htm"].contains(url.pathExtension.lowercased()))
        }
        guard !links.isEmpty else { return }
        do {
            let support = try FileManager.default.url(for: .applicationSupportDirectory,
                in: .userDomainMask, appropriateFor: nil, create: false)
            let state = support.appendingPathComponent("Google/Chrome/Local State")
            let profiles = try JSONDecoder().decode(ChromeState.self, from: Data(contentsOf: state)).profile.info_cache
            guard !profiles.isEmpty else { throw CocoaError(.fileReadNoSuchFile) }
            show(profiles, links: links)
        } catch {
            alert("Could not read your Chrome profiles", "Open Google Chrome and create a profile, then try the link again.")
        }
    }

    func alert(_ title: String, _ detail: String) {
        NSApp.activate(ignoringOtherApps: true)
        let message = NSAlert()
        message.messageText = title
        message.informativeText = detail
        message.runModal()
    }

    func show(_ profiles: [String: Profile], links: [URL]) {
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(NSEvent.mouseLocation) }) ?? NSScreen.main else { return }
        let area = screen.visibleFrame
        let size = NSSize(width: min(460, area.width), height: min(CGFloat(profiles.count * 70 + 22), area.height - 60))
        let window = NSWindow(contentRect: NSRect(origin: .zero, size: size),
                              styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.delegate = self
        windows.append(window)
        window.title = "Choose a Chrome profile"
        window.appearance = NSAppearance(named: .darkAqua)
        window.level = .floating
        window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        let colors = [Color.purple, .blue, .mint, .orange].map { $0.opacity(0.85) }
        let keys = profiles.keys.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
        let rows = ScrollView {
            VStack(spacing: 6) {
                ForEach(Array(keys.enumerated()), id: \.element) { index, directory in
                    if let profile = profiles[directory] {
                        ProfileRow(profile: profile, directory: directory, tint: colors[index % colors.count]) { [weak window] in
                            guard let chrome = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome"),
                                  let executable = Bundle(url: chrome)?.executableURL else {
                                self.alert("Google Chrome could not be found", "Install Google Chrome and try again.")
                                return
                            }
                            let launch = Process()
                            launch.executableURL = executable
                            launch.arguments = ["--profile-directory=" + directory] + links.map(\.absoluteString)
                            do {
                                try launch.run()
                                window?.close()
                            } catch {
                                self.alert("Could not open Google Chrome", error.localizedDescription)
                            }
                        }
                    }
                }
            }.padding(12)
        }.background(Color(red: 0.125, green: 0.137, blue: 0.153)).preferredColorScheme(.dark)
        window.contentView = NSHostingView(rootView: rows)
        window.setFrameOrigin(NSPoint(x: area.midX - window.frame.width / 2,
                                      y: area.midY - window.frame.height / 2))
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}

let app = NSApplication.shared
let chooser = Chooser()
app.delegate = chooser
app.setActivationPolicy(.accessory)
app.run()
