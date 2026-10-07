import SwiftUI

// Lifa SwiftUI components (step 2). Same set and behaviour as web (clients/web/src/design) and Compose
// (clients/android/core/design). Native controls and traits first, so VoiceOver and Dynamic Type work (NFR-ACC-001).

// MARK: - Icon

extension LifaIcon {
    /// Template icon tinted with the current foreground style; hidden from VoiceOver unless labelled by the caller.
    public func view(size: CGFloat = LifaSize.icon) -> some View {
        image.resizable().renderingMode(.template).scaledToFit().frame(width: size, height: size).accessibilityHidden(true)
    }
}

// MARK: - Buttons

public enum LifaButtonVariant: Sendable { case primary, secondary, text, destructive, dashed }

public struct LifaButtonStyle: ButtonStyle {
    let variant: LifaButtonVariant
    let fullWidth: Bool
    let compact: Bool
    @Environment(\.isEnabled) private var isEnabled

    public init(_ variant: LifaButtonVariant = .primary, fullWidth: Bool = false, compact: Bool = false) {
        self.variant = variant
        self.fullWidth = fullWidth
        self.compact = compact
    }

    public func makeBody(configuration: Configuration) -> some View {
        let (bg, fg): (Color, Color) = switch variant {
        case .primary: (configuration.isPressed ? LifaColor.primaryPressed : LifaColor.primary, LifaColor.onPrimary)
        case .secondary: (LifaColor.surface, LifaColor.primary)
        case .text: (.clear, LifaColor.primary)
        case .destructive: (LifaColor.critical, LifaColor.surface)
        case .dashed: (.clear, LifaColor.text)
        }
        let shape = RoundedRectangle(cornerRadius: LifaRadius.md, style: .continuous)
        return configuration.label
            .lifaText(variant == .dashed ? LifaTypography.label : LifaTypography.button)
            .underline(variant == .text)
            .multilineTextAlignment(variant == .text ? .leading : .center)
            .foregroundStyle(fg)
            .padding(.horizontal, variant == .text ? 0 : (compact ? LifaSpace.space4 : LifaSpace.space6))
            .padding(.vertical, LifaSpace.space2)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: compact || variant == .text ? LifaSize.touchMin : LifaSize.buttonHeight)
            .background(bg, in: shape)
            .overlay {
                switch variant {
                case .secondary: shape.strokeBorder(LifaColor.lineStrong, lineWidth: LifaSize.border)
                case .dashed: shape.strokeBorder(LifaColor.lineStrong, style: StrokeStyle(lineWidth: LifaSize.border, dash: [5, 4]))
                default: EmptyView()
                }
            }
            .contentShape(shape)
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

/// Convenience button with optional loading state and leading icon.
public struct LifaButton: View {
    let title: String
    let variant: LifaButtonVariant
    let fullWidth: Bool
    let compact: Bool
    let loading: Bool
    let icon: LifaIcon?
    let action: () -> Void

    public init(_ title: String, variant: LifaButtonVariant = .primary, fullWidth: Bool = false, compact: Bool = false,
                loading: Bool = false, icon: LifaIcon? = nil, action: @escaping () -> Void) {
        self.title = title; self.variant = variant; self.fullWidth = fullWidth; self.compact = compact
        self.loading = loading; self.icon = icon; self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: LifaSpace.space2) {
                if loading { ProgressView().tint(variant == .primary ? LifaColor.onPrimary : LifaColor.primary) }
                else if let icon { icon.view(size: 20) }
                Text(title)
            }
        }
        .buttonStyle(LifaButtonStyle(variant, fullWidth: fullWidth, compact: compact))
        .disabled(loading)
        .accessibilityValue(loading ? Text("Loading") : Text(""))
    }
}

