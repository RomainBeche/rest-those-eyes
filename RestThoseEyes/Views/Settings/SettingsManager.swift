//
//  SettingsManager.swift
//  RestThoseEyes
//
//  Created by Romain Bêche on 01/04/2025.
//

import Foundation
import ServiceManagement

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private enum Keys {
        static let showNotifications = "showNotifications"
        static let soundAlerts = "soundAlerts"
        static let workDurationMinutes = "workDurationMinutes"
        static let breakDurationSeconds = "breakDurationSeconds"
        static let snoozeDurationMinutes = "snoozeDurationMinutes"
    }

    @Published var showNotifications: Bool {
        didSet {
            UserDefaults.standard.set(showNotifications, forKey: Keys.showNotifications)
            if !showNotifications { soundAlerts = false }
        }
    }

    @Published var soundAlerts: Bool {
        didSet { UserDefaults.standard.set(soundAlerts, forKey: Keys.soundAlerts) }
    }

    @Published var workDurationMinutes: Int {
        didSet { UserDefaults.standard.set(workDurationMinutes, forKey: Keys.workDurationMinutes) }
    }

    @Published var breakDurationSeconds: Int {
        didSet { UserDefaults.standard.set(breakDurationSeconds, forKey: Keys.breakDurationSeconds) }
    }

    @Published var snoozeDurationMinutes: Int {
        didSet { UserDefaults.standard.set(snoozeDurationMinutes, forKey: Keys.snoozeDurationMinutes) }
    }

    @Published var launchAtLogin: Bool {
        didSet {
            if launchAtLogin {
                do {
                    try SMAppService.mainApp.register()
                } catch {
                    Task { @MainActor [weak self] in self?.launchAtLogin = false }
                }
            } else {
                SMAppService.mainApp.unregister { _ in }
            }
        }
    }

    private init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            Keys.showNotifications: true,
            Keys.soundAlerts: true,
            Keys.workDurationMinutes: 20,
            Keys.breakDurationSeconds: 20,
            Keys.snoozeDurationMinutes: 5
        ])
        showNotifications = defaults.bool(forKey: Keys.showNotifications)
        soundAlerts = defaults.bool(forKey: Keys.soundAlerts)
        workDurationMinutes = defaults.integer(forKey: Keys.workDurationMinutes)
        breakDurationSeconds = defaults.integer(forKey: Keys.breakDurationSeconds)
        snoozeDurationMinutes = defaults.integer(forKey: Keys.snoozeDurationMinutes)
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }
}
