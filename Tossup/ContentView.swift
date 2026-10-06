import SwiftUI

/// Root view. The ticket session owns the chart. This file only hosts it.
struct ContentView: View {
    @StateObject private var session = TicketSession()

    var body: some View {
        TicketRoot(session: session)
    }
}

#Preview {
    ContentView()
}