/// Home quick action (Will, Assets, Simulate, Card).
public struct QuickActionTile: View {
    let icon: LifaIcon; let label: String; let action: () -> Void
    public init(icon: LifaIcon, label: String, action: @escaping () -> Void) { self.icon = icon; self.label = label; self.action = action }
    public var body: some View {
        Button(action: action) {
            VStack(spacing: LifaSpace.space2) {
                icon.view().foregroundStyle(LifaColor.primary)
                Text(label).lifaText(LifaTypography.label).foregroundStyle(LifaColor.text).multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: LifaSize.touchMin)
            .padding(.vertical, LifaSpace.space4).padding(.horizontal, LifaSpace.space2)
            .background(LifaColor.surface, in: RoundedRectangle(cornerRadius: LifaRadius.md, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: LifaRadius.md, style: .continuous).strokeBorder(LifaColor.line, lineWidth: LifaSize.border))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Badges and values

public enum LifaBadgeTone: Sendable { case plan, neutral, success, warning, critical }

public struct LifaBadge: View {
    let text: String; let tone: LifaBadgeTone; let uppercase: Bool
    public init(_ text: String, tone: LifaBadgeTone = .neutral, uppercase: Bool = true) { self.text = text; self.tone = tone; self.uppercase = uppercase }
    public var body: some View {
        let (bg, fg): (Color, Color) = switch tone {
        case .plan: (LifaColor.goldSoft, LifaColor.goldText)
        case .neutral: (LifaColor.background, LifaColor.textMuted)
        case .success: (LifaColor.leafSoft, LifaColor.leafText)
        case .warning: (LifaColor.warningSoft, LifaColor.warningText)
        case .critical: (LifaColor.criticalSoft, LifaColor.critical)
        }
        Text(uppercase ? text.uppercased() : text)
            .lifaText(uppercase ? LifaTypography.overline : LifaTypography.caption)
            .foregroundStyle(fg)
            .padding(.horizontal, LifaSpace.space2).padding(.vertical, 2)
            .background(bg, in: Capsule())
            .overlay { if tone == .neutral { Capsule().strokeBorder(LifaColor.line, lineWidth: LifaSize.border) } }
    }
}

/// FRS principle 4: every figure shows whether it is declared, evidenced or estimated.
public struct BasisBadge: View {
    let basis: ValueBasis
    public init(_ basis: ValueBasis) { self.basis = basis }
    public var body: some View {
        LifaBadge(basis.rawValue, tone: basis == .evidenced ? .success : basis == .estimated ? .warning : .neutral, uppercase: false)
    }
}

public struct LabelledValue: View {
    let label: String; let cents: Int64; let basis: ValueBasis; let compact: Bool
    public init(_ label: String, cents: Int64, basis: ValueBasis, compact: Bool = false) { self.label = label; self.cents = cents; self.basis = basis; self.compact = compact }
    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).lifaText(LifaTypography.caption).foregroundStyle(LifaColor.textMuted)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: LifaSpace.space2) { amount; BasisBadge(basis) }
                VStack(alignment: .leading, spacing: LifaSpace.space1) { amount; BasisBadge(basis) }
            }
        }
        .accessibilityElement(children: .combine)
    }
    private var amount: some View { Text(formatZar(cents: cents, compact: compact)).lifaText(LifaTypography.title2).foregroundStyle(LifaColor.text) }
}

// MARK: - Containers

public struct LifaCard<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        VStack(alignment: .leading, spacing: LifaSpace.space3) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(LifaSpace.space4)
            .background(LifaColor.surface, in: RoundedRectangle(cornerRadius: LifaRadius.lg, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: LifaRadius.lg, style: .continuous).strokeBorder(LifaColor.line, lineWidth: LifaSize.border))
    }
}

public struct HeroTile: Sendable, Hashable { public let label: String; public let value: String
    public init(_ label: String, _ value: String) { self.label = label; self.value = value } }

