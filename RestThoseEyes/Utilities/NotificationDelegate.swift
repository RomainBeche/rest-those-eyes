//
//  NotificationDelegate.swift
//  RestThoseEyes
//
//  Created by Romain Bêche on 05/04/2025.
//

import SwiftUI
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    weak var timerManager: TimerManager?

    private override init() { super.init() }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == "snooze" {
            Task { @MainActor [weak self] in
                self?.timerManager?.snoozeTimer()
            }
        }
        completionHandler()
    }
}
