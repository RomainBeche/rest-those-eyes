//
//  TimerManager.swift
//  RestThoseEyes
//
//  Created by Romain Bêche on 04/04/2025.
//

import SwiftUI
import UserNotifications

@MainActor @Observable final class TimerManager {
    var currentTimer: CircularProgressionBarViewModel {
        didSet {
            currentPhaseElapsed = 0
            setupTimerLoop()
            currentTimer.startTimer()
        }
    }
    var isPaused = false
    var isBreak = false
    var totalWorkSeconds = 0
    var totalBreakSeconds = 0
    var breaksTakenToday = 0
    var currentPhaseElapsed = 0

    private let settings = SettingsManager.shared
    private let snoozeIncrement = 300     // 5 minutes

    private enum StatKeys {
        static let breaksTakenToday = "statBreaksTakenToday"
        static let totalWorkSeconds = "statTotalWorkSeconds"
        static let totalBreakSeconds = "statTotalBreakSeconds"
        static let lastStatDate = "statLastDate"
    }

    init() {
        let workDuration = SettingsManager.shared.workDurationMinutes * 60
        currentTimer = CircularProgressionBarViewModel(
            totalTime: workDuration,
            lineColor: .purple,
            lineColorBackground: Self.ringBackground(NSColor.systemPurple),
            isBreak: false
        )
        loadDailyStats()
        setupTimerLoop()
        currentTimer.startTimer()
    }

    func togglePause() {
        if isPaused {
            isPaused = false
            currentTimer.resumeTimer()
        } else {
            isPaused = true
            currentTimer.pauseTimer()
        }
    }

    func snoozeTimer() {
        isPaused = false
        if currentTimer.isBreak {
            isBreak = false
            currentTimer = CircularProgressionBarViewModel(
                totalTime: settings.snoozeDurationMinutes * 60,
                lineColor: .purple,
                lineColorBackground: Self.ringBackground(NSColor.systemPurple),
                isBreak: false
            )
        } else {
            currentTimer.adjustTime(additionalSeconds: snoozeIncrement)
        }
    }

    private static func ringBackground(_ nsColor: NSColor) -> Color {
        Color(nsColor.blended(withFraction: 0.45, of: NSColor.windowBackgroundColor) ?? nsColor)
    }
}

// MARK: - Private Methods
private extension TimerManager {
    func setupTimerLoop() {
        currentTimer.onTick = { [weak self] in
            guard let self else { return }
            self.currentPhaseElapsed = self.currentTimer.totalTime - self.currentTimer.timeRemaining
        }
        currentTimer.onCompletion = { [weak self] in
            guard let self else { return }
            if !self.currentTimer.isBreak {
                self.totalWorkSeconds += self.currentTimer.totalTime
                self.sendCompletionNotification()
            } else {
                self.totalBreakSeconds += self.currentTimer.totalTime
                self.breaksTakenToday += 1
            }
            self.saveStats()
            self.switchToNextPhase()
        }
    }

    func switchToNextPhase() {
        let nextIsBreak = !currentTimer.isBreak
        let nextDuration = nextIsBreak
            ? settings.breakDurationSeconds
            : settings.workDurationMinutes * 60
        let nextColor: Color = nextIsBreak ? .green : .purple
        let nextNSColor: NSColor = nextIsBreak ? NSColor.systemGreen : NSColor.systemPurple

        withAnimation(.spring(duration: 0.5)) {
            isPaused = false
            isBreak = nextIsBreak
        }

        currentTimer = CircularProgressionBarViewModel(
            totalTime: nextDuration,
            lineColor: nextColor,
            lineColorBackground: Self.ringBackground(nextNSColor),
            isBreak: nextIsBreak
        )
    }

    func loadDailyStats() {
        let defaults = UserDefaults.standard
        guard let lastDate = defaults.object(forKey: StatKeys.lastStatDate) as? Date,
              Calendar.current.isDateInToday(lastDate) else { return }
        totalWorkSeconds = defaults.integer(forKey: StatKeys.totalWorkSeconds)
        totalBreakSeconds = defaults.integer(forKey: StatKeys.totalBreakSeconds)
        breaksTakenToday = defaults.integer(forKey: StatKeys.breaksTakenToday)
    }

    func saveStats() {
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: StatKeys.lastStatDate)
        defaults.set(totalWorkSeconds, forKey: StatKeys.totalWorkSeconds)
        defaults.set(totalBreakSeconds, forKey: StatKeys.totalBreakSeconds)
        defaults.set(breaksTakenToday, forKey: StatKeys.breaksTakenToday)
    }

    func sendCompletionNotification() {
        guard settings.showNotifications else { return }

        let center = UNUserNotificationCenter.current()
        let identifier = "timer_completion_notification"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent().configuredContent()
        let request = UNNotificationRequest.createRequest(content: content)
        center.add(request)
    }
}

// MARK: - Notification Extensions
@MainActor
private extension UNMutableNotificationContent {
    func configuredContent() -> UNMutableNotificationContent {
        self.title = Localization.Notifications.title.key
        self.body = Localization.Notifications.formattedBody(seconds: SettingsManager.shared.breakDurationSeconds)
        self.categoryIdentifier = "timerCategory"
        self.interruptionLevel = .timeSensitive
        self.sound = SettingsManager.shared.soundAlerts ? .default : nil
        return self
    }
}

private extension UNNotificationRequest {
    static func createRequest(content: UNMutableNotificationContent) -> UNNotificationRequest {
        UNNotificationRequest(
            identifier: "timer_completion_notification",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
    }
}
