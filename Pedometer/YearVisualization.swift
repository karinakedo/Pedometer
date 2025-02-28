//
//  YearVisualization.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/26/25.
//


struct YearVisualization: StepCountVisualization {
    typealias TimeUnit = String // Use a string to represent months (e.g., "January", "February")

    var data: [TimeUnit: Int] // Dictionary mapping month names to step counts
    var centerLabel: String // The label displayed at the center of the visualization
    var currentIndex: Int // Tracks the currently selected month
    var numberOfUnits: Int { data.count } // Number of months (typically 12)

    // Converts an index to a month name (TimeUnit)
    func convertToTimeUnit(_ index: Int) -> TimeUnit {
        let months = Array(data.keys.sorted()) // Sort months alphabetically or in a custom order
        guard index >= 0 && index < months.count else { return "" }
        return months[index]
    }

    // Formats the label for a specific month (e.g., "January")
    func formatUnitLabel(_ unit: TimeUnit) -> String {
        return unit // The unit is already a string (e.g., "January")
    }

    // Gets the step count for a specific month
    func getSteps(for unit: TimeUnit) -> Int {
        return data[unit] ?? 0 // Return 0 if the month is not found
    }
}

