import Foundation

#if os(Windows)
import WinSDK
#endif

enum Theme {
    static let reset = "\u{1B}[0m"
    static let bold = "\u{1B}[1m"
    static let dim = "\u{1B}[2m"
    static let accent = "\u{1B}[38;5;213m"
    static let cyan = "\u{1B}[38;5;81m"
    static let green = "\u{1B}[38;5;114m"
    static let red = "\u{1B}[38;5;203m"
    static let yellow = "\u{1B}[38;5;221m"
    static let muted = "\u{1B}[38;5;245m"
    static let white = "\u{1B}[38;5;255m"
}

func setupConsole() {
    #if os(Windows)
    _ = SetConsoleOutputCP(65001)
    _ = SetConsoleCP(65001)

    let handle = GetStdHandle(DWORD(bitPattern: Int32(-11)))
    var mode: DWORD = 0
    if GetConsoleMode(handle, &mode) {
        _ = SetConsoleMode(handle, mode | DWORD(0x0004))
    }
    #endif
}

func clearScreen() {
    print("\u{1B}[2J\u{1B}[H", terminator: "")
}

func characterWidth(_ character: Character) -> Int {
    let scalars = character.unicodeScalars
    if scalars.contains(where: { $0.value == 0xFE0F || $0.value == 0x200D }) {
        return 2
    }
    guard let scalar = scalars.first else { return 0 }
    let value = scalar.value
    if value < 0x20 { return 0 }
    if (0x1F000...0x1FAFF).contains(value) || (0x2600...0x27BF).contains(value) {
        return 2
    }
    if (0x1100...0x115F).contains(value) { return 2 }
    if (0x2E80...0xA4CF).contains(value) { return 2 }
    if (0xAC00...0xD7A3).contains(value) { return 2 }
    return 1
}

func visibleWidth(_ text: String) -> Int {
    var width = 0
    var inEscape = false
    for character in text {
        if inEscape {
            if character == "m" { inEscape = false }
            continue
        }
        if character == "\u{1B}" {
            inEscape = true
            continue
        }
        width += characterWidth(character)
    }
    return width
}

enum Alignment {
    case left
    case center
    case right
}

func pad(_ text: String, to width: Int, alignment: Alignment = .left) -> String {
    let needed = max(0, width - visibleWidth(text))
    switch alignment {
    case .left:
        return text + String(repeating: " ", count: needed)
    case .right:
        return String(repeating: " ", count: needed) + text
    case .center:
        let left = needed / 2
        return String(repeating: " ", count: left) + text
            + String(repeating: " ", count: needed - left)
    }
}

func truncate(_ text: String, to width: Int) -> String {
    guard visibleWidth(text) > width else { return text }

    var result = ""
    var used = 0
    for character in text {
        let size = characterWidth(character)
        if used + size > width - 1 { break }
        result.append(character)
        used += size
    }
    return result + "…"
}

func twoColumn(left: String, right: String, width: Int) -> String {
    let gap = max(1, width - visibleWidth(left) - visibleWidth(right))
    return left + String(repeating: " ", count: gap) + right
}

func box(lines: [String], width: Int, color: String) -> [String] {
    var result: [String] = []
    result.append(color + "╭" + String(repeating: "─", count: width + 2) + "╮" + Theme.reset)
    for line in lines {
        let content = pad(" " + line, to: width + 2)
        result.append(color + "│" + Theme.reset + content + color + "│" + Theme.reset)
    }
    result.append(color + "╰" + String(repeating: "─", count: width + 2) + "╯" + Theme.reset)
    return result
}
