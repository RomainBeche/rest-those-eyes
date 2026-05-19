//
//  SettingsView.swift
//  RestThoseEyes
//
//  Created by Romain Bêche on 01/04/2025.
//

import SwiftUI

// MARK: - Settings Tab

private enum SettingsTab: String, CaseIterable, Identifiable {
    case timer = "Timer"
    case notifications = "Notifications"
    case behavior = "Behavior"
    case support = "Support"

    var id: String { rawValue }

    // Decoupled from rawValue so display strings can be localized independently
    var title: LocalizedStringKey {
        switch self {
        case .timer: "Timer"
        case .notifications: "Notifications"
        case .behavior: "Behavior"
        case .support: "Support"
        }
    }

    var systemImage: String {
        switch self {
        case .timer: "timer"
        case .notifications: "bell.fill"
        case .behavior: "gearshape.fill"
        case .support: "questionmark.circle.fill"
        }
    }
}

// MARK: - Main View

struct SettingsView: View {
    @State private var selection: SettingsTab? = .timer

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $selection) {
                ForEach(SettingsTab.allCases) { tab in
                    Label(tab.title, systemImage: tab.systemImage)
                        .tag(tab)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("RestThoseEyes")
            .navigationSplitViewColumnWidth(min: 200, ideal: 200, max: 200)
            .toolbar(removing: .sidebarToggle)
        } detail: {
            switch selection ?? .timer {
            case .timer: TimerDetailView()
            case .notifications: NotificationDetailView()
            case .behavior: BehaviorDetailView()
            case .support: SupportDetailView()
            }
        }
        .tint(.purple)
        .frame(minWidth: 520, minHeight: 320)
        .background(WindowConfigurator())
    }
}

// MARK: - Window Configurator

// Uses a custom NSView subclass so viewDidMoveToWindow() reliably fires
// once the view is actually inside the window hierarchy.
private struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> SettingsWindowView { SettingsWindowView() }
    func updateNSView(_ nsView: SettingsWindowView, context: Context) {}
}

private final class SettingsWindowView: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard let window else { return }
        applyWindowStyle(window)
        // Defer sidebar locking one cycle so NavigationSplitView's
        // NSSplitViewController is fully installed before we query it.
        Task { @MainActor [weak window] in
            guard let window, let contentView = window.contentView else { return }
            Self.lockSidebar(in: contentView)
        }
    }

    private func applyWindowStyle(_ window: NSWindow) {
        window.titlebarAppearsTransparent = true
        window.title = ""
        window.toolbarStyle = .unified
        let toolbar = NSToolbar(identifier: "SettingsToolbar")
        toolbar.allowsUserCustomization = false
        window.toolbar = toolbar
    }

    private static func lockSidebar(in contentView: NSView) {
        guard let splitVC = findSplitViewController(in: contentView) else { return }
        let item = splitVC.splitViewItems.first
        item?.canCollapse = false
        item?.holdingPriority = .defaultHigh
        item?.minimumThickness = 200
        item?.maximumThickness = 200
    }

    private static func findSplitViewController(in view: NSView) -> NSSplitViewController? {
        if let splitView = view as? NSSplitView,
           let delegate = splitView.delegate as? NSSplitViewController {
            return delegate
        }
        return view.subviews.lazy.compactMap { findSplitViewController(in: $0) }.first
    }
}

// MARK: - Shared Helpers

private struct SettingsIcon: View {
    let systemName: String
    let color: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.caption.bold())
            .foregroundStyle(color)
            .frame(width: 28, height: 28)
            .background(RoundedRectangle(cornerRadius: 7).fill(color.opacity(0.12)))
    }
}

private extension View {
    func detailFormStyle() -> some View {
        formStyle(.grouped).frame(maxWidth: .infinity)
    }
}

// MARK: - Timer Detail

private struct TimerDetailView: View {
    @Environment(SettingsManager.self) private var settings

