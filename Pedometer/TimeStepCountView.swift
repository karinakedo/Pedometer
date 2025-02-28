//
//  TimeStepCountView.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/26/25.
//

import SwiftUI

struct TextSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct ViewSizes {
    let adjustedMinSize: CGFloat
    let centerCircleSize: CGFloat
    let lineOffset: CGFloat
    let maxAllowedLength: CGFloat
    let unitLabelPadding: CGFloat
}

struct TimeStepCountView<T: StepCountVisualization>: View {
    let visualization: T
    @Binding var selectedUnit: Int?
    @State private var textSize: CGSize = .zero

    private let centerCircleRatio: CGFloat = 0.4

    // MARK: - Computed Properties
    private func calculateSizes(for geometry: GeometryProxy) -> ViewSizes {
        let minSize = min(geometry.size.width, geometry.size.height)
        let unitLabelPadding: CGFloat = 60
        let adjustedMinSize = minSize - (unitLabelPadding * 2)
        let centerCircleSize = adjustedMinSize * centerCircleRatio
        let lineOffset = max(centerCircleSize / 2, (textSize.width + 20) / 2)
        let horizontalPadding = adjustedMinSize * 0.01
        let maxAllowedLength =
            (adjustedMinSize / 2) - lineOffset - horizontalPadding

        return ViewSizes(
            adjustedMinSize: adjustedMinSize,
            centerCircleSize: centerCircleSize,
            lineOffset: lineOffset,
            maxAllowedLength: maxAllowedLength,
            unitLabelPadding: unitLabelPadding
        )
    }

    // MARK: - Subviews
    private func timeLines(sizes: ViewSizes) -> some View {
        ForEach(0..<visualization.numberOfUnits, id: \.self) { unit in
            let timeUnit = visualization.convertToTimeUnit(unit)
            TimeLine(
                steps: visualization.getSteps(for: timeUnit),
                angle: Double(unit)
                    * (360.0 / Double(visualization.numberOfUnits)),
                maxSteps: visualization.data.values.max() ?? 0,
                lineOffset: sizes.lineOffset,
                maxAllowedLength: sizes.maxAllowedLength,
                unit: unit,
                totalUnits: visualization.numberOfUnits,
                selectedUnit: $selectedUnit
            )
        }
    }

    private func centerLabel(sizes: ViewSizes) -> some View {
        Text(visualization.centerLabel)
            .font(.title3)
            .bold()
            .padding(20)
            .background(
                Circle()
                    .fill(Color.white)
                    .frame(
                        width: sizes.centerCircleSize,
                        height: sizes.centerCircleSize)
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
    }

    private func stepCountTooltip(sizes: ViewSizes) -> some View {
        Group {
            if let selectedUnit = selectedUnit {
                let timeUnit = visualization.convertToTimeUnit(selectedUnit)
                Text("\(visualization.getSteps(for: timeUnit)) steps")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.7))
                    )
                    .offset(y: sizes.lineOffset * 2)
            }
        }
    }

    private func unitLabel(sizes: ViewSizes) -> some View {
        Group {
            if let selectedUnit = selectedUnit {
                let timeUnit = visualization.convertToTimeUnit(selectedUnit)
                Text(visualization.formatUnitLabel(timeUnit))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .offset(y: -(sizes.lineOffset + 40))
                    .rotationEffect(
                        .degrees(
                            Double(selectedUnit)
                                * (360.0 / Double(visualization.numberOfUnits)))
                    )
            }
        }
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let sizes = calculateSizes(for: geometry)

            VStack(spacing: 0) {
                ZStack {
                    timeLines(sizes: sizes)
                    centerLabel(sizes: sizes)
                    stepCountTooltip(sizes: sizes)
                    unitLabel(sizes: sizes)
                }
                .frame(
                    width: sizes.adjustedMinSize, height: sizes.adjustedMinSize
                )
                .padding(sizes.unitLabelPadding)
            }
        }
    }
}
