import Foundation

/// Progress. Length is the live run. Consecutive corrects grant a shield every 7.
struct Streak: Codable, Equatable, Sendable {
    var length: Int
    var consecutiveCorrect: Int

    static let empty = Streak(length: 0, consecutiveCorrect: 0)

    /// difficulty + min(streak, 10), using the streak before it increments.
    static func points(difficulty: Int, streakLength: Int) -> Int {
        difficulty + min(streakLength, 10)
    }
}
