import Foundation
import Combine

@MainActor
final class HabitViewModel: ObservableObject {
    @Published private(set) var habits: [Habit] = []
    @Published var errorMessage: String?

    private let store: HabitStore

    var today: Day {
        Day.today()
    }

    init() {
        let store = HabitStore(fileURL: Self.makeFileURL())
        self.store = store
        self.habits = store.habits
        if let error = store.loadError {
            self.errorMessage = error
        }
    }

    private static func makeFileURL() -> URL {
        let fileManager = FileManager.default
        let base = fileManager
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first ?? fileManager.temporaryDirectory
        let directory = base.appendingPathComponent("HabitTracker", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("habits.json")
    }

    func add(name: String, emoji: String, color: HabitColor) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        do {
            _ = try store.add(name: trimmed, emoji: emoji, color: color)
            habits = store.habits
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ habit: Habit) {
        do {
            try store.remove(id: habit.id)
            habits = store.habits
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggle(_ habit: Habit) {
        do {
            _ = try store.toggle(id: habit.id)
            habits = store.habits
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func habit(id: UUID) -> Habit? {
        habits.first { $0.id == id }
    }

    var completedToday: Int {
        habits.filter { $0.isCompleted(on: today) }.count
    }

    var completionFraction: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(completedToday) / Double(habits.count)
    }

    var bestCurrentStreak: Int {
        habits.map { $0.currentStreak(asOf: today) }.max() ?? 0
    }

    var averageCompletionRate: Double {
        guard !habits.isEmpty else { return 0 }
        let total = habits.reduce(0.0) { $0 + $1.completionRate(lastDays: 30, asOf: today) }
        return total / Double(habits.count)
    }
}
