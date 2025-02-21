//  ContentView.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/20/25.

import SwiftUI

struct ContentView: View {
    @StateObject private var pedometerManager = PedometerManager()
    @State private var daysData: [DaySteps] = []

    var body: some View {
        HourlyStepsView(daysData: daysData)
            .onAppear {
                pedometerManager.requestAuthorization()
                loadData()
            }
    }

    private func loadData() {
        pedometerManager.fetchHistoricalData(forDays: 7) { fetchedData in
            daysData = fetchedData
        }
    }
}
