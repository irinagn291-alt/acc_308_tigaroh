import Foundation

/// Chart root. The only storage seam. UI never touches UserDefaults.
struct TicketChart: Codable, Equatable, Sendable {
    var schemaVersion: Int
    var selectedDeckIDs: [String]
    var onboardingComplete: Bool
    var tickets: [DayTicket]
    var stakeMarks: [StakeMark]
    var sealMarks: [SealMark]
    var cards: [Card]
    var missMarks: [MissMark]
    var shieldMarks: [ShieldMark]
    var waverMarks: [WaverMark]
    var earlyMarks: [EarlyMark]
    var streak: Streak
    /// Set when a decode failure was replaced with a fresh chart.
    var recoveredFromCorrupt: Bool

    static let currentSchema = 1
    static let storageKey = "tsp.chart.v1"
    static let demoKey = "tsp.demo.v1"

    static func fresh(deckIDs: [String] = []) -> TicketChart {
        TicketChart(
            schemaVersion: currentSchema,
            selectedDeckIDs: deckIDs,
            onboardingComplete: false,
            tickets: [],
            stakeMarks: [],
            sealMarks: [],
            cards: [],
            missMarks: [],
            shieldMarks: [],
            waverMarks: [],
            earlyMarks: [],
            streak: .empty,
            recoveredFromCorrupt: false
        )
    }

    func ticket(daykey: Int) -> DayTicket? {
        tickets.first { $0.daykey == daykey }
    }

    init(
        schemaVersion: Int,
        selectedDeckIDs: [String],
        onboardingComplete: Bool,
        tickets: [DayTicket],
        stakeMarks: [StakeMark],
        sealMarks: [SealMark],
        cards: [Card],
        missMarks: [MissMark],
        shieldMarks: [ShieldMark],
        waverMarks: [WaverMark],
        earlyMarks: [EarlyMark],
        streak: Streak,
        recoveredFromCorrupt: Bool
    ) {
        self.schemaVersion = schemaVersion
        self.selectedDeckIDs = selectedDeckIDs
        self.onboardingComplete = onboardingComplete
        self.tickets = tickets
        self.stakeMarks = stakeMarks
        self.sealMarks = sealMarks
        self.cards = cards
        self.missMarks = missMarks
        self.shieldMarks = shieldMarks
        self.waverMarks = waverMarks
        self.earlyMarks = earlyMarks
        self.streak = streak
        self.recoveredFromCorrupt = recoveredFromCorrupt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            selectedDeckIDs = try container.decode([String].self, forKey: .selectedDeckIDs)
            onboardingComplete = try container.decode(Bool.self, forKey: .onboardingComplete)
            tickets = try container.decode([DayTicket].self, forKey: .tickets)
            stakeMarks = try container.decode([StakeMark].self, forKey: .stakeMarks)
            sealMarks = try container.decode([SealMark].self, forKey: .sealMarks)
            cards = try container.decode([Card].self, forKey: .cards)
            missMarks = try container.decode([MissMark].self, forKey: .missMarks)
            shieldMarks = try container.decode([ShieldMark].self, forKey: .shieldMarks)
            waverMarks = try container.decode([WaverMark].self, forKey: .waverMarks)
            earlyMarks = try container.decode([EarlyMark].self, forKey: .earlyMarks)
            streak = try container.decode(Streak.self, forKey: .streak)
            recoveredFromCorrupt = try container.decodeIfPresent(Bool.self, forKey: .recoveredFromCorrupt) ?? false
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unknown chart schema \(version)"
            )
        }
    }
}

/// Writes the encoded chart off the main actor. A later generation never loses to an earlier one.
actor ChartWriter {
    private let defaults: UserDefaults
    private var appliedGeneration = 0

    init(suiteName: String?) {
        if let suiteName {
            defaults = UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
        } else {
            defaults = UserDefaults.standard
        }
    }

    func read(key: String) -> Data? {
        defaults.data(forKey: key)
    }

    func flag(key: String) -> Bool {
        defaults.bool(forKey: key)
    }

    func setFlag(_ value: Bool, key: String) {
        defaults.set(value, forKey: key)
    }

    func write(data: Data, key: String, generation: Int) {
        guard generation >= appliedGeneration else {
            return
        }
        appliedGeneration = generation
        defaults.set(data, forKey: key)
    }

    func remove(key: String) {
        defaults.removeObject(forKey: key)
        appliedGeneration = 0
    }
}

/// In-memory chart is the source of truth. UserDefaults is a debounced projection.
@MainActor
final class ChartStore {
    private let writer: ChartWriter
    private var generation = 0
    private var saveTask: Task<Void, Never>?
    let debounceNanoseconds: UInt64

    private(set) var chart: TicketChart
    /// Plain sentence when a corrupt record was replaced. Empty when the load was clean.
    private(set) var recoveryNote: String = ""

    init(suiteName: String?, debounceNanoseconds: UInt64 = 400_000_000) {
        writer = ChartWriter(suiteName: suiteName)
        chart = .fresh()
        self.debounceNanoseconds = debounceNanoseconds
    }

    func load() async {
        let data = await writer.read(key: TicketChart.storageKey)
        guard let data else {
            chart = .fresh()
            recoveryNote = ""
            return
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        do {
            chart = try decoder.decode(TicketChart.self, from: data)
            recoveryNote = ""
        } catch {
            chart = .fresh()
            chart.recoveredFromCorrupt = true
            recoveryNote = "Saved ticket could not be read. Started a fresh chart."
            await flush()
        }
    }

    func replace(_ chart: TicketChart) {
        self.chart = chart
        scheduleSave()
    }

    func scheduleSave() {
        generation += 1
        saveTask?.cancel()
        let wait = debounceNanoseconds
        saveTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: wait)
            } catch {
                return
            }
            guard let self, !Task.isCancelled else {
                return
            }
            await self.flush()
        }
    }

    func flush() async {
        saveTask?.cancel()
        saveTask = nil
        generation += 1
        let token = generation
        let snapshot = chart
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        let data: Data
        do {
            data = try encoder.encode(snapshot)
        } catch {
            recoveryNote = "Ticket could not be saved."
            return
        }
        await writer.write(data: data, key: TicketChart.storageKey, generation: token)
    }

    /// scenePhase left active. Writes immediately so a force-quit keeps the last mark.
    func presenceLeftActive() async {
        await flush()
    }

    func resetAllData() async {
        saveTask?.cancel()
        saveTask = nil
        chart = .fresh()
        recoveryNote = ""
        generation += 1
        await writer.remove(key: TicketChart.storageKey)
    }

    func applySeedIfNeeded(now: Date, calendar: Calendar, bank: [Deck]) async {
        guard DemoSeed.allowed else {
            return
        }
        let already = await writer.flag(key: TicketChart.demoKey)
        guard !already else {
            return
        }
        chart = DemoSeed.chart(now: now, calendar: calendar, bank: bank)
        await flush()
        await writer.setFlag(true, key: TicketChart.demoKey)
    }
}
