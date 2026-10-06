import Foundation

/// Freeze written when Seal folds Staked to Sealed. The answer stays hidden until Score.
struct SealMark: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var daykey: Int
    var choiceID: String
}
