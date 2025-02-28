//  ContentView.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/20/25.

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var pedometerManager = PedometerManager()

    // State variables to hold data for each view
    @State private var hourlyData: [HourSteps] = []
    @State private var dailyData: [DaySteps] = []
    @State private var monthlyData: [MonthSteps] = []
    @State private var yearlyData: [YearSteps] = []

    var body: some View {
        TabView {
            HourlyStepsView(hourlyData: hourlyData)
                .tabItem {
                    Label("Day", systemImage: "clock")
                }

            MonthlyStepsView(dailyData: dailyData)
                .tabItem {
                    Label("Month", systemImage: "calendar")
                }

            YearlyStepsView(monthlyData: monthlyData)
                .tabItem {
                    Label("Year", systemImage: "calendar.circle")
                }

            LifetimeStepsView(yearlyData: yearlyData)
                .tabItem {
                    Label("Lifetime", systemImage: "infinity")
                }
        }
        .onAppear {
            pedometerManager.requestAuthorization()
            loadData()
        }
    }

    private func loadData() {
        // Fetch hourly data for Day view
        pedometerManager.fetchDailyData { fetchedHourlyData in
            DispatchQueue.main.async {
                self.hourlyData = fetchedHourlyData
            }
        }

        // Fetch daily data for Month view
        pedometerManager.fetchMonthlyData { fetchedDailyData in
            DispatchQueue.main.async {
                self.dailyData = fetchedDailyData
            }
        }

        // Fetch monthly data for Year view
        pedometerManager.fetchYearlyData { fetchedMonthlyData in
            DispatchQueue.main.async {
                self.monthlyData = fetchedMonthlyData
            }
        }

        // Fetch yearly data for Lifetime view
        pedometerManager.fetchLifetimeData { fetchedYearlyData in
            DispatchQueue.main.async {
                self.yearlyData = fetchedYearlyData
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
