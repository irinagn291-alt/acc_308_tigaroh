import SwiftUI
import UIKit

/// Presentation tokens. Colour stays in DesignTokens. Radius, type, and motion live here.
enum TicketLook {
    static let unit: CGFloat = 8
    static let s1 = unit
    static let s2 = unit * 2
    static let s3 = unit * 3
    static let s4 = unit * 4
    static let s5 = unit * 5
    static let s6 = unit * 6
    static let hit: CGFloat = 48
    static let tileRadius: CGFloat = 14
    static let surfaceRadius: CGFloat = 28
    static let hairline: CGFloat = 1
    static let pressScale: CGFloat = 0.97
    static let sheetScale: CGFloat = 0.96
    static let pressDuration: Double = 0.16
    static let shadowRadius: CGFloat = 8
    static let shadowY: CGFloat = 4
    static let stripHeight: CGFloat = 160
    static let statsHeight: CGFloat = 320
    static let artHeight: CGFloat = 220
    static let tileShort: CGFloat = 88
    static let tileTall: CGFloat = 132
    static let band: CGFloat = 8

    @MainActor
    static func display() -> Font {
        face("Cochin-Bold", size: 34, relativeTo: .largeTitle, relax: false)
    }

    @MainActor
    static func title() -> Font {
        face("Cochin-Bold", size: 28, relativeTo: .title, relax: false)
    }

    @MainActor
    static func headline() -> Font {
        face("Cochin-Bold", size: 22, relativeTo: .title2, relax: false)
    }

    @MainActor
    static func body() -> Font {
        face(DesignTokens.fontFamily, size: 17, relativeTo: .body, relax: true)
    }

    @MainActor
    static func caption() -> Font {
        face(DesignTokens.fontFamily, size: 14, relativeTo: .caption, relax: true)
    }

    @MainActor
    static func micro() -> Font {
        face(DesignTokens.fontFamily, size: 12, relativeTo: .caption2, relax: true)
    }

    /// Short display stays Cochin. Long lines at accessibility sizes use New York.
    @MainActor
    private static func face(
        _ name: String,
        size: CGFloat,
        relativeTo style: Font.TextStyle,
        relax: Bool
    ) -> Font {
        let category = UIApplication.shared.preferredContentSizeCategory
        let chosen: String
        if relax && category.isAccessibilityCategory {
            chosen = "New York"
        } else if UIFont(name: name, size: size) != nil {
            chosen = name
        } else {
            chosen = "New York"
        }
        return Font.custom(chosen, size: size, relativeTo: style)
    }
}

/// Product words kept off the Text() literal so the type name is not the label source.
enum TicketWords {
    static let streak = "Streak"
    static let choice = "Choice"
    static let inkLine = "Ink line is streak. Red line is points."
}

extension View {
    func ticketShadow() -> some View {
        shadow(color: DesignTokens.ink.opacity(0.12), radius: TicketLook.shadowRadius, y: TicketLook.shadowY)
    }
}

/// Whole numbers and day labels. Views do not interpolate counts.
enum TicketFormat {
    static func whole(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func dayLabel(_ key: Int) -> String {
        guard let date = DayKey.date(from: key) else {
            return whole(key)
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

/// One haptic when Score files a Card. Sheets stay silent.
enum TicketHaptic {
    @MainActor
    static func commit() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

/// Filled capsule for the live verb, destructive for reset, quiet for the strip.
struct TicketButtonStyle: ButtonStyle {
    enum Role {
        case verb
        case destructive
        case quiet
        case tile
    }

    var role: Role
    var loading: Bool = false

    @Environment(\.isEnabled) private var enabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && enabled && !loading
        Group {
            if role == .tile {
                tileBody(configuration: configuration, pressed: pressed)
            } else {
                capsuleBody(configuration: configuration, pressed: pressed)
            }
        }
    }

    private func tileBody(configuration: Configuration, pressed: Bool) -> some View {
        configuration.label
            .scaleEffect(!reduceMotion && pressed ? TicketLook.pressScale : 1)
            .opacity(tileOpacity(pressed: pressed))
            .animation(.easeOut(duration: TicketLook.pressDuration), value: pressed)
    }

    private func tileOpacity(pressed: Bool) -> Double {
        if !enabled {
            return 0.4
        }
        if reduceMotion && pressed {
            return 0.72
        }
        return 1
    }

    private func capsuleBody(configuration: Configuration, pressed: Bool) -> some View {
        HStack(spacing: TicketLook.s1) {
            if loading {
                ProgressView()
                    .tint(foreground)
            }
            configuration.label
        }
        .font(TicketLook.headline())
        .foregroundStyle(foreground)
        .frame(maxWidth: .infinity, minHeight: TicketLook.hit)
        .padding(.horizontal, TicketLook.s2)
        .background(fill(pressed: pressed))
        .clipShape(Capsule())
        .contentShape(Capsule())
        .ticketShadow()
        .scaleEffect(!reduceMotion && pressed ? TicketLook.pressScale : 1)
        .opacity(reduceMotion && pressed ? 0.72 : 1)
        .animation(.easeOut(duration: TicketLook.pressDuration), value: pressed)
        .allowsHitTesting(!loading)
    }

    private var foreground: Color {
        switch role {
        case .verb:
            return enabled ? DesignTokens.bg : DesignTokens.ink
        case .destructive:
            return DesignTokens.bg
        case .quiet:
            return enabled ? DesignTokens.ink : DesignTokens.muted
        case .tile:
            return DesignTokens.ink
        }
    }

    private func fill(pressed: Bool) -> Color {
        guard enabled else {
            return DesignTokens.muted.opacity(0.35)
        }
        switch role {
        case .verb:
            return pressed ? DesignTokens.accent.opacity(0.84) : DesignTokens.accent
        case .destructive:
            return pressed ? DesignTokens.ink.opacity(0.84) : DesignTokens.ink
        case .quiet:
            return pressed ? DesignTokens.muted.opacity(0.16) : DesignTokens.surface
        case .tile:
            return DesignTokens.surface
        }
    }
}

/// Inline bar title in Cochin. The system navigation title face is not used.
struct TicketBarTitle: View {
    var title: String

    var body: some View {
        Text(title)
            .font(TicketLook.headline())
            .foregroundStyle(DesignTokens.ink)
            .lineLimit(1)
    }
}

/// SF Symbol close control. The hit target is the whole button, not the glyph.
struct TicketDismiss: View {
    var name: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(TicketLook.body())
                .foregroundStyle(DesignTokens.ink)
                .frame(minWidth: TicketLook.hit, minHeight: TicketLook.hit)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Close \(name)")
    }
}

/// Navigation bar title face. Sheets still draw TicketBarTitle; this covers the bar chrome.
enum TicketChrome {
    @MainActor
    static func install() {
        let base = UIFont(name: "Cochin-Bold", size: 22)
            ?? UIFont(name: "New York", size: 22)
            ?? UIFont.preferredFont(forTextStyle: .headline)
        let font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: base)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(DesignTokens.bg)
        appearance.titleTextAttributes = [
            .font: font,
            .foregroundColor: UIColor(DesignTokens.ink)
        ]
        let bar = UINavigationBar.appearance()
        bar.standardAppearance = appearance
        bar.scrollEdgeAppearance = appearance
        bar.compactAppearance = appearance
    }
}

/// Sheet content scales from 0.96 with a fade. Reduce Motion keeps the fade and drops the scale.
struct SheetEntrance: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1 : (shown ? 1 : TicketLook.sheetScale))
            .opacity(shown ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: TicketLook.pressDuration)) {
                    shown = true
                }
            }
    }
}
