import Foundation

/// Stake ADT. The day's ticket folds Open, Staked, Sealed, Scored. Blank is an empty ticket.
enum TicketPhase: String, Codable, Equatable, Sendable {
    case blank
    case open
    case staked
    case sealed
    case scored
}

enum FoldRefusal: String, Equatable, Sendable {
    case emptyTicket
    case unknownChoice
    case sealOnOpen
    case stakeOnSealed
    case stakeOnScored
    case peelNotStaked
    case scoreNotSealed
    case alreadyScored
}

struct FoldNotice: Equatable, Sendable {
    var refusal: FoldRefusal? = nil
    var waver: WaverMark? = nil
    var early: EarlyMark? = nil
    var card: Card? = nil
    var miss: MissMark? = nil
    var shieldGranted: ShieldMark? = nil
}

/// One daykey's fold over its Choices.
struct DayTicket: Codable, Equatable, Sendable, Identifiable {
    var daykey: Int
    var phase: TicketPhase
    var drop: Drop?
    var stake: StakeMark?

    var id: Int { daykey }

    static func blank(daykey: Int) -> DayTicket {
        DayTicket(daykey: daykey, phase: .blank, drop: nil, stake: nil)
    }

    static func dealt(daykey: Int, drop: Drop) -> DayTicket {
        DayTicket(daykey: daykey, phase: .open, drop: drop, stake: nil)
    }

    /// Why line is visible only after Scored.
    func whyLine() -> String? {
        guard phase == .scored else {
            return nil
        }
        return drop?.why
    }
}

/// Pure fold. Chart lists are appended by the caller from the notice.
enum TicketFold {
    static func stake(ticket: DayTicket, choiceID: String) -> (DayTicket, FoldNotice) {
        guard ticket.phase != .blank, ticket.drop != nil else {
            return (ticket, FoldNotice(refusal: .emptyTicket))
        }
        guard ticket.drop?.choice(id: choiceID) != nil else {
            return (ticket, FoldNotice(refusal: .unknownChoice))
        }
        switch ticket.phase {
        case .blank:
            return (ticket, FoldNotice(refusal: .emptyTicket))
        case .open:
            var next = ticket
            let mark = StakeMark(id: UUID().uuidString, daykey: ticket.daykey, choiceID: choiceID)
            next.stake = mark
            next.phase = .staked
            return (next, FoldNotice())
        case .staked:
            let waver = WaverMark(id: UUID().uuidString, daykey: ticket.daykey, attemptedChoiceID: choiceID)
            return (ticket, FoldNotice(waver: waver))
        case .sealed:
            return (ticket, FoldNotice(refusal: .stakeOnSealed))
        case .scored:
            return (ticket, FoldNotice(refusal: .stakeOnScored))
        }
    }

    static func seal(ticket: DayTicket) -> (DayTicket, FoldNotice) {
        switch ticket.phase {
        case .blank:
            return (ticket, FoldNotice(refusal: .emptyTicket))
        case .open:
            let early = EarlyMark(id: UUID().uuidString, daykey: ticket.daykey)
            return (ticket, FoldNotice(refusal: .sealOnOpen, early: early))
        case .staked:
            guard ticket.stake != nil else {
                return (ticket, FoldNotice(refusal: .scoreNotSealed))
            }
            var next = ticket
            next.phase = .sealed
            return (next, FoldNotice())
        case .sealed:
            return (ticket, FoldNotice())
        case .scored:
            return (ticket, FoldNotice(refusal: .alreadyScored))
        }
    }

    /// Seal mark is produced here so the caller can file it. `seal` folds the phase.
    static func sealMark(for ticket: DayTicket) -> SealMark? {
        guard ticket.phase == .sealed || ticket.phase == .staked, let stake = ticket.stake else {
            return nil
        }
        return SealMark(id: UUID().uuidString, daykey: ticket.daykey, choiceID: stake.choiceID)
    }

    static func score(
        ticket: DayTicket,
        streak: Streak,
        shields: [ShieldMark],
        spendShield: Bool
    ) -> (DayTicket, Streak, [ShieldMark], FoldNotice) {
        guard ticket.phase == .sealed, let drop = ticket.drop, let stake = ticket.stake else {
            let refusal: FoldRefusal = ticket.phase == .scored ? .alreadyScored : .scoreNotSealed
            return (ticket, streak, shields, FoldNotice(refusal: refusal))
        }
        let correct = stake.choiceID == drop.correctChoiceID
        let choiceLine = drop.choice(id: stake.choiceID)?.line ?? ""
        var nextTicket = ticket
        nextTicket.phase = .scored
        var nextStreak = streak
        var nextShields = shields
        if correct {
            let awarded = Streak.points(difficulty: drop.difficulty, streakLength: streak.length)
            nextStreak.length += 1
            nextStreak.consecutiveCorrect += 1
            var granted: ShieldMark?
            if nextStreak.consecutiveCorrect > 0, nextStreak.consecutiveCorrect % 7 == 0 {
                let mark = ShieldMark(id: UUID().uuidString, grantedDaykey: ticket.daykey, spentDaykey: nil)
                nextShields.append(mark)
                granted = mark
            }
            let card = Card(
                id: UUID().uuidString,
                daykey: ticket.daykey,
                dropID: drop.id,
                stem: drop.stem,
                choiceID: stake.choiceID,
                choiceLine: choiceLine,
                correct: true,
                difficulty: drop.difficulty,
                points: awarded,
                why: drop.why
            )
            return (nextTicket, nextStreak, nextShields, FoldNotice(card: card, shieldGranted: granted))
        }
        var spent = false
        if spendShield, let index = nextShields.firstIndex(where: \.available) {
            nextShields[index].spentDaykey = ticket.daykey
            spent = true
            nextStreak.consecutiveCorrect = 0
        } else {
            nextStreak.length = 0
            nextStreak.consecutiveCorrect = 0
        }
        let miss = MissMark(
            id: UUID().uuidString,
            daykey: ticket.daykey,
            choiceID: stake.choiceID,
            shieldSpent: spent
        )
        let card = Card(
            id: UUID().uuidString,
            daykey: ticket.daykey,
            dropID: drop.id,
            stem: drop.stem,
            choiceID: stake.choiceID,
            choiceLine: choiceLine,
            correct: false,
            difficulty: drop.difficulty,
            points: 0,
            why: drop.why
        )
        return (nextTicket, nextStreak, nextShields, FoldNotice(card: card, miss: miss))
    }

    static func peel(ticket: DayTicket) -> (DayTicket, FoldNotice) {
        guard ticket.phase == .staked else {
            return (ticket, FoldNotice(refusal: .peelNotStaked))
        }
        var next = ticket
        next.stake = nil
        next.phase = .open
        return (next, FoldNotice())
    }
}
