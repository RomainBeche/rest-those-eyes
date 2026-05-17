//
//  SettingsView.swift
//  RestThoseEyes
//
//  Created by Romain Bêche on 01/04/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Form {
                TimerSection()
                NotificationSection()
                BehaviorSection()
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button(Localization.Settings.closeButton.key) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(.top)
        .fixedSize()
        .tint(.purple)
        .navigationTitle("RestThoseEyes Settings")
    }
}

// MARK: - Timer Section

private struct TimerSection: View {
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        Section {
            Stepper(value: $settings.workDurationMinutes, in: 10...60) {
                LabeledContent("Work interval:", value: "\(settings.workDurationMinutes) min")
            }

            Stepper(value: $settings.breakDurationSeconds, in: 20...120, step: 10) {
                LabeledContent("Break duration:", value: "\(settings.breakDurationSeconds) sec")
            }

            Stepper(value: $settings.snoozeDurationMinutes, in: 1...10) {
                LabeledContent("Snooze duration:", value: "\(settings.snoozeDurationMinutes) min")
            }
        } header: {
            Text("Timer")
        } footer: {
            Text("The changes will take effect starting with the next phase.")
        }
    }
}

// MARK: - Notifications Section

private struct NotificationSection: View {
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        Section(Localization.Settings.notifications.key) {
            Toggle(Localization.Settings.enableNotifications.key,
                   isOn: $settings.showNotifications)

            Toggle(Localization.Settings.soundAlerts.key,
                   isOn: $settings.soundAlerts)
                .disabled(!settings.showNotifications)
        }
    }
}

// MARK: - Behavior Section

private struct BehaviorSection: View {
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        Section(Localization.Settings.behavior.key) {
            Toggle(Localization.Settings.startAtLogin.key,
                   isOn: $settings.launchAtLogin)
        }
    }
}
