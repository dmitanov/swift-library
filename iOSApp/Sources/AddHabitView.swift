import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject private var model: HabitViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var emoji = "⭐️"
    @State private var color: HabitColor = .blue

    private let emojis = [
        "⭐️", "🔥", "💧", "🏃", "📚", "🧘", "🥗", "💤",
        "🎯", "💪", "🎨", "🎵", "🌱", "☀️", "🧠", "✍️"
    ]

    private let emojiColumns = [
        GridItem(.adaptive(minimum: 52), spacing: 10)
    ]

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        preview
                        nameField
                        emojiSection
                        colorSection
                        addButton
                    }
                    .padding(20)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Новая привычка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.secondaryText)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var preview: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.swiftUIColor.opacity(0.18))
                    .frame(width: 70, height: 70)
                Circle()
                    .strokeBorder(color.swiftUIColor.opacity(0.35), lineWidth: 1)
                    .frame(width: 70, height: 70)
                Text(emoji)
                    .font(.system(size: 34))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(trimmedName.isEmpty ? "Новая привычка" : trimmedName)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(
                        trimmedName.isEmpty ? AppTheme.secondaryText : AppTheme.text
                    )
                    .lineLimit(1)

                Text("Предпросмотр карточки")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            AppTheme.cardGradient(color.swiftUIColor),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(color.swiftUIColor.opacity(0.20), lineWidth: 1)
        )
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Название")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.secondaryText)

            TextField("Например: читать 20 минут", text: $name)
                .font(.body)
                .foregroundStyle(AppTheme.text)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.done)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    AppTheme.surface,
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(AppTheme.muted.opacity(0.16), lineWidth: 1)
                )
        }
    }

    private var emojiSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Иконка")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.secondaryText)

            LazyVGrid(columns: emojiColumns, spacing: 10) {
                ForEach(emojis, id: \.self) { item in
                    Button {
                        emoji = item
                    } label: {
                        Text(item)
                            .font(.system(size: 24))
                            .frame(width: 52, height: 52)
                            .background(
                                emoji == item
                                    ? color.swiftUIColor.opacity(0.20)
                                    : AppTheme.surface,
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(
                                        emoji == item
                                            ? color.swiftUIColor.opacity(0.55)
                                            : AppTheme.muted.opacity(0.12),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Цвет")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.secondaryText)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 34), spacing: 10)],
                spacing: 10
            ) {
                ForEach(HabitColor.allCases, id: \.self) { habitColor in
                    Button {
                        color = habitColor
                    } label: {
                        ZStack {
                            Circle()
                                .fill(habitColor.swiftUIColor)
                                .frame(width: 32, height: 32)

                            if color == habitColor {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.black.opacity(0.7))
                            }
                        }
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    Color.white.opacity(color == habitColor ? 0.9 : 0),
                                    lineWidth: 2
                                )
                                .padding(2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var addButton: some View {
        Button {
            model.add(name: trimmedName, emoji: emoji, color: color)
            dismiss()
        } label: {
            Label("Создать привычку", systemImage: "plus")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    trimmedName.isEmpty
                        ? AnyShapeStyle(AppTheme.muted.opacity(0.25))
                        : AnyShapeStyle(color.swiftUIColor),
                    in: Capsule()
                )
                .foregroundStyle(
                    trimmedName.isEmpty
                        ? AnyShapeStyle(AppTheme.secondaryText)
                        : AnyShapeStyle(Color.black.opacity(0.78))
                )
        }
        .buttonStyle(.plain)
        .disabled(trimmedName.isEmpty)
    }
}
