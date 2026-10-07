package za.co.lifa.design.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.RadioButton
import androidx.compose.material3.RadioButtonDefaults
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.error
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import za.co.lifa.design.LifaTheme
import za.co.lifa.design.generated.LifaRadius
import za.co.lifa.design.generated.LifaSize
import za.co.lifa.design.generated.LifaSpace

/**
 * Text field with a visible label, hint and error. The label is also the accessible name; errors are announced
 * through the semantics error property. Border uses line-strong (3:1, WCAG 1.4.11).
 */
@Composable
fun LifaTextField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    hint: String? = null,
    hintPositive: Boolean = false,
    errorText: String? = null,
    suffix: String? = null,
    keyboardType: KeyboardType = KeyboardType.Text,
    compact: Boolean = false,
    showLabel: Boolean = true,
) {
    val c = LifaTheme.colors
    var focused by remember { mutableStateOf(false) }
    val borderColor = when {
        focused -> c.focus
        errorText != null -> c.critical
        else -> c.lineStrong
    }
    Column(modifier, verticalArrangement = Arrangement.spacedBy(LifaSpace.space1)) {
        if (showLabel) Text(label, style = LifaTheme.type.label, color = c.text, modifier = Modifier.clearAndSetSemantics {})
        BasicTextField(
            value = value,
            onValueChange = onValueChange,
            singleLine = true,
            textStyle = LifaTheme.type.body.copy(color = c.text, textAlign = if (compact) TextAlign.End else TextAlign.Start),
            cursorBrush = SolidColor(c.primary),
            keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
            modifier = Modifier
                .onFocusChanged { focused = it.isFocused }
                .semantics {
                    contentDescription = label
                    if (errorText != null) error(errorText)
                },
            decorationBox = { inner ->
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(LifaSpace.space2),
                    modifier = Modifier
                        .then(if (compact) Modifier.width(96.dp) else Modifier.fillMaxWidth())
                        .heightIn(min = if (compact) LifaSize.touchMinAndroid else LifaSize.inputHeight)
                        .clip(RoundedCornerShape(LifaRadius.sm))
                        .background(c.surface)
                        .border(if (focused) LifaSize.focusRing else LifaSize.border, borderColor, RoundedCornerShape(LifaRadius.sm))
                        .padding(horizontal = if (compact) LifaSpace.space3 else LifaSpace.space4),
                ) {
                    Box(Modifier.weight(1f)) { inner() }
                    if (suffix != null) Text(suffix, style = LifaTheme.type.body, color = c.textMuted, modifier = Modifier.clearAndSetSemantics {})
                }
            },
        )
        if (hint != null) Text(hint, style = LifaTheme.type.caption, color = if (hintPositive) c.leafText else c.textMuted)
        if (errorText != null) Text(errorText, style = LifaTheme.type.caption, color = c.critical)
    }
}

/** One person's residue share (FR-WIL-003). Wraps at large font scales. */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun AllocationRow(initials: String, tone: AvatarTone, name: String, detail: String, value: String, onValueChange: (String) -> Unit) {
    FlowRow(
        horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3),
        verticalArrangement = Arrangement.spacedBy(LifaSpace.space2),
        modifier = Modifier.fillMaxWidth(),
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3),
            modifier = Modifier.weight(1f).widthIn(min = 160.dp).align(Alignment.CenterVertically),
        ) {
            LifaAvatar(initials, tone)
            Column {
                Text(name, style = LifaTheme.type.bodyStrong, color = LifaTheme.colors.text)
                Text(detail, style = LifaTheme.type.caption, color = LifaTheme.colors.textMuted)
            }
        }
        LifaTextField(
            label = "Share for $name", value = value, onValueChange = onValueChange, suffix = "%",
            keyboardType = KeyboardType.Decimal, compact = true, showLabel = false,
        )
    }
}

data class ChoiceOption(val value: String, val label: String, val hint: String? = null)

