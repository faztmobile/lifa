import SwiftUI
import LifaDesign

/// Demo screens for the end-to-end walkthrough: one per mobile journey, with sample data and no backend.
/// Built only from LifaDesign. Opened with the launch argument `-LifaDemo <id>`; the real feature screens
/// replace these in step 4. People and figures are fictional.
enum DemoScreens {
    static let ids = ["signup", "home", "will", "assets", "vault", "emergency", "checkin", "activation", "executor", "plans"]
}

struct DemoScreen: View {
    let id: String
    var body: some View {
        switch id {
        case "signup": SignUpDemo()
        case "will": WillDemo()
        case "assets": AssetsDemo()
        case "vault": VaultDemo()
        case "emergency": EmergencyDemo()
        case "checkin": CheckInDemo()
        case "activation": ActivationDemo()
        case "executor": ExecutorDemo()
        case "plans": PlansDemo()
        default: HomeDemo()
        }
    }
}

private let tabs = [LifaTab("home", "Home", .house), LifaTab("will", "Will", .fileText), LifaTab("vault", "Vault", .lock),
                    LifaTab("family", "Family", .users), LifaTab("account", "Account", .user)]

private struct DemoChrome<Content: View>: View {
    var title: String? = nil
    var back = false
    var tab: String? = nil
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            if let title {
                HStack(spacing: LifaSpace.space1) {
                    if back { LifaIcon.chevronLeft.view(size: 26).foregroundStyle(LifaColor.primary).frame(width: 44, height: 44).accessibilityLabel("Back") }
                    Text(title).lifaText(LifaTypography.title2).foregroundStyle(LifaColor.text).accessibilityAddTraits(.isHeader)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, back ? LifaSpace.space2 : LifaSpace.space4)
                .padding(.vertical, LifaSpace.space2)
            }
            VStack(alignment: .leading, spacing: LifaSpace.space4) { content }
                .padding(.horizontal, LifaSpace.space4)
                .padding(.bottom, LifaSpace.space4)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            if let tab { LifaTabBar(tabs, selection: .constant(tab)).background(LifaColor.surface.ignoresSafeArea(edges: .bottom)) }
        }
        .background(LifaColor.background)
    }
}

private struct Lead: View { let text: String; init(_ t: String) { text = t }
    var body: some View { Text(text).lifaText(LifaTypography.body).foregroundStyle(LifaColor.textMuted) } }
private struct DemoSection: View { let text: String; init(_ t: String) { text = t }
    var body: some View { Text(text).lifaText(LifaTypography.bodyStrong).foregroundStyle(LifaColor.text) } }
private struct Caption: View { let text: String; init(_ t: String) { text = t }
    var body: some View { Text(text).lifaText(LifaTypography.caption).foregroundStyle(LifaColor.textMuted) } }

// 1 · Sign up: verify the mobile number (FR-ONB-002)
private struct SignUpDemo: View {
    var body: some View {
        DemoChrome(title: "Verify your mobile", back: true) {
            StepProgress(current: 2, total: 4)
            Lead("We sent a 6-digit code to your phone. We also check that the number hasn’t recently moved to a new SIM.")
            LifaTextField("Mobile number", text: .constant("+27 82 555 0143"), hint: "Number format is valid", hintPositive: true)
            VStack(alignment: .leading, spacing: LifaSpace.space2) {
                Text("Code from the SMS").lifaText(LifaTypography.label).foregroundStyle(LifaColor.text)
                HStack(spacing: LifaSpace.space2) {
                    ForEach(Array(["4", "8", "1", "7", "", ""].enumerated()), id: \.offset) { item in
                        let i = item.offset
                        Text(item.element).lifaText(LifaTypography.title2).foregroundStyle(LifaColor.text)
                            .frame(maxWidth: .infinity).frame(height: 56)
                            .background(LifaColor.surface, in: RoundedRectangle(cornerRadius: LifaRadius.sm, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: LifaRadius.sm, style: .continuous)
                                .strokeBorder(i == 4 ? LifaColor.focus : LifaColor.lineStrong, lineWidth: i == 4 ? 2 : 1))
                    }
                }
                Caption("Didn’t get it? You can ask for a new code in 0:42")
            }
            Spacer(minLength: 0)
            LifaCallout("This phone will be your key", tone: .info, message: "Lifa ties your account to this device. Signing in somewhere new needs an extra check, and we tell your other devices.")
            LifaButton("Verify", fullWidth: true) {}
        }
    }
}

