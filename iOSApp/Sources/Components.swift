import SwiftUI

struct CardContainer<Content: View>: View {
    let color: Color
    private let content: Content

    init(color: Color, @ViewBuilder content: () -> Content) {
        self.color = color
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                AppTheme.cardGradient(color),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(color.opacity(0.20), lineWidth: 1)
            )
    }
}

struct StatTile: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                Text(title)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
            }
            .foregroundStyle(tint)

            Text(value)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(AppTheme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(tint.opacity(0.14), lineWidth: 1)
        )
    }
}

struct ProgressRing: View {
    let progress: Double
    var size: CGFloat = 78
    var lineWidth: CGFloat = 9

    private var clamped: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.muted.opacity(0.22), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(0.001, clamped))
                .stroke(
                    AngularGradient(
                        colors: [AppTheme.accent, AppTheme.cyan, AppTheme.green, AppTheme.accent],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.45), value: clamped)

            Text("\(Int((clamped * 100).rounded()))%")
                .font(.system(size: size * 0.24, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.text)
        }
        .frame(width: size, height: size)
    }
}

struct WeekdayDots: View {
    let habit: Habit
    let today: Day

    var body: some View {
        HStack(spacing: 5) {
            ForEach(habit.recentDays(7, asOf: today), id: \.self) { day in
                let done = habit.isCompleted(on: day)
                Circle()
                    .fill(done ? habit.color.swiftUIColor : AppTheme.muted.opacity(0.16))
                    .frame(width: 9, height: 9)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                habit.color.swiftUIColor.opacity(done ? 0 : 0.30),
                                lineWidth: 1
                            )
                    )
            }
        }
    }
}

struct RecentDaysRow: View {
    let habit: Habit
    let today: Day
    var count: Int = 14

    private let calendar = Calendar.current
    private let weekdaySymbols = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]

    var body: some View {
        HStack(spacing: 5) {
            ForEach(habit.recentDays(count, asOf: today, calendar: calendar), id: \.self) { day in
                VStack(spacing: 6) {
                    Text(weekdaySymbol(day))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryText)

                    Circle()
                        .fill(
                            habit.isCompleted(on: day)
                                ? habit.color.swiftUIColor
                                : AppTheme.muted.opacity(0.16)
                        )
                        .frame(width: 14, height: 14)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func weekdaySymbol(_ day: Day) -> String {
        guard let date = day.date(calendar: calendar) else { return "" }
        return weekdaySymbols[calendar.component(.weekday, from: date) - 1]
    }
}

struct SectionTitle: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(AppTheme.text)
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
