//  Models.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/20/25.

import Foundation

struct HourSteps: Identifiable {
    let id = UUID()
    let hour: Int
    let steps: Int // Single step count for the hour
}

struct DaySteps: Identifiable {
    let id = UUID()
    let date: Date
    let steps: [Int] // Array of hourly step counts
}

struct MonthSteps: Identifiable {
    let id = UUID()
    let month: String
    let steps: [Int] // Array of daily step counts
}

struct YearSteps: Identifiable {
    let id = UUID()
    let year: Int
    let steps: [Int] // Array of monthly step counts
}

struct LifetimeSteps {
    let startYear: Int
    let steps: [Int] // Array of yearly step counts
}
