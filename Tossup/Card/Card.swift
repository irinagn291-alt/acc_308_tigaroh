import Foundation

/// Filed score. Points are the award at scoring time: difficulty + min(streak, 10).
struct Card: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var daykey: Int
    var dropID: String
    var stem: String
    var choiceID: String
    var choiceLine: String
    var correct: Bool
    var difficulty: Int
    var points: Int
    var why: String
}
