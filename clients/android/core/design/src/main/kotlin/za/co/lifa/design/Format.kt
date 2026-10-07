package za.co.lifa.design

import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.time.LocalDate
import java.util.Locale
import kotlin.math.abs
import kotlin.math.roundToLong

/** How a figure is known (FRS principle 4, FR-AST-004). */
enum class ValueBasis { Declared, Evidenced, Estimated }

private val whole = DecimalFormat("#,##0", DecimalFormatSymbols(Locale.US))
private val compactFmt = DecimalFormat("0.##", DecimalFormatSymbols(Locale.US))

/** "R8,920,000", "−R2,230,000"; compact: "R8.92m", "R510k" (as on the reference screens). Same rules as web format.ts. */
fun formatZar(cents: Long, compact: Boolean = false): String {
    val rands = (cents / 100.0).roundToLong()
    val sign = if (rands < 0) "−" else ""
    val a = abs(rands)
    return when {
        compact && a >= 1_000_000 -> "${sign}R${compactFmt.format(a / 1_000_000.0)}m"
        compact && a >= 1_000 -> "${sign}R${compactFmt.format(a / 1_000.0)}k"
        else -> "${sign}R${whole.format(a)}"
    }
}

private val months = listOf("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

/** "17 Nov 2026" (SA date format, NFR-LOC-001). */
fun formatDate(date: LocalDate): String = "${date.dayOfMonth} ${months[date.monthValue - 1]} ${date.year}"
