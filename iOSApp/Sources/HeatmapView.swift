import SwiftUI

struct HeatmapView: View {
    let habit: Habit
    let today: Day
    var weeks: Int = 8

    private let calendar = Calendar.current
    private let weekdayLabels = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

    private var startDay: Day {
        let date = today.date(calendar: calendar) ?? Date()
        let weekday = calendar.component(.weekday, from: date)
        let daysSinceMonday = (weekday + 5) % 7
        return today.adding(
            days: -(weeks - 1) * 7 - daysSinceMonday,
            calendar: calendar
        )
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(spacing: 6) {
                ForEach(weekdayLabels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryText)
                        .frame(height: 16)
                }
            }

            HStack(spacing: 6) {
                ForEach(0..<weeks, id: \.self) { week in
                    VStack(spacing: 6) {
                        ForEach(0..<7, id: \.self) { weekdayIndex in
                            cell(for: startDay.adding(
                                days: week * 7 + weekdayIndex,
                                calendar: calendar
                            ))
                        }
                    }
                }
            }
        }
    }

    private func cell(for day: Day) -> some View {
        let completed = habit.isCompleted(on: day)
        let future = day > today
        let fillColor: Color

        if future {
            fillColor = AppTheme.muted.opacity(0.07)
        } else if completed {
            fillColor = habit.color.swiftUIColor
        } else {
            fillColor = AppTheme.muted.opacity(0.18)
        }

        return RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(fillColor)
            .frame(width: 16, height: 16)
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(
                        future
                            ? AppTheme.muted.opacity(0.06)
                            : habit.color.swiftUIColor.opacity(completed ? 0 : 0.10),
                        lineWidth: 1
                    )
            )
    }
}
