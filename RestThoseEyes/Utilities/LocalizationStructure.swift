//
//  LocalizationStructure.swift
//  RestThoseEyes
//
//  Created by Romain Bêche on 05/04/2025.
//

import Foundation

struct Localization {
    enum Timer: String {
        case appName = "timer.app_name"
        case workMessage = "timer.work_message"
        case breakMessage = "timer.break_message"
        case notificationTitle = "timer.notification_title"
        case notificationBody = "timer.notification_body"
        case settingsButton = "timer.settings_button"
        case quitButton = "timer.quit_button"
        case phaseWork = "timer.phase_work"
        case phaseBreak = "timer.phase_break"
        case statFocus = "timer.stat_focus"
        case statAway = "timer.stat_away"
        case breaksTodayFormat = "timer.breaks_today"

        var key: String {
            NSLocalizedString(rawValue, comment: "")
        }

        static func formattedWorkMessage(minutes: Int) -> String {
            String(format: NSLocalizedString(workMessage.rawValue, comment: "Shown during work phase"), minutes)
        }

        static func formattedBreakMessage(seconds: Int) -> String {
            String(format: NSLocalizedString(breakMessage.rawValue, comment: "Shown during break phase"), seconds)
        }

        static func formattedBreaksToday(count: Int) -> String {
            String(format: NSLocalizedString(breaksTodayFormat.rawValue, comment: "Breaks taken today count"), count)
        }
    }

    enum Settings: String {
        case notifications = "settings.notifications"
        case enableNotifications = "settings.enable_notifications"
        case soundAlerts = "settings.sound_alerts"
        case behavior = "settings.behavior"
        case startAtLogin = "settings.start_at_login"
        case breakInterval = "settings.break_interval"
        case closeButton = "settings.close_button"

        var key: String {
            NSLocalizedString(rawValue, comment: "")
        }

        static func formattedBreakInterval(minutes: Int) -> String {
            String(format: NSLocalizedString(breakInterval.rawValue, comment: "Break interval stepper"), minutes)
        }
    }

    enum Notifications: String {
        case title = "notifications.title"
        case body = "notifications.body"
        case doneButton = "notifications.done_button"
        case snoozeButton = "notifications.snooze_button"

        var key: String {
            NSLocalizedString(rawValue, comment: "")
        }
    }

    enum Actions: String {
        case done = "action.done"
        case snooze = "action.snooze"
        case quit = "action.quit"

        var key: String {
            NSLocalizedString(rawValue, comment: "")
        }
    }

    enum Errors: String {
        case generic = "error.generic"
        case notificationPermission = "error.notification_permission"

        var key: String {
            NSLocalizedString(rawValue, comment: "")
        }
    }
}

// MARK: - Localization Helpers
extension String {
    func localized(_ args: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: args)
    }

    static func localized(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}
