import Foundation

/// Answer in the turnstile lexicon. A stable id, never a list index.
struct Choice: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var line: String
}
