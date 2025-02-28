//  HourlyStepsView.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/18/25.

// HourlyStepsView.swift
import SwiftUI

struct HourlyStepsView: View {
    let hourlyData: [HourSteps]  // Data passed to this view

    var body: some View {
        VStack {
            Text("Steps by Hour")
                .font(.headline)
                .padding()

            // Display each hour's step count
            ForEach(hourlyData) { hourStep in
                HStack {
                    Text("Hour \(hourStep.hour):")
                    Spacer()
                    Text("\(hourStep.steps) steps")
                }
                .padding()
            }
        }
        .padding()
    }
}

struct HourlyStepsView_Previews: PreviewProvider {
    static var previews: some View {
        let mockHourlySteps = PedometerManager.MockData
            .generateMockHourlySteps()
        let hourlyData = mockHourlySteps.enumerated().map {
            HourSteps(hour: $0.offset, steps: $0.element)
        }
        return HourlyStepsView(hourlyData: hourlyData)
    }
}
