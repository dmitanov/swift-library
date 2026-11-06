import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var model: HabitViewModel

    @State private var showingAdd = false
    @State private var showingDelete = false
    @State private var pendingDelete: Habit?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        summary
                        statsRow

                        if model.habits.isEmpty {
                            emptyState
                        } else {
                            habitList
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Мои привычки")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(AppTheme.accent)
                            .frame(width: 34, height: 34)
                            .background(AppTheme.accent.opacity(0.16), in: Circle())
                    }
                    .accessibilityLabel("Добавить привычку")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddHabitView()
                    .environmentObject(model)
            }
            .alert(
                "Удалить привычку?",
                isPresented: $showingDelete,
                presenting: pendingDelete
            ) { habit in
                Button("Удалить", role: .destructive) {
                    model.delete(habit)
                }
                Button("Отмена", role: .cancel) {}
            } message: { habit in
                Text("«\(habit.name)» и вся история выполнений будут удалены.")
            }
            .alert(
                "Ошибка",
                isPresented: Binding(
                    get: { model.errorMessage != nil },
                    set: { if !$0 { model.errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    model.errorMessage = nil
                }
            } message: {
                Text(model.errorMessage ?? "")
            }
        }
    }

    private var summary: some View {
        HStack(spacing: 16) {
            ProgressRing(progress: model.completionFraction)

            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)

                Text("\(model.completedToday) из \(model.habits.count)")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(AppTheme.text)

                Text(model.habits.isEmpty ? "добавьте первую привычку" : "выполнено сегодня")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [AppTheme.accent.opacity(0.16), AppTheme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AppTheme.accent.opacity(0.18), lineWidth: 1)
        )
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatTile(
                title: "Лучшая серия",
                value: "\(model.bestCurrentStreak) \(daysWord(model.bestCurrentStreak))",
                icon: "flame.fill",
                tint: AppTheme.yellow
            )
            StatTile(
                title: "За 30 дней",
                value: "\(Int((model.averageCompletionRate * 100).rounded()))%",
                icon: "chart.line.uptrend.xyaxis",
                tint: AppTheme.cyan
            )
        }
    }

    private var habitList: some View {
        VStack(spacing: 14) {
            SectionTitle(
                title: "Сегодня",
                subtitle: "Нажмите на кружок, чтобы отметить выполнение"
            )

            LazyVStack(spacing: 12) {
                ForEach(model.habits) { habit in
                    HabitCardView(habit: habit)
                        .contextMenu {
                            Button(role: .destructive) {
                                pendingDelete = habit
                                showingDelete = true
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.14))
                    .frame(width: 96, height: 96)
                Text("🌱")
                    .font(.system(size: 44))
            }

            Text("Пока пусто")
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(AppTheme.text)

            Text("Создайте привычку, отмечайте дни и наблюдайте, как растёт ваша серия.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button {
                showingAdd = true
            } label: {
                Label("Добавить привычку", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 13)
                    .background(AppTheme.accent, in: Capsule())
                    .foregroundStyle(Color.black.opacity(0.8))
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 12)
        .background(
            AppTheme.surface,
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Доброе утро"
        case 12..<18: return "Добрый день"
        case 18..<23: return "Добрый вечер"
        default: return "Доброй ночи"
        }
    }
}
