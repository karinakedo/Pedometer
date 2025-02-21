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
                completion(Array(repeating: 0, count: 24))
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

    // MARK: - New Methods for Historical Data
    func fetchHistoricalData(forDays days: Int, completion: @escaping ([DaySteps]) -> Void) {
        guard
            let stepCount = HKQuantityType.quantityType(
                forIdentifier: .stepCount)
        else { return }

        let now = Date()
        let calendar = Calendar.current
        guard let daysAgo = calendar.date(byAdding: .day, value: -(days - 1), to: now) else {
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
                    // If no data is available, return sample data for testing
                    completion(self?.createSampleData(forDays: days) ?? [])
                }
                return
            }

            var daysData: [DaySteps] = []

            // Process each day
            for dayOffset in 0..<days {
                guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
                let dayStart = calendar.startOfDay(for: date)
                guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { continue }

                var daySteps = Array(repeating: 0, count: 24)

                results.enumerateStatistics(from: dayStart, to: dayEnd) { statistics, _ in
                    if let sum = statistics.sumQuantity() {
                        let steps = Int(sum.doubleValue(for: HKUnit.count()))
                        let hour = calendar.component(.hour, from: statistics.startDate)
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

    // MARK: - Private Helper Methods
    private func createSampleData(forDays days: Int) -> [DaySteps] {
        let calendar = Calendar.current
        let now = Date()

        return (0..<days).map { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else {
                fatalError("Could not create date")
            }

            // Use your existing sample data pattern with some randomization
            let steps = [
                500 + Int.random(in: -200...200),    // 12am
                1200 + Int.random(in: -300...300),   // 1am
                300 + Int.random(in: -100...100),    // 2am
                0,                                   // 3am
                200 + Int.random(in: -100...100),    // 4am
                0,                                   // 5am
                200 + Int.random(in: -100...100),    // 6am
                2000 + Int.random(in: -500...500),   // 7am
                1500 + Int.random(in: -400...400),   // 8am
                800 + Int.random(in: -200...200),    // 9am
                600 + Int.random(in: -200...200),    // 10am
                800 + Int.random(in: -200...200),    // 11am
                1000 + Int.random(in: -300...300),   // 12pm
                2000 + Int.random(in: -500...500),   // 1pm
                900 + Int.random(in: -300...300),    // 2pm
                700 + Int.random(in: -200...200),    // 3pm
                1600 + Int.random(in: -400...400),   // 4pm
                5500 + Int.random(in: -1000...1000), // 5pm
                1800 + Int.random(in: -400...400),   // 6pm
                1000 + Int.random(in: -300...300),   // 7pm
                500 + Int.random(in: -200...200),    // 8pm
                300 + Int.random(in: -100...100),    // 9pm
                200 + Int.random(in: -100...100),    // 10pm
                100 + Int.random(in: -50...50),      // 11pm
            ]

            return DaySteps(date: date, steps: steps)
        }
    }
}

