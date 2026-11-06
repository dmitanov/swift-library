import Foundation

/// A calendar day without a time component. Stored as `YYYY-MM-DD`.
public struct Day: Codable, Hashable, Comparable, Sendable, CustomStringConvertible {
    public let year: Int
    public let month: Int
    public let day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    public init(date: Date, calendar: Calendar = .current) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.year = components.year ?? 1970
        self.month = components.month ?? 1
        self.day = components.day ?? 1
    }

    public init?(string: String) {
        let parts = string.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2])
        else {
            return nil
        }
        self.init(year: year, month: month, day: day)
    }

    public static func today(calendar: Calendar = .current) -> Day {
        Day(date: Date(), calendar: calendar)
    }

    public var description: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    public func date(calendar: Calendar = .current) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components)
    }

    public func adding(days: Int, calendar: Calendar = .current) -> Day {
        guard let base = date(calendar: calendar),
              let shifted = calendar.date(byAdding: .day, value: days, to: base)
        else {
            return self
        }
        return Day(date: shifted, calendar: calendar)
    }

    public func previous(calendar: Calendar = .current) -> Day {
        adding(days: -1, calendar: calendar)
    }

    public static func < (lhs: Day, rhs: Day) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let day = Day(string: value) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid day value: \(value)"
            )
        }
        self = day
    }
}
