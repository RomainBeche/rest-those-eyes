//
//  CircularProgressionBarVM.swift
//  RestThoseEyes
//
//  Created by Romain Bêche on 05/04/2025.
//

import SwiftUI

@MainActor @Observable final class CircularProgressionBarViewModel {
    var fillAmount: Double = 0
    var timeRemaining: Int
    var totalTime: Int
    let lineColor: Color
    let lineColorBackground: Color
    let isBreak: Bool

    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var startDate: Date?
    @ObservationIgnored private var accumulatedPauseTime: TimeInterval = 0
    @ObservationIgnored private var pausedAt: Date?
    @ObservationIgnored var onCompletion: (() -> Void)?
    @ObservationIgnored var onTick: (() -> Void)?

    init(totalTime: Int, lineColor: Color, lineColorBackground: Color, isBreak: Bool) {
        self.totalTime = totalTime
        self.lineColor = lineColor
        self.lineColorBackground = lineColorBackground
        self.isBreak = isBreak
        self.timeRemaining = totalTime
    }

    func startTimer() {
        resetTimer()
        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.updateProgress() }
        }
        t.tolerance = 0.2
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        pausedAt = nil
        withAnimation { fillAmount = 0 }
    }

    func pauseTimer() {
        guard timer != nil, pausedAt == nil else { return }
        pausedAt = Date.now
        timer?.invalidate()
        timer = nil
    }

    func resumeTimer() {
        guard let paused = pausedAt else { return }
        accumulatedPauseTime += Date.now.timeIntervalSince(paused)
        pausedAt = nil
        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.updateProgress() }
        }
        t.tolerance = 0.2
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func adjustTime(additionalSeconds: Int) {
        totalTime += additionalSeconds
        timeRemaining = max(timeRemaining + additionalSeconds, 0)
        if timer == nil && pausedAt == nil {
            startTimer()
        } else {
            updateProgress()
        }
    }

    deinit {
        timer?.invalidate()
    }
}

private extension CircularProgressionBarViewModel {
    func resetTimer() {
        timer?.invalidate()
        startDate = Date.now
        fillAmount = 0
        timeRemaining = totalTime
        accumulatedPauseTime = 0
        pausedAt = nil
    }

    func updateProgress() {
        guard let startDate else { return }

        let elapsed = Date.now.timeIntervalSince(startDate) - accumulatedPauseTime
        timeRemaining = max(totalTime - Int(elapsed), 0)
        fillAmount = min(elapsed / Double(totalTime), 1)
        onTick?()

        if timeRemaining <= 0 {
            handleCompletion()
        }
    }

    func handleCompletion() {
        timer?.invalidate()
        withAnimation(.easeInOut(duration: 0.5)) { fillAmount = 0 }
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(0.5))
            self?.onCompletion?()
        }
    }
}
