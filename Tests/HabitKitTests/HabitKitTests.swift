import Foundation
import Testing
@testable import HabitKit

private let calendar = Calendar(identifier: .gregorian)
private let today = Day(year: 2026, month: 11, day: 6)

private func day(_ offset: Int) -> Day {
    today.adding(days: offset, calendar: calendar)
}

@Test func dayRoundTripsThroughString() {
    let value = Day(year: 2026, month: 11, day: 6)
    #expect(value.description == "2026-11-06")
    #expect(Day(string: "2026-11-06") == value)
    #expect(Day(string: "not-a-day") == nil)
}

@Test func dayArithmeticCrossesMonthBoundary() {
    let lastDay = Day(year: 2026, month: 10, day: 31)
    let nextDay = lastDay.adding(days: 1, calendar: calendar)
    #expect(nextDay == Day(year: 2026, month: 11, day: 1))
    #expect(nextDay.previous(calendar: calendar) == lastDay)
}

@Test func currentStreakCountsConsecutiveDays() {
    var habit = Habit(name: "Read")
    for offset in -4...0 {
        habit.completions.insert(day(offset))
    }
    #expect(habit.currentStreak(asOf: today, calendar: calendar) == 5)
}

@Test func currentStreakSurvivesUnfinishedToday() {
    var habit = Habit(name: "Run")
    for offset in -3...(-1) {
        habit.completions.insert(day(offset))
    }
    #expect(habit.currentStreak(asOf: today, calendar: calendar) == 3)
}

@Test func currentStreakBreaksOnMissedDay() {
    var habit = Habit(name: "Meditate")
    habit.completions = [day(-3), day(-2), day(0)]
    #expect(habit.currentStreak(asOf: today, calendar: calendar) == 1)
}

@Test func longestStreakFindsBestRun() {
    var habit = Habit(name: "Write")
    habit.completions = [
        day(-10), day(-9), day(-8), day(-7),
        day(-4),
        day(-2), day(-1), day(0),
    ]
    #expect(habit.longestStreak(calendar: calendar) == 4)
}

@Test func completionRateUsesWindow() {
    var habit = Habit(name: "Water")
    habit.completions = [day(0), day(-1), day(-3)]
    #expect(habit.completionRate(lastDays: 4, asOf: today, calendar: calendar) == 0.75)
}

@Test func toggleAddsAndRemovesCompletion() {
    var habit = Habit(name: "Stretch")
    habit.toggle(on: today)
    #expect(habit.isCompleted(on: today))
    habit.toggle(on: today)
    #expect(!habit.isCompleted(on: today))
}

@Test func storePersistsHabitsToDisk() throws {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let fileURL = directory.appendingPathComponent("habits.json")
    defer { try? FileManager.default.removeItem(at: directory) }

    let store = HabitStore(fileURL: fileURL, calendar: calendar)
    let habit = try store.add(name: "Read", emoji: "📚", color: .green)
    _ = try store.toggle(id: habit.id, on: today)

    let reloaded = HabitStore(fileURL: fileURL, calendar: calendar)
    #expect(reloaded.loadError == nil)
    #expect(reloaded.habits.count == 1)
    #expect(reloaded.habits.first?.name == "Read")
    #expect(reloaded.habits.first?.isCompleted(on: today) == true)
}

@Test func storeRemovesHabits() throws {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let fileURL = directory.appendingPathComponent("habits.json")
    defer { try? FileManager.default.removeItem(at: directory) }

    let store = HabitStore(fileURL: fileURL, calendar: calendar)
    let habit = try store.add(name: "Run", emoji: "🏃", color: .orange)
    try store.remove(id: habit.id)
    #expect(store.habits.isEmpty)

    let reloaded = HabitStore(fileURL: fileURL, calendar: calendar)
    #expect(reloaded.habits.isEmpty)
}
