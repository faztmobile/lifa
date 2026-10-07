package za.co.lifa.design.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.ProgressBarRangeInfo
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.progressBarRangeInfo
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import za.co.lifa.design.LifaTheme
import za.co.lifa.design.ValueBasis
import za.co.lifa.design.formatZar
import za.co.lifa.design.generated.LifaIcons
import za.co.lifa.design.generated.LifaRadius
import za.co.lifa.design.generated.LifaSize
import za.co.lifa.design.generated.LifaSpace

enum class BadgeTone { Plan, Neutral, Success, Warning, Critical }

@Composable
fun LifaBadge(text: String, tone: BadgeTone = BadgeTone.Neutral, uppercase: Boolean = true) {
    val c = LifaTheme.colors
    val (bg, fg) = when (tone) {
        BadgeTone.Plan -> c.goldSoft to c.goldText
        BadgeTone.Neutral -> c.background to c.textMuted
        BadgeTone.Success -> c.leafSoft to c.leafText
        BadgeTone.Warning -> c.warningSoft to c.warningText
        BadgeTone.Critical -> c.criticalSoft to c.critical
    }
    Text(
        if (uppercase) text.uppercase() else text,
        style = if (uppercase) LifaTheme.type.overline else LifaTheme.type.caption,
        color = fg,
        modifier = Modifier
            .clip(RoundedCornerShape(LifaRadius.pill))
            .background(bg)
            .then(if (tone == BadgeTone.Neutral) Modifier.border(LifaSize.border, c.line, RoundedCornerShape(LifaRadius.pill)) else Modifier)
            .padding(horizontal = LifaSpace.space2, vertical = 2.dp),
    )
}

