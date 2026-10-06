import SwiftUI

/// Uneven Choice tiles. A tap while Open writes the StakeMark. A later tap writes WaverMark.
struct ChoiceRail: View {
    var choices: [Choice]
    var phase: TicketPhase
    var stakedID: String?
    var onStake: (String) -> Void

    var body: some View {
        let items = Array(choices.prefix(4))
        VStack(alignment: .leading, spacing: TicketLook.s2) {
            if let first = items.first {
                tile(first, minHeight: TicketLook.tileShort)
            }
            if items.count >= 3 {
                HStack(alignment: .top, spacing: TicketLook.s2) {
                    tile(items[1], minHeight: TicketLook.tileTall)
                    tile(items[2], minHeight: TicketLook.tileShort)
                }
            } else if items.count == 2 {
                tile(items[1], minHeight: TicketLook.tileTall)
            }
            if items.count > 3 {
                tile(items[3], minHeight: TicketLook.tileShort)
            }
        }
    }

    private func tile(_ choice: Choice, minHeight: CGFloat) -> some View {
        let staked = stakedID == choice.id
        let live = phase == .open || phase == .staked
        return Button {
            onStake(choice.id)
        } label: {
            VStack(alignment: .leading, spacing: TicketLook.s1) {
                Text(staked ? "Staked" : TicketWords.choice)
                    .font(TicketLook.caption())
                    .foregroundStyle(staked ? DesignTokens.bg : DesignTokens.muted)
                Text(choice.line)
                    .font(TicketLook.body())
                    .foregroundStyle(staked ? DesignTokens.bg : DesignTokens.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .padding(TicketLook.s2)
            .frame(maxWidth: .infinity, minHeight: max(minHeight, TicketLook.hit), alignment: .topLeading)
            .background(staked ? DesignTokens.accent : DesignTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: TicketLook.tileRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: TicketLook.tileRadius, style: .continuous)
                    .stroke(DesignTokens.ink, lineWidth: TicketLook.hairline)
            )
            .ticketShadow()
            .contentShape(RoundedRectangle(cornerRadius: TicketLook.tileRadius, style: .continuous))
        }
        .buttonStyle(TicketButtonStyle(role: .tile))
        .disabled(!live)
        .accessibilityLabel(staked ? "Staked \(choice.line)" : "Stake \(choice.line)")
    }
}
