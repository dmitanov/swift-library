import Foundation

public enum HabitColor: String, Codable, CaseIterable, Sendable {
    case red
    case orange
    case yellow
    case green
    case mint
    case blue
    case purple
    case pink

    public var title: String {
        switch self {
        case .red: "красный"
        case .orange: "оранжевый"
        case .yellow: "жёлтый"
        case .green: "зелёный"
        case .mint: "мятный"
        case .blue: "синий"
        case .purple: "фиолетовый"
        case .pink: "розовый"
        }
    }
}

public struct Habit: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var emoji: String
    public var color: HabitColor
    public var createdAt: Day
    public var completions: Set<Day>

    public init(
        id: UUID = UUID(),
        name: String,
        emoji: String = "⭐️",
        color: HabitColor = .blue,
        createdAt: Day = .today(),
        completions: Set<Day> = []
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.createdAt = createdAt
        self.completions = completions
    }

    public func isCompleted(on day: Day) -> Bool {
        completions.contains(day)
    }

    public mutating func toggle(on day: Day) {
        if completions.contains(day) {
            completions.remove(day)
        } else {
            completions.insert(day)
        }
    }

    /// Consecutive completed days ending today. If today is not done yet,
    /// the streak is still alive when yesterday was completed.
    public func currentStreak(asOf today: Day = .today(), calendar: Calendar = .current) -> Int {
        var cursor = today
        if !isCompleted(on: cursor) {
            cursor = cursor.previous(calendar: calendar)
        }

        var streak = 0
        while isCompleted(on: cursor) {
            streak += 1
            cursor = cursor.previous(calendar: calendar)
        }
        return streak
    }

    public func longestStreak(calendar: Calendar = .current) -> Int {
        let sorted = completions.sorted()
        guard let first = sorted.first else { return 0 }

        var best = 1
        var current = 1
        var previous = first

        for day in sorted.dropFirst() {
            if day == previous.adding(days: 1, calendar: calendar) {
                current += 1
            } else {
                current = 1
            }
            best = max(best, current)
            previous = day
        }
        return best
    }

    public func completionRate(
        lastDays: Int,
        asOf today: Day = .today(),
        calendar: Calendar = .current
    ) -> Double {
        guard lastDays > 0 else { return 0 }
        let completed = (0..<lastDays).reduce(into: 0) { count, offset in
            if isCompleted(on: today.adding(days: -offset, calendar: calendar)) {
                count += 1
            }
        }
        return Double(completed) / Double(lastDays)
    }

    public func recentDays(
        _ count: Int,
        asOf today: Day = .today(),
        calendar: Calendar = .current
    ) -> [Day] {
        (0..<count).reversed().map { today.adding(days: -$0, calendar: calendar) }
    }

    public var totalCompletions: Int {
        completions.count
    }
}
