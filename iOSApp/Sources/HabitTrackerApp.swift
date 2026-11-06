import SwiftUI

@main
struct HabitTrackerApp: App {
    @StateObject private var model = HabitViewModel()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(model)
                .preferredColorScheme(.dark)
                .tint(AppTheme.accent)
        }
    }
}
