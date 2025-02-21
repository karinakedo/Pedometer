//  PedometerApp.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/17/25.
//

import SwiftUI

@main
struct PedometerApp: App {
    var body: some Scene {
        WindowGroup {
            HourlyStepsView(daysData: createSampleData())
        }
    }

    private func createSampleData() -> [DaySteps] {
        let calendar = Calendar.current
        let today = Date()

        // Create sample data for the last 7 days
        return (0...6).map { daysAgo in
            guard
                let date = calendar.date(
                    byAdding: .day, value: -daysAgo, to: today)
            else {
                fatalError("Could not create date")
            }

            // Generate slightly different step patterns for each day
            let steps = [
                500 + Int.random(in: -200...200),  // 12am
                1200 + Int.random(in: -300...300),  // 1am
                300 + Int.random(in: -100...100),  // 2am
                0,  // 3am
                200 + Int.random(in: -100...100),  // 4am
                0,  // 5am
                200 + Int.random(in: -100...100),  // 6am
                2000 + Int.random(in: -500...500),  // 7am
                1500 + Int.random(in: -400...400),  // 8am
                800 + Int.random(in: -200...200),  // 9am
                600 + Int.random(in: -200...200),  // 10am
                800 + Int.random(in: -200...200),  // 11am
                1000 + Int.random(in: -300...300),  // 12pm
                2000 + Int.random(in: -500...500),  // 1pm
                900 + Int.random(in: -300...300),  // 2pm
                700 + Int.random(in: -200...200),  // 3pm
                1600 + Int.random(in: -400...400),  // 4pm
                5500 + Int.random(in: -1000...1000),  // 5pm
                1800 + Int.random(in: -400...400),  // 6pm
                1000 + Int.random(in: -300...300),  // 7pm
                500 + Int.random(in: -200...200),  // 8pm
                300 + Int.random(in: -100...100),  // 9pm
                200 + Int.random(in: -100...100),  // 10pm
                100 + Int.random(in: -50...50),  // 11pm
            ]

            return DaySteps(date: date, steps: steps)
        }
    }
}
