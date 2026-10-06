import SwiftUI

/// Three gate pages. Skip writes every bundled deck. Continue writes the toggles on the last page.
struct OnboardingView: View {
    @ObservedObject var session: TicketSession
    @State private var page = 0
    @State private var selected: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: TicketLook.s2) {
            RoundedRectangle(cornerRadius: TicketLook.tileRadius, style: .continuous)
                .fill(DesignTokens.accent)
                .frame(maxWidth: .infinity)
                .frame(height: TicketLook.band)
                .accessibilityHidden(true)
            ScrollView {
                pageBody
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            Button(page < 2 ? "Next" : "Continue") {
                if page < 2 {
                    page += 1
                } else {
                    let ids = selected.isEmpty ? session.bank.map(\.id) : session.bank.map(\.id).filter { selected.contains($0) }
                    session.finishGate(selectedDeckIDs: ids)
                }
            }
            .buttonStyle(TicketButtonStyle(role: .verb))
            Button("Skip") {
                session.skipGate()
            }
            .buttonStyle(TicketButtonStyle(role: .quiet))
        }
        .padding(TicketLook.s2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.bg)
        .onAppear {
            if selected.isEmpty {
                selected = Set(session.bank.map(\.id))
            }
        }
    }

    @ViewBuilder
    private var pageBody: some View {
        switch page {
        case 0:
            pageCopy(
                image: "tsp_Onboarding1",
                headline: "ONE TICKET.",
                line: "One question a day. Stake a single choice before you see the answer."
            )
        case 1:
            pageCopy(
                image: "tsp_Onboarding2",
                headline: "SEAL IT.",
                line: "Seal freezes the stake. Peel only works before that seal."
            )
        default:
            VStack(alignment: .leading, spacing: TicketLook.s2) {
                pageCopy(
                    image: "tsp_Onboarding3",
                    headline: "FILE THE CARD.",
                    line: "A correct seal adds difficulty plus the streak, capped at 10. A miss clears the run unless you spend a shield."
                )
                ForEach(session.bank) { deck in
                    Toggle(isOn: deckBinding(deck.id)) {
                        Text(deck.title)
                            .font(TicketLook.body())
                            .foregroundStyle(DesignTokens.ink)
                    }
                    .tint(DesignTokens.accent)
                    .frame(minHeight: TicketLook.hit)
                }
            }
        }
    }

    private func pageCopy(image: String, headline: String, line: String) -> some View {
        VStack(alignment: .leading, spacing: TicketLook.s2) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: TicketLook.artHeight)
                .clipped()
                .accessibilityHidden(true)
            Text(headline)
                .font(TicketLook.display())
                .foregroundStyle(DesignTokens.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(line)
                .font(TicketLook.body())
                .foregroundStyle(DesignTokens.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func deckBinding(_ id: String) -> Binding<Bool> {
        Binding(
            get: { selected.contains(id) },
            set: { on in
                if on {
                    selected.insert(id)
                } else {
                    selected.remove(id)
                }
            }
        )
    }
}
