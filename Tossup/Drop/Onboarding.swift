import Foundation

/// Onboarding writes selected decks and the completion flag. Skip uses every bundled deck.
enum OnboardingGate {
    static func complete(chart: TicketChart, selectedDeckIDs: [String]) -> TicketChart {
        var next = chart
        next.onboardingComplete = true
        next.selectedDeckIDs = selectedDeckIDs
        return next
    }

    static func skip(chart: TicketChart, bank: [Deck]) -> TicketChart {
        complete(chart: chart, selectedDeckIDs: bank.map(\.id))
    }
}

/// Simulator-only seed. Never runs on device.
enum DemoSeed {
    static var allowed: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    /// Today's Drop is Open so Stake is the first live tap. Prior days are already Cards.
    static func chart(now: Date, calendar: Calendar, bank: [Deck]) -> TicketChart {
        let selected = bank.map(\.id)
        var chart = OnboardingGate.skip(chart: .fresh(deckIDs: selected), bank: bank)
        let today = DayKey.key(for: now, calendar: calendar)
        let priorKeys = priorDaykeys(before: today, calendar: calendar, count: 4)
        var streak = Streak.empty
        var shields: [ShieldMark] = []
        for key in priorKeys {
            guard let date = DayKey.date(from: key, calendar: calendar) else {
                continue
            }
            let index = DayKey.dayIndex(for: date, calendar: calendar)
            guard let drop = DropPicker.select(dayIndex: index, decks: bank, selectedIDs: selected) else {
                continue
            }
            guard let choice = drop.choices.first(where: { $0.id == drop.correctChoiceID }) else {
                continue
            }
            var ticket = DayTicket.dealt(daykey: key, drop: drop)
            let staked = TicketFold.stake(ticket: ticket, choiceID: choice.id)
            ticket = staked.0
            if let mark = ticket.stake {
                chart.stakeMarks.append(mark)
            }
            let sealed = TicketFold.seal(ticket: ticket)
            ticket = sealed.0
            if let seal = TicketFold.sealMark(for: ticket) {
                chart.sealMarks.append(seal)
            }
            let scored = TicketFold.score(ticket: ticket, streak: streak, shields: shields, spendShield: false)
            ticket = scored.0
            streak = scored.1
            shields = scored.2
            if let card = scored.3.card {
                chart.cards.append(card)
            }
            chart.tickets.append(ticket)
        }
        chart.streak = streak
        chart.shieldMarks = shields
        let todayIndex = DayKey.dayIndex(for: now, calendar: calendar)
        if let drop = DropPicker.select(dayIndex: todayIndex, decks: bank, selectedIDs: selected) {
            chart.tickets.append(DayTicket.dealt(daykey: today, drop: drop))
        } else {
            chart.tickets.append(DayTicket.blank(daykey: today))
        }
        return chart
    }

    private static func priorDaykeys(before today: Int, calendar: Calendar, count: Int) -> [Int] {
        guard let date = DayKey.date(from: today, calendar: calendar) else {
            return []
        }
        var keys: [Int] = []
        for offset in stride(from: count, through: 1, by: -1) {
            guard let prior = calendar.date(byAdding: .day, value: -offset, to: date) else {
                continue
            }
            keys.append(DayKey.key(for: prior, calendar: calendar))
        }
        return keys
    }
}
