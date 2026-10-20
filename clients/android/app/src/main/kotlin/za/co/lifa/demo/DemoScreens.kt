package za.co.lifa.demo

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import za.co.lifa.design.LifaTheme
import za.co.lifa.design.ValueBasis
import za.co.lifa.design.components.AllocationRow
import za.co.lifa.design.components.AvatarTone
import za.co.lifa.design.components.BadgeTone
import za.co.lifa.design.components.BasisBadge
import za.co.lifa.design.components.ButtonVariant
import za.co.lifa.design.components.CalloutTone
import za.co.lifa.design.components.ChoiceOption
import za.co.lifa.design.components.HeroScoreCard
import za.co.lifa.design.components.HeroTile
import za.co.lifa.design.components.LabelledValue
import za.co.lifa.design.components.LifaAvatar
import za.co.lifa.design.components.LifaBadge
import za.co.lifa.design.components.LifaBanner
import za.co.lifa.design.components.LifaButton
import za.co.lifa.design.components.LifaCallout
import za.co.lifa.design.components.LifaCard
import za.co.lifa.design.components.LifaCheckboxRow
import za.co.lifa.design.components.LifaDisclosure
import za.co.lifa.design.components.LifaIcon
import za.co.lifa.design.components.LifaListRow
import za.co.lifa.design.components.LifaProgressBar
import za.co.lifa.design.components.LifaSwitchRow
import za.co.lifa.design.components.LifaTabBar
import za.co.lifa.design.components.LifaTextField
import za.co.lifa.design.components.QuickActionTile
import za.co.lifa.design.components.RowIndicator
import za.co.lifa.design.components.SegmentedControl
import za.co.lifa.design.components.StepProgress
import za.co.lifa.design.components.TabItem
import za.co.lifa.design.formatZar
import za.co.lifa.design.generated.LifaIcons
import za.co.lifa.design.generated.LifaRadius
import za.co.lifa.design.generated.LifaSize
import za.co.lifa.design.generated.LifaSpace

/**
 * Demo screens for the end-to-end walkthrough: one per mobile journey, with sample data and no backend.
 * Built only from the design system. Opened with `adb shell am start ... --es lifa.demo <id>`; the real
 * feature screens replace these in step 4. People and figures are fictional.
 */
val demoScreenIds = listOf("signup", "home", "will", "assets", "vault", "emergency", "checkin", "activation", "executor", "plans")

@Composable
fun DemoScreen(id: String) {
    when (id) {
        "signup" -> SignUp()
        "will" -> Will()
        "assets" -> Assets()
        "vault" -> Vault()
        "emergency" -> Emergency()
        "checkin" -> CheckIn()
        "activation" -> Activation()
        "executor" -> Executor()
        "plans" -> Plans()
        else -> Home()
    }
}

private val tabs = listOf(
    TabItem("home", "Home", LifaIcons.House), TabItem("will", "Will", LifaIcons.FileText), TabItem("vault", "Vault", LifaIcons.Lock),
    TabItem("family", "Family", LifaIcons.Users), TabItem("account", "Account", LifaIcons.User),
)

@Composable
private fun Screen(title: String? = null, back: Boolean = false, tab: String? = null, content: @Composable ColumnScope.() -> Unit) {
    val c = LifaTheme.colors
    Column(Modifier.fillMaxSize().background(c.background)) {
        if (title != null) {
            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(start = LifaSpace.space2, end = LifaSpace.space4, top = LifaSpace.space2, bottom = LifaSpace.space2)) {
                if (back) Box(Modifier.size(48.dp), contentAlignment = Alignment.Center) { LifaIcon(LifaIcons.ChevronLeft, "Back", tint = c.primary) }
                else Spacer(Modifier.width(LifaSpace.space2))
                Text(title, style = LifaTheme.type.title2, color = c.text, modifier = Modifier.semantics { heading() })
            }
        }
        Column(
            Modifier.weight(1f).fillMaxWidth().padding(horizontal = LifaSpace.space4).padding(bottom = LifaSpace.space4),
            verticalArrangement = Arrangement.spacedBy(LifaSpace.space4),
            content = content,
        )
        if (tab != null) LifaTabBar(tabs, tab, {})
    }
}

