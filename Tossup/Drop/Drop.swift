import Foundation

/// Question in the turnstile lexicon. Copied from the bank into the chart when dealt.
struct Drop: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var stem: String
    var difficulty: Int
    var why: String
    var correctChoiceID: String
    var choices: [Choice]

    func choice(id: String) -> Choice? {
        choices.first { $0.id == id }
    }
}

/// Calendar day as YYYYMMDD, and the pool index from start-of-day distance.
enum DayKey {
    static func key(for date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10000 + month * 100 + day
    }

    /// Whole days from 2020-01-01 local start-of-day. Used as dayIndex % pool.count.
    static func dayIndex(for date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        var parts = DateComponents()
        parts.year = 2020
        parts.month = 1
        parts.day = 1
        guard let epoch = calendar.date(from: parts) else {
            return 0
        }
        let epochStart = calendar.startOfDay(for: epoch)
        let days = calendar.dateComponents([.day], from: epochStart, to: start).day ?? 0
        return max(0, days)
    }

    static func date(from key: Int, calendar: Calendar = .current) -> Date? {
        let year = key / 10000
        let month = (key / 100) % 100
        let day = key % 100
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        guard let date = calendar.date(from: parts) else {
            return nil
        }
        return calendar.startOfDay(for: date)
    }
}

enum DropPicker {
    /// dayIndex % pool.count over drops in the selected decks, in deck then drop order.
    static func pool(decks: [Deck], selectedIDs: [String]) -> [Drop] {
        let selected = Set(selectedIDs)
        return decks.filter { selected.contains($0.id) }.flatMap(\.drops)
    }

    static func select(dayIndex: Int, decks: [Deck], selectedIDs: [String]) -> Drop? {
        let drops = pool(decks: decks, selectedIDs: selectedIDs)
        guard !drops.isEmpty else {
            return nil
        }
        let count = drops.count
        let wrapped = ((dayIndex % count) + count) % count
        return drops[wrapped]
    }
}