    var body: some View {
        @Bindable var settings = settings
        Form {
            Section {
                Stepper(value: $settings.workDurationMinutes, in: 10...60) {
                    HStack(spacing: 10) {
                        SettingsIcon(systemName: "timer", color: .purple)
                        LabeledContent("Work interval:", value: "\(settings.workDurationMinutes) min")
                    }
                }
                Stepper(value: $settings.breakDurationSeconds, in: 20...120, step: 10) {
                    HStack(spacing: 10) {
                        SettingsIcon(systemName: "eye.fill", color: .green)
                        LabeledContent("Break duration:", value: "\(settings.breakDurationSeconds) sec")
                    }
                }
                Stepper(value: $settings.snoozeDurationMinutes, in: 1...10) {
                    HStack(spacing: 10) {
                        SettingsIcon(systemName: "zzz", color: .orange)
                        LabeledContent("Snooze duration:", value: "\(settings.snoozeDurationMinutes) min")
                    }
                }
            } footer: {
                Text("The changes will take effect starting with the next phase.")
            }
        }
        .detailFormStyle()
    }
}

// MARK: - Notifications Detail

private struct NotificationDetailView: View {
    @Environment(SettingsManager.self) private var settings

    var body: some View {
        @Bindable var settings = settings
        Form {
            Section {
                Toggle(isOn: $settings.showNotifications) {
                    HStack(spacing: 10) {
                        SettingsIcon(systemName: "bell.fill", color: .red)
                        Text(Localization.Settings.enableNotifications.key)
                    }
                }
                Toggle(isOn: $settings.soundAlerts) {
                    HStack(spacing: 10) {
                        SettingsIcon(systemName: "speaker.wave.3.fill", color: .blue)
                        Text(Localization.Settings.soundAlerts.key)
                    }
                }
                .disabled(!settings.showNotifications)
            }
        }
        .detailFormStyle()
    }
}

// MARK: - Behavior Detail

private struct BehaviorDetailView: View {
    @Environment(SettingsManager.self) private var settings

    var body: some View {
        @Bindable var settings = settings
        Form {
            Section {
                Toggle(isOn: $settings.launchAtLogin) {
                    HStack(spacing: 10) {
                        SettingsIcon(systemName: "power", color: .blue)
                        Text(Localization.Settings.startAtLogin.key)
                    }
                }
            }
        }
        .detailFormStyle()
        .alert("Launch at Login Failed", isPresented: $settings.launchAtLoginFailed) {
        } message: {
            Text("The app could not be registered to launch at login.")
        }
    }
}

// MARK: - Support Detail

private struct SupportDetailView: View {
    private static let reportBugURL     = URL(string: "https://github.com/RomainBeche/rest-those-eyes/issues/new?labels=bug")!
    private static let requestFeatureURL = URL(string: "https://github.com/RomainBeche/rest-those-eyes/issues/new?labels=enhancement")!
    private static let sourceCodeURL    = URL(string: "https://github.com/RomainBeche/rest-those-eyes")!

    var body: some View {
        Form {
            Section {
                SupportLink(
                    systemName: "ladybug.fill", color: .red,
                    title: "Report a Bug",
                    subtitle: "Help us improve by reporting issues",
                    url: Self.reportBugURL
                )
                SupportLink(
                    systemName: "lightbulb.fill", color: .yellow,
                    title: "Request a Feature",
                    subtitle: "Suggest new features to make the app better",
                    url: Self.requestFeatureURL
                )
                SupportLink(
                    systemName: "curlybraces", color: .purple,
                    title: "View Source Code",
                    subtitle: "RestThoseEyes is open source on GitHub",
                    url: Self.sourceCodeURL
                )
            }
        }
        .detailFormStyle()
    }
}

private struct SupportLink: View {
    let systemName: String
    let color: Color
    let title: String
    let subtitle: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 10) {
                SettingsIcon(systemName: systemName, color: color)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).foregroundStyle(.primary)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}
