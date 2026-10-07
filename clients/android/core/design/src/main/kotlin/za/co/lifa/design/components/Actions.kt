package za.co.lifa.design.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import za.co.lifa.design.LifaTheme
import za.co.lifa.design.generated.LifaIcons
import za.co.lifa.design.generated.LifaRadius
import za.co.lifa.design.generated.LifaSize
import za.co.lifa.design.generated.LifaSpace

/** Lucide icon tinted from the theme. Pass contentDescription only when the icon carries meaning on its own. */
@Composable
fun LifaIcon(
    icon: LifaIcons,
    contentDescription: String?,
    modifier: Modifier = Modifier,
    tint: Color = LifaTheme.colors.text,
    size: Dp = LifaSize.icon,
) {
    Icon(painterResource(icon.res), contentDescription, modifier.size(size), tint = tint)
}

enum class ButtonVariant { Primary, Secondary, Text, Destructive, Dashed }

/**
 * Button. Material's clickable Surface guarantees the 48 dp minimum touch target (Android guidance, LifaSize.touchMinAndroid);
 * full-size buttons are 56 dp tall as on the reference screens.
 */
@Composable
fun LifaButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    variant: ButtonVariant = ButtonVariant.Primary,
    enabled: Boolean = true,
    loading: Boolean = false,
    compact: Boolean = false,
    leadingIcon: LifaIcons? = null,
) {
    val c = LifaTheme.colors
    val (bg, fg, border) = when (variant) {
        ButtonVariant.Primary -> Triple(c.primary, c.onPrimary, null)
        ButtonVariant.Secondary -> Triple(c.surface, c.primary, BorderStroke(LifaSize.border, c.lineStrong))
        ButtonVariant.Text -> Triple(Color.Transparent, c.primary, null)
        ButtonVariant.Destructive -> Triple(c.critical, c.surface, null)
        ButtonVariant.Dashed -> Triple(Color.Transparent, c.text, BorderStroke(LifaSize.border, c.lineStrong))
    }
    Surface(
        onClick = onClick,
        enabled = enabled && !loading,
        shape = RoundedCornerShape(LifaRadius.md),
        color = bg,
        contentColor = fg,
        border = border,
        modifier = modifier
            .heightIn(min = if (compact || variant == ButtonVariant.Text) LifaSize.touchMinAndroid else LifaSize.buttonHeight)
            .semantics { if (loading) stateDescription = "Loading" },
    ) {
        Row(
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(
                horizontal = if (variant == ButtonVariant.Text) 0.dp else if (compact) LifaSpace.space4 else LifaSpace.space6,
                vertical = LifaSpace.space2,
            ),
        ) {
            if (loading) {
                CircularProgressIndicator(color = fg, strokeWidth = 2.dp, modifier = Modifier.size(18.dp))
                Spacer(Modifier.width(LifaSpace.space2))
            } else if (leadingIcon != null) {
                LifaIcon(leadingIcon, null, tint = fg, size = 20.dp)
                Spacer(Modifier.width(LifaSpace.space2))
            }
            Text(
                text,
                style = if (variant == ButtonVariant.Dashed) LifaTheme.type.label else LifaTheme.type.button,
                color = if (enabled) fg else fg.copy(alpha = 0.5f),
                textAlign = if (variant == ButtonVariant.Text) TextAlign.Start else TextAlign.Center,
                textDecoration = if (variant == ButtonVariant.Text) TextDecoration.Underline else null,
            )
        }
    }
}

/** Home quick action (Will, Assets, Simulate, Card). */
@Composable
fun QuickActionTile(icon: LifaIcons, label: String, onClick: () -> Unit, modifier: Modifier = Modifier) {
    val c = LifaTheme.colors
    Surface(
        onClick = onClick,
        shape = RoundedCornerShape(LifaRadius.md),
        color = c.surface,
        border = BorderStroke(LifaSize.border, c.line),
        modifier = modifier,
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(LifaSpace.space2),
            modifier = Modifier.padding(vertical = LifaSpace.space4, horizontal = LifaSpace.space2),
        ) {
            LifaIcon(icon, null, tint = c.primary)
            Text(label, style = LifaTheme.type.label, color = c.text, textAlign = TextAlign.Center)
        }
    }
}

data class TabItem(val key: String, val label: String, val icon: LifaIcons)

/** Bottom tab bar: Home, Will, Vault, Family, Account (brief). */
@Composable
fun LifaTabBar(items: List<TabItem>, selected: String, onSelect: (String) -> Unit, modifier: Modifier = Modifier) {
    val c = LifaTheme.colors
    Surface(color = c.surface, border = BorderStroke(LifaSize.border, c.line), modifier = modifier.fillMaxWidth()) {
        Row(Modifier.selectableGroup()) {
            items.forEach { item ->
                val isSelected = item.key == selected
                val tint = if (isSelected) c.primary else c.textMuted
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier
                        .weight(1f)
                        .heightIn(min = LifaSize.tabBarHeight)
                        .selectable(selected = isSelected, onClick = { onSelect(item.key) }, role = Role.Tab)
                        .padding(vertical = LifaSpace.space2),
                ) {
                    LifaIcon(item.icon, null, tint = tint)
                    Text(
                        item.label,
                        style = LifaTheme.type.caption,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                        color = tint,
                        textAlign = TextAlign.Center,
                    )
                }
            }
        }
    }
}
