//
//  TimeLine.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/26/25.
//

import SwiftUI

struct TimeLine: View {
    let steps: Int
    let angle: Double
    let maxSteps: Int
    let lineOffset: CGFloat
    let maxAllowedLength: CGFloat
    let unit: Int
    let totalUnits: Int
    @Binding var selectedUnit: Int?

    var body: some View {
        let normalizedLength = maxSteps > 0 ? Double(steps) / Double(maxSteps) : 0
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
                        updateSelectedUnit(for: gesture)
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedUnit = nil
                        }
                    }
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.1)
                    .onEnded { _ in
                        selectedUnit = unit
                    }
            )
    }

    private func updateSelectedUnit(for gesture: DragGesture.Value) {
        let location = gesture.location
        let center = CGPoint(x: 0, y: 0)
        let touchAngle = atan2(location.x, -location.y) * 180 / .pi
        let normalizedAngle = (touchAngle + 360).truncatingRemainder(dividingBy: 360)
        let touchedUnit = Int((normalizedAngle / (360.0 / Double(totalUnits))).rounded()) % totalUnits
        selectedUnit = touchedUnit
    }
}
