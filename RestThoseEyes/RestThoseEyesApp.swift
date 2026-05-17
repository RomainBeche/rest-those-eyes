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
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var timerManager = TimerManager()

    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        requestNotificationAuthorization()
    }

    var body: some Scene {
        MenuBarExtra {
            MenuView()
                .environmentObject(settings)
                .environmentObject(timerManager)
        } label: {
            Image(systemName: timerManager.isBreak ? "eye.slash.fill" : "eye.fill")
                .symbolEffect(.bounce, value: timerManager.isBreak)
                .task {
                    NotificationDelegate.shared.timerManager = timerManager
                }
        }
        .menuBarExtraStyle(.window)
        .windowStyle(.plain)

        Settings {
            SettingsView()
                .environmentObject(settings)
        }
    }

    private func requestNotificationAuthorization() {
        registerNotificationCategories()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
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
