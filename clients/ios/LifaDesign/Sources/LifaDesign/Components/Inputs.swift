import SwiftUI
import UIKit

/// Text field with a visible label (also its accessible name), hint and error. Border uses line-strong (3:1, WCAG 1.4.11).
public struct LifaTextField: View {
    let label: String; @Binding var text: String
    let hint: String?; let hintPositive: Bool; let error: String?; let suffix: String?
    let keyboard: UIKeyboardType; let compact: Bool; let showLabel: Bool
    @FocusState private var focused: Bool

    public init(_ label: String, text: Binding<String>, hint: String? = nil, hintPositive: Bool = false, error: String? = nil,
                suffix: String? = nil, keyboard: UIKeyboardType = .default, compact: Bool = false, showLabel: Bool = true) {
        self.label = label; self._text = text; self.hint = hint; self.hintPositive = hintPositive; self.error = error
        self.suffix = suffix; self.keyboard = keyboard; self.compact = compact; self.showLabel = showLabel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: LifaSpace.space1) {
            if showLabel { Text(label).lifaText(LifaTypography.label).foregroundStyle(LifaColor.text).accessibilityHidden(true) }
            HStack(spacing: LifaSpace.space2) {
                TextField(label, text: $text)
                    .lifaText(LifaTypography.body)
                    .foregroundStyle(LifaColor.text)
                    .keyboardType(keyboard)
                    .multilineTextAlignment(compact ? .trailing : .leading)
                    .focused($focused)
                    .accessibilityLabel(label)
                    .accessibilityHint(error ?? hint ?? "")
                if let suffix { Text(suffix).lifaText(LifaTypography.body).foregroundStyle(LifaColor.textMuted).accessibilityHidden(true) }
            }
            .padding(.horizontal, compact ? LifaSpace.space3 : LifaSpace.space4)
            .frame(width: compact ? 96 : nil)
            .frame(maxWidth: compact ? nil : .infinity, minHeight: compact ? LifaSize.touchMin : LifaSize.inputHeight)
            .background(LifaColor.surface, in: RoundedRectangle(cornerRadius: LifaRadius.sm, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LifaRadius.sm, style: .continuous)
                    .strokeBorder(focused ? LifaColor.focus : error != nil ? LifaColor.critical : LifaColor.lineStrong,
                                  lineWidth: focused ? LifaSize.focusRing : LifaSize.border)
            )
            if let hint { Text(hint).lifaText(LifaTypography.caption).foregroundStyle(hintPositive ? LifaColor.leafText : LifaColor.textMuted) }
            if let error { Text(error).lifaText(LifaTypography.caption).foregroundStyle(LifaColor.critical) }
        }
    }
}

/// One person's residue share (FR-WIL-003). Stacks vertically at large Dynamic Type sizes.
public struct AllocationRow: View {
    let initials: String; let tone: LifaAvatarTone; let name: String; let detail: String; @Binding var value: String
    public init(initials: String, tone: LifaAvatarTone, name: String, detail: String, value: Binding<String>) {
        self.initials = initials; self.tone = tone; self.name = name; self.detail = detail; self._value = value
    }
    public var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: LifaSpace.space3) { person; Spacer(minLength: 0); field }
            VStack(alignment: .leading, spacing: LifaSpace.space2) { person; field }
        }
    }
    private var person: some View {
        HStack(spacing: LifaSpace.space3) {
            LifaAvatar(initials, tone: tone)
            VStack(alignment: .leading, spacing: 0) {
                Text(name).lifaText(LifaTypography.bodyStrong).foregroundStyle(LifaColor.text)
                Text(detail).lifaText(LifaTypography.caption).foregroundStyle(LifaColor.textMuted)
            }
        }
    }
    private var field: some View {
        LifaTextField("Share for \(name)", text: $value, suffix: "%", keyboard: .decimalPad, compact: true, showLabel: false)
    }
}

public struct LifaChoice: Sendable, Hashable, Identifiable {
    public let value: String; public let label: String; public let hint: String?
    public var id: String { value }
    public init(_ value: String, _ label: String, hint: String? = nil) { self.value = value; self.label = label; self.hint = hint }
}

/// Single choice as cards, for example "How are you married?" (FR-WIL-002). Each card is a button with the Selected trait.
public struct OptionCards: View {
    let legend: String; let options: [LifaChoice]; @Binding var selection: String
    public init(_ legend: String, options: [LifaChoice], selection: Binding<String>) { self.legend = legend; self.options = options; self._selection = selection }
    public var body: some View {
        VStack(alignment: .leading, spacing: LifaSpace.space3) {
            Text(legend).lifaText(LifaTypography.label).foregroundStyle(LifaColor.text).accessibilityAddTraits(.isHeader)
            ForEach(options) { o in
                let selected = o.value == selection
                Button { selection = o.value } label: {
                    HStack(spacing: LifaSpace.space3) {
                        ZStack {
                            Circle().strokeBorder(selected ? LifaColor.primary : LifaColor.lineStrong, lineWidth: 2).frame(width: 22, height: 22)
                            if selected { Circle().fill(LifaColor.primary).frame(width: 12, height: 12) }
                        }
                        .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(o.label).lifaText(LifaTypography.body).foregroundStyle(LifaColor.text)
                            if let hint = o.hint { Text(hint).lifaText(LifaTypography.caption).foregroundStyle(LifaColor.textMuted) }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, LifaSpace.space4).padding(.vertical, LifaSpace.space3)
                    .frame(maxWidth: .infinity, minHeight: LifaSize.inputHeight, alignment: .leading)
                    .background(LifaColor.surface, in: RoundedRectangle(cornerRadius: LifaRadius.md, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: LifaRadius.md, style: .continuous)
                        .strokeBorder(selected ? LifaColor.primary : LifaColor.lineStrong, lineWidth: selected ? 2 : LifaSize.border))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? [.isSelected] : [])
            }
        }
    }
}

