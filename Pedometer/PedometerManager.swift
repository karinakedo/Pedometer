//
//  PedometerManager.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/18/25.
//

import Foundation
import HealthKit

final class PedometerManager {
    // MARK: - Properties
    private let healthStore: HKHealthStore

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

    // Add this function to your existing PedometerManager class
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

}