/** Single choice as cards, for example "How are you married?" (FR-WIL-002). */
@Composable
fun OptionCards(legend: String, options: List<ChoiceOption>, selected: String?, onSelect: (String) -> Unit) {
    val c = LifaTheme.colors
    Column(verticalArrangement = Arrangement.spacedBy(LifaSpace.space3)) {
        Text(legend, style = LifaTheme.type.label, color = c.text, modifier = Modifier.semantics { heading() })
        Column(Modifier.selectableGroup(), verticalArrangement = Arrangement.spacedBy(LifaSpace.space3)) {
            options.forEach { o ->
                val isSelected = o.value == selected
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3),
                    modifier = Modifier
                        .fillMaxWidth()
                        .heightIn(min = LifaSize.inputHeight)
                        .clip(RoundedCornerShape(LifaRadius.md))
                        .background(c.surface)
                        .border(if (isSelected) 2.dp else LifaSize.border, if (isSelected) c.primary else c.lineStrong, RoundedCornerShape(LifaRadius.md))
                        .selectable(selected = isSelected, onClick = { onSelect(o.value) }, role = Role.RadioButton)
                        .padding(horizontal = LifaSpace.space4, vertical = LifaSpace.space3),
                ) {
                    RadioButton(selected = isSelected, onClick = null, colors = RadioButtonDefaults.colors(selectedColor = c.primary, unselectedColor = c.lineStrong))
                    Column {
                        Text(o.label, style = LifaTheme.type.body, color = c.text)
                        if (o.hint != null) Text(o.hint, style = LifaTheme.type.caption, color = c.textMuted)
                    }
                }
            }
        }
    }
}

/** Segmented control (30/60/90 days; Monthly/Yearly). Wraps when labels do not fit at large font scales. */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun SegmentedControl(label: String, options: List<ChoiceOption>, selected: String, onSelect: (String) -> Unit) {
    val c = LifaTheme.colors
    FlowRow(
        horizontalArrangement = Arrangement.spacedBy(4.dp),
        verticalArrangement = Arrangement.spacedBy(4.dp),
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(LifaRadius.md))
            .background(c.background)
            .border(LifaSize.border, c.lineStrong, RoundedCornerShape(LifaRadius.md))
            .padding(4.dp)
            .selectableGroup()
            .semantics { contentDescription = label },
    ) {
        options.forEach { o ->
            val isSelected = o.value == selected
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .weight(1f)
                    .heightIn(min = LifaSize.touchMinAndroid)
                    .clip(RoundedCornerShape(LifaRadius.sm))
                    .background(if (isSelected) c.primary else c.background)
                    .selectable(selected = isSelected, onClick = { onSelect(o.value) }, role = Role.RadioButton)
                    .padding(horizontal = LifaSpace.space3),
            ) {
                Text(o.label, style = LifaTheme.type.label, color = if (isSelected) c.onPrimary else c.text, textAlign = TextAlign.Center)
            }
        }
    }
}

/** Switch row. The whole row is the 48 dp touch target and carries Role.Switch. */
@Composable
fun LifaSwitchRow(label: String, checked: Boolean, onCheckedChange: (Boolean) -> Unit, description: String? = null) {
    val c = LifaTheme.colors
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3),
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = LifaSize.touchMinAndroid)
            .toggleable(value = checked, onValueChange = onCheckedChange, role = Role.Switch),
    ) {
        Column(Modifier.weight(1f)) {
            Text(label, style = LifaTheme.type.body, color = c.text)
            if (description != null) Text(description, style = LifaTheme.type.caption, color = c.textMuted)
        }
        Switch(
            checked = checked,
            onCheckedChange = null,
            colors = SwitchDefaults.colors(
                checkedTrackColor = c.primary, checkedThumbColor = c.onPrimary,
                uncheckedTrackColor = c.surface, uncheckedBorderColor = c.lineStrong, uncheckedThumbColor = c.lineStrong,
            ),
        )
    }
}

@Composable
fun LifaCheckboxRow(label: String, checked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    val c = LifaTheme.colors
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(LifaSpace.space3),
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = LifaSize.touchMinAndroid)
            .toggleable(value = checked, onValueChange = onCheckedChange, role = Role.Checkbox),
    ) {
        Checkbox(checked = checked, onCheckedChange = null, colors = CheckboxDefaults.colors(checkedColor = c.primary, uncheckedColor = c.lineStrong, checkmarkColor = c.onPrimary))
        Text(label, style = LifaTheme.type.body, color = c.text)
    }
}
