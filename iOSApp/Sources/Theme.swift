import SwiftUI
import UIKit

enum AppTheme {
    static let background = Color(red: 0.055, green: 0.060, blue: 0.075)
    static let surface = Color(red: 0.090, green: 0.100, blue: 0.125)
    static let surfaceElevated = Color(red: 0.120, green: 0.130, blue: 0.170)
    static let text = Color(red: 0.950, green: 0.955, blue: 0.970)
    static let secondaryText = Color(red: 0.580, green: 0.600, blue: 0.660)
    static let accent = Color(red: 0.890, green: 0.440, blue: 0.860)
    static let cyan = Color(red: 0.370, green: 0.840, blue: 0.840)
    static let green = Color(red: 0.530, green: 0.840, blue: 0.530)
    static let yellow = Color(red: 1.000, green: 0.840, blue: 0.370)
    static let red = Color(red: 1.000, green: 0.370, blue: 0.370)
    static let muted = Color(red: 0.450, green: 0.470, blue: 0.530)

    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.075, green: 0.070, blue: 0.120),
            background,
            Color(red: 0.040, green: 0.045, blue: 0.060)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func cardGradient(_ color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color.opacity(0.20), surface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension HabitColor {
    var swiftUIColor: Color {
        switch self {
        case .red: AppTheme.red
        case .orange: Color(red: 1.00, green: 0.62, blue: 0.30)
        case .yellow: AppTheme.yellow
        case .green: AppTheme.green
        case .mint: Color(red: 0.40, green: 0.88, blue: 0.68)
        case .blue: Color(red: 0.36, green: 0.62, blue: 1.00)
        case .purple: Color(red: 0.68, green: 0.52, blue: 1.00)
        case .pink: AppTheme.accent
        }
    }
}

func daysWord(_ count: Int) -> String {
    let lastTwo = count % 100
    let lastOne = count % 10
    if (11...14).contains(lastTwo) { return "дней" }
    switch lastOne {
    case 1: return "день"
    case 2...4: return "дня"
    default: return "дней"
    }
}
