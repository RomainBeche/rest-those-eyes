//
//  SettingsManager.swift
//  RestThoseEyes
//
//  Created by Romain Bêche on 01/04/2025.
//

import Foundation
import ServiceManagement

@MainActor @Observable final class SettingsManager {
    static let shared = SettingsManager()

    private enum Keys {
        static let showNotifications = "showNotifications"
        static let soundAlerts = "soundAlerts"
        static let workDurationMinutes = "workDurationMinutes"
        static let breakDurationSeconds = "breakDurationSeconds"
        static let snoozeDurationMinutes = "snoozeDurationMinutes"
    }

    var showNotifications: Bool {
        didSet {
            UserDefaults.standard.set(showNotifications, forKey: Keys.showNotifications)
            if !showNotifications { soundAlerts = false }
        }
    }

    var soundAlerts: Bool {
        didSet { UserDefaults.standard.set(soundAlerts, forKey: Keys.soundAlerts) }
    }

    var workDurationMinutes: Int {
        didSet { UserDefaults.standard.set(workDurationMinutes, forKey: Keys.workDurationMinutes) }
    }

    var breakDurationSeconds: Int {
        didSet { UserDefaults.standard.set(breakDurationSeconds, forKey: Keys.breakDurationSeconds) }
    }

    var snoozeDurationMinutes: Int {
        didSet { UserDefaults.standard.set(snoozeDurationMinutes, forKey: Keys.snoozeDurationMinutes) }
    }

    var launchAtLogin: Bool {
        didSet {
            if launchAtLogin {
                do {
                    try SMAppService.mainApp.register()
                } catch {
                    Task { @MainActor [weak self] in
                        self?.launchAtLogin = false
                        self?.launchAtLoginFailed = true
                    }
                }
            } else {
                SMAppService.mainApp.unregister { _ in }
            }
        }
    }

    // Set to true when launch-at-login registration fails, triggers an alert in the UI.
    var launchAtLoginFailed = false

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