/// Home Legacy Score card (FR-SCR-002).
public struct HeroScoreCard: View {
    let score: Int; let delta: String?; let tiles: [HeroTile]
    public init(score: Int, delta: String? = nil, tiles: [HeroTile]) { self.score = score; self.delta = delta; self.tiles = tiles }
    public var body: some View {
        VStack(alignment: .leading, spacing: LifaSpace.space4) {
            Text("Legacy Score").lifaText(LifaTypography.label).foregroundStyle(LifaColor.onHeroMuted).accessibilityAddTraits(.isHeader)
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .lastTextBaseline) { scoreText; Spacer(); deltaText }
                VStack(alignment: .leading) { scoreText; deltaText }
            }
            LifaProgressBar(value: Double(score), label: "Legacy Score", onHero: true)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: LifaSpace.space3) { ForEach(tiles, id: \.self, content: tile) }
                VStack(spacing: LifaSpace.space3) { ForEach(tiles, id: \.self, content: tile) }
            }
        }
        .padding(LifaSpace.space5)
        .background(LifaColor.hero, in: RoundedRectangle(cornerRadius: LifaRadius.xl, style: .continuous))
    }
    private var scoreText: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text("\(score)").lifaText(LifaTypography.display).foregroundStyle(LifaColor.onHero)
            Text("/100").lifaText(LifaTypography.title2).foregroundStyle(LifaColor.onHeroMuted)
        }
        .accessibilityElement(children: .combine)
    }
    @ViewBuilder private var deltaText: some View {
        if let delta { Text(delta).lifaText(LifaTypography.label).fontWeight(.bold).foregroundStyle(LifaColor.heroPositive) }
    }
    private func tile(_ t: HeroTile) -> some View {
        VStack(alignment: .leading) {
            Text(t.label).lifaText(LifaTypography.caption).foregroundStyle(LifaColor.onHeroMuted)
            Text(t.value).lifaText(LifaTypography.title2).foregroundStyle(LifaColor.onHero)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(LifaSpace.space3)
        .background(LifaColor.heroInset, in: RoundedRectangle(cornerRadius: LifaRadius.md, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

/// Slim banner, for example "Monthly check-in is due · I'm still here" (FR-DMS-002).
public struct LifaBanner<Action: View>: View {
    let text: String; let icon: LifaIcon?; let action: Action
    public init(_ text: String, icon: LifaIcon? = nil, @ViewBuilder action: () -> Action) { self.text = text; self.icon = icon; self.action = action() }
    public var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: LifaSpace.space3) { label; Spacer(minLength: 0); action }
            VStack(alignment: .leading, spacing: LifaSpace.space2) { label; action }
        }
        .padding(.horizontal, LifaSpace.space4).padding(.vertical, LifaSpace.space3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LifaColor.leafSoft, in: RoundedRectangle(cornerRadius: LifaRadius.md, style: .continuous))
    }
    private var label: some View {
        HStack(spacing: LifaSpace.space3) {
            if let icon { icon.view(size: 20).foregroundStyle(LifaColor.text) }
            Text(text).lifaText(LifaTypography.body).foregroundStyle(LifaColor.text)
        }
    }
}

public enum LifaCalloutTone: Sendable { case info, warning, critical }

public struct LifaCallout<Action: View>: View {
    let title: String; let tone: LifaCalloutTone; let message: String?; let action: Action
    public init(_ title: String, tone: LifaCalloutTone = .info, message: String? = nil, @ViewBuilder action: () -> Action = { EmptyView() }) {
        self.title = title; self.tone = tone; self.message = message; self.action = action()
    }
    public var body: some View {
        let (bg, border, tint, icon): (Color, Color, Color, LifaIcon) = switch tone {
        case .info: (LifaColor.leafSoft, LifaColor.leafSoft, LifaColor.leafText, .info)
        case .warning: (LifaColor.warningSoft, LifaColor.warning, LifaColor.warningText, .triangleAlert)
        case .critical: (LifaColor.criticalSoft, LifaColor.critical, LifaColor.critical, .circleAlert)
        }
        HStack(alignment: .top, spacing: LifaSpace.space3) {
            icon.view(size: 22).foregroundStyle(tint)
            VStack(alignment: .leading, spacing: LifaSpace.space1) {
                Text(title).lifaText(LifaTypography.bodyStrong).foregroundStyle(LifaColor.text)
                if let message { Text(message).lifaText(LifaTypography.body).foregroundStyle(LifaColor.text) }
                action
            }
            Spacer(minLength: 0)
        }
        .padding(LifaSpace.space4)
        .background(bg, in: RoundedRectangle(cornerRadius: LifaRadius.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: LifaRadius.lg, style: .continuous).strokeBorder(border, lineWidth: LifaSize.border))
        .accessibilityElement(children: .contain)
        .onAppear { if tone == .critical { AccessibilityNotification.Announcement(title).post() } }
    }
}

// MARK: - Progress

public struct LifaProgressBar: View {
    let value: Double; let max: Double; let label: String; let onHero: Bool
    public init(value: Double, max: Double = 100, label: String, onHero: Bool = false) { self.value = value; self.max = max; self.label = label; self.onHero = onHero }
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(onHero ? LifaColor.heroInset : LifaColor.line)
                Capsule().fill(onHero ? LifaColor.heroAccent : LifaColor.leaf)
                    .frame(width: geo.size.width * min(1, Swift.max(0, value / max)))
            }
        }
        .frame(height: LifaSize.progressHeight)
        .accessibilityElement()
        .accessibilityLabel(label)
        .accessibilityValue(Text("\(Int((value / max * 100).rounded())) percent"))
    }
}