@Composable private fun Lead(text: String) = Text(text, style = LifaTheme.type.body, color = LifaTheme.colors.textMuted)
@Composable private fun Section(text: String) = Text(text, style = LifaTheme.type.bodyStrong, color = LifaTheme.colors.text)
@Composable private fun Caption(text: String) = Text(text, style = LifaTheme.type.caption, color = LifaTheme.colors.textMuted)
@Composable private fun ColumnScope.Fill() = Spacer(Modifier.weight(1f))

// 1 · Sign up: verify the mobile number (FR-ONB-002)
@Composable
private fun SignUp() = Screen("Verify your mobile", back = true) {
    val c = LifaTheme.colors
    StepProgress(2, 4)
    Lead("We sent a 6-digit code to your phone. We also check that the number hasn’t recently moved to a new SIM.")
    LifaTextField("Mobile number", "+27 82 555 0143", {}, hint = "Number format is valid", hintPositive = true)
    Column(verticalArrangement = Arrangement.spacedBy(LifaSpace.space2)) {
        Text("Code from the SMS", style = LifaTheme.type.label, color = c.text)
        Row(horizontalArrangement = Arrangement.spacedBy(LifaSpace.space2)) {
            listOf("4", "8", "1", "7", "", "").forEachIndexed { i, d ->
                Box(
                    Modifier.weight(1f).height(56.dp).clip(RoundedCornerShape(LifaRadius.sm)).background(c.surface)
                        .border(if (i == 4) 2.dp else LifaSize.border, if (i == 4) c.focus else c.lineStrong, RoundedCornerShape(LifaRadius.sm)),
                    contentAlignment = Alignment.Center,
                ) { Text(d, style = LifaTheme.type.title2, color = c.text) }
            }
        }
        Caption("Didn’t get it? You can ask for a new code in 0:42")
    }
    Fill()
    LifaCallout("This phone will be your key", CalloutTone.Info, "Lifa ties your account to this device. Signing in somewhere new needs an extra check, and we tell your other devices.")
    LifaButton("Verify", {}, Modifier.fillMaxWidth())
}

// 2 · Home and the Legacy Score (FR-SCR-002, FR-SCR-003, FR-DMS-002)
@Composable
private fun Home() = Screen(tab = "home") {
    val c = LifaTheme.colors
    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(top = LifaSpace.space3)) {
        Column(Modifier.weight(1f)) {
            Caption("Good morning")
            Text("Thandi", style = LifaTheme.type.title1, color = c.text)
        }
        LifaIcon(LifaIcons.Bell, "Inbox")
    }
    LifaBanner("Monthly check-in is due", LifaIcons.Heart) { LifaButton("I’m still here", {}, variant = ButtonVariant.Text) }
    HeroScoreCard(72, listOf(HeroTile("Estimated net estate", "R8.92m"), HeroTile("Signed will", "Version 2")), delta = "+28 since September")
    Row(horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3)) {
        QuickActionTile(LifaIcons.FileText, "Will", {}, Modifier.weight(1f))
        QuickActionTile(LifaIcons.House, "Assets", {}, Modifier.weight(1f))
        QuickActionTile(LifaIcons.ChartLine, "Simulate", {}, Modifier.weight(1f))
        QuickActionTile(LifaIcons.CreditCard, "Card", {}, Modifier.weight(1f))
    }
    Section("Needs your attention")
    LifaListRow("Name an alternate guardian", "Adds 3 points", RowIndicator.Warning, onClick = {})
    LifaListRow("Passport expires in 41 days", "Upload the new one before 17 Nov 2026", RowIndicator.Warning, onClick = {})
}

