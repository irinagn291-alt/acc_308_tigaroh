import SwiftUI

/// Local marks from streak and deck milestones. No shop.
struct TrophyMark: Identifiable, Equatable {
    var id: String
    var title: String
    var detail: String
    var earned: Bool
}

enum TrophyBoard {
    static func marks(chart: TicketChart, bank: [Deck]) -> [TrophyMark] {
        let bestStreak = max(chart.streak.length, chart.cards.filter(\.correct).count)
        let bestPoints = chart.cards.map(\.points).max() ?? 0
        let allDecks = !bank.isEmpty && Set(chart.selectedDeckIDs) == Set(bank.map(\.id))
        return [
            TrophyMark(id: "first", title: "First card", detail: "File one scored card.", earned: !chart.cards.isEmpty),
            TrophyMark(id: "run", title: "Three day run", detail: "Hold three correct days.", earned: bestStreak >= 3),
            TrophyMark(id: "shield", title: "Shield filed", detail: "Every seventh correct day grants one.", earned: !chart.shieldMarks.isEmpty),
            TrophyMark(id: "points", title: "Double digits", detail: "Score at least 10 points on one card.", earned: bestPoints >= 10),
            TrophyMark(id: "decks", title: "All decks on", detail: "Keep every themed deck in the pool.", earned: allDecks && chart.cards.count >= 1)
        ]
    }
}

struct TrophiesView: View {
    @ObservedObject var session: TicketSession
    @Environment(\.dismiss) private var dismiss

    private var marks: [TrophyMark] {
        TrophyBoard.marks(chart: session.chart, bank: session.bank)
    }

    var body: some View {
        NavigationStack {
            Group {
                if session.recoveryVisible && marks.allSatisfy({ !$0.earned }) {
                    EmptyPlate(
                        imageName: "tsp_TwistHero",
                        headline: "Trophies unread.",
                        line: "Saved ticket could not be read. Started a fresh chart.",
                        actionTitle: "Retry",
                        action: { Task { await session.retry() } }
                    )
                } else if marks.allSatisfy({ !$0.earned }) {
                    EmptyPlate(
                        imageName: "tsp_TwistHero",
                        headline: "No trophy filed yet.",
                        line: "A filed card, a three day run, and a shield each leave a mark.",
                        actionTitle: "Back to ticket",
                        action: { dismiss() }
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: TicketLook.s2) {
                            Text("MARKS")
                                .font(TicketLook.display())
                                .foregroundStyle(DesignTokens.ink)
                            ForEach(marks) { mark in
                                row(mark)
                            }
                        }
                        .padding(TicketLook.s2)
                    }
                }
            }
            .padding(marks.contains(where: \.earned) ? 0 : TicketLook.s2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(DesignTokens.bg)
            .navigationTitle("Trophies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TicketBarTitle(title: "Trophies")
                }
                ToolbarItem(placement: .cancellationAction) {
                    TicketDismiss(name: "trophies") { dismiss() }
                }
            }
        }
        .modifier(SheetEntrance())
    }

    private func row(_ mark: TrophyMark) -> some View {
        HStack(alignment: .top, spacing: TicketLook.s2) {
            VStack(alignment: .leading, spacing: TicketLook.s1) {
                Text(mark.earned ? "Earned" : "Locked")
                    .font(TicketLook.micro())
                    .foregroundStyle(mark.earned ? DesignTokens.bg : DesignTokens.muted)
                Text(mark.title)
                    .font(TicketLook.headline())
                    .foregroundStyle(mark.earned ? DesignTokens.bg : DesignTokens.ink)
                Text(mark.detail)
                    .font(TicketLook.caption())
                    .foregroundStyle(mark.earned ? DesignTokens.bg : DesignTokens.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: mark.earned ? "checkmark.seal.fill" : "seal")
                .font(TicketLook.headline())
                .foregroundStyle(mark.earned ? DesignTokens.bg : DesignTokens.ink)
                .accessibilityHidden(true)
        }
        .padding(TicketLook.s2)
        .frame(maxWidth: .infinity, minHeight: TicketLook.tileShort, alignment: .leading)
        .background(mark.earned ? DesignTokens.accent : DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: mark.earned ? TicketLook.surfaceRadius : TicketLook.tileRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: mark.earned ? TicketLook.surfaceRadius : TicketLook.tileRadius, style: .continuous)
                .stroke(DesignTokens.ink, lineWidth: TicketLook.hairline)
        )
        .ticketShadow()
        .accessibilityElement(children: .combine)
    }
}
