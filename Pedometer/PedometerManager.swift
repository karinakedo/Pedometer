//
//  PedometerManager.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/18/25.
//

import Foundation
import HealthKit
import SwiftUI

final class PedometerManager: ObservableObject {
    // MARK: - Properties
    private let healthStore: HKHealthStore
    @Published var hourlySteps: [Int] = Array(repeating: 0, count: 24)

    // MARK: - Initialization
    init() {
        self.healthStore = HKHealthStore()
    }

    // MARK: - Public Methods
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }

        guard
            let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount)
        else {
            print("Step Count is not available")
            return
        }

        healthStore.requestAuthorization(
            toShare: [stepCount], read: [stepCount]
        ) { success, error in
            if success {
                print("Authorization successful")
            } else {
                print("Authorization failed: \(String(describing: error))")
            }
        }
    }

    func fetchStepCount(completion: @escaping (Double) -> Void) {
        guard
            let stepCount = HKQuantityType.quantityType(
                forIdentifier: .stepCount)
        else { return }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: stepCount,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch steps: \(String(describing: error))")
                completion(0.0)
                return
            }

            let steps = sum.doubleValue(for: HKUnit.count())
            completion(steps)
        }

        healthStore.execute(query)
    }

    func fetchHourlySteps(completion: @escaping ([Int]) -> Void) {
        guard
            let stepCount = HKQuantityType.quantityType(
                forIdentifier: .stepCount)
        else { return }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay, end: now, options: .strictStartDate)

        let interval = DateComponents(hour: 1)

        let query = HKStatisticsCollectionQuery(
            quantityType: stepCount,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfDay,
            intervalComponents: interval
        )

        query.initialResultsHandler = { query, results, error in
            guard let results = results else {
                completion(MockData.generateMockHourlySteps())
                return
            }

            var hourlySteps = Array(repeating: 0, count: 24)

            results.enumerateStatistics(from: startOfDay, to: now) {
                statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let steps = Int(sum.doubleValue(for: HKUnit.count()))
                    let hour = Calendar.current.component(
                        .hour, from: statistics.startDate)
                    hourlySteps[hour] = steps
                }
            }

            DispatchQueue.main.async {
                completion(hourlySteps)
            }
        }

        healthStore.execute(query)
    }

    func fetchDailyData(completion: @escaping ([HourSteps]) -> Void) {
        // Fetch hourly step data for the current day
        // Call completion with the fetched data
    }

    // Add to PedometerManager class
    func fetchMonthlyData(completion: @escaping ([DaySteps]) -> Void) {
        // Similar to fetchHistoricalData but aggregated by day
        // Implementation to be added
    }

    func fetchYearlyData(completion: @escaping ([MonthSteps]) -> Void) {
        // Similar to fetchHistoricalData but aggregated by month
        // Implementation to be added
    }

    func fetchLifetimeData(completion: @escaping ([YearSteps]) -> Void) {
        guard
            let stepCount = HKQuantityType.quantityType(
                forIdentifier: .stepCount)
        else { return }

        let now = Date()
        let calendar = Calendar.current

        // Query the earliest available data
        let anchorDate = calendar.startOfDay(for: now)
        let interval = DateComponents(month: 1)  // Monthly interval

        let query = HKStatisticsCollectionQuery(
            quantityType: stepCount,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: interval
        )

        query.initialResultsHandler = { query, results, error in
            guard let results = results else {

                DispatchQueue.main.async {
                    // Generate mock data for 4 years if no results
                    let mockData = MockData.generateMockStepData(forYears: 4)
                    completion(mockData)
                }
                return
            }

            var yearStepsArray: [YearSteps] = []

            // Process the results to calculate monthly step counts
            let startDate = results.statistics().first?.startDate ?? now
            let endDate = now

            // Group statistics by year
            var yearlyData: [Int: [Int]] = [:]  // Dictionary to store monthly steps for each year

            results.enumerateStatistics(from: startDate, to: endDate) {
                statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let steps = Int(sum.doubleValue(for: HKUnit.count()))
                    let year = calendar.component(
                        .year, from: statistics.startDate)
                    let month = calendar.component(
                        .month, from: statistics.startDate)

                    // Ensure the year exists in the dictionary
                    if yearlyData[year] == nil {
                        yearlyData[year] = Array(repeating: 0, count: 12)  // 12 months
                    }

                    // Add the steps to the correct month (0-indexed)
                    yearlyData[year]?[month - 1] = steps
                }
            }

            // Convert yearlyData into an array of YearSteps
            for (year, monthlySteps) in yearlyData {
                yearStepsArray.append(
                    YearSteps(year: year, steps: monthlySteps))
            }

            // Sort the array by year (ascending)
            yearStepsArray.sort { $0.year < $1.year }

            DispatchQueue.main.async {
                completion(yearStepsArray)  // Return the array of YearSteps
            }
        }

        healthStore.execute(query)
    }

    // MARK: - New Methods for Historical Data
    func fetchHistoricalData(
        forDays days: Int, completion: @escaping ([DaySteps]) -> Void
    ) {
        guard
            let stepCount = HKQuantityType.quantityType(
                forIdentifier: .stepCount)
        else { return }

        let now = Date()
        let calendar = Calendar.current
        guard
            let daysAgo = calendar.date(
                byAdding: .day, value: -(days - 1), to: now)
        else {
            completion([])
            return
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: calendar.startOfDay(for: daysAgo),
            end: now,
            options: .strictStartDate)

        let interval = DateComponents(hour: 1)

        let query = HKStatisticsCollectionQuery(
            quantityType: stepCount,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: calendar.startOfDay(for: daysAgo),
            intervalComponents: interval
        )

        query.initialResultsHandler = { [weak self] query, results, error in
            guard let results = results else {
                DispatchQueue.main.async {
                    // Generate mock daily data for the requested number of days
                    let calendar = Calendar.current
                    let now = Date()
                    let daysData = (0..<days).map { dayOffset in
                        guard
                            let date = calendar.date(
                                byAdding: .day, value: -dayOffset, to: now)
                        else {
                            fatalError("Could not create date")
                        }

                        // Generate random hourly step data for the day
                        let steps = (0..<24).map { _ in Int.random(in: 0...1500)
                        }
                        return DaySteps(date: date, steps: steps)
                    }
                    completion(daysData)
                }

                return
            }

            var daysData: [DaySteps] = []

            // Process each day
            for dayOffset in 0..<days {
                guard
                    let date = calendar.date(
                        byAdding: .day, value: -dayOffset, to: now)
                else { continue }
                let dayStart = calendar.startOfDay(for: date)
                guard
                    let dayEnd = calendar.date(
                        byAdding: .day, value: 1, to: dayStart)
                else { continue }

                var daySteps = Array(repeating: 0, count: 24)

                results.enumerateStatistics(from: dayStart, to: dayEnd) {
                    statistics, _ in
                    if let sum = statistics.sumQuantity() {
                        let steps = Int(sum.doubleValue(for: HKUnit.count()))
                        let hour = calendar.component(
                            .hour, from: statistics.startDate)
                        daySteps[hour] = steps
                    }
                }

                daysData.append(DaySteps(date: date, steps: daySteps))
            }

            DispatchQueue.main.async {
                completion(daysData)
            }
        }

        healthStore.execute(query)
    }

    struct MockData {
        static func generateMockStepData(forYears years: Int) -> [YearSteps] {
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            var yearStepsArray: [YearSteps] = []

            for year in (currentYear - years + 1)...currentYear {
                var monthlySteps: [Int] = []

                for month in 1...12 {
                    // Get the number of days in the month
                    let dateComponents = DateComponents(
                        year: year, month: month)
                    let date = calendar.date(from: dateComponents)!
                    let range = calendar.range(of: .day, in: .month, for: date)!
                    let numberOfDays = range.count

                    // Generate random daily step counts for the month
                    let dailySteps = (0..<numberOfDays).map { _ in
                        Int.random(in: 0...36_000)
                    }

                    // Sum the daily steps for the month
                    let monthlyTotal = dailySteps.reduce(0, +)
                    monthlySteps.append(monthlyTotal)
                }

                // Add the year's data to the array
                yearStepsArray.append(
                    YearSteps(year: year, steps: monthlySteps))
            }

            return yearStepsArray
        }

        static func generateMockHourlySteps() -> [Int] {
            // Generate random hourly step counts for a single day (24 hours)
            return (0..<24).map { _ in Int.random(in: 0...1500) }
        }
    }

    //    // MARK: - Private Helper Methods
    //    private func createSampleData(forDays days: Int) -> [DaySteps] {
    //        let calendar = Calendar.current
    //        let now = Date()
    //
    //        return (0..<days).map { dayOffset in
    //            guard
    //                let date = calendar.date(
    //                    byAdding: .day, value: -dayOffset, to: now)
    //            else {
    //                fatalError("Could not create date")
    //            }
    //
    //            // Use your existing sample data pattern with some randomization
    //            let steps = [
    //                500 + Int.random(in: -200...200),  // 12am
    //                1200 + Int.random(in: -300...300),  // 1am
    //                300 + Int.random(in: -100...100),  // 2am
    //                0,  // 3am
    //                200 + Int.random(in: -100...100),  // 4am
    //                0,  // 5am
    //                200 + Int.random(in: -100...100),  // 6am
    //                2000 + Int.random(in: -500...500),  // 7am
    //                1500 + Int.random(in: -400...400),  // 8am
    //                800 + Int.random(in: -200...200),  // 9am
    //                600 + Int.random(in: -200...200),  // 10am
    //                800 + Int.random(in: -200...200),  // 11am
    //                1000 + Int.random(in: -300...300),  // 12pm
    //                2000 + Int.random(in: -500...500),  // 1pm
    //                900 + Int.random(in: -300...300),  // 2pm
    //                700 + Int.random(in: -200...200),  // 3pm
    //                1600 + Int.random(in: -400...400),  // 4pm
    //                5500 + Int.random(in: -1000...1000),  // 5pm
    //                1800 + Int.random(in: -400...400),  // 6pm
    //                1000 + Int.random(in: -300...300),  // 7pm
    //                500 + Int.random(in: -200...200),  // 8pm
    //                300 + Int.random(in: -100...100),  // 9pm
    //                200 + Int.random(in: -100...100),  // 10pm
    //                100 + Int.random(in: -50...50),  // 11pm
    //            ]
    //
    //            return DaySteps(date: date, steps: steps)
    //        }
}
