//
//  LifetimeStepsView.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/26/25.
//

// LifetimeStepsView.swift
import SwiftUI

struct LifetimeStepsView: View {
    let yearlyData: [YearSteps] // Data passed to this view

    var body: some View {
        VStack {
            Text("Steps by Year")
                .font(.headline)
                .padding()

            // Display each year's step count
            ForEach(yearlyData) { yearStep in
                HStack {
                    Text("Year \(yearStep.year):")
                    Spacer()
                    Text("\(yearStep.steps) steps")
                }
                .padding()
            }
        }
        .padding()
    }
}
