import SwiftUI

/// Today. The admission ticket, the Choice rail, fused Stake and Seal, and the docked timeline.
struct AdmissionBoard: View {
    @ObservedObject var session: TicketSession

    var body: some View {
        Group {
            if case .failed(let message) = session.load {
                fullPlate(
                    headline: "Bank unread.",
                    line: message,
                    actionTitle: "Retry",
                    action: { Task { await session.retry() } }
                )
            } else if session.load == .ready && !hasLiveDrop {
                fullPlate(
                    headline: "Today's drop is waiting.",
                    line: "Turn a deck on in Settings, then stake the next ticket.",
                    actionTitle: "Settings",
                    action: { session.sheet = .settings }
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: TicketLook.s2) {
                        band
                        if session.load == .loading {
                            loadingPlate
                        } else {
                            ready
                        }
                    }
                    .padding(.horizontal, TicketLook.s2)
                    .padding(.bottom, TicketLook.s4)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.bg)
    }

    private var hasLiveDrop: Bool {
        guard let ticket = session.todayTicket else {
            return false
        }
        return ticket.drop != nil && ticket.phase != .blank
    }

    private func fullPlate(
        headline: String,
        line: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: TicketLook.s2) {
            band
            EmptyPlate(
                imageName: "tsp_EmptyHome",
                headline: headline,
                line: line,
                actionTitle: actionTitle,
                action: action
            )
        }
        .padding(.horizontal, TicketLook.s2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var band: some View {
        Text("TODAY")
            .font(TicketLook.caption())
            .foregroundStyle(DesignTokens.bg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, TicketLook.s2)
            .frame(minHeight: TicketLook.hit)
            .background(DesignTokens.accent)
            .clipShape(RoundedRectangle(cornerRadius: TicketLook.tileRadius, style: .continuous))
            .padding(.top, TicketLook.s2)
    }

    @ViewBuilder
    private var ready: some View {
        if let ticket = session.todayTicket, let drop = ticket.drop, ticket.phase != .blank {
            ticketHero(ticket: ticket, drop: drop)
            ChoiceRail(
                choices: drop.choices,
                phase: ticket.phase,
                stakedID: ticket.stake?.choiceID,
                onStake: { session.stake(choiceID: $0) }
            )
            if ticket.phase == .staked {
                Text("Peel to change.")
                    .font(TicketLook.caption())
                    .foregroundStyle(DesignTokens.muted)
                Button("Peel") {
                    session.peel()
                }
                .buttonStyle(TicketButtonStyle(role: .quiet))
                if session.availableShields > 0 {
                    let ready = TicketFormat.whole(session.availableShields)
                    Toggle(isOn: $session.spendShield) {
                        Text("Spend shield on a miss. \(ready) ready.")
                            .font(TicketLook.body())
                            .foregroundStyle(DesignTokens.ink)
                    }
                    .tint(DesignTokens.accent)
                    .frame(minHeight: TicketLook.hit)
                }
            }
            if ticket.phase == .scored, let why = ticket.whyLine() {
                VStack(alignment: .leading, spacing: TicketLook.s1) {
                    Text(session.status.contains("Miss") ? "Miss" : "Card filed")
                        .font(TicketLook.caption())
                        .foregroundStyle(DesignTokens.muted)
                    Text(why)
                        .font(TicketLook.body())
                        .foregroundStyle(DesignTokens.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(TicketLook.s2)
                .background(DesignTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: TicketLook.surfaceRadius, style: .continuous))
                .ticketShadow()
            }
            verb(for: ticket)
            Text(session.status)
                .font(TicketLook.caption())
                .foregroundStyle(DesignTokens.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel(session.status)
            StreakStrip(
                samples: TimelineSeries.samples(cards: session.chart.cards, misses: session.chart.missMarks),
                streakLength: session.chart.streak.length
            )
            stripButtons
        }
    }

    private func ticketHero(ticket: DayTicket, drop: Drop) -> some View {
        VStack(alignment: .leading, spacing: TicketLook.s2) {
            Text(phaseWord(ticket.phase))
                .font(TicketLook.display())
                .foregroundStyle(DesignTokens.ink)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(phaseCaption(ticket.phase))
                .font(TicketLook.caption())
                .foregroundStyle(DesignTokens.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(drop.stem)
                .font(TicketLook.body())
                .foregroundStyle(DesignTokens.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: TicketLook.s2) {
                meta("Difficulty", TicketFormat.whole(drop.difficulty))
                meta("Streak", TicketFormat.whole(session.chart.streak.length))
                meta("Shields", TicketFormat.whole(session.availableShields))
            }
        }
        .padding(TicketLook.s3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: TicketLook.surfaceRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TicketLook.surfaceRadius, style: .continuous)
                .stroke(DesignTokens.ink, lineWidth: TicketLook.hairline)
        )
        .ticketShadow()
    }

    private func meta(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: TicketLook.s1) {
            Text(label)
                .font(TicketLook.caption())
                .foregroundStyle(DesignTokens.muted)
            Text(value)
                .font(TicketLook.body())
                .foregroundStyle(DesignTokens.ink)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func verb(for ticket: DayTicket) -> some View {
        let title: String
        let enabled: Bool
        let action: () -> Void
        switch ticket.phase {
        case .open:
            title = "Stake"
            enabled = true
            action = { session.promptStake() }
        case .staked:
            title = "Seal"
            enabled = true
            action = { session.seal() }
        case .sealed:
            title = "Seal"
            enabled = false
            action = {}
        case .scored:
            title = "Filed"
            enabled = false
            action = {}
        case .blank:
            title = "Stake"
            enabled = false
            action = {}
        }
        return Button(title, action: action)
            .buttonStyle(TicketButtonStyle(role: .verb, loading: session.sealing))
            .disabled(!enabled || session.sealing)
    }

    private var stripButtons: some View {
        VStack(alignment: .leading, spacing: TicketLook.s2) {
            dockTile(
                kicker: "Journal",
                figure: TicketFormat.whole(session.chart.cards.count),
                line: "Filed cards",
                minHeight: TicketLook.tileTall,
                radius: TicketLook.surfaceRadius,
                action: { session.sheet = .journal }
            )
            HStack(alignment: .top, spacing: TicketLook.s2) {
                dockTile(
                    kicker: "Stats",
                    figure: TicketFormat.whole(session.chart.cards.reduce(0) { $0 + $1.points }),
                    line: "Points",
                    minHeight: TicketLook.tileShort,
                    radius: TicketLook.tileRadius,
                    action: { session.sheet = .stats }
                )
                dockTile(
                    kicker: "Trophies",
                    figure: TicketFormat.whole(earnedMarks),
                    line: "Earned",
                    minHeight: TicketLook.tileTall,
                    radius: TicketLook.tileRadius,
                    action: { session.sheet = .trophies }
                )
                .frame(maxWidth: TicketLook.statsHeight / 2)
            }
            Button("Settings") { session.sheet = .settings }
                .buttonStyle(TicketButtonStyle(role: .quiet))
        }
    }

    private var earnedMarks: Int {
        TrophyBoard.marks(chart: session.chart, bank: session.bank).filter(\.earned).count
    }

    private func dockTile(
        kicker: String,
        figure: String,
        line: String,
        minHeight: CGFloat,
        radius: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: TicketLook.s1) {
                Text(kicker)
                    .font(TicketLook.caption())
                    .foregroundStyle(DesignTokens.muted)
                Text(figure)
                    .font(TicketLook.body())
                    .foregroundStyle(DesignTokens.ink)
                    .monospacedDigit()
                    .lineLimit(1)
                Text(line)
                    .font(TicketLook.caption())
                    .foregroundStyle(DesignTokens.ink)
            }
            .padding(TicketLook.s2)
            .frame(maxWidth: .infinity, minHeight: max(minHeight, TicketLook.hit), alignment: .topLeading)
            .background(DesignTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(DesignTokens.ink, lineWidth: TicketLook.hairline)
            )
            .ticketShadow()
            .contentShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
        .buttonStyle(TicketButtonStyle(role: .tile))
        .accessibilityLabel("\(kicker), \(figure) \(line)")
    }

    private var loadingPlate: some View {
        VStack(alignment: .leading, spacing: TicketLook.s2) {
            RoundedRectangle(cornerRadius: TicketLook.surfaceRadius, style: .continuous)
                .fill(DesignTokens.muted.opacity(0.2))
                .frame(height: TicketLook.tileTall)
            RoundedRectangle(cornerRadius: TicketLook.tileRadius, style: .continuous)
                .fill(DesignTokens.muted.opacity(0.2))
                .frame(height: TicketLook.tileShort)
        }
        .redacted(reason: .placeholder)
        .accessibilityLabel("Loading today's ticket.")
    }

    private func phaseWord(_ phase: TicketPhase) -> String {
        switch phase {
        case .blank: "Blank"
        case .open: "Open"
        case .staked: "Staked"
        case .sealed: "Sealed"
        case .scored: "Scored"
        }
    }

    private func phaseCaption(_ phase: TicketPhase) -> String {
        switch phase {
        case .open: "Tap a pick to stake."
        case .staked: "Seal freezes the pick."
        case .sealed: "Seal is filing the card."
        case .scored: "Card filed."
        case .blank: "Waiting on a deal."
        }
    }
}

/// Full-page empty or error. One headline, one line, one bottom action.
struct EmptyPlate: View {
    var imageName: String
    var headline: String
    var line: String
    var actionTitle: String
    var action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: TicketLook.s2) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: TicketLook.artHeight)
                .clipped()
                .accessibilityHidden(true)
            Text(headline)
                .font(TicketLook.display())
                .foregroundStyle(DesignTokens.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(line)
                .font(TicketLook.body())
                .foregroundStyle(DesignTokens.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: TicketLook.s4)
            Button(actionTitle, action: action)
                .buttonStyle(TicketButtonStyle(role: .verb))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
