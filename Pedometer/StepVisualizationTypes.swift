//
//  StepVisualizationTypes.swift.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/26/25.
//

import Foundation

struct DailyStepVisualization: StepCountVisualization {
    typealias TimeUnit = Int
    var data: [Int: Int]
    var centerLabel: String
    let numberOfUnits = 24
    var currentIndex: Int

    func convertToTimeUnit(_ index: Int) -> Int {
        return index
    }

    func formatUnitLabel(_ unit: Int) -> String {
        let hourNumber = unit % 12 == 0 ? 12 : unit % 12
        let period = unit < 12 ? "AM" : "PM"
        return "\(hourNumber) \(period)"
    }

    func getSteps(for unit: Int) -> Int {
        return data[unit] ?? 0
    }
}

struct MonthlyStepVisualization: StepCountVisualization {
    typealias TimeUnit = Int
    var data: [Int: Int]
    var centerLabel: String
    var numberOfUnits: Int // Varies by month
    var currentIndex: Int

    func convertToTimeUnit(_ index: Int) -> Int {
        return index + 1 // Days are 1-based
    }

    func formatUnitLabel(_ unit: Int) -> String {
        return "Day \(unit)"
    }

    func getSteps(for unit: Int) -> Int {
        return data[unit] ?? 0
    }
}

struct YearlyStepVisualization: StepCountVisualization {
    typealias TimeUnit = Int
    var data: [Int: Int]
    var centerLabel: String
    let numberOfUnits = 12
    var currentIndex: Int

    func convertToTimeUnit(_ index: Int) -> Int {
        return index + 1 // Months are 1-based
    }

    func formatUnitLabel(_ unit: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(month: unit))!
        return dateFormatter.string(from: date)
    }

    func getSteps(for unit: Int) -> Int {
        return data[unit] ?? 0
    }
}

struct LifetimeStepVisualization: StepCountVisualization {
    typealias TimeUnit = Int
    var data: [Int: Int]
    var centerLabel: String
    var numberOfUnits: Int // Varies by available years
    var currentIndex: Int

    func convertToTimeUnit(_ index: Int) -> Int {
        return index // Years are 0-based from start year
    }

    func formatUnitLabel(_ unit: Int) -> String {
        return String(unit)
    }

    func getSteps(for unit: Int) -> Int {
        return data[unit] ?? 0
    }
}
