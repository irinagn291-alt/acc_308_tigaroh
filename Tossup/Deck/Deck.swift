import Foundation

/// Themed pool the day's Drop is drawn from. Selected decks form the modulo pool.
struct Deck: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var title: String
    var drops: [Drop]
}

/// Bundled bank DTO. Mapped into Deck so the chart never decodes the file as its model.
struct BankDocument: Decodable, Sendable {
    var schemaVersion: Int
    var decks: [BankDeck]

    func decksMapped() -> [Deck] {
        decks.map { deck in
            Deck(
                id: deck.id,
                title: deck.title,
                drops: deck.drops.map { drop in
                    Drop(
                        id: drop.id,
                        stem: drop.stem,
                        difficulty: drop.difficulty,
                        why: drop.why,
                        correctChoiceID: drop.correctChoiceID,
                        choices: drop.choices.map { Choice(id: $0.id, line: $0.line) }
                    )
                }
            )
        }
    }
}

struct BankDeck: Decodable, Sendable {
    var id: String
    var title: String
    var drops: [BankDrop]
}

struct BankDrop: Decodable, Sendable {
    var id: String
    var stem: String
    var difficulty: Int
    var why: String
    var correctChoiceID: String
    var choices: [BankChoice]
}

struct BankChoice: Decodable, Sendable {
    var id: String
    var line: String
}

enum QuestionBank {
    static func load(from data: Data) -> [Deck] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        guard let document = try? decoder.decode(BankDocument.self, from: data) else {
            return []
        }
        guard document.schemaVersion == 1 else {
            return []
        }
        return document.decksMapped()
    }

    static func loadBundled() -> [Deck] {
        guard let url = Bundle.main.url(forResource: "QuestionBank", withExtension: "json") else {
            return []
        }
        guard let data = try? Data(contentsOf: url) else {
            return []
        }
        return load(from: data)
    }
}
