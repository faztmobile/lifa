package za.co.lifa.design.gallery

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.Density
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
import za.co.lifa.design.components.LifaListRow
import za.co.lifa.design.components.LifaProgressBar
import za.co.lifa.design.components.LifaSwitchRow
import za.co.lifa.design.components.LifaTabBar
import za.co.lifa.design.components.LifaTextField
import za.co.lifa.design.components.OptionCards
import za.co.lifa.design.components.QuickActionTile
import za.co.lifa.design.components.RowIndicator
import za.co.lifa.design.components.SegmentedControl
import za.co.lifa.design.components.StepProgress
import za.co.lifa.design.components.TabItem
import za.co.lifa.design.generated.LifaIcons
import za.co.lifa.design.generated.LifaRadius
import za.co.lifa.design.generated.LifaSpace

/** Theme choice for the gallery: follow the system, or force light or dark. */
enum class GalleryTheme { System, Light, Dark }

/**
 * Component gallery (step 2). Mirrors the web gallery: every component, in light and dark, at 100–200 % font scale.
 * Specimens use content from the UI reference screens; people and figures are fictional.
 */
@Composable
fun LifaGallery(
    systemDark: Boolean,
    initialTheme: GalleryTheme = GalleryTheme.System,
    initialFontScale: Float = 1f,
    platform: String = "Android",
) {
    var theme by rememberSaveable { mutableStateOf(initialTheme) }
    var fontScale by rememberSaveable { mutableStateOf(initialFontScale) }
    val dark = when (theme) { GalleryTheme.System -> systemDark; GalleryTheme.Light -> false; GalleryTheme.Dark -> true }
    val density = LocalDensity.current
    CompositionLocalProvider(LocalDensity provides Density(density.density, fontScale)) {
        LifaTheme(darkTheme = dark) {
            GalleryContent(platform, theme, { theme = it }, fontScale, { fontScale = it })
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun GalleryContent(platform: String, theme: GalleryTheme, onTheme: (GalleryTheme) -> Unit, fontScale: Float, onFontScale: (Float) -> Unit) {
    val c = LifaTheme.colors
    var regime by remember { mutableStateOf("in_community") }
    var interval by remember { mutableStateOf("30") }
    var billing by remember { mutableStateOf("yearly") }
    var pause by remember { mutableStateOf(false) }
    var tab by remember { mutableStateOf("home") }
    val shares = remember { mutableStateMapOf("SM" to "50", "LM" to "20", "KM" to "20", "HC" to "10") }
    val cardFields = remember { mutableStateMapOf("Contacts and executor" to true, "Where my will is kept" to true, "Children and guardian" to true, "Funeral wishes" to false) }
    val total = shares.values.sumOf { it.toIntOrNull() ?: 0 }

    LazyColumn(
        modifier = Modifier.fillMaxSize().background(c.background).testTag("gallery"),
        contentPadding = androidx.compose.foundation.layout.PaddingValues(LifaSpace.space4),
        verticalArrangement = Arrangement.spacedBy(LifaSpace.space6),
    ) {
        item {
            Column(verticalArrangement = Arrangement.spacedBy(LifaSpace.space3)) {
                Text("Lifa design system", style = LifaTheme.type.title1, color = c.text, modifier = Modifier.semantics { heading() })
                Text("Component gallery · $platform", style = LifaTheme.type.caption, color = c.textMuted)
                SegmentedControl("Theme", GalleryTheme.entries.map { ChoiceOption(it.name, it.name) }, theme.name) { onTheme(GalleryTheme.valueOf(it)) }
                SegmentedControl("Font scale", listOf(1f, 1.5f, 2f).map { ChoiceOption(it.toString(), "${(it * 100).toInt()}%") }, fontScale.toString()) { onFontScale(it.toFloat()) }
            }
        }
        section("Colours") {
            Text("Semantic tokens. Every text and control pairing is checked for WCAG contrast in both modes.", style = LifaTheme.type.caption, color = c.textMuted)
            FlowRow(horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3), verticalArrangement = Arrangement.spacedBy(LifaSpace.space3)) {
                swatches(LifaTheme.colors).forEach { (name, color) ->
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(LifaSpace.space2), modifier = Modifier.widthIn(min = 140.dp)) {
                        Box(Modifier.size(32.dp).clip(RoundedCornerShape(LifaRadius.sm)).background(color).border(1.dp, c.lineStrong, RoundedCornerShape(LifaRadius.sm)))
                        Text(name, style = LifaTheme.type.caption, color = c.text)
                    }
                }
            }
        }
        section("Typography") {
            LifaCard {
                Text("YOUR LEGACY SCORE", style = LifaTheme.type.overline, color = c.textMuted)
                Text("72", style = LifaTheme.type.display, color = c.text)
                Text("Who inherits the rest?", style = LifaTheme.type.title1, color = c.text)
                Text("Needs your attention", style = LifaTheme.type.title2, color = c.text)
                Text("Name an alternate guardian", style = LifaTheme.type.title3, color = c.text)
                Text("Everything not left as a specific gift is your residue. Shares must add up to exactly 100%.", style = LifaTheme.type.body, color = c.text)
                Text("Lerato is under 18", style = LifaTheme.type.bodyStrong, color = c.text)
                Text("Mobile number", style = LifaTheme.type.label, color = c.text)
                Text("Lifa is not a law firm or financial adviser.", style = LifaTheme.type.caption, color = c.textMuted)
                Text("Fallback glyphs: Ṱhavhudzwi Muḓau · Ḽivhuwani Ṅemaṋozwi", style = LifaTheme.type.body, color = c.text)
            }
        }
        section("Buttons") {
            LifaButton("Start my free will", onClick = {}, modifier = Modifier.fillMaxWidth())
            LifaButton("Go to my plan", onClick = {}, variant = ButtonVariant.Secondary, modifier = Modifier.fillMaxWidth())
            Row(horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3)) {
                LifaButton("Back", onClick = {}, variant = ButtonVariant.Secondary)
                LifaButton("Next: specific gifts", onClick = {}, modifier = Modifier.weight(1f))
            }
            FlowRow(horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3), verticalArrangement = Arrangement.spacedBy(LifaSpace.space2)) {
                LifaButton("Add a testamentary trust clause", onClick = {}, variant = ButtonVariant.Text)
                LifaButton("Close account", onClick = {}, variant = ButtonVariant.Destructive, compact = true)
                LifaButton("Saving", onClick = {}, loading = true, compact = true)
                LifaButton("Disabled", onClick = {}, enabled = false, compact = true)
            }
            LifaButton("Add a beneficiary", onClick = {}, variant = ButtonVariant.Dashed, leadingIcon = LifaIcons.Plus, modifier = Modifier.fillMaxWidth())
        }
        section("Badges and evidence labels") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(LifaSpace.space2), verticalArrangement = Arrangement.spacedBy(LifaSpace.space2)) {
                LifaBadge("Plus", BadgeTone.Plan); LifaBadge("Accepted", BadgeTone.Success); LifaBadge("Invite sent", BadgeTone.Warning)
                LifaBadge("Not chosen yet"); LifaBadge("Overdue", BadgeTone.Critical)
                BasisBadge(ValueBasis.Evidenced); BasisBadge(ValueBasis.Declared); BasisBadge(ValueBasis.Estimated)
            }
            LabelledValue("Estimated net estate", 892_000_000, ValueBasis.Estimated)
            LabelledValue("Property · 2", 530_000_000, ValueBasis.Evidenced)
            LabelledValue("Household net worth", 892_000_000, ValueBasis.Declared, compact = true)
        }
        section("Cards") {
            LifaBanner("Monthly check-in is due", LifaIcons.Heart) { LifaButton("I’m still here", onClick = {}, variant = ButtonVariant.Text) }
            HeroScoreCard(72, listOf(HeroTile("Estimated net estate", "R8.92m"), HeroTile("Signed will", "Version 2")), delta = "+28 since September")
            Row(horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3)) {
                QuickActionTile(LifaIcons.FileText, "Will", {}, Modifier.weight(1f))
                QuickActionTile(LifaIcons.House, "Assets", {}, Modifier.weight(1f))
                QuickActionTile(LifaIcons.ChartLine, "Simulate", {}, Modifier.weight(1f))
                QuickActionTile(LifaIcons.CreditCard, "Card", {}, Modifier.weight(1f))
            }
        }
        section("List rows") {
            LifaListRow("Name an alternate guardian", "Adds 3 points", RowIndicator.Warning, onClick = {})
            LifaListRow("Passport expires in 41 days", "Upload the new one before 17 Nov 2026", RowIndicator.Warning, onClick = {})
            LifaListRow("Sipho Mokoena", "Executor", leading = { LifaAvatar("SM") }, trailing = { LifaBadge("Accepted", BadgeTone.Success) })
            LifaListRow("Nomsa Dlamini", "Guardian for Lerato", leading = { LifaAvatar("ND", AvatarTone.Gold) }, trailing = { LifaBadge("Invite sent", BadgeTone.Warning) })
            LifaListRow("Hope Children’s Home", "Charity", leading = { LifaAvatar("HC", AvatarTone.Lavender) })
        }
        section("Progress") {
            Text("My will · Step 3 of 7", style = LifaTheme.type.caption, color = c.textMuted)
            StepProgress(3, 7)
            LifaProgressBar(3.2f, 10f, "Vault storage used")
            Text("3.2 of 10 GB", style = LifaTheme.type.caption, color = c.textMuted)
        }
        section("Text fields") {
            var mobile by remember { mutableStateOf("+27 82 555 0143") }
            var idNumber by remember { mutableStateOf("8702145800087") }
            var email by remember { mutableStateOf("thandi@") }
            LifaTextField("Mobile number", mobile, { mobile = it }, keyboardType = KeyboardType.Phone)
            LifaTextField("South African ID number", idNumber, { idNumber = it }, hint = "ID number format is valid", hintPositive = true, keyboardType = KeyboardType.Number)
            LifaTextField("Email", email, { email = it }, errorText = "Enter an email address like name@example.com", keyboardType = KeyboardType.Email)
            LifaCard {
                listOf(
                    Triple("SM", "Sipho Mokoena", "Spouse") to AvatarTone.Green,
                    Triple("LM", "Lerato Mokoena", "Daughter · 12 years") to AvatarTone.Gold,
                    Triple("KM", "Kabelo Mokoena", "Son · 25 years") to AvatarTone.Green,
                    Triple("HC", "Hope Children’s Home", "Charity") to AvatarTone.Lavender,
                ).forEach { (p, tone) ->
                    AllocationRow(p.first, tone, p.second, p.third, shares[p.first].orEmpty()) { shares[p.first] = it }
                }
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3)) {
                    LifaProgressBar(total.coerceAtMost(100).toFloat(), label = "Residue allocated", modifier = Modifier.weight(1f))
                    Text("$total% allocated", style = LifaTheme.type.label, color = c.leafText, modifier = Modifier.semantics { liveRegion = LiveRegionMode.Polite })
                }
            }
            if (total != 100) LifaCallout("Allocations total $total%; they must total 100%", CalloutTone.Critical)
            LifaCallout(
                "Lerato is under 18", CalloutTone.Warning,
                "A minor can’t take an inheritance directly. Without a trust, her share may go to the Guardian’s Fund until she turns 18.",
            ) { LifaButton("Learn about the Guardian’s Fund", onClick = {}, variant = ButtonVariant.Text) }
            LifaCallout("Stored in South Africa", CalloutTone.Info, "Your documents are encrypted with your own key.")
        }
        section("Choices") {
            OptionCards(
                "How are you married?",
                listOf(
                    ChoiceOption("not_married", "Not married"), ChoiceOption("in_community", "In community of property"),
                    ChoiceOption("accrual", "Out of community, with accrual"), ChoiceOption("no_accrual", "Out of community, no accrual"),
                    ChoiceOption("customary", "Customary marriage"),
                ),
                regime,
            ) { regime = it }
            SegmentedControl("Ask me every", listOf(ChoiceOption("30", "30 days"), ChoiceOption("60", "60 days"), ChoiceOption("90", "90 days")), interval) { interval = it }
            SegmentedControl("Billing period", listOf(ChoiceOption("monthly", "Monthly"), ChoiceOption("yearly", "Yearly · save 17%")), billing) { billing = it }
            LifaCard {
                LifaSwitchRow("Pause while I travel", pause, { pause = it }, "Up to 180 days")
                Text("Show on the card", style = LifaTheme.type.label, color = c.text)
                cardFields.keys.toList().forEach { k -> LifaCheckboxRow(k, cardFields[k] == true) { cardFields[k] = it } }
            }
        }
        section("Navigation") {
            LifaTabBar(
                listOf(
                    TabItem("home", "Home", LifaIcons.House), TabItem("will", "Will", LifaIcons.FileText), TabItem("vault", "Vault", LifaIcons.Lock),
                    TabItem("family", "Family", LifaIcons.Users), TabItem("account", "Account", LifaIcons.User),
                ),
                tab,
                { tab = it },
            )
        }
        section("Disclosures") {
            LifaDisclosure("Lifa is not a law firm and does not give legal advice.")
            LifaDisclosure("Education only. Lifa does not recommend financial products.")
        }
    }
}

private fun androidx.compose.foundation.lazy.LazyListScope.section(title: String, content: @Composable () -> Unit) {
    item(key = title) {
        Column(verticalArrangement = Arrangement.spacedBy(LifaSpace.space4), modifier = Modifier.fillMaxWidth()) {
            Text(title, style = LifaTheme.type.title2, color = LifaTheme.colors.text, modifier = Modifier.semantics { heading() })
            content()
        }
    }
}

private fun swatches(s: za.co.lifa.design.generated.LifaColorScheme): List<Pair<String, Color>> = listOf(
    "background" to s.background, "surface" to s.surface, "line" to s.line, "lineStrong" to s.lineStrong, "text" to s.text,
    "textMuted" to s.textMuted, "primary" to s.primary, "onPrimary" to s.onPrimary, "hero" to s.hero, "heroInset" to s.heroInset,
    "heroAccent" to s.heroAccent, "goldText" to s.goldText, "goldSoft" to s.goldSoft, "leaf" to s.leaf, "leafText" to s.leafText,
    "leafSoft" to s.leafSoft, "warning" to s.warning, "warningText" to s.warningText, "warningSoft" to s.warningSoft,
    "critical" to s.critical, "criticalSoft" to s.criticalSoft, "focus" to s.focus,
)
