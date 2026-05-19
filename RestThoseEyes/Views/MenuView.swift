//
//  MenuView.swift
//  RestThoseEyes
//
//  Created by Romain Bêche on 01/04/2025.
//

import SwiftUI

struct MenuView: View {
    @Environment(TimerManager.self) private var timerManager

    var body: some View {
        VStack(spacing: 0) {
            MenuHeaderSection()
            MenuTimerDisplaySection()
            Divider()
                .padding(.horizontal, 16)
            MenuActionButtonsSection()
        }
        .frame(width: 320)
        .animation(.spring(duration: 0.45), value: timerManager.isBreak)
        .animation(.spring(duration: 0.25), value: timerManager.isPaused)
    }
}

// MARK: - Header

private struct MenuHeaderSection: View {
    @Environment(TimerManager.self) private var timerManager

    var body: some View {
        HStack(alignment: .center) {
            Text(Localization.Timer.appName.key)
                .font(.headline)
                .fontDesign(.rounded)
                .bold()

            Spacer()

            if timerManager.totalWorkSeconds > 0 || timerManager.totalBreakSeconds > 0 || timerManager.currentPhaseElapsed > 0 {
                Text(formattedSessionTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontDesign(.rounded)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }

    private var formattedSessionTime: String {
        let workSeconds = timerManager.totalWorkSeconds + (timerManager.isBreak ? 0 : timerManager.currentPhaseElapsed)
        let breakSeconds = timerManager.totalBreakSeconds + (timerManager.isBreak ? timerManager.currentPhaseElapsed : 0)
        var parts: [String] = []
        if workSeconds > 0 { parts.append(formatDuration(workSeconds, label: Localization.Timer.statFocus.key)) }
        if breakSeconds > 0 { parts.append(formatDuration(breakSeconds, label: Localization.Timer.statAway.key)) }
        return parts.joined(separator: " · ")
    }

    private func formatDuration(_ seconds: Int, label: String) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return "\(h)h \(m)m \(label)" }
        if m > 0 { return "\(m)m \(label)" }
        return "\(s)s \(label)"
    }
}

// MARK: - Timer Display

private struct MenuTimerDisplaySection: View {
    @Environment(TimerManager.self) private var timerManager

    var body: some View {
        HStack(spacing: 14) {
            Button {
                timerManager.togglePause()
            } label: {
                ZStack {
                    CircularProgressionBar(viewModel: timerManager.currentTimer)
                    Image(systemName: timerManager.isPaused ? "play.fill" : "pause.fill")
                        .font(.body.bold())
                        .foregroundStyle(phaseColor)
                        .opacity(timerManager.isPaused ? 1 : 0.35)
                }
                .frame(width: 60, height: 60)
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(timerManager.isPaused ? "Resume timer" : "Pause timer")
            .padding(.vertical, 22)
            .padding(.horizontal, 8)

            VStack(alignment: .leading, spacing: 6) {
                Text(phaseLabel)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .foregroundStyle(phaseColor)

                Text(timerText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontDesign(.rounded)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)

                if timerManager.breaksTakenToday > 0 {
                    Text(Localization.Timer.formattedBreaksToday(count: timerManager.breaksTakenToday))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .fontDesign(.rounded)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private var phaseColor: Color {
        timerManager.isBreak ? .green : .purple
    }

    private var phaseLabel: String {
        timerManager.isBreak ? Localization.Timer.phaseBreak.key : Localization.Timer.phaseWork.key
    }

    private var timerText: String {
        let remaining = max(timerManager.currentTimer.totalTime - timerManager.currentPhaseElapsed, 0)
        return timerManager.currentTimer.isBreak
            ? Localization.Timer.formattedBreakMessage(seconds: remaining)
            : Localization.Timer.formattedWorkMessage(minutes: max(remaining / 60, 1))
    }
}

// MARK: - Action Buttons

private struct MenuActionButtonsSection: View {
    var body: some View {
        HStack {
            SettingsLink {
                Image(systemName: "gear")
                    .font(.callout)
            }
            .simultaneousGesture(TapGesture().onEnded {
                NSApp.activate(ignoringOtherApps: true)
            })
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")

            Spacer()

            Button("Quit", systemImage: "power") {
                NSApplication.shared.terminate(nil)
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
        }
        .padding(16)
    }
}
