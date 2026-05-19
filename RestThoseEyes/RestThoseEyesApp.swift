//
//  RestThoseEyesApp.swift
//  RestThoseEyes
//
//  Created by Romain Bêche on 01/04/2025.
//

import SwiftUI
import UserNotifications

@main
struct RestThoseEyesApp: App {
    @State private var settings = SettingsManager.shared
    @State private var timerManager = TimerManager()

    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        registerNotificationCategories()
    }

    var body: some Scene {
        MenuBarExtra {
            MenuView()
                .environment(settings)
                .environment(timerManager)
        } label: {
            Image(systemName: timerManager.isBreak ? "eye.slash.fill" : "eye.fill")
                .symbolEffect(.bounce, value: timerManager.isBreak)
                .task {
                    NotificationDelegate.shared.timerManager = timerManager
                    _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
                }
        }
        .menuBarExtraStyle(.window)
        .windowStyle(.plain)

        Settings {
            SettingsView()
                .environment(settings)
        }
    }

    private func registerNotificationCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: "snooze",
            title: Localization.Notifications.snoozeButton.key,
            options: []
        )
        let category = UNNotificationCategory(
            identifier: "timerCategory",
            actions: [snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
