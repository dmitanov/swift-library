import Foundation
import HabitKit

final class HabitTrackerApp {
    private let store: HabitStore
    private let calendar: Calendar
    private var message: String?

    init() {
        let calendar = Calendar.current
        self.calendar = calendar
        self.store = HabitStore(calendar: calendar)
    }

    func run() {
        setupConsole()

        if let loadError = store.loadError {
            message = "\(Theme.red)Не удалось загрузить данные: \(loadError)\(Theme.reset)"
        }

        while true {
            renderDashboard()

            guard let raw = readLine() else { break }
            let command = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if command.isEmpty { continue }

            switch command {
            case "q", "й", "quit", "выход":
                clearScreen()
                print("  \(Theme.accent)До встречи! 👋\(Theme.reset)")
                return
            case "a", "ф":
                addHabit()
            case "d", "в":
                deleteHabit()
            case "i", "ш":
                showDetail()
            case "s", "ы":
                showStats()
            default:
                if let index = Int(command), (1...max(1, store.habits.count)).contains(index),
                   index <= store.habits.count {
                    toggleHabit(at: index)
                } else {
                    message = "\(Theme.red)Неизвестная команда: \(command)\(Theme.reset)"
                }
            }
        }
    }

    private func renderDashboard(clear: Bool = true, showPrompt: Bool = true) {
        if clear { clearScreen() }

        let today = store.today()
        let total = store.habits.count
        let completed = store.habits.filter { $0.isCompleted(on: today) }.count
        let bestStreak = store.habits
            .map { $0.currentStreak(asOf: today, calendar: calendar) }
            .max() ?? 0
        let progress = total == 0 ? 0 : Double(completed) / Double(total)

        let header = box(
            lines: [
                "\(Theme.bold)🔥  ТРЕКЕР ПРИВЫЧЕК\(Theme.reset)",
                "\(Theme.muted)\(dateTitle(today, calendar: calendar))\(Theme.reset)",
            ],
            width: 63,
            color: Theme.accent
        )
        print(header.map { "  " + $0 }.joined(separator: "\n"))

        print("")
        print(
            "  \(Theme.white)Сегодня: \(Theme.green)\(completed)\(Theme.white) / \(total)\(Theme.reset)"
                + "   \(progressBar(progress))"
                + "   \(Theme.yellow)🔥 лучшая серия: \(bestStreak) \(daysWord(bestStreak))\(Theme.reset)"
        )
        print("")

        if store.habits.isEmpty {
            print(emptyState())
        } else {
            for (offset, habit) in store.habits.enumerated() {
                if offset > 0 { print("") }
                let card = habitCard(
                    index: offset + 1,
                    habit: habit,
                    today: today,
                    calendar: calendar
                )
                print(card.map { "  " + $0 }.joined(separator: "\n"))
            }
        }

        print("")
        if let message {
            print("  " + message)
            print("")
        }
        print(
            "  \(Theme.muted)[1-9]\(Theme.reset) отметить  "
                + "\(Theme.muted)[a]\(Theme.reset) добавить  "
                + "\(Theme.muted)[d]\(Theme.reset) удалить  "
                + "\(Theme.muted)[i]\(Theme.reset) подробнее  "
                + "\(Theme.muted)[s]\(Theme.reset) статистика  "
                + "\(Theme.muted)[q]\(Theme.reset) выход"
        )
        print("")
        if showPrompt {
            print("  \(Theme.accent)❯\(Theme.reset) ", terminator: "")
        }

        message = nil
    }

    private func toggleHabit(at index: Int) {
        let habit = store.habits[index - 1]
        do {
            let done = try store.toggle(id: habit.id)
            let today = store.today()
            if done == true {
                let streak = store.habit(id: habit.id)?
                    .currentStreak(asOf: today, calendar: calendar) ?? 0
                message = "\(Theme.green)✓ \(habit.emoji) \(habit.name)"
                    + " — серия \(streak) \(daysWord(streak))\(Theme.reset)"
            } else {
                message = "\(Theme.yellow)↺ Отметка снята: \(habit.emoji) \(habit.name)\(Theme.reset)"
            }
        } catch {
            message = "\(Theme.red)Ошибка сохранения: \(error.localizedDescription)\(Theme.reset)"
        }
    }