// 2 · Home and the Legacy Score (FR-SCR-002, FR-SCR-003, FR-DMS-002)
private struct HomeDemo: View {
    var body: some View {
        DemoChrome(tab: "home") {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Caption("Good morning")
                    Text("Thandi").lifaText(LifaTypography.title1).foregroundStyle(LifaColor.text)
                }
                Spacer()
                LifaIcon.bell.view().foregroundStyle(LifaColor.text).accessibilityLabel("Inbox")
            }
            .padding(.top, LifaSpace.space2)
            LifaBanner("Monthly check-in is due", icon: .heart) { LifaButton("I’m still here", variant: .text) {} }
            HeroScoreCard(score: 72, delta: "+28 since September", tiles: [HeroTile("Estimated net estate", "R8.92m"), HeroTile("Signed will", "Version 2")])
            QuickActionGrid {
                QuickActionTile(icon: .fileText, label: "Will") {}
                QuickActionTile(icon: .house, label: "Assets") {}
                QuickActionTile(icon: .chartLine, label: "Simulate") {}
                QuickActionTile(icon: .creditCard, label: "Card") {}
            }
            DemoSection("Needs your attention")
            LifaListRow("Name an alternate guardian", subtitle: "Adds 3 points", indicator: .warning, action: {})
        }
    }
}

// 3 · Will builder: divide the residue (FR-WIL-003, FR-WIL-007)
private struct WillDemo: View {
    var body: some View {
        DemoChrome(title: "My will · Step 3 of 7", back: true) {
            StepProgress(current: 3, total: 7)
            VStack(alignment: .leading, spacing: LifaSpace.space1) {
                Text("Who inherits the rest?").lifaText(LifaTypography.title1).foregroundStyle(LifaColor.text)
                Lead("Your residue is everything not left as a gift. Shares must total 100%.")
            }
            LifaCard {
                AllocationRow(initials: "SM", tone: .green, name: "Sipho Mokoena", detail: "Spouse", value: .constant("50"))
                AllocationRow(initials: "LM", tone: .gold, name: "Lerato Mokoena", detail: "Daughter · 12 years", value: .constant("20"))
                AllocationRow(initials: "KM", tone: .green, name: "Kabelo Mokoena", detail: "Son · 25 years", value: .constant("20"))
                AllocationRow(initials: "HC", tone: .lavender, name: "Hope Children’s Home", detail: "Charity", value: .constant("10"))
                HStack(spacing: LifaSpace.space3) {
                    LifaProgressBar(value: 100, label: "Residue allocated")
                    Text("100% allocated").lifaText(LifaTypography.label).fontWeight(.bold).foregroundStyle(LifaColor.leafText)
                }
            }
            LifaCallout("Lerato is under 18", tone: .warning, message: "Her share may go to the Guardian’s Fund until she turns 18.") {
                LifaButton("Learn about the Guardian’s Fund", variant: .text) {}
            }
            Spacer(minLength: 0)
            HStack(spacing: LifaSpace.space3) {
                LifaButton("Back", variant: .secondary) {}.fixedSize()
                LifaButton("Next: specific gifts", fullWidth: true) {}
            }
        }
    }
}

