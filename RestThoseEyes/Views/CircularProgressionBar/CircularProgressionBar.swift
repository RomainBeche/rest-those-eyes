//
//  CircularProgressionBar.swift
//  RestThoseEyes
//
//  Created by Romain Bêche on 01/04/2025.
//

import SwiftUI

struct CircularProgressionBar: View {
    let viewModel: CircularProgressionBarViewModel

    var body: some View {
        ZStack {
            BackgroundCircle(color: viewModel.lineColorBackground)
            ProgressCircle(fillAmount: viewModel.fillAmount, color: viewModel.lineColor)
        }
    }
}

private struct BackgroundCircle: View {
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 12)
                .foregroundStyle(color)
            Circle()
                .stroke(lineWidth: 12)
                .foregroundStyle(color)
                .blur(radius: 8, opaque: false)
        }
    }
}

private struct ProgressCircle: View {
    let fillAmount: Double
    let color: Color

    var body: some View {
        Circle()
            .trim(from: 0, to: fillAmount)
            .stroke(style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round))
            .foregroundStyle(color)
            .rotationEffect(.degrees(-90))
            .animation(.linear(duration: 1.0), value: fillAmount)
    }
}
