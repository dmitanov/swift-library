import SwiftUI

struct HabitDetailView: View {
    @EnvironmentObject private var model: HabitViewModel
    @Environment(\.dismiss) private var dismiss

    let habitID: UUID
    @State private var showingDelete = false

    private var habit: Habit? {
        model.habit(id: habitID)
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            if let habit {
                ScrollView {
                    VStack(spacing: 18) {
                        header(habit)
                        statsGrid(habit)
                        heatmapCard(habit)
                        recentCard(habit)
                        toggleButton(habit)
                        deleteButton
                    }
                    .padding(20)
                    .padding(.bottom, 24)
                }
            } else {
                Text("Привычка не найдена")
                    .font(.headline)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .navigationTitle(habit?.name ?? "Привычка")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Удалить привычку?", isPresented: $showingDelete) {
            Button("Удалить", role: .destructive) {
                if let habit {
                    model.delete(habit)
                }
                dismiss()
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Вся история выполнений будет удалена безвозвратно.")
        }
    }

    private func header(_ habit: Habit) -> some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(habit.color.swiftUIColor.opacity(0.18))
                    .frame(width: 92, height: 92)
                Circle()
                    .strokeBorder(habit.color.swiftUIColor.opacity(0.35), lineWidth: 1)
                    .frame(width: 92, height: 92)
                Text(habit.emoji)
                    .font(.system(size: 44))
            }

            Text(habit.name)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(AppTheme.text)
                .multilineTextAlignment(.center)

            Text("Создана \(formatted(habit.createdAt))")
                .font(.footnote)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }

    private func statsGrid(_ habit: Habit) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            StatTile(
                title: "Серия сейчас",
                value: "\(habit.currentStreak(asOf: model.today)) \(daysWord(habit.currentStreak(asOf: model.today)))",
                icon: "flame.fill",
                tint: AppTheme.yellow
            )
            StatTile(
                title: "Лучшая серия",
                value: "\(habit.longestStreak()) \(daysWord(habit.longestStreak()))",
                icon: "crown.fill",
                tint: AppTheme.accent
            )
            StatTile(
                title: "Всего дней",
                value: "\(habit.totalCompletions)",
                icon: "checkmark.seal.fill",
                tint: AppTheme.green
            )
            StatTile(
                title: "За 30 дней",
                value: "\(Int((habit.completionRate(lastDays: 30, asOf: model.today) * 100).rounded()))%",
                icon: "chart.bar.fill",
                tint: AppTheme.cyan
            )
        }
    }

    private func heatmapCard(_ habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(
                title: "Карта выполнения",
                subtitle: "Последние 8 недель"
            )
            HeatmapView(habit: habit, today: model.today)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            AppTheme.surface,
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(AppTheme.muted.opacity(0.10), lineWidth: 1)
        )
    }

    private func recentCard(_ habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(
                title: "Последние 14 дней",
                subtitle: "Заполненные дни отмечены цветом"
            )
            RecentDaysRow(habit: habit, today: model.today)
        }
        .padding(16)
        .background(
            AppTheme.surface,
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(AppTheme.muted.opacity(0.10), lineWidth: 1)
        )
    }

    private func toggleButton(_ habit: Habit) -> some View {
        let done = habit.isCompleted(on: model.today)

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                model.toggle(habit)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: done ? "arrow.uturn.backward" : "checkmark")
                    .font(.headline.weight(.bold))
                Text(done ? "Снять отметку за сегодня" : "Выполнено сегодня")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                done
                    ? AnyShapeStyle(AppTheme.surfaceElevated)
                    : AnyShapeStyle(habit.color.swiftUIColor),
                in: Capsule()
            )
            .foregroundStyle(
                done
                    ? AnyShapeStyle(AppTheme.text)
                    : AnyShapeStyle(Color.black.opacity(0.78))
            )
        }
        .buttonStyle(.plain)
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showingDelete = true
        } label: {
            Label("Удалить привычку", systemImage: "trash")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(AppTheme.red.opacity(0.10), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func formatted(_ day: Day) -> String {
        guard let date = day.date() else { return day.description }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}