    private func addHabit() {
        clearScreen()
        print("  \(Theme.bold)✨  Новая привычка\(Theme.reset)")
        print("")

        guard let rawName = ask("Название: ") else { return }
        let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            message = "\(Theme.red)Название не может быть пустым\(Theme.reset)"
            return
        }

        let rawEmoji = ask("Эмодзи (Enter — ⭐️): ") ?? ""
        let emoji = rawEmoji.trimmingCharacters(in: .whitespacesAndNewlines)
        let chosenEmoji = emoji.isEmpty ? "⭐️" : emoji

        print("")
        print("  \(Theme.muted)Цвет:\(Theme.reset)")
        for (offset, color) in HabitColor.allCases.enumerated() {
            print("   \(offset + 1). \(color.ansi)●\(Theme.reset) \(color.title)")
        }

        let rawColor = ask("Цвет (Enter — синий): ") ?? ""
        let colorNumber = Int(rawColor.trimmingCharacters(in: .whitespacesAndNewlines))
        let color: HabitColor
        if let colorNumber, (1...HabitColor.allCases.count).contains(colorNumber) {
            color = HabitColor.allCases[colorNumber - 1]
        } else {
            color = .blue
        }

        do {
            let habit = try store.add(name: name, emoji: chosenEmoji, color: color)
            message = "\(Theme.green)Добавлено: \(habit.emoji) \(habit.name)\(Theme.reset)"
        } catch {
            message = "\(Theme.red)Ошибка сохранения: \(error.localizedDescription)\(Theme.reset)"
        }
    }

    private func deleteHabit() {
        guard !store.habits.isEmpty else {
            message = "\(Theme.muted)Пока нет привычек для удаления\(Theme.reset)"
            return
        }

        renderDashboard(clear: true, showPrompt: false)
        guard let raw = ask("Номер привычки для удаления: "),
              let index = Int(raw.trimmingCharacters(in: .whitespacesAndNewlines)),
              (1...store.habits.count).contains(index)
        else {
            message = "\(Theme.red)Некорректный номер\(Theme.reset)"
            return
        }

        let habit = store.habits[index - 1]
        let answer = ask("Удалить «\(habit.emoji) \(habit.name)»? (д/н): ")?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? ""

        guard ["д", "да", "y", "yes"].contains(answer) else {
            message = "\(Theme.muted)Удаление отменено\(Theme.reset)"
            return
        }

        do {
            try store.remove(id: habit.id)
            message = "\(Theme.yellow)Удалено: \(habit.emoji) \(habit.name)\(Theme.reset)"
        } catch {
            message = "\(Theme.red)Ошибка сохранения: \(error.localizedDescription)\(Theme.reset)"
        }
    }

    private func showDetail() {
        guard !store.habits.isEmpty else {
            message = "\(Theme.muted)Сначала добавьте привычку\(Theme.reset)"
            return
        }

        renderDashboard(clear: true, showPrompt: false)
        guard let raw = ask("Номер привычки: "),
              let index = Int(raw.trimmingCharacters(in: .whitespacesAndNewlines)),
              (1...store.habits.count).contains(index)
        else {
            message = "\(Theme.red)Некорректный номер\(Theme.reset)"
            return
        }

        let habit = store.habits[index - 1]
        let today = store.today()
        let streak = habit.currentStreak(asOf: today, calendar: calendar)
        let longest = habit.longestStreak(calendar: calendar)
        let rate = habit.completionRate(lastDays: 30, asOf: today, calendar: calendar)

        clearScreen()
        var lines: [String] = [
            "\(habit.emoji)  \(habit.color.ansi)\(Theme.bold)\(truncate(habit.name, to: 40))\(Theme.reset)",
            "\(Theme.muted)с \(habit.createdAt.description) · \(habit.color.title)\(Theme.reset)",
            "",
            "\(Theme.muted)Текущая серия\(Theme.reset)      \(Theme.yellow)🔥 \(streak) \(daysWord(streak))\(Theme.reset)",
            "\(Theme.muted)Лучшая серия\(Theme.reset)       \(Theme.accent)\(longest) \(daysWord(longest))\(Theme.reset)",
            "\(Theme.muted)Всего отметок\(Theme.reset)      \(Theme.white)\(habit.totalCompletions)\(Theme.reset)",
            "",
            "\(Theme.muted)Выполнение за 30 дней\(Theme.reset)  \(progressBar(rate, width: 20))",
            "",
            "\(Theme.bold)Последние 8 недель\(Theme.reset)",
        ]
        lines.append(contentsOf: heatmap(habit: habit, today: today, calendar: calendar, weeks: 8))

        print(box(lines: lines, width: 63, color: habit.color.ansi).map { "  " + $0 }.joined(separator: "\n"))
        print("")
        _ = ask("Enter — назад ")
    }

    private func showStats() {
        let today = store.today()
        let total = store.habits.count
        let completed = store.habits.filter { $0.isCompleted(on: today) }.count
        let totalCompletions = store.habits.reduce(0) { $0 + $1.totalCompletions }
        let averageRate = total == 0
            ? 0
            : store.habits.reduce(0.0) {
                $0 + $1.completionRate(lastDays: 7, asOf: today, calendar: calendar)
            } / Double(total)

        let bestHabit = store.habits.max {
            $0.currentStreak(asOf: today, calendar: calendar)
                < $1.currentStreak(asOf: today, calendar: calendar)
        }
        let bestStreak = bestHabit?.currentStreak(asOf: today, calendar: calendar) ?? 0

        clearScreen()
        var lines: [String] = [
            "\(Theme.bold)📊  Статистика\(Theme.reset)",
            "\(Theme.muted)\(dateTitle(today, calendar: calendar))\(Theme.reset)",
            "",
            "\(Theme.muted)Всего привычек\(Theme.reset)       \(Theme.white)\(total)\(Theme.reset)",
            "\(Theme.muted)Выполнено сегодня\(Theme.reset)    \(Theme.green)\(completed)\(Theme.muted) / \(total)\(Theme.reset)",
            "\(Theme.muted)Среднее за 7 дней\(Theme.reset)     \(Theme.accent)\(Int((averageRate * 100).rounded()))%\(Theme.reset)",
            "\(Theme.muted)Всего отметок\(Theme.reset)         \(Theme.white)\(totalCompletions)\(Theme.reset)",
        ]

        if let bestHabit, bestStreak > 0 {
            lines.append(
                "\(Theme.muted)Лучшая серия\(Theme.reset)        "
                    + "\(bestHabit.emoji) \(Theme.yellow)🔥 \(bestStreak) \(daysWord(bestStreak))\(Theme.reset)"
            )
        }

        lines.append("")
        lines.append(progressBar(total == 0 ? 0 : Double(completed) / Double(total), width: 30))

        print(box(lines: lines, width: 63, color: Theme.accent).map { "  " + $0 }.joined(separator: "\n"))
        print("")
        _ = ask("Enter — назад ")
    }

    private func ask(_ prompt: String) -> String? {
        print("  \(Theme.accent)❯\(Theme.reset) \(prompt)", terminator: "")
        return readLine()
    }

    private func emptyState() -> String {
        let lines = [
            "",
            "       \(Theme.accent)✨  Пока нет привычек\(Theme.reset)",
            "",
            "       \(Theme.muted)Нажмите [a], чтобы добавить первую\(Theme.reset)",
            "",
        ]
        return box(lines: lines, width: 63, color: Theme.muted)
            .map { "  " + $0 }
            .joined(separator: "\n")
    }
}

HabitTrackerApp().run()
