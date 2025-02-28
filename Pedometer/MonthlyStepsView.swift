//
//  MonthlyStepsView.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/26/25.
//

// MonthlyStepsView.swift
import SwiftUI

struct MonthlyStepsView: View {
    let dailyData: [DaySteps] // Data passed to this view

    var body: some View {
        VStack {
            Text("Steps by Day")
                .font(.headline)
                .padding()

            // Display each day's step count
            ForEach(dailyData) { dayStep in
                HStack {
                    Text(dayStep.date, style: .date) // Format the date
                    Spacer()
                    Text("\(dayStep.steps) steps")
                }
                .padding()
            }
        }
        .padding()
    }
}