/// Wizard progress, for example "My will · Step 3 of 7" (FR-WIL-001).
public struct StepProgress: View {
    let current: Int; let total: Int
    public init(current: Int, total: Int) { self.current = current; self.total = total }
    public var body: some View {
        HStack(spacing: LifaSpace.space1) {
            ForEach(0..<total, id: \.self) { i in Capsule().fill(i < current ? LifaColor.primary : LifaColor.line).frame(height: 4) }
        }
        .accessibilityElement()
        .accessibilityLabel("Step \(current) of \(total)")
    }
}

// MARK: - Lists

public enum LifaRowIndicator: Sendable { case warning, critical, success }

public struct LifaListRow<Leading: View, Trailing: View>: View {
    let title: String; let subtitle: String?; let indicator: LifaRowIndicator?
    let leading: Leading; let trailing: Trailing; let action: (() -> Void)?

    public init(_ title: String, subtitle: String? = nil, indicator: LifaRowIndicator? = nil, action: (() -> Void)? = nil,
                @ViewBuilder leading: () -> Leading = { EmptyView() }, @ViewBuilder trailing: () -> Trailing = { EmptyView() }) {
        self.title = title; self.subtitle = subtitle; self.indicator = indicator; self.action = action
        self.leading = leading(); self.trailing = trailing()
    }

    public var body: some View {
        if let action { Button(action: action) { row(chevron: true) }.buttonStyle(.plain) } else { row(chevron: false).accessibilityElement(children: .combine) }
    }

    private func row(chevron: Bool) -> some View {
        HStack(spacing: LifaSpace.space3) {
            if let indicator {
                Circle().fill(indicator == .warning ? LifaColor.warning : indicator == .critical ? LifaColor.critical : LifaColor.leaf)
                    .frame(width: 10, height: 10).accessibilityHidden(true)
            }
            leading
            ViewThatFits(in: .horizontal) {
                HStack(spacing: LifaSpace.space2) { texts; Spacer(minLength: 0); trailing }
                VStack(alignment: .leading, spacing: LifaSpace.space2) { texts; trailing }
            }
            if chevron { LifaIcon.chevronRight.view(size: 20).foregroundStyle(LifaColor.textMuted) }
        }
        .padding(LifaSpace.space4)
        .frame(maxWidth: .infinity, minHeight: LifaSize.touchMin, alignment: .leading)
        .background(LifaColor.surface, in: RoundedRectangle(cornerRadius: LifaRadius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: LifaRadius.md, style: .continuous).strokeBorder(LifaColor.line, lineWidth: LifaSize.border))
        .contentShape(Rectangle())
    }

    private var texts: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title).lifaText(LifaTypography.bodyStrong).foregroundStyle(LifaColor.text)
            if let subtitle { Text(subtitle).lifaText(LifaTypography.label).foregroundStyle(LifaColor.textMuted) }
        }
    }
}

public enum LifaAvatarTone: Sendable { case green, gold, lavender }

/// Initials avatar. Decorative: the person's name is always shown next to it.
public struct LifaAvatar: View {
    let initials: String; let tone: LifaAvatarTone
    public init(_ initials: String, tone: LifaAvatarTone = .green) { self.initials = initials; self.tone = tone }
    public var body: some View {
        let (bg, fg): (Color, Color) = switch tone {
        case .green: (LifaColor.avatarGreenBg, LifaColor.avatarGreenFg)
        case .gold: (LifaColor.avatarGoldBg, LifaColor.avatarGoldFg)
        case .lavender: (LifaColor.avatarLavenderBg, LifaColor.avatarLavenderFg)
        }
        Text(initials).lifaText(LifaTypography.label).fontWeight(.bold).foregroundStyle(fg)
            .frame(width: LifaSize.avatar, height: LifaSize.avatar).background(bg, in: Circle())
            .accessibilityHidden(true)
    }
}

/// Mandatory disclosure (FRS 12.2, FR-WIL-018). Text comes from content and is rendered verbatim.
public struct LifaDisclosure: View {
    let text: String
    public init(_ text: String) { self.text = text }
    public var body: some View {
        Text(text).lifaText(LifaTypography.caption).foregroundStyle(LifaColor.textMuted).multilineTextAlignment(.center).frame(maxWidth: .infinity)
    }
}
