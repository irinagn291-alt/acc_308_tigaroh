import Charts
import SwiftUI

/// Docked timeline. LineMark series for streak length and daily points. It never leaves Today.
struct StreakStrip: View {
    var samples: [TimelineSample]
    var streakLength: Int
    var tall: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: TicketLook.s1) {
            HStack(alignment: .firstTextBaseline) {
                Text(TicketWords.streak)
                    .font(TicketLook.caption())
                    .foregroundStyle(DesignTokens.ink)
                    .textCase(.uppercase)
                Spacer(minLength: TicketLook.s2)
                Text(TicketFormat.whole(streakLength))
                    .font(TicketLook.headline())
                    .foregroundStyle(DesignTokens.ink)
                    .monospacedDigit()
            }
            Chart {
                ForEach(plot) { sample in
                    LineMark(
                        x: .value("Day", sample.date),
                        y: .value("Streak", sample.streakLength)
                    )
                    .foregroundStyle(by: .value("Series", "Streak"))
                }
                ForEach(plot) { sample in
                    LineMark(
                        x: .value("Day", sample.date),
                        y: .value("Points", sample.points)
                    )
                    .foregroundStyle(by: .value("Series", "Points"))
                }
            }
            .chartForegroundStyleScale([
                "Streak": DesignTokens.ink,
                "Points": DesignTokens.accent
            ])
            .chartLegend(position: .bottom, alignment: .leading, spacing: TicketLook.s1) {
                HStack(spacing: TicketLook.s2) {
                    legendItem(TicketWords.streak, color: DesignTokens.ink)
                    legendItem("Points", color: DesignTokens.accent)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine().foregroundStyle(DesignTokens.muted.opacity(0.4))
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .font(TicketLook.micro())
                        .foregroundStyle(DesignTokens.muted)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(DesignTokens.muted.opacity(0.4))
                    AxisValueLabel()
                        .font(TicketLook.micro())
                        .foregroundStyle(DesignTokens.muted)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: tall ? TicketLook.statsHeight : TicketLook.stripHeight)
            Text(TicketWords.inkLine)
                .font(TicketLook.caption())
                .foregroundStyle(DesignTokens.muted)
        }
        .padding(TicketLook.s2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: TicketLook.surfaceRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TicketLook.surfaceRadius, style: .continuous)
                .stroke(DesignTokens.ink, lineWidth: TicketLook.hairline)
        )
        .ticketShadow()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(TicketWords.streak) \(TicketFormat.whole(streakLength)). Timeline of points.")
    }

    private func legendItem(_ title: String, color: Color) -> some View {
        HStack(spacing: TicketLook.s1) {
            RoundedRectangle(cornerRadius: TicketLook.tileRadius, style: .continuous)
                .fill(color)
                .frame(width: TicketLook.s2, height: TicketLook.s1)
                .accessibilityHidden(true)
            Text(title)
                .font(TicketLook.caption())
                .foregroundStyle(DesignTokens.ink)
        }
    }

    private var plot: [TimelineSample] {
        if samples.isEmpty {
            let today = DayKey.key(for: Date())
            let date = DayKey.date(from: today) ?? .now
            return [TimelineSample(daykey: today, streakLength: streakLength, points: 0, date: date)]
        }
        return samples
    }
}