// 4 · Assets and debts (FR-AST-001..004, FRS principle 4)
private struct AssetsDemo: View {
    private let rows: [(LifaIcon, String, String, Int64, ValueBasis)] = [
        (.house, "Family home, Midrand", "Property · joint", 420_000_000, .evidenced),
        (.house, "Flat, Durban North", "Property", 110_000_000, .evidenced),
        (.landmark, "Retirement annuity", "Investment", 304_000_000, .declared),
        (.landmark, "Savings account", "Bank", 41_000_000, .evidenced),
        (.car, "Toyota Fortuner", "Vehicle", 52_000_000, .estimated),
    ]
    var body: some View {
        DemoChrome(title: "Assets and debts", tab: "family") {
            LifaCard {
                LabelledValue("Estimated net estate", cents: 892_000_000, basis: .estimated)
                Caption("Assets \(formatZar(cents: 927_000_000)) · Debts \(formatZar(cents: -35_000_000))")
            }
            DemoSection("Assets · 5 of 15 on Free")
            ForEach(rows, id: \.1) { row in
                LifaListRow(row.1, subtitle: row.2, action: {}, leading: {
                    row.0.view().foregroundStyle(LifaColor.text)
                }, trailing: {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formatZar(cents: row.3, compact: true)).lifaText(LifaTypography.bodyStrong).foregroundStyle(LifaColor.text)
                        BasisBadge(row.4)
                    }
                })
            }
        }
    }
}

// 5 · Vault with the biometric step-up sheet (FR-VLT-001..004, FR-ONB-006)
private struct VaultDemo: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            DemoChrome(title: "Vault", tab: "vault") {
                LifaCard {
                    HStack { DemoSection("Storage"); Spacer(); Caption("3.2 of 10 GB") }
                    LifaProgressBar(value: 3.2, max: 10, label: "Storage used")
                }
                LifaListRow("Identity", subtitle: "4 documents · passport expires in 41 days", indicator: .warning, action: {}, leading: { LifaIcon.idCard.view().foregroundStyle(LifaColor.text) })
                LifaListRow("Will and estate", subtitle: "3 documents", action: {}, leading: { LifaIcon.fileText.view().foregroundStyle(LifaColor.text) })
                LifaListRow("Property", subtitle: "6 documents", action: {}, leading: { LifaIcon.folder.view().foregroundStyle(LifaColor.text) })
                LifaCallout("Stored in South Africa", tone: .info, message: "Your documents are encrypted with your own key.")
            }
            LifaColor.scrim.ignoresSafeArea()
            VStack(spacing: LifaSpace.space4) {
                LifaIcon.fingerprint.view(size: 40).foregroundStyle(LifaColor.leafText)
                    .frame(width: 72, height: 72).background(LifaColor.leafSoft, in: Circle())
                Text("Confirm it’s you").lifaText(LifaTypography.title1).foregroundStyle(LifaColor.text)
                Text("Opening documents needs Face ID. Every time a document is opened, it’s recorded.")
                    .lifaText(LifaTypography.body).foregroundStyle(LifaColor.textMuted).multilineTextAlignment(.center)
                LifaButton("Use Face ID", fullWidth: true) {}
                LifaButton("Cancel", variant: .text) {}
            }
            .padding(.horizontal, LifaSpace.space5).padding(.top, LifaSpace.space6).padding(.bottom, LifaSpace.space8)
            .frame(maxWidth: .infinity)
            .background(LifaColor.surface, in: UnevenRoundedRectangle(topLeadingRadius: LifaRadius.xl, topTrailingRadius: LifaRadius.xl, style: .continuous))
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// 6 · Emergency card and who sees what (FR-EMG-001..002, FR-PRM-001, D-017)
private struct EmergencyDemo: View {
    var body: some View {
        DemoChrome(title: "Emergency card", back: true) {
            VStack(alignment: .leading, spacing: LifaSpace.space2) {
                Text("LIFA · EMERGENCY").lifaText(LifaTypography.overline).foregroundStyle(LifaColor.onHeroMuted)
                Text("Thandi Mokoena").lifaText(LifaTypography.bodyStrong)
                Text("Call Sipho Mokoena · +27 82 555 0198").lifaText(LifaTypography.body)
                Text("Executor: Nomsa Dlamini").lifaText(LifaTypography.body)
            }
            .foregroundStyle(LifaColor.onHero)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(LifaSpace.space4)
            .background(LifaColor.hero, in: RoundedRectangle(cornerRadius: LifaRadius.lg, style: .continuous))
            LifaCard {
                LifaToggleRow("Show on my lock screen", description: "Anyone holding your phone can see it", isOn: .constant(true))
                DemoSection("Show on the card")
                LifaCheckboxRow("Contacts and executor", isOn: .constant(true))
                LifaCheckboxRow("Where my will is kept", isOn: .constant(false))
                LifaCheckboxRow("Funeral wishes", isOn: .constant(false))
            }
            DemoSection("People who can see your plan")
            LifaListRow("Sipho Mokoena", subtitle: "Emergency contact", leading: { LifaAvatar("SM") }, trailing: { LifaBadge("Accepted", tone: .success) })
            LifaListRow("Nomsa Dlamini", subtitle: "Executor", leading: { LifaAvatar("ND", tone: .gold) }, trailing: { LifaBadge("Invite sent", tone: .warning) })
        }
    }
}

