//
//  MonthVisualization.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/26/25.
//


struct MonthVisualization: StepCountVisualization {
    typealias TimeUnit = Int // Use an integer to represent days (e.g., 1, 2, 3)

    var data: [TimeUnit: Int] // Dictionary mapping days to step counts
    var centerLabel: String // The label displayed at the center of the visualization
    var currentIndex: Int // Tracks the currently selected day
    var numberOfUnits: Int { data.count } // Number of days in the month

    // Converts an index to a day (TimeUnit)
    func convertToTimeUnit(_ index: Int) -> TimeUnit {
        let days = Array(data.keys.sorted()) // Sort days numerically
        guard index >= 0 && index < days.count else { return 0 }
        return days[index]
    }

    // Formats the label for a specific day (e.g., "Day 1")
    func formatUnitLabel(_ unit: TimeUnit) -> String {
        return "Day \(unit)"
    }

    // Gets the step count for a specific day
    func getSteps(for unit: TimeUnit) -> Int {
        return data[unit] ?? 0 // Return 0 if the day is not found
    }
}
