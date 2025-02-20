import SwiftUI

struct ContentView: View {
    @State private var hourlySteps: [Int] = Array(repeating: 0, count: 24)
    @State private var totalSteps: Double = 0
    let pedometerManager = PedometerManager()

    var body: some View {
        VStack {
            Text("Steps today: \(Int(totalSteps))")
                .font(.largeTitle)

            HourlyStepsView(steps: hourlySteps)
        }
        .onAppear {
            pedometerManager.requestAuthorization()
            updateSteps()
        }
    }

    private func updateSteps() {
        // Fetch total steps
        pedometerManager.fetchStepCount { stepCount in
            totalSteps = stepCount
        }

        // Fetch hourly steps
        pedometerManager.fetchHourlySteps { steps in
            hourlySteps = steps
        }
    }
}

#Preview {
    ContentView()
}

