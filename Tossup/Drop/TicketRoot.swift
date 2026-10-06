import SwiftUI

/// Ticket-strip chrome. Today and the timeline stay. Journal, Stats, Trophies, and Settings are sheets.
struct TicketRoot: View {
    @ObservedObject var session: TicketSession
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            DesignTokens.bg.ignoresSafeArea()
            if session.reviewGate {
                OnboardingView(session: session)
            } else if session.chart.onboardingComplete || session.load != .ready {
                AdmissionBoard(session: session)
            } else {
                OnboardingView(session: session)
            }
            if session.recoveryVisible && session.load == .ready && session.chart.onboardingComplete {
                recoveryCover
            }
        }
        .sheet(item: $session.sheet) { destination in
            switch destination {
            case .journal:
                JournalView(session: session)
            case .stats:
                StatsView(session: session)
            case .trophies:
                TrophiesView(session: session)
            case .settings:
                SettingsSheet(session: session)
            }
        }
        .task {
            await session.bootstrap()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                session.refreshDay()
            } else {
                Task { await session.leftActive() }
            }
        }
    }

    private var recoveryCover: some View {
        VStack(alignment: .leading, spacing: TicketLook.s2) {
            EmptyPlate(
                imageName: "tsp_EmptyHome",
                headline: "Chart replaced.",
                line: "Saved ticket could not be read. Started a fresh chart.",
                actionTitle: "Continue",
                action: { session.dismissRecovery() }
            )
        }
        .padding(TicketLook.s2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.bg)
    }
}
