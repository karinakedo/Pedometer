//
//  TimeVisualizationProtocol.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/26/25.
//

import Foundation

protocol StepCountVisualization {
    associatedtype TimeUnit: Hashable

    var data: [TimeUnit: Int] { get }
    var centerLabel: String { get }
    var numberOfUnits: Int { get }
    var currentIndex: Int { get set }

    // New safe conversion methods
    func convertToTimeUnit(_ index: Int) -> TimeUnit
    func formatUnitLabel(_ unit: TimeUnit) -> String
    func getSteps(for unit: TimeUnit) -> Int
}
