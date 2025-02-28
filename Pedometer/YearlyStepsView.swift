//
//  YearlyStepsView.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/26/25.
//

// YearlyStepsView.swift
import SwiftUI

struct YearlyStepsView: View {
    let monthlyData: [MonthSteps] // Data passed to this view

    var body: some View {
        VStack {
            Text("Steps by Month")
                .font(.headline)
                .padding()

            // Display each month's step count
            ForEach(monthlyData) { monthStep in
                HStack {
                    Text(monthStep.month) // Display the month name
                    Spacer()
                    Text("\(monthStep.steps) steps")
                }
                .padding()
            }
        }
        .padding()
    }
}