// 3 · Will builder: divide the residue (FR-WIL-003, FR-WIL-007)
@Composable
private fun Will() = Screen("My will · Step 3 of 7", back = true) {
    StepProgress(3, 7)
    Column(verticalArrangement = Arrangement.spacedBy(LifaSpace.space1)) {
        Text("Who inherits the rest?", style = LifaTheme.type.title1, color = LifaTheme.colors.text)
        Lead("Everything not left as a specific gift is your residue. Shares must add up to exactly 100%.")
    }
    LifaCard {
        AllocationRow("SM", AvatarTone.Green, "Sipho Mokoena", "Spouse", "50") {}
        AllocationRow("LM", AvatarTone.Gold, "Lerato Mokoena", "Daughter · 12 years", "20") {}
        AllocationRow("KM", AvatarTone.Green, "Kabelo Mokoena", "Son · 25 years", "20") {}
        AllocationRow("HC", AvatarTone.Lavender, "Hope Children’s Home", "Charity", "10") {}
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3)) {
            LifaProgressBar(100f, label = "Residue allocated", modifier = Modifier.weight(1f))
            Text("100% allocated", style = LifaTheme.type.label, color = LifaTheme.colors.leafText)
        }
    }
    LifaCallout("Lerato is under 18", CalloutTone.Warning, "Without a trust, her share may go to the Guardian’s Fund until she turns 18.") {
        LifaButton("Learn about the Guardian’s Fund", {}, variant = ButtonVariant.Text)
    }
    Fill()
    Row(horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3)) {
        LifaButton("Back", {}, variant = ButtonVariant.Secondary)
        LifaButton("Next: specific gifts", {}, Modifier.weight(1f))
    }
}

private data class A(val icon: LifaIcons, val title: String, val sub: String, val cents: Long, val basis: ValueBasis)

// 4 · Assets and debts (FR-AST-001..004, FRS principle 4)
@Composable
private fun Assets() = Screen("Assets and debts", tab = "family") {
    LifaCard {
        LabelledValue("Estimated net estate", 892_000_000, ValueBasis.Estimated)
        Caption("Assets ${formatZar(927_000_000)} · Debts ${formatZar(-35_000_000)}")
    }
    Section("Assets · 5 of 15 on Free")
    listOf(
        A(LifaIcons.House, "Family home, Midrand", "Property · joint", 420_000_000, ValueBasis.Evidenced),
        A(LifaIcons.House, "Flat, Durban North", "Property", 110_000_000, ValueBasis.Evidenced),
        A(LifaIcons.Landmark, "Retirement annuity", "Investment", 304_000_000, ValueBasis.Declared),
        A(LifaIcons.Landmark, "Savings account", "Bank", 41_000_000, ValueBasis.Evidenced),
        A(LifaIcons.Car, "Toyota Fortuner", "Vehicle", 52_000_000, ValueBasis.Estimated),
    ).forEach { a ->
        LifaListRow(a.title, a.sub, leading = { LifaIcon(a.icon, null) }, trailing = {
            Column(horizontalAlignment = Alignment.End, verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text(formatZar(a.cents, compact = true), style = LifaTheme.type.bodyStrong, color = LifaTheme.colors.text)
                BasisBadge(a.basis)
            }
        }, onClick = {})
    }
}

// 5 · Vault with the biometric step-up sheet (FR-VLT-001..004, FR-ONB-006)
@Composable
private fun Vault() {
    val c = LifaTheme.colors
    Box(Modifier.fillMaxSize()) {
        Screen("Vault", tab = "vault") {
            LifaCard {
                Row { Section("Storage"); Spacer(Modifier.weight(1f)); Caption("3.2 of 10 GB") }
                LifaProgressBar(3.2f, 10f, "Storage used")
            }
            LifaListRow("Identity", "4 documents · passport expires in 41 days", RowIndicator.Warning, leading = { LifaIcon(LifaIcons.IdCard, null) }, onClick = {})
            LifaListRow("Will and estate", "3 documents", leading = { LifaIcon(LifaIcons.FileText, null) }, onClick = {})
            LifaListRow("Property", "6 documents", leading = { LifaIcon(LifaIcons.Folder, null) }, onClick = {})
            LifaCallout("Stored in South Africa", CalloutTone.Info, "Your documents are encrypted with your own key.")
        }
        Box(Modifier.fillMaxSize().background(c.scrim))
        Surface(
            color = c.surface, shape = RoundedCornerShape(topStart = LifaRadius.xl, topEnd = LifaRadius.xl),
            modifier = Modifier.align(Alignment.BottomCenter).fillMaxWidth(),
        ) {
            Column(
                Modifier.padding(start = LifaSpace.space5, end = LifaSpace.space5, top = LifaSpace.space6, bottom = LifaSpace.space8),
                horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(LifaSpace.space4),
            ) {
                Box(Modifier.size(72.dp).clip(CircleShape).background(c.leafSoft), contentAlignment = Alignment.Center) {
                    LifaIcon(LifaIcons.Fingerprint, null, tint = c.leafText, size = 40.dp)
                }
                Text("Confirm it’s you", style = LifaTheme.type.title1, color = c.text)
                Text("Opening documents needs your fingerprint or face. Every time a document is opened, it’s recorded.", style = LifaTheme.type.body, color = c.textMuted, textAlign = TextAlign.Center)
                LifaButton("Use fingerprint", {}, Modifier.fillMaxWidth())
                LifaButton("Cancel", {}, variant = ButtonVariant.Text)
            }
        }
    }
}