/// Segmented control (30/60/90 days; Monthly/Yearly). Falls back to a vertical stack when labels do not fit.
public struct LifaSegmentedControl: View {
    let label: String; let options: [LifaChoice]; @Binding var selection: String
    public init(_ label: String, options: [LifaChoice], selection: Binding<String>) { self.label = label; self.options = options; self._selection = selection }
    public var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 4) { segments }
            VStack(spacing: 4) { segments }
        }
        .padding(4)
        .background(LifaColor.background, in: RoundedRectangle(cornerRadius: LifaRadius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: LifaRadius.md, style: .continuous).strokeBorder(LifaColor.lineStrong, lineWidth: LifaSize.border))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(label)
    }
    private var segments: some View {
        ForEach(options) { o in
            let selected = o.value == selection
            Button { selection = o.value } label: {
                Text(o.label).lifaText(LifaTypography.label).fontWeight(selected ? .bold : .medium)
                    .foregroundStyle(selected ? LifaColor.onPrimary : LifaColor.text)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LifaSpace.space3)
                    .frame(maxWidth: .infinity, minHeight: LifaSize.touchMin)
                    .background(selected ? LifaColor.primary : .clear, in: RoundedRectangle(cornerRadius: LifaRadius.sm, style: .continuous))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(selected ? [.isSelected] : [])
        }
    }
}

/// Native Toggle (VoiceOver announces it as a switch), styled with the theme.
public struct LifaToggleRow: View {
    let label: String; let description: String?; @Binding var isOn: Bool
    public init(_ label: String, description: String? = nil, isOn: Binding<Bool>) { self.label = label; self.description = description; self._isOn = isOn }
    public var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 0) {
                Text(label).lifaText(LifaTypography.body).foregroundStyle(LifaColor.text)
                if let description { Text(description).lifaText(LifaTypography.caption).foregroundStyle(LifaColor.textMuted) }
            }
        }
        .tint(LifaColor.primary)
        .frame(minHeight: LifaSize.touchMin)
    }
}

/// Checkbox row: a button with the toggle trait and a checked/unchecked value.
public struct LifaCheckboxRow: View {
    let label: String; @Binding var isOn: Bool
    public init(_ label: String, isOn: Binding<Bool>) { self.label = label; self._isOn = isOn }
    public var body: some View {
        Button { isOn.toggle() } label: {
            HStack(spacing: LifaSpace.space3) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(isOn ? LifaColor.primary : LifaColor.lineStrong, lineWidth: 2)
                    .background(isOn ? LifaColor.primary : .clear, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .overlay { if isOn { LifaIcon.check.view(size: 16).foregroundStyle(LifaColor.onPrimary) } }
                    .frame(width: 22, height: 22)
                Text(label).lifaText(LifaTypography.body).foregroundStyle(LifaColor.text)
                Spacer(minLength: 0)
            }
            .frame(minHeight: LifaSize.touchMin)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(isOn ? "Checked" : "Not checked")
    }
}

public struct LifaTab: Sendable, Hashable, Identifiable {
    public let key: String; public let label: String; public let icon: LifaIcon
    public var id: String { key }
    public init(_ key: String, _ label: String, _ icon: LifaIcon) { self.key = key; self.label = label; self.icon = icon }
}

/// Tab bar matching the reference screens. The app uses TabView with this styling in step 4; this view is for the gallery.
public struct LifaTabBar: View {
    let tabs: [LifaTab]; @Binding var selection: String
    public init(_ tabs: [LifaTab], selection: Binding<String>) { self.tabs = tabs; self._selection = selection }
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { t in
                let selected = t.key == selection
                Button { selection = t.key } label: {
                    VStack(spacing: 2) {
                        t.icon.view()
                        Text(t.label).lifaText(LifaTypography.caption).fontWeight(selected ? .bold : .regular)
                    }
                    .foregroundStyle(selected ? LifaColor.primary : LifaColor.textMuted)
                    .frame(maxWidth: .infinity, minHeight: LifaSize.tabBarHeight)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? [.isSelected] : [])
            }
        }
        .background(LifaColor.surface)
        .overlay(alignment: .top) { Rectangle().fill(LifaColor.line).frame(height: LifaSize.border) }
        .accessibilityElement(children: .contain)
    }
}
