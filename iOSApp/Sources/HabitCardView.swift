import SwiftUI

struct HabitCardView: View {
    @EnvironmentObject private var model: HabitViewModel
    let habit: Habit

    private var done: Bool {
        habit.isCompleted(on: model.today)
    }

    private var streak: Int {
        habit.currentStreak(asOf: model.today)
    }

    var body: some View {
        HStack(spacing: 14) {
            NavigationLink {
                HabitDetailView(habitID: habit.id)
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(habit.color.swiftUIColor.opacity(0.18))
                            .frame(width: 48, height: 48)
                        Text(habit.emoji)
                            .font(.system(size: 24))
                    }

                    VStack(alignment: .leading, spacing: 7) {
                        Text(habit.name)
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(AppTheme.text)
                            .lineLimit(1)

                        HStack(spacing: 9) {
                            if streak > 0 {
                                HStack(spacing: 3) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 10, weight: .semibold))
                                    Text("\(streak)")
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(AppTheme.yellow)
                            } else {
                                Text("нет серии")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.secondaryText)
                            }

                            WeekdayDots(habit: habit, today: model.today)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    model.toggle(habit)
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            done
                                ? habit.color.swiftUIColor
                                : AppTheme.muted.opacity(0.12)
                        )
                        .frame(width: 40, height: 40)

                    Image(systemName: done ? "checkmark" : "circle")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(
                            done
                                ? Color.black.opacity(0.75)
                                : AppTheme.secondaryText
                        )
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(done ? "Снять отметку" : "Отметить выполнение")
        }
        .padding(14)
        .background(
            AppTheme.cardGradient(habit.color.swiftUIColor),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(habit.color.swiftUIColor.opacity(0.22), lineWidth: 1)
        )
    }
}