// 7 · Check-in (FR-DMS-001..003)
private struct CheckInDemo: View {
    var body: some View {
        DemoChrome(title: "Check-ins", tab: "account") {
            VStack(alignment: .leading, spacing: LifaSpace.space4) {
                Text("Are you OK, Thandi?").lifaText(LifaTypography.title1)
                Text("One tap tells Lifa you’re well.").lifaText(LifaTypography.body)
                Text("I’m still here").lifaText(LifaTypography.button).foregroundStyle(LifaColor.hero)
                    .frame(maxWidth: .infinity).frame(height: LifaSize.buttonHeight)
                    .background(LifaColor.heroAccent, in: RoundedRectangle(cornerRadius: LifaRadius.md, style: .continuous))
                    .accessibilityAddTraits(.isButton)
            }
            .foregroundStyle(LifaColor.onHero)
            .padding(LifaSpace.space5)
            .background(LifaColor.hero, in: RoundedRectangle(cornerRadius: LifaRadius.xl, style: .continuous))
            LifaSegmentedControl("Ask me every", options: [LifaChoice("30", "30 days"), LifaChoice("60", "60 days"), LifaChoice("90", "90 days")], selection: .constant("30"))
            LifaToggleRow("Pause while I travel", description: "Up to 180 days", isOn: .constant(false))
            DemoSection("If you don’t answer")
            LifaListRow("Sipho Mokoena", subtitle: "Verifier · asked to confirm you’re safe", leading: { LifaAvatar("SM") })
            LifaListRow("Nomsa Dlamini", subtitle: "Verifier", leading: { LifaAvatar("ND", tone: .gold) })
            LifaDisclosure("Lifa never declares a death. A missed check-in only starts a human review.")
        }
    }
}

// 8 · Activation notice to the owner (FR-ACT-004, FR-DMS-006)
private struct ActivationDemo: View {
    var body: some View {
        DemoChrome {
            VStack(spacing: LifaSpace.space3) {
                LifaIcon.shieldCheck.view(size: 40).foregroundStyle(LifaColor.critical)
                    .frame(width: 72, height: 72).background(LifaColor.criticalSoft, in: Circle())
                Text("Someone has asked to open your estate plan").lifaText(LifaTypography.title1).foregroundStyle(LifaColor.text)
                Text("Lifa received a report and supporting documents. Two of our team reviewed it. Your plan will open to the people you chose in:")
                    .lifaText(LifaTypography.body).foregroundStyle(LifaColor.textMuted)
                Text("71 h 12 m").lifaText(LifaTypography.display).foregroundStyle(LifaColor.critical)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, LifaSpace.space8)
            LifaCallout("If you’re reading this, you’re OK", tone: .critical, message: "Signing in cancels the request. Nothing has been shared yet.")
            Spacer(minLength: 0)
            LifaButton("I’m still here, cancel this", fullWidth: true) {}
            LifaButton("Contact Lifa support", variant: .secondary, fullWidth: true) {}
        }
    }
}

