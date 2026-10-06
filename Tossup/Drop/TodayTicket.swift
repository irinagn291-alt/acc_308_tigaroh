import Foundation

/// Home mechanic over the chart. Stake, then Seal fused into Score. Peel only before Seal.
enum TodayTicket {
    static func deal(chart: TicketChart, now: Date, calendar: Calendar, bank: [Deck]) -> TicketChart {
        var next = chart
        let key = DayKey.key(for: now, calendar: calendar)
        let index = DayKey.dayIndex(for: now, calendar: calendar)
        let drop = DropPicker.select(dayIndex: index, decks: bank, selectedIDs: next.selectedDeckIDs)
        if let existing = next.tickets.firstIndex(where: { $0.daykey == key }) {
            // A blank day stored before decks were chosen must take the drop once the pool exists.
            if next.tickets[existing].phase == .blank, let drop {
                next.tickets[existing] = DayTicket.dealt(daykey: key, drop: drop)
            }
            return next
        }
        if let drop {
            next.tickets.append(DayTicket.dealt(daykey: key, drop: drop))
        } else {
            next.tickets.append(DayTicket.blank(daykey: key))
        }
        return next
    }

    static func stake(chart: TicketChart, daykey: Int, choiceID: String) -> (TicketChart, FoldNotice) {
        guard let index = chart.tickets.firstIndex(where: { $0.daykey == daykey }) else {
            return (chart, FoldNotice(refusal: .emptyTicket))
        }
        let (ticket, notice) = TicketFold.stake(ticket: chart.tickets[index], choiceID: choiceID)
        var next = chart
        next.tickets[index] = ticket
        if let stake = ticket.stake, chart.tickets[index].stake?.id != stake.id {
            next.stakeMarks.append(stake)
        }
        if let waver = notice.waver {
            next.waverMarks.append(waver)
        }
        return (next, notice)
    }

    /// Fuses Seal into Score so the why line stays hidden until the card is filed.
    static func sealAndScore(chart: TicketChart, daykey: Int, spendShield: Bool) -> (TicketChart, FoldNotice) {
        guard let index = chart.tickets.firstIndex(where: { $0.daykey == daykey }) else {
            return (chart, FoldNotice(refusal: .emptyTicket))
        }
        var next = chart
        var ticket = next.tickets[index]
        if ticket.phase == .staked {
            if let seal = TicketFold.sealMark(for: ticket) {
                next.sealMarks.append(seal)
            }
            let sealed = TicketFold.seal(ticket: ticket)
            ticket = sealed.0
            if sealed.1.refusal != nil {
                next.tickets[index] = ticket
                return (next, sealed.1)
            }
        }
        if ticket.phase == .open || ticket.phase == .blank {
            let early = TicketFold.seal(ticket: ticket)
            if let mark = early.1.early {
                next.earlyMarks.append(mark)
            }
            next.tickets[index] = early.0
            return (next, early.1)
        }
        let scored = TicketFold.score(
            ticket: ticket,
            streak: next.streak,
            shields: next.shieldMarks,
            spendShield: spendShield
        )
        next.tickets[index] = scored.0
        next.streak = scored.1
        next.shieldMarks = scored.2
        if let card = scored.3.card {
            next.cards.append(card)
        }
        if let miss = scored.3.miss {
            next.missMarks.append(miss)
        }
        return (next, scored.3)
    }

    static func peel(chart: TicketChart, daykey: Int) -> (TicketChart, FoldNotice) {
        guard let index = chart.tickets.firstIndex(where: { $0.daykey == daykey }) else {
            return (chart, FoldNotice(refusal: .emptyTicket))
        }
        let (ticket, notice) = TicketFold.peel(ticket: chart.tickets[index])
        var next = chart
        if notice.refusal == nil, let stake = chart.tickets[index].stake {
            next.stakeMarks.removeAll { $0.id == stake.id }
        }
        next.tickets[index] = ticket
        return (next, notice)
    }
}
