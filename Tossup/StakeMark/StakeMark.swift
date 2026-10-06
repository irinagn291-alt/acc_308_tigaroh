import Foundation

/// Live stake on one Choice. A later stake while Staked does not replace it.
struct StakeMark: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var daykey: Int
    var choiceID: String
}
