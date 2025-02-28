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
            HourlyStepsView(hourlyData: createSampleData()) // Pass HourSteps data
        }
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()  // Initialize your struct
        }
    }

    private func createSampleData() -> [HourSteps] {
        let calendar = Calendar.current
        let today = Date()

        // Create sample data for a single day
        guard let date = calendar.date(byAdding: .day, value: 0, to: today) else {
            fatalError("Could not create date")
        }

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

        let daySteps = DaySteps(date: date, steps: steps)
        return convertDayStepsToHourlySteps(daySteps: daySteps) // Convert to HourSteps
    }

    private func convertDayStepsToHourlySteps(daySteps: DaySteps) -> [HourSteps] {
        return daySteps.steps.enumerated().map { index, stepCount in
            HourSteps(hour: index, steps: stepCount)
        }
    }
}
