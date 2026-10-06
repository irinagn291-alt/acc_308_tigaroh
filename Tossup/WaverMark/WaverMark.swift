import Foundation

/// A second Stake while Staked. The original StakeMark stays.
struct WaverMark: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var daykey: Int
    var attemptedChoiceID: String
}