// 6 · Emergency card and who sees what (FR-EMG-001..002, FR-PRM-001, D-017)
@Composable
private fun Emergency() = Screen("Emergency card", back = true) {
    val c = LifaTheme.colors
    Column(
        Modifier.fillMaxWidth().clip(RoundedCornerShape(LifaRadius.lg)).background(c.hero).padding(LifaSpace.space4),
        verticalArrangement = Arrangement.spacedBy(LifaSpace.space2),
    ) {
        Text("LIFA · EMERGENCY", style = LifaTheme.type.overline, color = c.onHeroMuted)
        Text("Thandi Mokoena", style = LifaTheme.type.bodyStrong, color = c.onHero)
        Text("Call Sipho Mokoena · +27 82 555 0198", style = LifaTheme.type.body, color = c.onHero)
        Text("Executor: Nomsa Dlamini", style = LifaTheme.type.body, color = c.onHero)
    }
    LifaCard {
        LifaSwitchRow("Show on my lock screen", true, {}, "Anyone holding your phone can see it")
        Section("Show on the card")
        LifaCheckboxRow("Contacts and executor", true) {}
        LifaCheckboxRow("Where my will is kept", false) {}
        LifaCheckboxRow("Funeral wishes", false) {}
    }
    Section("People who can see your plan")
    LifaListRow("Sipho Mokoena", "Emergency contact", leading = { LifaAvatar("SM") }, trailing = { LifaBadge("Accepted", BadgeTone.Success) })
    LifaListRow("Nomsa Dlamini", "Executor", leading = { LifaAvatar("ND", AvatarTone.Gold) }, trailing = { LifaBadge("Invite sent", BadgeTone.Warning) })
}

// 7 · Check-in (FR-DMS-001..003)
@Composable
private fun CheckIn() = Screen("Check-ins", tab = "account") {
    val c = LifaTheme.colors
    Column(
        Modifier.fillMaxWidth().clip(RoundedCornerShape(LifaRadius.xl)).background(c.hero).padding(LifaSpace.space5),
        verticalArrangement = Arrangement.spacedBy(LifaSpace.space4),
    ) {
        Text("Are you OK, Thandi?", style = LifaTheme.type.title1, color = c.onHero)
        Text("Your monthly check-in is due. One tap tells Lifa you’re well.", style = LifaTheme.type.body, color = c.onHero)
        Surface(color = c.heroAccent, shape = RoundedCornerShape(LifaRadius.md), modifier = Modifier.fillMaxWidth().height(LifaSize.buttonHeight)) {
            Box(contentAlignment = Alignment.Center) { Text("I’m still here", style = LifaTheme.type.button, color = c.hero) }
        }
    }
    SegmentedControl("Ask me every", listOf(ChoiceOption("30", "30 days"), ChoiceOption("60", "60 days"), ChoiceOption("90", "90 days")), "30") {}
    LifaSwitchRow("Pause while I travel", false, {}, "Up to 180 days")
    Section("If you don’t answer")
    LifaListRow("Sipho Mokoena", "Verifier · asked to confirm you’re safe", leading = { LifaAvatar("SM") })
    LifaListRow("Nomsa Dlamini", "Verifier", leading = { LifaAvatar("ND", AvatarTone.Gold) })
    LifaDisclosure("Lifa never declares a death. A missed check-in only starts a human review.")
}

