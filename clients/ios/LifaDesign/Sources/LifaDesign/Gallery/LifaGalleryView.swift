import SwiftUI

/// Component gallery (step 2). Mirrors the web and Android galleries: every component, light and dark, Dynamic Type.
/// Specimens use content from the UI reference screens; people and figures are fictional.
public struct LifaGalleryView: View {
    public enum ThemeChoice: String, CaseIterable, Sendable { case system = "System", light = "Light", dark = "Dark" }

    @State private var theme: ThemeChoice
    @State private var textSize = "system"
    @State private var regime = "in_community"
    @State private var interval = "30"
    @State private var billing = "yearly"
    @State private var pause = false
    @State private var tab = "home"
    @State private var mobile = "+27 82 555 0143"
    @State private var idNumber = "8702145800087"
    @State private var email = "thandi@"
    @State private var shares = ["SM": "50", "LM": "20", "KM": "20", "HC": "10"]
    @State private var fields = ["Contacts and executor": true, "Where my will is kept": true, "Children and guardian": true, "Funeral wishes": false]

    /// Swatch column width grows with the text size, so token names do not break mid-word.
    @ScaledMetric(relativeTo: .caption) private var swatchMinWidth: CGFloat = 140

    public init(theme: ThemeChoice = .system) { _theme = State(initialValue: theme) }

