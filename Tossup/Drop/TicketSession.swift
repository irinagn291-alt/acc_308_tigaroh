import SwiftUI

/// Root session. The chart is the only record the screens mutate. UserDefaults stays inside ChartStore.
@MainActor
final class TicketSession: ObservableObject {
    @Published private(set) var chart: TicketChart
    @Published private(set) var bank: [Deck] = []
    @Published private(set) var load: LoadState = .loading
    @Published var sheet: TicketSheet?
    @Published var status: String = "Pick a choice."
    @Published var spendShield = false
    @Published var sealing = false
    @Published var confirmReset = false
    @Published private(set) var recoveryVisible = false
    @Published var reviewGate = false

    private let store: ChartStore
    private var started = false
    private var reviewApplied = false

    enum LoadState: Equatable {
        case loading
        case ready
        case failed(String)
    }

    init(store: ChartStore = ChartStore(suiteName: nil)) {
        self.store = store
        chart = store.chart
    }

    func bootstrap() async {
        guard !started else {
            return
        }
        started = true
        reviewGate = false
        load = .loading
        await store.load()
        bank = QuestionBank.loadBundled()
        guard !bank.isEmpty else {
            load = .failed("Question bank missing. The bundled file did not open.")
            return
        }
        let now = Date()
        let calendar = Calendar.current
        await store.applySeedIfNeeded(now: now, calendar: calendar, bank: bank)
        let stored = store.chart
        // Do not file a Blank day before a deck is selected. The gate deals once the pool exists.
        let next = stored.selectedDeckIDs.isEmpty
            ? stored
            : TodayTicket.deal(chart: stored, now: now, calendar: calendar, bank: bank)
        store.replace(next)
        chart = next
        recoveryVisible = !store.recoveryNote.isEmpty
        status = openingStatus(for: next)
        load = .ready
        applyReviewIfReady()
    }

    func retry() async {
        started = false
        reviewApplied = false
        await bootstrap()
    }

    func refreshDay() {
        guard load == .ready else {
            return
        }
        let next = TodayTicket.deal(chart: chart, now: Date(), calendar: .current, bank: bank)
        guard next != chart else {
            return
        }
        commit(next)
    }

    func leftActive() async {
        await store.presenceLeftActive()
    }

    func stake(choiceID: String) {
        guard let key = todayKey else {
            status = "Today's drop is waiting."
            return
        }
        let (next, notice) = TodayTicket.stake(chart: chart, daykey: key, choiceID: choiceID)
        commit(next)
        if notice.waver != nil {
            status = "Already staked."
        } else if notice.refusal == .stakeOnSealed {
            status = "Stake refused. Ticket sealed."
        } else if notice.refusal != nil {
            status = "Stake refused."
        } else {
            status = "Staked. Peel to change."
        }
    }

    func promptStake() {
        status = "Pick a choice."
    }

    func seal() {
        guard !sealing, let key = todayKey else {
            return
        }
        sealing = true
        let (next, notice) = TodayTicket.sealAndScore(chart: chart, daykey: key, spendShield: spendShield)
        commit(next)
        sealing = false
        if notice.refusal == .sealOnOpen || notice.early != nil {
            status = "Seal refused. Stake first."
            return
        }
        guard let card = notice.card else {
            status = "Score refused. Seal a staked ticket."
            return
        }
        TicketHaptic.commit()
        if card.correct {
            status = "Stake sealed."
        } else if notice.miss?.shieldSpent == true {
            status = "Miss. Shield spent."
        } else {
            status = "Miss. Streak cleared."
        }
    }

    func peel() {
        guard let key = todayKey else {
            return
        }
        let (next, notice) = TodayTicket.peel(chart: chart, daykey: key)
        commit(next)
        if notice.refusal != nil {
            status = "Peel refused."
        } else {
            status = "Open. Pick a choice."
        }
    }

    func finishGate(selectedDeckIDs: [String]) {
        reviewGate = false
        var next = OnboardingGate.complete(chart: chart, selectedDeckIDs: selectedDeckIDs)
        next = TodayTicket.deal(chart: next, now: Date(), calendar: .current, bank: bank)
        commit(next)
        status = openingStatus(for: next)
        applyReviewIfReady()
    }

    func skipGate() {
        reviewGate = false
        let skipped = OnboardingGate.skip(chart: chart, bank: bank)
        let dealt = TodayTicket.deal(chart: skipped, now: Date(), calendar: .current, bank: bank)
        commit(dealt)
        status = openingStatus(for: dealt)
        applyReviewIfReady()
    }

    func replayGate() {
        var next = chart
        next.onboardingComplete = false
        commit(next)
        sheet = nil
    }

    func setDeck(_ id: String, on: Bool) {
        var ids = chart.selectedDeckIDs
        if on {
            if !ids.contains(id) {
                ids.append(id)
            }
        } else {
            ids.removeAll { $0 == id }
        }
        var next = chart
        next.selectedDeckIDs = ids
        if let key = todayKey, let ticket = next.ticket(daykey: key), ticket.phase == .open || ticket.phase == .blank {
            next.tickets.removeAll { $0.daykey == key }
            next = TodayTicket.deal(chart: next, now: Date(), calendar: .current, bank: bank)
        }
        commit(next)
    }

    func reset() async {
        await store.resetAllData()
        chart = store.chart
        spendShield = false
        confirmReset = false
        sheet = nil
        status = "Chart reset."
        recoveryVisible = false
    }

    func dismissRecovery() {
        recoveryVisible = false
    }

    var todayTicket: DayTicket? {
        guard let key = todayKey else {
            return nil
        }
        return chart.ticket(daykey: key)
    }

    var todayKey: Int? {
        DayKey.key(for: Date())
    }

    var availableShields: Int {
        chart.shieldMarks.filter(\.available).count
    }

    var resetConsequence: String {
        let cards = TicketFormat.whole(chart.cards.count)
        let streak = TicketFormat.whole(chart.streak.length)
        return "Reset erases \(cards) filed cards and streak \(streak)."
    }

    private func commit(_ next: TicketChart) {
        chart = next
        store.replace(next)
    }

    private func openingStatus(for chart: TicketChart) -> String {
        let key = DayKey.key(for: Date())
        switch chart.ticket(daykey: key)?.phase {
        case .staked:
            return "Staked. Peel to change."
        case .scored:
            return "Stake sealed."
        case .blank, .none:
            return "Today's drop is waiting."
        case .open, .sealed:
            return "Pick a choice."
        }
    }

    /// Launch key, once, only after the gate is down.
    private func applyReviewIfReady() {
        guard chart.onboardingComplete, !reviewApplied else {
            return
        }
        reviewApplied = true
        switch ReviewLaunch.screen {
        case "log", "journal":
            sheet = .journal
        case "goals", "stats":
            sheet = .stats
        case "trophies":
            sheet = .trophies
        case "settings":
            sheet = .settings
        case "onboarding":
            sheet = nil
            reviewGate = true
        default:
            sheet = nil
        }
    }
}

/// Sheets over the locked ticket. Not tabs.
enum TicketSheet: String, Identifiable {
    case journal
    case stats
    case trophies
    case settings

    var id: String { rawValue }
}
