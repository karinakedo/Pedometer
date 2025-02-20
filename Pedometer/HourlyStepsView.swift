//  HourlyStepsView.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/18/25.

import SwiftUI

struct HourlyStepsView: View {
    let steps: [Int]
    @State private var selectedHour: Int? = nil
    var previewWeekday: Int? = nil
    @State private var textSize: CGSize = .zero

    private var maxSteps: Int {
        steps.max() ?? 0
    }

    private let centerCircleRatio: CGFloat = 0.4

    var body: some View {
        GeometryReader { geometry in
            let minSize = min(geometry.size.width, geometry.size.height)
            let centerCircleSize = minSize * centerCircleRatio
            let lineOffset = max(
                centerCircleSize / 2, (textSize.width + 20) / 2)
            let horizontalPadding = minSize * 0.01
            let maxAllowedLength =
                (minSize / 2) - lineOffset - horizontalPadding

            ZStack {
                // Lines
                ForEach(0..<24) { hour in
                    Line(
                        steps: steps[hour],
                        angle: Double(hour) * (360.0 / 24.0),
                        maxSteps: maxSteps,
                        lineOffset: lineOffset,
                        maxAllowedLength: maxAllowedLength,
                        hour: hour,
                        selectedHour: $selectedHour
                    )
                }

                // Day of week in center
                Text(formattedWeekday())
                    .font(.title3)
                    .bold()
                    .padding(20)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(
                                width: centerCircleSize,
                                height: centerCircleSize)
                    )
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: TextSizePreferenceKey.self,
                                value: geometry.size
                            )
                        }
                    )
                    .onPreferenceChange(TextSizePreferenceKey.self) { size in
                        self.textSize = size
                    }

                // Step count tooltip
                if let selectedHour = selectedHour {
                    Text("\(steps[selectedHour]) steps")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.7))
                        )
                        .offset(y: lineOffset * 2)
                }

                // Hour label for selected hour
                if let selectedHour = selectedHour {
                    let normalizedLength =
                        maxSteps > 0
                        ? Double(steps[selectedHour]) / Double(maxSteps) : 0
                    let lineLength = CGFloat(
                        normalizedLength * Double(maxAllowedLength))

                    Text(formatHour(selectedHour))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .offset(y: -(lineOffset + lineLength + 20))
                        .rotationEffect(
                            .degrees(Double(selectedHour) * (360.0 / 24.0))
                        )
                        .transition(.opacity)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(40)
    }

    private func formatHour(_ hour: Int) -> String {
        let hourNumber = hour % 12 == 0 ? 12 : hour % 12
        let period = hour < 12 ? "AM" : "PM"
        return "\(hourNumber)\(period)"
    }

    private func formattedWeekday() -> String {
        if let previewDay = previewWeekday {
            return Calendar.current.weekdaySymbols[previewDay]
        }
        return Calendar.current.weekdaySymbols[
            Calendar.current.component(.weekday, from: Date()) - 1]
    }
}

struct Line: View {
    let steps: Int
    let angle: Double
    let maxSteps: Int
    let lineOffset: CGFloat
    let maxAllowedLength: CGFloat
    let hour: Int
    @Binding var selectedHour: Int?

    var body: some View {
        let normalizedLength =
            maxSteps > 0 ? Double(steps) / Double(maxSteps) : 0
        let length = normalizedLength * Double(maxAllowedLength)

        Rectangle()
            .fill(Color.blue)
            .frame(width: 3, height: length)
            .offset(y: -(lineOffset + length / 2))
            .rotationEffect(.degrees(angle))
            .animation(.spring(), value: length)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        updateSelectedHour(for: gesture)
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedHour = nil
                        }
                    }
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.1)
                    .onEnded { _ in
                        selectedHour = hour
                    }
            )
    }

    private func updateSelectedHour(for gesture: DragGesture.Value) {
        let location = gesture.location
        // Convert touch location to polar coordinates
        let center = CGPoint(x: 0, y: 0)  // Assuming the center is at (0,0)
        let touchAngle = atan2(location.x, -location.y) * 180 / .pi
        let normalizedAngle = (touchAngle + 360).truncatingRemainder(
            dividingBy: 360)
        let touchedHour = Int((normalizedAngle / 15).rounded()) % 24
        selectedHour = touchedHour
    }
}

struct TextSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
