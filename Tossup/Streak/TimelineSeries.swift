import Foundation

/// One scored day on the streak timeline. Built from filed Cards, not a second store.
struct TimelineSample: Identifiable, Equatable, Sendable {
    var daykey: Int
    var streakLength: Int
    var points: Int
    var date: Date

    var id: Int { daykey }
}

enum TimelineSeries {
    /// Walks Cards in day order. A spent ShieldMark keeps the run. A bare miss zeros it.
    static func samples(cards: [Card], misses: [MissMark], calendar: Calendar = .current) -> [TimelineSample] {
        let spent = Set(misses.filter(\.shieldSpent).map(\.daykey))
        let ordered = cards.sorted { $0.daykey < $1.daykey }
        var run = 0
        var rows: [TimelineSample] = []
        for card in ordered {
            if card.correct {
                run += 1
            } else if spent.contains(card.daykey) {
                run = max(run, 0)
            } else {
                run = 0
            }
            let date = DayKey.date(from: card.daykey, calendar: calendar) ?? .now
            rows.append(TimelineSample(daykey: card.daykey, streakLength: run, points: card.points, date: date))
        }
        return rows
    }
}