/** FRS principle 4: every figure shows whether it is declared, evidenced or estimated. */
@Composable
fun BasisBadge(basis: ValueBasis) {
    val tone = when (basis) {
        ValueBasis.Evidenced -> BadgeTone.Success
        ValueBasis.Estimated -> BadgeTone.Warning
        ValueBasis.Declared -> BadgeTone.Neutral
    }
    LifaBadge(basis.name, tone, uppercase = false)
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun LabelledValue(label: String, cents: Long, basis: ValueBasis, compact: Boolean = false) {
    Column {
        Text(label, style = LifaTheme.type.caption, color = LifaTheme.colors.textMuted)
        FlowRow(horizontalArrangement = Arrangement.spacedBy(LifaSpace.space2), verticalArrangement = Arrangement.Center) {
            Text(formatZar(cents, compact), style = LifaTheme.type.title2, color = LifaTheme.colors.text)
            Box(Modifier.align(Alignment.CenterVertically)) { BasisBadge(basis) }
        }
    }
}

@Composable
fun LifaCard(modifier: Modifier = Modifier, content: @Composable ColumnScope.() -> Unit) {
    val c = LifaTheme.colors
    Surface(shape = RoundedCornerShape(LifaRadius.lg), color = c.surface, border = BorderStroke(LifaSize.border, c.line), modifier = modifier.fillMaxWidth()) {
        Column(Modifier.padding(LifaSpace.space4), verticalArrangement = Arrangement.spacedBy(LifaSpace.space3), content = content)
    }
}

@Composable
fun LifaProgressBar(value: Float, max: Float = 100f, label: String, modifier: Modifier = Modifier, onHero: Boolean = false) {
    val c = LifaTheme.colors
    val fraction = (value / max).coerceIn(0f, 1f)
    Box(
        modifier
            .fillMaxWidth()
            .height(LifaSize.progressHeight)
            .clip(RoundedCornerShape(LifaRadius.pill))
            .background(if (onHero) c.heroInset else c.line)
            .semantics {
                contentDescription = label
                progressBarRangeInfo = ProgressBarRangeInfo(value, 0f..max)
            },
    ) {
        Box(Modifier.fillMaxWidth(fraction).height(LifaSize.progressHeight).clip(RoundedCornerShape(LifaRadius.pill)).background(if (onHero) c.heroAccent else c.leaf))
    }
}

/** Wizard progress, for example "My will · Step 3 of 7" (FR-WIL-001). */
@Composable
fun StepProgress(current: Int, total: Int, modifier: Modifier = Modifier) {
    val c = LifaTheme.colors
    Row(
        horizontalArrangement = Arrangement.spacedBy(LifaSpace.space1),
        modifier = modifier.fillMaxWidth().clearAndSetSemantics { contentDescription = "Step $current of $total" },
    ) {
        repeat(total) { i ->
            Box(Modifier.weight(1f).height(4.dp).clip(RoundedCornerShape(LifaRadius.pill)).background(if (i < current) c.primary else c.line))
        }
    }
}

data class HeroTile(val label: String, val value: String)

/** Home Legacy Score card (FR-SCR-002). */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun HeroScoreCard(score: Int, tiles: List<HeroTile>, delta: String? = null, modifier: Modifier = Modifier) {
    val c = LifaTheme.colors
    Surface(shape = RoundedCornerShape(LifaRadius.xl), color = c.hero, contentColor = c.onHero, modifier = modifier.fillMaxWidth()) {
        Column(Modifier.padding(LifaSpace.space5), verticalArrangement = Arrangement.spacedBy(LifaSpace.space4)) {
            Text("Legacy Score", style = LifaTheme.type.label, color = c.onHeroMuted, modifier = Modifier.semantics { heading() })
            FlowRow(horizontalArrangement = Arrangement.SpaceBetween, verticalArrangement = Arrangement.Bottom, modifier = Modifier.fillMaxWidth()) {
                Row(verticalAlignment = Alignment.Bottom, modifier = Modifier.semantics(mergeDescendants = true) {}) {
                    Text("$score", style = LifaTheme.type.display, color = c.onHero)
                    Text(" /100", style = LifaTheme.type.title2, color = c.onHeroMuted, modifier = Modifier.padding(bottom = 6.dp))
                }
                if (delta != null) {
                    Text(delta, style = LifaTheme.type.label, color = c.heroPositive, modifier = Modifier.align(Alignment.Bottom).padding(bottom = 8.dp))
                }
            }
            LifaProgressBar(score.toFloat(), label = "Legacy Score", onHero = true)
            FlowRow(horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3), verticalArrangement = Arrangement.spacedBy(LifaSpace.space3), maxItemsInEachRow = 2) {
                tiles.forEach { t ->
                    Column(
                        Modifier.weight(1f).widthIn(min = 120.dp).clip(RoundedCornerShape(LifaRadius.md)).background(c.heroInset).padding(LifaSpace.space3)
                            .semantics(mergeDescendants = true) {},
                    ) {
                        Text(t.label, style = LifaTheme.type.caption, color = c.onHeroMuted)
                        Text(t.value, style = LifaTheme.type.title2, color = c.onHero)
                    }
                }
            }
        }
    }
}

/** Slim banner, for example "Monthly check-in is due · I'm still here" (FR-DMS-002). */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun LifaBanner(text: String, icon: LifaIcons? = null, action: (@Composable () -> Unit)? = null) {
    val c = LifaTheme.colors
    FlowRow(
        horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3),
        verticalArrangement = Arrangement.Center,
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(LifaRadius.md)).background(c.leafSoft)
            .padding(horizontal = LifaSpace.space4, vertical = LifaSpace.space3),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3), modifier = Modifier.weight(1f).align(Alignment.CenterVertically)) {
            if (icon != null) LifaIcon(icon, null, size = 20.dp)
            Text(text, style = LifaTheme.type.body, color = c.text)
        }
        action?.invoke()
    }
}

enum class CalloutTone { Info, Warning, Critical }