// 9 · Executor workspace (FR-EXE-001..008)
private struct ExecutorDemo: View {
    private let tasks: [(String, Bool)] = [
        ("Get certified death certificates", true), ("Find the original signed will", true),
        ("Notify banks and insurers · 3 of 5", false), ("Value the property", false), ("Send an update to beneficiaries", false),
    ]
    var body: some View {
        DemoChrome(title: "Estate of T. Mokoena", back: true) {
            LifaCard {
                HStack { DemoSection("Checklist"); Spacer(); Caption("4 of 12 done") }
                LifaProgressBar(value: 4, max: 12, label: "Checklist progress")
            }
            LifaCard {
                ForEach(tasks, id: \.0) { task in
                    let title = task.0, done = task.1
                    HStack(spacing: LifaSpace.space3) {
                        (done ? LifaIcon.circleCheck : LifaIcon.circle).view().foregroundStyle(done ? LifaColor.leaf : LifaColor.lineStrong)
                        Text(title).lifaText(LifaTypography.body).strikethrough(done).foregroundStyle(done ? LifaColor.textMuted : LifaColor.text)
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: 44)
                }
            }
            DemoSection("Coming up")
            LifaListRow("Letter to Standard Bank", subtitle: "Draft ready to send", indicator: .warning, action: {})
            LifaListRow("Beneficiary update", subtitle: "Last sent 12 days ago", indicator: .success, action: {})
            LifaDisclosure("Lifa organises the work. It doesn’t act on the executor’s behalf.")
        }
    }
}

// 10 · Plans (FR-SUB-001..003). Prices come from the store catalogue at runtime, so none are shown here.
private struct PlansDemo: View {
    var body: some View {
        DemoChrome(title: "Plans", back: true) {
            LifaSegmentedControl("Billing period", options: [LifaChoice("monthly", "Monthly"), LifaChoice("yearly", "Yearly · save 17%")], selection: .constant("yearly"))
            PlanCard(name: "Free", features: ["One will draft, 15 assets, 10 people", "500 MB vault"], badge: LifaBadge("Current"))
            PlanCard(name: "Plus", features: ["Will history, codicils, minor warnings", "10 GB vault with expiry reminders", "3 trusted people, release rules, check-ins"],
                     selected: true, badge: LifaBadge("14-day trial", tone: .plan), note: "Price shown from the App Store")
            PlanCard(name: "Family", features: ["Two adults, linked plans, 50 GB shared", "Mirror wills, trust clauses"], badge: EmptyView())
            Spacer(minLength: 0)
            LifaButton("Start free trial", fullWidth: true) {}
            LifaDisclosure("Billed by the App Store. Cancel any time in Settings.")
        }
    }
}

private struct PlanCard<Badge: View>: View {
    let name: String; let features: [String]; var selected = false; let badge: Badge; var note: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: LifaSpace.space1) {
            HStack { DemoSection(name); Spacer(); badge }
            ForEach(features, id: \.self) { Text("•  \($0)").lifaText(LifaTypography.label).foregroundStyle(LifaColor.textMuted) }
            if let note { Caption(note) }
        }
        .padding(LifaSpace.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LifaColor.surface, in: RoundedRectangle(cornerRadius: LifaRadius.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: LifaRadius.lg, style: .continuous).strokeBorder(selected ? LifaColor.primary : LifaColor.line, lineWidth: selected ? 2 : 1))
    }
}