    private var total: Int { shares.values.reduce(0) { $0 + (Int($1) ?? 0) } }
    /// "System" follows the user's Dynamic Type setting; 150 % and 200 % override it for review.
    private var dynamicTypeOverride: DynamicTypeSize? { textSize == "200" ? .accessibility3 : textSize == "150" ? .xxxLarge : nil }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LifaSpace.space8) {
                header
                section("Colours") {
                    Text("Semantic tokens. Every text and control pairing is checked for WCAG contrast in both modes.")
                        .lifaText(LifaTypography.caption).foregroundStyle(LifaColor.textMuted)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: swatchMinWidth), alignment: .leading)], alignment: .leading, spacing: LifaSpace.space3) {
                        ForEach(swatches, id: \.0) { swatch in
                            HStack(spacing: LifaSpace.space2) {
                                RoundedRectangle(cornerRadius: LifaRadius.sm).fill(swatch.1).frame(width: 32, height: 32)
                                    .overlay(RoundedRectangle(cornerRadius: LifaRadius.sm).strokeBorder(LifaColor.lineStrong))
                                Text(swatch.0).lifaText(LifaTypography.caption).foregroundStyle(LifaColor.text)
                            }
                        }
                    }
                }
                section("Typography") {
                    LifaCard {
                        Text("YOUR LEGACY SCORE").lifaText(LifaTypography.overline).foregroundStyle(LifaColor.textMuted)
                        Text("72").lifaText(LifaTypography.display)
                        Text("Who inherits the rest?").lifaText(LifaTypography.title1)
                        Text("Needs your attention").lifaText(LifaTypography.title2)
                        Text("Name an alternate guardian").lifaText(LifaTypography.title3)
                        Text("Everything not left as a specific gift is your residue. Shares must add up to exactly 100%.").lifaText(LifaTypography.body)
                        Text("Lerato is under 18").lifaText(LifaTypography.bodyStrong)
                        Text("Mobile number").lifaText(LifaTypography.label)
                        Text("Lifa is not a law firm or financial adviser.").lifaText(LifaTypography.caption).foregroundStyle(LifaColor.textMuted)
                        Text("Fallback glyphs: Ṱhavhudzwi Muḓau · Ḽivhuwani Ṅemaṋozwi").lifaText(LifaTypography.body)
                    }
                    .foregroundStyle(LifaColor.text)
                }
                section("Buttons") {
                    LifaButton("Start my free will", fullWidth: true) {}
                    LifaButton("Go to my plan", variant: .secondary, fullWidth: true) {}
                    LifaAdaptiveStack {
                        LifaButton("Back", variant: .secondary) {}
                        LifaButton("Next: specific gifts", fullWidth: true) {}
                    }
                    LifaButton("Add a testamentary trust clause", variant: .text) {}
                    LifaAdaptiveStack {
                        LifaButton("Close account", variant: .destructive, compact: true) {}
                        LifaButton("Saving", compact: true, loading: true) {}
                        LifaButton("Disabled", compact: true) {}.disabled(true)
                    }
                    LifaButton("Add a beneficiary", variant: .dashed, fullWidth: true, icon: .plus) {}
                }
                section("Badges and evidence labels") {
                    ViewThatFits(in: .horizontal) {
                        HStack { badges }
                        VStack(alignment: .leading) { badges }
                    }
                    LabelledValue("Estimated net estate", cents: 892_000_000, basis: .estimated)
                    LabelledValue("Property · 2", cents: 530_000_000, basis: .evidenced)
                    LabelledValue("Household net worth", cents: 892_000_000, basis: .declared, compact: true)
                }
                section("Cards") {
                    LifaBanner("Monthly check-in is due", icon: .heart) { LifaButton("I’m still here", variant: .text) {} }
                    HeroScoreCard(score: 72, delta: "+28 since September", tiles: [HeroTile("Estimated net estate", "R8.92m"), HeroTile("Signed will", "Version 2")])
                    QuickActionGrid {
                        QuickActionTile(icon: .fileText, label: "Will") {}
                        QuickActionTile(icon: .house, label: "Assets") {}
                        QuickActionTile(icon: .chartLine, label: "Simulate") {}
                        QuickActionTile(icon: .creditCard, label: "Card") {}
                    }
                }
                section("List rows") {
                    LifaListRow("Name an alternate guardian", subtitle: "Adds 3 points", indicator: .warning, action: {})
                    LifaListRow("Passport expires in 41 days", subtitle: "Upload the new one before \(formatDate(year: 2026, month: 11, day: 17))", indicator: .warning, action: {})
                    LifaListRow("Sipho Mokoena", subtitle: "Executor", leading: { LifaAvatar("SM") }, trailing: { LifaBadge("Accepted", tone: .success) })
                    LifaListRow("Nomsa Dlamini", subtitle: "Guardian for Lerato", leading: { LifaAvatar("ND", tone: .gold) }, trailing: { LifaBadge("Invite sent", tone: .warning) })
                    LifaListRow("Hope Children’s Home", subtitle: "Charity", leading: { LifaAvatar("HC", tone: .lavender) })
                }
                section("Progress") {
                    Text("My will · Step 3 of 7").lifaText(LifaTypography.caption).foregroundStyle(LifaColor.textMuted)
                    StepProgress(current: 3, total: 7)
                    LifaProgressBar(value: 3.2, max: 10, label: "Vault storage used")
                    Text("3.2 of 10 GB").lifaText(LifaTypography.caption).foregroundStyle(LifaColor.textMuted)
                }
                section("Text fields") {
                    LifaTextField("Mobile number", text: $mobile, keyboard: .phonePad)
                    LifaTextField("South African ID number", text: $idNumber, hint: "ID number format is valid", hintPositive: true, keyboard: .numberPad)
                    LifaTextField("Email", text: $email, error: "Enter an email address like name@example.com", keyboard: .emailAddress)
                    LifaCard {
                        ForEach(people, id: \.initials) { p in
                            AllocationRow(initials: p.initials, tone: p.tone, name: p.name, detail: p.detail,
                                          value: Binding(get: { shares[p.initials] ?? "" }, set: { shares[p.initials] = $0 }))
                        }
                        LifaAdaptiveStack {
                            LifaProgressBar(value: Double(min(total, 100)), label: "Residue allocated")
                            Text("\(total)% allocated").lifaText(LifaTypography.label).fontWeight(.bold).foregroundStyle(LifaColor.leafText)
                        }
                    }
                    if total != 100 { LifaCallout("Allocations total \(total)%; they must total 100%", tone: .critical) }
                    LifaCallout("Lerato is under 18", tone: .warning,
                                message: "A minor can’t take an inheritance directly. Without a trust, her share may go to the Guardian’s Fund until she turns 18.") {
                        LifaButton("Learn about the Guardian’s Fund", variant: .text) {}
                    }
                    LifaCallout("Stored in South Africa", tone: .info, message: "Your documents are encrypted with your own key.")
                }
                section("Choices") {
                    OptionCards("How are you married?", options: [
                        LifaChoice("not_married", "Not married"), LifaChoice("in_community", "In community of property"),
                        LifaChoice("accrual", "Out of community, with accrual"), LifaChoice("no_accrual", "Out of community, no accrual"),
                        LifaChoice("customary", "Customary marriage"),
                    ], selection: $regime)
                    LifaSegmentedControl("Ask me every", options: [LifaChoice("30", "30 days"), LifaChoice("60", "60 days"), LifaChoice("90", "90 days")], selection: $interval)
                    LifaSegmentedControl("Billing period", options: [LifaChoice("monthly", "Monthly"), LifaChoice("yearly", "Yearly · save 17%")], selection: $billing)
                    LifaCard {
                        LifaToggleRow("Pause while I travel", description: "Up to 180 days", isOn: $pause)
                        Text("Show on the card").lifaText(LifaTypography.label).foregroundStyle(LifaColor.text)
                        ForEach(fields.keys.sorted(), id: \.self) { k in
                            LifaCheckboxRow(k, isOn: Binding(get: { fields[k] ?? false }, set: { fields[k] = $0 }))
                        }
                    }
                }
                section("Navigation") {
                    LifaTabBar([LifaTab("home", "Home", .house), LifaTab("will", "Will", .fileText), LifaTab("vault", "Vault", .lock),
                                LifaTab("family", "Family", .users), LifaTab("account", "Account", .user)], selection: $tab)
                }
                section("Disclosures") {
                    LifaDisclosure("Lifa is not a law firm and does not give legal advice.")
                    LifaDisclosure("Education only. Lifa does not recommend financial products.")
                }
            }
            .padding(LifaSpace.space4)
        }
        .background(LifaColor.background)
        // Opaque strip behind the status bar so scrolled content does not run under the clock.
        .safeAreaInset(edge: .top, spacing: 0) { Color.clear.frame(height: 0).background(LifaColor.background) }
        .preferredColorScheme(theme == .system ? nil : theme == .dark ? .dark : .light)
        .modifier(DynamicTypeOverride(size: dynamicTypeOverride))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: LifaSpace.space3) {
            Text("Lifa design system").lifaText(LifaTypography.title1).foregroundStyle(LifaColor.text).accessibilityAddTraits(.isHeader)
            Text("Component gallery · iOS").lifaText(LifaTypography.caption).foregroundStyle(LifaColor.textMuted)
            LifaSegmentedControl("Theme", options: ThemeChoice.allCases.map { LifaChoice($0.rawValue, $0.rawValue) },
                                 selection: Binding(get: { theme.rawValue }, set: { theme = ThemeChoice(rawValue: $0) ?? .system }))
            LifaSegmentedControl("Text size", options: [LifaChoice("system", "System"), LifaChoice("150", "150%"), LifaChoice("200", "200%")], selection: $textSize)
        }
    }

    @ViewBuilder private var badges: some View {
        LifaBadge("Plus", tone: .plan); LifaBadge("Accepted", tone: .success); LifaBadge("Invite sent", tone: .warning)
        LifaBadge("Not chosen yet"); LifaBadge("Overdue", tone: .critical)
        BasisBadge(.evidenced); BasisBadge(.declared); BasisBadge(.estimated)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: LifaSpace.space4) {
            Text(title).lifaText(LifaTypography.title2).foregroundStyle(LifaColor.text).accessibilityAddTraits(.isHeader)
            content()
        }
    }

    private struct Person { let initials: String; let name: String; let detail: String; let tone: LifaAvatarTone }
    private let people: [Person] = [
        Person(initials: "SM", name: "Sipho Mokoena", detail: "Spouse", tone: .green),
        Person(initials: "LM", name: "Lerato Mokoena", detail: "Daughter · 12 years", tone: .gold),
        Person(initials: "KM", name: "Kabelo Mokoena", detail: "Son · 25 years", tone: .green),
        Person(initials: "HC", name: "Hope Children’s Home", detail: "Charity", tone: .lavender),
    ]

    private var swatches: [(String, Color)] {
        [("background", LifaColor.background), ("surface", LifaColor.surface), ("line", LifaColor.line), ("lineStrong", LifaColor.lineStrong),
         ("text", LifaColor.text), ("textMuted", LifaColor.textMuted), ("primary", LifaColor.primary), ("onPrimary", LifaColor.onPrimary),
         ("hero", LifaColor.hero), ("heroInset", LifaColor.heroInset), ("heroAccent", LifaColor.heroAccent), ("goldText", LifaColor.goldText),
         ("goldSoft", LifaColor.goldSoft), ("leaf", LifaColor.leaf), ("leafText", LifaColor.leafText), ("leafSoft", LifaColor.leafSoft),
         ("warning", LifaColor.warning), ("warningText", LifaColor.warningText), ("warningSoft", LifaColor.warningSoft),
         ("critical", LifaColor.critical), ("criticalSoft", LifaColor.criticalSoft), ("focus", LifaColor.focus)]
    }
}

#Preview("Light") { LifaGalleryView(theme: .light) }
#Preview("Dark") { LifaGalleryView(theme: .dark) }

private struct DynamicTypeOverride: ViewModifier {
    let size: DynamicTypeSize?
    func body(content: Content) -> some View {
        if let size { content.dynamicTypeSize(size) } else { content }
    }
}
