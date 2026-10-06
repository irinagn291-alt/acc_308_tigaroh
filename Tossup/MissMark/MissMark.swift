import Foundation

/// Recorded when Score finds the StakeMark on the wrong Choice.
struct MissMark: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var daykey: Int
    var choiceID: String
    var shieldSpent: Bool
}
