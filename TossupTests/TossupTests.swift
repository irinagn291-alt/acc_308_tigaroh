import XCTest
@testable import Tossup

@MainActor
final class TossupTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        return calendar
    }

    private func sampleDrop(correct: String = "b") -> Drop {
        Drop(
            id: "drop-1",
            stem: "Which answer is filed?",
            difficulty: 4,
            why: "The sealed choice matches the bank.",
            correctChoiceID: correct,
            choices: [
                Choice(id: "a", line: "First"),
                Choice(id: "b", line: "Second"),
                Choice(id: "c", line: "Third"),
                Choice(id: "d", line: "Fourth")
            ]
        )
    }

    private func openTicket() -> DayTicket {
        DayTicket.dealt(daykey: 20260927, drop: sampleDrop())
    }

    func testReviewLaunchParsesScreenArgument() {
        XCTAssertEqual(ReviewLaunch.screen(from: ["Tossup", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(from: ["Tossup", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(from: ["Tossup", "-ReviewScreen", "goals"]), "goals")
        XCTAssertNil(ReviewLaunch.screen(from: ["Tossup"]))
        XCTAssertNil(ReviewLaunch.screen(from: ["Tossup", "-ReviewScreen"]))
    }

    func testDayIndexSelectsFromSelectedDecks() {
        let decks = [
            Deck(id: "world", title: "World", drops: [sampleDrop()]),
            Deck(id: "arts", title: "Arts", drops: [
                Drop(id: "other", stem: "Other", difficulty: 1, why: "Because", correctChoiceID: "a", choices: [Choice(id: "a", line: "A")])
            ])
        ]
        let pool = DropPicker.pool(decks: decks, selectedIDs: ["arts"])
        XCTAssertEqual(pool.count, 1)
        let picked = DropPicker.select(dayIndex: 5, decks: decks, selectedIDs: ["arts"])
        XCTAssertEqual(picked?.id, "other", "dayIndex % pool.count from selected decks")
        XCTAssertNil(DropPicker.select(dayIndex: 0, decks: decks, selectedIDs: []))
    }

    func testPointsUseDifficultyPlusCappedStreak() {
        XCTAssertEqual(Streak.points(difficulty: 4, streakLength: 0), 4)
        XCTAssertEqual(Streak.points(difficulty: 4, streakLength: 3), 7)
        XCTAssertEqual(Streak.points(difficulty: 4, streakLength: 10), 14)
        XCTAssertEqual(Streak.points(difficulty: 4, streakLength: 12), 14, "difficulty + min(streak,10)")
    }

    func testStakeEmptyPopulatedAndInvalid() {
        let blank = DayTicket.blank(daykey: 20260927)
        let empty = TicketFold.stake(ticket: blank, choiceID: "a")
        XCTAssertEqual(empty.1.refusal, .emptyTicket)
        XCTAssertEqual(empty.0.phase, .blank)

        let opened = TicketFold.stake(ticket: openTicket(), choiceID: "b")
        XCTAssertNil(opened.1.refusal)
        XCTAssertEqual(opened.0.phase, .staked)
        XCTAssertEqual(opened.0.stake?.choiceID, "b")

        let invalid = TicketFold.stake(ticket: openTicket(), choiceID: "missing")
        XCTAssertEqual(invalid.1.refusal, .unknownChoice)
        XCTAssertEqual(invalid.0.phase, .open)
    }

    func testStakeThenSealFold() {
        var ticket = openTicket()
        let early = TicketFold.seal(ticket: ticket)
        XCTAssertEqual(early.1.refusal, .sealOnOpen)
        XCTAssertNotNil(early.1.early)
        XCTAssertEqual(early.0.phase, .open)

        let staked = TicketFold.stake(ticket: ticket, choiceID: "a")
        ticket = staked.0
        let kept = ticket.stake?.choiceID
        let waver = TicketFold.stake(ticket: ticket, choiceID: "c")
        XCTAssertNotNil(waver.1.waver)
        XCTAssertEqual(waver.0.stake?.choiceID, kept)
        XCTAssertEqual(waver.0.phase, .staked)

        let peeled = TicketFold.peel(ticket: ticket)
        XCTAssertEqual(peeled.0.phase, .open)
        XCTAssertNil(peeled.0.stake)
        XCTAssertEqual(TicketFold.peel(ticket: peeled.0).1.refusal, .peelNotStaked)

        ticket = TicketFold.stake(ticket: peeled.0, choiceID: "b").0
        ticket = TicketFold.seal(ticket: ticket).0
        XCTAssertEqual(ticket.phase, .sealed)
        XCTAssertNil(ticket.whyLine())

        let refused = TicketFold.stake(ticket: ticket, choiceID: "a")
        XCTAssertEqual(refused.1.refusal, .stakeOnSealed)
        XCTAssertEqual(refused.0.phase, .sealed)

        let scored = TicketFold.score(ticket: ticket, streak: Streak(length: 2, consecutiveCorrect: 2), shields: [], spendShield: false)
        XCTAssertEqual(scored.0.phase, .scored)
        XCTAssertEqual(scored.3.card?.points, 6)
        XCTAssertEqual(scored.3.card?.correct, true)
        XCTAssertEqual(scored.1.length, 3)
        XCTAssertEqual(scored.0.whyLine(), ticket.drop?.why)
    }

    func testMissZerosStreakUnlessShieldSpent() {
        let ticket = sealed(choiceID: "a")
        let missed = TicketFold.score(ticket: ticket, streak: Streak(length: 4, consecutiveCorrect: 4), shields: [], spendShield: true)
        XCTAssertEqual(missed.1.length, 0)
        XCTAssertEqual(missed.3.miss?.shieldSpent, false)
        XCTAssertEqual(missed.3.card?.points, 0)

        let shield = ShieldMark(id: "shield-1", grantedDaykey: 20260101, spentDaykey: nil)
        let saved = TicketFold.score(
            ticket: ticket,
            streak: Streak(length: 4, consecutiveCorrect: 4),
            shields: [shield],
            spendShield: true
        )
        XCTAssertEqual(saved.1.length, 4, "Miss zeros streak unless a shield")
        XCTAssertEqual(saved.1.consecutiveCorrect, 0)
        XCTAssertEqual(saved.2.first?.spentDaykey, ticket.daykey)
        XCTAssertEqual(saved.3.miss?.shieldSpent, true)
    }

    func testSeventhCorrectDayWritesShield() {
        var streak = Streak.empty
        var shields: [ShieldMark] = []
        let ticket = sealed(choiceID: "b")
        for _ in 0..<6 {
            let step = TicketFold.score(ticket: ticket, streak: streak, shields: shields, spendShield: false)
            streak = step.1
            shields = step.2
            XCTAssertNil(step.3.shieldGranted)
        }
        let seventh = TicketFold.score(ticket: ticket, streak: streak, shields: shields, spendShield: false)
        XCTAssertEqual(seventh.1.length, 7)
        XCTAssertEqual(seventh.1.consecutiveCorrect, 7)
        XCTAssertNotNil(seventh.3.shieldGranted)
        XCTAssertEqual(seventh.2.count, 1)
    }

    func testChartRoundTripAndCorruptRecovery() async throws {
        let suite = "tossup-tests-\(UUID().uuidString)"
        let store = ChartStore(suiteName: suite, debounceNanoseconds: 50_000_000)
        await store.load()
        var chart = TicketChart.fresh(deckIDs: ["world"])
        chart.onboardingComplete = true
        let drop = sampleDrop()
        chart.tickets = [DayTicket.dealt(daykey: 20260927, drop: drop)]
        let staked = TodayTicket.stake(chart: chart, daykey: 20260927, choiceID: "b")
        store.replace(staked.0)
        await store.flush()

        let reloaded = ChartStore(suiteName: suite, debounceNanoseconds: 50_000_000)
        await reloaded.load()
        XCTAssertEqual(reloaded.chart.tickets.first?.phase, .staked)
        XCTAssertEqual(reloaded.chart.stakeMarks.count, 1)
        XCTAssertTrue(reloaded.chart.onboardingComplete)
        XCTAssertEqual(reloaded.recoveryNote, "")

        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defaults.set(Data("{".utf8), forKey: TicketChart.storageKey)
        let broken = ChartStore(suiteName: suite)
        await broken.load()
        XCTAssertTrue(broken.chart.recoveredFromCorrupt)
        XCTAssertFalse(broken.recoveryNote.isEmpty)
        XCTAssertTrue(broken.chart.tickets.isEmpty)

        await store.resetAllData()
        let cleared = ChartStore(suiteName: suite)
        await cleared.load()
        XCTAssertFalse(cleared.chart.onboardingComplete)
        XCTAssertTrue(cleared.chart.cards.isEmpty)
    }

    func testDebouncedSaveKeepsLatestChart() async {
        let suite = "tossup-debounce-\(UUID().uuidString)"
        let store = ChartStore(suiteName: suite, debounceNanoseconds: 400_000_000)
        await store.load()
        var first = TicketChart.fresh(deckIDs: ["world"])
        first.onboardingComplete = false
        store.replace(first)
        var second = first
        second.onboardingComplete = true
        second.selectedDeckIDs = ["arts"]
        store.replace(second)
        await store.flush()
        let reloaded = ChartStore(suiteName: suite)
        await reloaded.load()
        XCTAssertTrue(reloaded.chart.onboardingComplete)
        XCTAssertEqual(reloaded.chart.selectedDeckIDs, ["arts"])
    }

    func testBlankDayTakesDropOnceDecksAreSelected() {
        let bank = [Deck(id: "world", title: "World", drops: [sampleDrop()])]
        let now = Date(timeIntervalSince1970: 1_758_960_000)
        let blanked = TodayTicket.deal(chart: .fresh(), now: now, calendar: calendar, bank: bank)
        let key = DayKey.key(for: now, calendar: calendar)
        XCTAssertEqual(blanked.ticket(daykey: key)?.phase, .blank)
        XCTAssertNil(blanked.ticket(daykey: key)?.drop)

        let chosen = OnboardingGate.skip(chart: blanked, bank: bank)
        let dealt = TodayTicket.deal(chart: chosen, now: now, calendar: calendar, bank: bank)
        XCTAssertEqual(dealt.ticket(daykey: key)?.phase, .open)
        XCTAssertNotNil(dealt.ticket(daykey: key)?.drop)

        let again = TodayTicket.deal(chart: dealt, now: now, calendar: calendar, bank: bank)
        XCTAssertEqual(again.ticket(daykey: key)?.drop?.id, dealt.ticket(daykey: key)?.drop?.id)
        XCTAssertEqual(again.tickets.filter { $0.daykey == key }.count, 1)
    }

    func testSeedDealsOpenDropAndPriorCards() {
        let bank = [
            Deck(id: "world", title: "World", drops: [sampleDrop()]),
            Deck(id: "arts", title: "Arts", drops: [sampleDrop(correct: "a")])
        ]
        let now = Date(timeIntervalSince1970: 1_758_960_000)
        let chart = DemoSeed.chart(now: now, calendar: calendar, bank: bank)
        XCTAssertTrue(chart.onboardingComplete)
        XCTAssertGreaterThanOrEqual(chart.cards.count, 3)
        let today = DayKey.key(for: now, calendar: calendar)
        let live = chart.ticket(daykey: today)
        XCTAssertEqual(live?.phase, .open)
        XCTAssertNotNil(live?.drop)
        XCTAssertNil(live?.stake)
    }

    func testFusedSealScoresAndRefusesEarly() {
        var chart = TicketChart.fresh(deckIDs: ["world"])
        chart.tickets = [openTicket()]
        let early = TodayTicket.sealAndScore(chart: chart, daykey: 20260927, spendShield: false)
        XCTAssertEqual(early.1.refusal, .sealOnOpen)
        XCTAssertEqual(early.0.earlyMarks.count, 1)
        XCTAssertTrue(early.0.cards.isEmpty)

        let staked = TodayTicket.stake(chart: chart, daykey: 20260927, choiceID: "b")
        let scored = TodayTicket.sealAndScore(chart: staked.0, daykey: 20260927, spendShield: false)
        XCTAssertNil(scored.1.refusal)
        XCTAssertEqual(scored.0.tickets.first?.phase, .scored)
        XCTAssertEqual(scored.0.cards.count, 1)
        XCTAssertEqual(scored.0.sealMarks.count, 1)
        XCTAssertEqual(scored.0.streak.length, 1)
    }

    func testBundledBankDecodesWithDefaultKeys() throws {
        let data = try XCTUnwrap(bankJSON().data(using: .utf8))
        let decks = QuestionBank.load(from: data)
        XCTAssertEqual(decks.count, 1)
        XCTAssertEqual(decks.first?.drops.first?.choices.count, 4)
        let unknown = Data("{\"schemaVersion\":9,\"decks\":[]}".utf8)
        XCTAssertTrue(QuestionBank.load(from: unknown).isEmpty)
        XCTAssertTrue(QuestionBank.load(from: Data("[]".utf8)).isEmpty)
    }

    private func sealed(choiceID: String) -> DayTicket {
        let staked = TicketFold.stake(ticket: openTicket(), choiceID: choiceID).0
        return TicketFold.seal(ticket: staked).0
    }

    private func bankJSON() -> String {
        """
        {"schemaVersion":1,"decks":[{"id":"world","title":"World","drops":[{"id":"d","stem":"Stem","difficulty":2,"why":"Why","correctChoiceID":"b","choices":[{"id":"a","line":"A"},{"id":"b","line":"B"},{"id":"c","line":"C"},{"id":"d","line":"D"}]}]}]}
        """
    }
}
