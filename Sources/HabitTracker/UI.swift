import Foundation
import HabitKit

extension HabitColor {
    var ansi: String {
        switch self {
        case .red: "\u{1B}[38;5;203m"
        case .orange: "\u{1B}[38;5;215m"
        case .yellow: "\u{1B}[38;5;221m"
        case .green: "\u{1B}[38;5;114m"
        case .mint: "\u{1B}[38;5;121m"
        case .blue: "\u{1B}[38;5;75m"
        case .purple: "\u{1B}[38;5;141m"
        case .pink: "\u{1B}[38;5;212m"
        }
    }
}

extension String {
    var uppercasingFirstCharacter: String {
        guard let first else { return self }
        return String(first).uppercased() + dropFirst()
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

func dateTitle(_ day: Day, calendar: Calendar) -> String {
    guard let date = day.date(calendar: calendar) else { return day.description }
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "EEEE, d MMMM yyyy"
    return formatter.string(from: date).uppercasingFirstCharacter
}

func progressBar(_ value: Double, width: Int = 16) -> String {
    let clamped = min(max(value, 0), 1)
    let filled = Int((Double(width) * clamped).rounded())
    let empty = width - filled
    let color = clamped >= 1 ? Theme.green : clamped > 0 ? Theme.yellow : Theme.muted

    return color + String(repeating: "█", count: filled)
        + Theme.muted + String(repeating: "░", count: empty) + Theme.reset
        + " \(Int((clamped * 100).rounded()))%"
}

func habitCard(index: Int, habit: Habit, today: Day, calendar: Calendar) -> [String] {
    let done = habit.isCompleted(on: today)
    let streak = habit.currentStreak(asOf: today, calendar: calendar)

    let indexText = pad("\(Theme.muted)\(index).\(Theme.reset)", to: 3)
    let emojiText = pad(habit.emoji, to: 3)
    let nameText = pad(
        "\(habit.color.ansi)\(Theme.bold)\(truncate(habit.name, to: 28))\(Theme.reset)",
        to: 28
    )
    let statusText = pad(
        done ? "\(Theme.green)✓ готово\(Theme.reset)" : "\(Theme.muted)○ ждёт\(Theme.reset)",
        to: 13
    )
    let streakText = pad(
        streak > 0
            ? "\(Theme.yellow)🔥 \(streak) \(daysWord(streak))\(Theme.reset)"
            : "\(Theme.muted)нет серии\(Theme.reset)",
        to: 16,
        alignment: .right
    )

    let days = habit.recentDays(7, asOf: today, calendar: calendar)
    let dots = days.map { day in
        habit.isCompleted(on: day)
            ? "\(habit.color.ansi)●\(Theme.reset)"
            : "\(Theme.muted)○\(Theme.reset)"
    }.joined(separator: " ")
    let rate = Int((habit.completionRate(lastDays: 30, asOf: today, calendar: calendar) * 100).rounded())

    let left = "\(Theme.muted)7 дней\(Theme.reset)  \(dots)"
    let right = "\(Theme.muted)30 дней: \(Theme.accent)\(rate)%\(Theme.reset)"
    let secondLine = twoColumn(left: left, right: right, width: 63)

    return box(
        lines: [indexText + emojiText + nameText + statusText + streakText, secondLine],
        width: 63,
        color: habit.color.ansi
    )
}

func heatmap(habit: Habit, today: Day, calendar: Calendar, weeks: Int = 8) -> [String] {
    let weekdayLabels = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    let header = weekdayLabels.map { pad($0, to: 3) }.joined()

    let weekday = calendar.component(.weekday, from: today.date(calendar: calendar) ?? Date())
    let daysSinceMonday = (weekday + 5) % 7
    let start = today.adding(
        days: -(weeks - 1) * 7 - daysSinceMonday,
        calendar: calendar
    )

    var lines = ["\(Theme.muted)\(header)\(Theme.reset)"]
    for week in 0..<weeks {
        var cells: [String] = []
        for weekdayIndex in 0..<7 {
            let day = start.adding(days: week * 7 + weekdayIndex, calendar: calendar)
            let symbol: String
            if day > today {
                symbol = "\(Theme.dim)·\(Theme.reset)"
            } else if habit.isCompleted(on: day) {
                symbol = "\(habit.color.ansi)●\(Theme.reset)"
            } else {
                symbol = "\(Theme.muted)○\(Theme.reset)"
            }
            cells.append(pad(symbol, to: 3))
        }
        lines.append(cells.joined())
    }
    return lines
}
