import Foundation

/// Seal attempted while the ticket is still Open. The fold is refused.
struct EarlyMark: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var daykey: Int
}