// 8 · Activation notice to the owner (FR-ACT-004, FR-DMS-006)
@Composable
private fun Activation() = Screen {
    val c = LifaTheme.colors
    Column(
        Modifier.fillMaxWidth().padding(top = LifaSpace.space8),
        horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(LifaSpace.space3),
    ) {
        Box(Modifier.size(72.dp).clip(CircleShape).background(c.criticalSoft), contentAlignment = Alignment.Center) {
            LifaIcon(LifaIcons.ShieldCheck, null, tint = c.critical, size = 40.dp)
        }
        Text("Someone has asked to open your estate plan", style = LifaTheme.type.title1, color = c.text, textAlign = TextAlign.Center)
        Text("Lifa received a report and supporting documents. Two of our team reviewed it. Your plan will open to the people you chose in:", style = LifaTheme.type.body, color = c.textMuted, textAlign = TextAlign.Center)
        Text("71 h 12 m", style = LifaTheme.type.display, color = c.critical)
    }
    LifaCallout("If you’re reading this, you’re OK", CalloutTone.Critical, "Signing in cancels the request. Nothing has been shared yet.")
    Fill()
    LifaButton("I’m still here, cancel this", {}, Modifier.fillMaxWidth())
    LifaButton("Contact Lifa support", {}, Modifier.fillMaxWidth(), variant = ButtonVariant.Secondary)
}

// 9 · Executor workspace (FR-EXE-001..008)
@Composable
private fun Executor() = Screen("Estate of T. Mokoena", back = true) {
    val c = LifaTheme.colors
    LifaCard {
        Row { Section("Checklist"); Spacer(Modifier.weight(1f)); Caption("4 of 12 done") }
        LifaProgressBar(4f, 12f, "Checklist progress")
    }
    LifaCard {
        listOf(
            "Get certified copies of the death certificate" to true, "Find the original signed will" to true,
            "Notify banks and insurers · 3 of 5" to false, "Value the property" to false, "Send an update to beneficiaries" to false,
        ).forEach { (t, done) ->
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3), modifier = Modifier.height(48.dp)) {
                LifaIcon(if (done) LifaIcons.CircleCheck else LifaIcons.Circle, null, tint = if (done) c.leaf else c.lineStrong)
                Text(t, style = LifaTheme.type.body, color = if (done) c.textMuted else c.text, textDecoration = if (done) TextDecoration.LineThrough else null)
            }
        }
    }
    Section("Coming up")
    LifaListRow("Letter to Standard Bank", "Draft ready to send", RowIndicator.Warning, onClick = {})
    LifaListRow("Beneficiary update", "Last sent 12 days ago", RowIndicator.Success, onClick = {})
    LifaDisclosure("Lifa organises the work. It doesn’t act on the executor’s behalf.")
}

// 10 · Plans (FR-SUB-001..003). Prices come from the store catalogue at runtime, so none are shown here.
@Composable
private fun Plans() = Screen("Plans", back = true) {
    SegmentedControl("Billing period", listOf(ChoiceOption("monthly", "Monthly"), ChoiceOption("yearly", "Yearly · save 17%")), "yearly") {}
    Plan("Free", listOf("One will draft, 15 assets, 10 people", "500 MB vault"), badge = { LifaBadge("Current") })
    Plan("Plus", listOf("Will history, codicils, minor warnings", "10 GB vault with expiry reminders", "3 trusted people, release rules, check-ins"), selected = true,
        badge = { LifaBadge("14-day trial", BadgeTone.Plan) }, note = "Price shown from the store")
    Plan("Family", listOf("Two adults, linked plans, 50 GB shared", "Mirror wills, trust clauses"))
    Fill()
    LifaButton("Start free trial", {}, Modifier.fillMaxWidth())
    LifaDisclosure("Billed by the store. Cancel any time in your store settings.")
}

@Composable
private fun Plan(name: String, features: List<String>, selected: Boolean = false, badge: (@Composable () -> Unit)? = null, note: String? = null) {
    val c = LifaTheme.colors
    Surface(
        color = c.surface, shape = RoundedCornerShape(LifaRadius.lg),
        border = BorderStroke(if (selected) 2.dp else LifaSize.border, if (selected) c.primary else c.line),
        modifier = Modifier.fillMaxWidth(),
    ) {
        Column(Modifier.padding(LifaSpace.space4), verticalArrangement = Arrangement.spacedBy(LifaSpace.space1)) {
            Row(verticalAlignment = Alignment.CenterVertically) { Section(name); Spacer(Modifier.weight(1f)); badge?.invoke() }
            features.forEach { Text("•  $it", style = LifaTheme.type.label, color = c.textMuted) }
            if (note != null) Caption(note)
        }
    }
}
