import SwiftUI

/// Journal lists filed Cards with the staked Choice and the outcome.
struct JournalView: View {
    @ObservedObject var session: TicketSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if session.recoveryVisible && session.chart.cards.isEmpty {
                    EmptyPlate(
                        imageName: "tsp_EmptyList",
                        headline: "Journal unread.",
                        line: "Saved ticket could not be read. Started a fresh chart.",
                        actionTitle: "Retry",
                        action: { Task { await session.retry() } }
                    )
                    .padding(TicketLook.s2)
                } else if session.chart.cards.isEmpty {
                    EmptyPlate(
                        imageName: "tsp_EmptyList",
                        headline: "No card filed yet.",
                        line: "Stake today's choice, then seal it. The card lands here.",
                        actionTitle: "Back to ticket",
                        action: { dismiss() }
                    )
                    .padding(TicketLook.s2)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: TicketLook.s2) {
                            ForEach(session.chart.cards.sorted { $0.daykey > $1.daykey }) { card in
                                cardRow(card)
                            }
                        }
                        .padding(TicketLook.s2)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(DesignTokens.bg)
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TicketBarTitle(title: "Journal")
                }
                ToolbarItem(placement: .cancellationAction) {
                    TicketDismiss(name: "journal") { dismiss() }
                }
            }
        }
        .modifier(SheetEntrance())
    }

    private func cardRow(_ card: Card) -> some View {
        VStack(alignment: .leading, spacing: TicketLook.s1) {
            HStack(alignment: .firstTextBaseline) {
                Text(card.correct ? "Correct" : "Miss")
                    .font(TicketLook.caption())
                    .foregroundStyle(DesignTokens.ink)
                Spacer(minLength: TicketLook.s2)
                Text(TicketFormat.whole(card.points))
                    .font(TicketLook.headline())
                    .foregroundStyle(DesignTokens.ink)
                    .monospacedDigit()
            }
            Text(card.choiceLine)
                .font(TicketLook.body())
                .foregroundStyle(DesignTokens.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(TicketFormat.dayLabel(card.daykey))
                .font(TicketLook.micro())
                .foregroundStyle(DesignTokens.muted)
        }
        .padding(TicketLook.s2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card.correct ? DesignTokens.surface : DesignTokens.muted.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: TicketLook.surfaceRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TicketLook.surfaceRadius, style: .continuous)
                .stroke(DesignTokens.ink, lineWidth: TicketLook.hairline)
        )
        .ticketShadow()
        .accessibilityElement(children: .combine)
    }
}
