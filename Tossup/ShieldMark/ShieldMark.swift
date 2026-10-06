import Foundation

/// Granted on every seventh consecutive correct day. Spending one keeps streak on a miss.
struct ShieldMark: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var grantedDaykey: Int
    var spentDaykey: Int?

    var available: Bool { spentDaykey == nil }
}
