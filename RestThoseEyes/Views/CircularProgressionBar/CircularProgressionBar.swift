//
//  CircularProgressionBar.swift
//  RestThoseEyes
//
//  Created by Romain Bêche on 01/04/2025.
//

import SwiftUI

struct CircularProgressionBar: View {
    @ObservedObject var viewModel: CircularProgressionBarViewModel

    var body: some View {
        ZStack {
            backgroundCircle
            progressCircle
        }
    }

    private var backgroundCircle: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 12)
                .foregroundStyle(viewModel.lineColorBackground)
            Circle()
                .stroke(lineWidth: 12)
                .foregroundStyle(viewModel.lineColorBackground)
                .blur(radius: 8, opaque: false)
        }
    }

    private var progressCircle: some View {
        Circle()
            .trim(from: 0, to: viewModel.fillAmount)
            .stroke(style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round))
            .foregroundStyle(viewModel.lineColor)
            .rotationEffect(Angle(degrees: -90))
            .animation(.linear(duration: 1.0), value: viewModel.fillAmount)
    }
}
