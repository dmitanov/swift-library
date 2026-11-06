import Foundation

public final class HabitStore {
    public private(set) var habits: [Habit]
    public let fileURL: URL
    public private(set) var loadError: String?

    private let calendar: Calendar

    public init(fileURL: URL? = nil, calendar: Calendar = .current) {
        self.fileURL = fileURL ?? Self.defaultFileURL()
        self.calendar = calendar
        self.habits = []

        do {
            try load()
        } catch {
            self.loadError = error.localizedDescription
        }
    }

    public static func defaultFileURL() -> URL {
        if let override = ProcessInfo.processInfo.environment["HABITTRACKER_DATA"],
           !override.isEmpty {
            return URL(fileURLWithPath: override)
        }

        let home: URL
        #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
        home = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        #else
        home = FileManager.default.homeDirectoryForCurrentUser
        #endif

        return home
            .appendingPathComponent(".habittracker", isDirectory: true)
            .appendingPathComponent("habits.json")
    }

    public func load() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            habits = []
            return
        }
        let data = try Data(contentsOf: fileURL)
        habits = try JSONDecoder().decode([Habit].self, from: data)
        loadError = nil
    }

    public func save() throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(habits)
        try data.write(to: fileURL, options: .atomic)
    }

    @discardableResult
    public func add(
        name: String,
        emoji: String = "⭐️",
        color: HabitColor = .blue
    ) throws -> Habit {
        let habit = Habit(
            name: name,
            emoji: emoji,
            color: color,
            createdAt: Day.today(calendar: calendar)
        )
        habits.append(habit)
        try save()
        return habit
    }

    public func remove(id: UUID) throws {
        habits.removeAll { $0.id == id }
        try save()
    }

    /// Returns the new completion state, or `nil` when the habit is missing.
    @discardableResult
    public func toggle(id: UUID, on day: Day? = nil) throws -> Bool? {
        guard let index = habits.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        let target = day ?? Day.today(calendar: calendar)
        habits[index].toggle(on: target)
        try save()
        return habits[index].isCompleted(on: target)
    }

    public func habit(id: UUID) -> Habit? {
        habits.first { $0.id == id }
    }

    public func today() -> Day {
        Day.today(calendar: calendar)
    }
}
