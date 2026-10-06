import SwiftUI

/// Stats. A large Swift Charts timeline, a different frame from the home strip.
struct StatsView: View {
    @ObservedObject var session: TicketSession
    @Environment(\.dismiss) private var dismiss

    private var samples: [TimelineSample] {
        TimelineSeries.samples(cards: session.chart.cards, misses: session.chart.missMarks)
    }

    var body: some View {
        NavigationStack {
            Group {
                if session.recoveryVisible && samples.isEmpty {
                    EmptyPlate(
                        imageName: "tsp_EmptyList",
                        headline: "Stats unread.",
                        line: "Saved ticket could not be read. Started a fresh chart.",
                        actionTitle: "Retry",
                        action: { Task { await session.retry() } }
                    )
                } else if samples.isEmpty {
                    EmptyPlate(
                        imageName: "tsp_EmptyList",
                        headline: "No card filed yet.",
                        line: "Seal a ticket to plot streak length and daily points.",
                        actionTitle: "Back to ticket",
                        action: { dismiss() }
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: TicketLook.s2) {
                            Text("TIMELINE")
                                .font(TicketLook.display())
                                .foregroundStyle(DesignTokens.ink)
                                .textCase(.uppercase)
                            StreakStrip(
                                samples: samples,
                                streakLength: session.chart.streak.length,
                                tall: true
                            )
                            HStack(spacing: TicketLook.s2) {
                                figure("Points", TicketFormat.whole(session.chart.cards.reduce(0) { $0 + $1.points }))
                                figure("Cards", TicketFormat.whole(session.chart.cards.count))
                            }
                        }
                        .padding(TicketLook.s2)
                    }
                }
            }
            .padding(samples.isEmpty || (session.recoveryVisible && samples.isEmpty) ? TicketLook.s2 : 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(DesignTokens.bg)
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TicketBarTitle(title: "Stats")
                }
                ToolbarItem(placement: .cancellationAction) {
                    TicketDismiss(name: "stats") { dismiss() }
                }
            }
        }
        .modifier(SheetEntrance())
    }

    private func figure(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: TicketLook.s1) {
            Text(label)
                .font(TicketLook.caption())
                .foregroundStyle(DesignTokens.muted)
            Text(value)
                .font(TicketLook.title())
                .foregroundStyle(DesignTokens.ink)
                .monospacedDigit()
        }
        .padding(TicketLook.s2)
        .frame(maxWidth: .infinity, minHeight: TicketLook.tileShort, alignment: .leading)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: TicketLook.tileRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TicketLook.tileRadius, style: .continuous)
                .stroke(DesignTokens.ink, lineWidth: TicketLook.hairline)
        )
        .ticketShadow()
    }
}