@Composable
fun LifaCallout(title: String, tone: CalloutTone = CalloutTone.Info, body: String? = null, action: (@Composable () -> Unit)? = null) {
    val c = LifaTheme.colors
    val (bg, border, iconTint, icon) = when (tone) {
        CalloutTone.Info -> Quad(c.leafSoft, c.leafSoft, c.leafText, LifaIcons.Info)
        CalloutTone.Warning -> Quad(c.warningSoft, c.warning, c.warningText, LifaIcons.TriangleAlert)
        CalloutTone.Critical -> Quad(c.criticalSoft, c.critical, c.critical, LifaIcons.CircleAlert)
    }
    Row(
        horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3),
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(LifaRadius.lg)).background(bg)
            .border(LifaSize.border, border, RoundedCornerShape(LifaRadius.lg)).padding(LifaSpace.space4)
            .semantics { if (tone == CalloutTone.Critical) liveRegion = LiveRegionMode.Polite },
    ) {
        LifaIcon(icon, null, tint = iconTint, size = 22.dp)
        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(LifaSpace.space1)) {
            Text(title, style = LifaTheme.type.bodyStrong, color = c.text)
            if (body != null) Text(body, style = LifaTheme.type.body, color = c.text)
            action?.invoke()
        }
    }
}

private data class Quad<A, B, C, D>(val a: A, val b: B, val c: C, val d: D)

enum class RowIndicator { Warning, Critical, Success }

/** List row, for example "Name an alternate guardian · Adds 3 points". Clickable rows get a chevron. */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun LifaListRow(
    title: String,
    subtitle: String? = null,
    indicator: RowIndicator? = null,
    leading: (@Composable () -> Unit)? = null,
    trailing: (@Composable () -> Unit)? = null,
    onClick: (() -> Unit)? = null,
) {
    val c = LifaTheme.colors
    Surface(shape = RoundedCornerShape(LifaRadius.md), color = c.surface, border = BorderStroke(LifaSize.border, c.line), modifier = Modifier.fillMaxWidth()) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3),
            modifier = Modifier
                .then(if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier.semantics(mergeDescendants = true) {})
                .heightIn(min = LifaSize.touchMinAndroid)
                .padding(LifaSpace.space4),
        ) {
            if (indicator != null) {
                val dot = when (indicator) { RowIndicator.Warning -> c.warning; RowIndicator.Critical -> c.critical; RowIndicator.Success -> c.leaf }
                Box(Modifier.size(10.dp).clip(CircleShape).background(dot))
            }
            leading?.invoke()
            FlowRow(Modifier.weight(1f), horizontalArrangement = Arrangement.spacedBy(LifaSpace.space2), verticalArrangement = Arrangement.Center) {
                Column(Modifier.weight(1f, fill = false).widthIn(min = 120.dp)) {
                    Text(title, style = LifaTheme.type.bodyStrong, color = c.text)
                    if (subtitle != null) Text(subtitle, style = LifaTheme.type.label, color = c.textMuted)
                }
                if (trailing != null) Box(Modifier.align(Alignment.CenterVertically)) { trailing() }
            }
            if (onClick != null) LifaIcon(LifaIcons.ChevronRight, null, tint = c.textMuted, size = 20.dp)
        }
    }
}

enum class AvatarTone { Green, Gold, Lavender }

/** Initials avatar. Decorative: the person's name is always shown next to it. */
@Composable
fun LifaAvatar(initials: String, tone: AvatarTone = AvatarTone.Green) {
    val c = LifaTheme.colors
    val (bg, fg) = when (tone) {
        AvatarTone.Green -> c.avatarGreenBg to c.avatarGreenFg
        AvatarTone.Gold -> c.avatarGoldBg to c.avatarGoldFg
        AvatarTone.Lavender -> c.avatarLavenderBg to c.avatarLavenderFg
    }
    Box(contentAlignment = Alignment.Center, modifier = Modifier.size(LifaSize.avatar).clip(CircleShape).background(bg).clearAndSetSemantics {}) {
        Text(initials, style = LifaTheme.type.label, color = fg)
    }
}

/** Mandatory disclosure (FRS 12.2, FR-WIL-018). Text comes from content and is rendered verbatim. */
@Composable
fun LifaDisclosure(text: String) {
    Text(text, style = LifaTheme.type.caption, color = LifaTheme.colors.textMuted, textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth())
}

