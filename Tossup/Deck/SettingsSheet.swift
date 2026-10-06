import SwiftUI
import UIKit

/// Settings. Deck toggles, a replay of the gate, a named reset, and the contact link.
struct SettingsSheet: View {
    @ObservedObject var session: TicketSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if session.bank.isEmpty {
                    EmptyPlate(
                        imageName: "tsp_EmptyList",
                        headline: "Decks unread.",
                        line: "The bundled bank did not open.",
                        actionTitle: "Retry",
                        action: { Task { await session.retry() } }
                    )
                } else if session.recoveryVisible && session.chart.selectedDeckIDs.isEmpty && !session.chart.onboardingComplete {
                    EmptyPlate(
                        imageName: "tsp_EmptyList",
                        headline: "Settings unread.",
                        line: "Saved ticket could not be read. Started a fresh chart.",
                        actionTitle: "Retry",
                        action: { Task { await session.retry() } }
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: TicketLook.s3) {
                            Text("DECKS")
                                .font(TicketLook.display())
                                .foregroundStyle(DesignTokens.ink)
                            ForEach(session.bank) { deck in
                                Toggle(isOn: binding(for: deck.id)) {
                                    VStack(alignment: .leading, spacing: TicketLook.s1) {
                                        Text(deck.title)
                                            .font(TicketLook.headline())
                                            .foregroundStyle(DesignTokens.ink)
                                        Text(poolCount(deck.drops.count))
                                            .font(TicketLook.caption())
                                            .foregroundStyle(DesignTokens.muted)
                                    }
                                }
                                .tint(DesignTokens.accent)
                                .frame(minHeight: TicketLook.hit)
                            }
                            Button("Replay intro") {
                                session.replayGate()
                            }
                            .buttonStyle(TicketButtonStyle(role: .quiet))
                            Button("Reset chart") {
                                session.confirmReset = true
                            }
                            .buttonStyle(TicketButtonStyle(role: .destructive))
                            Button("Contact") {
                                openContact()
                            }
                            .buttonStyle(TicketButtonStyle(role: .quiet))
                            Text(session.resetConsequence)
                                .font(TicketLook.caption())
                                .foregroundStyle(DesignTokens.muted)
                        }
                        .padding(TicketLook.s2)
                    }
                }
            }
            .padding(session.bank.isEmpty ? TicketLook.s2 : 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(DesignTokens.bg)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TicketBarTitle(title: "Settings")
                }
                ToolbarItem(placement: .cancellationAction) {
                    TicketDismiss(name: "settings") { dismiss() }
                }
            }
            .confirmationDialog(
                "Reset the chart?",
                isPresented: $session.confirmReset,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    Task { await session.reset() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(session.resetConsequence)
            }
        }
        .modifier(SheetEntrance())
    }

    private func poolCount(_ count: Int) -> String {
        let formatted = TicketFormat.whole(count)
        return "\(formatted) drops"
    }

    private func binding(for id: String) -> Binding<Bool> {
        Binding(
            get: { session.chart.selectedDeckIDs.contains(id) },
            set: { session.setDeck(id, on: $0) }
        )
    }

    private func openContact() {
        guard let url = URL(string: "https://tossup-ticket.pro/contact-us") else {
            return
        }
        UIApplication.shared.open(url)
    }
}
