package za.co.lifa.design

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf
import za.co.lifa.design.generated.LifaColorScheme
import za.co.lifa.design.generated.LifaDarkColors
import za.co.lifa.design.generated.LifaLightColors
import za.co.lifa.design.generated.LifaTypeScale

internal val LocalLifaColors = staticCompositionLocalOf { LifaLightColors }

/** Access to the Lifa theme from components: `LifaTheme.colors.primary`, `LifaTheme.type.body`. */
object LifaTheme {
    val colors: LifaColorScheme
        @Composable @ReadOnlyComposable get() = LocalLifaColors.current
    val type = LifaTypeScale
}

/**
 * Root theme. Follows the system dark setting by default (brief: support dark mode).
 * Material 3 is mapped from the Lifa tokens so platform widgets (dialogs, snackbars, pickers) match.
 */
@Composable
fun LifaTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    val c = if (darkTheme) LifaDarkColors else LifaLightColors
    val material = if (darkTheme) {
        darkColorScheme(
            primary = c.primary, onPrimary = c.onPrimary, background = c.background, onBackground = c.text,
            surface = c.surface, onSurface = c.text, onSurfaceVariant = c.textMuted, outline = c.lineStrong,
            outlineVariant = c.line, error = c.critical, errorContainer = c.criticalSoft, scrim = c.scrim,
        )
    } else {
        lightColorScheme(
            primary = c.primary, onPrimary = c.onPrimary, background = c.background, onBackground = c.text,
            surface = c.surface, onSurface = c.text, onSurfaceVariant = c.textMuted, outline = c.lineStrong,
            outlineVariant = c.line, error = c.critical, errorContainer = c.criticalSoft, scrim = c.scrim,
        )
    }
    val typography = Typography(
        displayLarge = LifaTypeScale.display,
        headlineMedium = LifaTypeScale.title1,
        titleLarge = LifaTypeScale.title2,
        titleMedium = LifaTypeScale.title3,
        bodyLarge = LifaTypeScale.body,
        bodyMedium = LifaTypeScale.body,
        labelLarge = LifaTypeScale.button,
        labelMedium = LifaTypeScale.label,
        bodySmall = LifaTypeScale.caption,
        labelSmall = LifaTypeScale.overline,
    )
    CompositionLocalProvider(LocalLifaColors provides c) {
        MaterialTheme(colorScheme = material, typography = typography, content = content)
    }
}
