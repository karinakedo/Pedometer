//
//  PedometerApp.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/17/25.
//

import SwiftUI

@main
struct PedometerApp: App {
    var body: some Scene {
        WindowGroup {
            HourlyStepsView(steps: [
                500, 1200, 300, 0, 200, 0,  // 12am-5am
                200, 2000, 1500, 800, 600, 800,  // 6am-11am
                1000, 2000, 900, 700, 1600, 5500,  // 12pm-5pm
                1800, 1000, 500, 300, 200, 100,  // 6pm-11pm
            ])
        }
    }
}
