package za.co.lifa.design

import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.assertIsOff
import androidx.compose.ui.test.assertIsOn
import androidx.compose.ui.test.hasClickAction
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onRoot
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollToIndex
import androidx.compose.ui.test.performScrollToNode
import androidx.compose.ui.test.performTextReplacement
import com.github.takahirom.roborazzi.captureRoboImage
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import za.co.lifa.design.gallery.GalleryTheme
import za.co.lifa.design.gallery.LifaGallery

/**
 * Compose UI tests for the gallery (step 2), run on the JVM with Robolectric so CI needs no emulator.
 * Screenshots: ./gradlew :core:design:recordRoborazziDebug → core/design/build/outputs/roborazzi.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [35], qualifiers = "w411dp-h914dp-xxhdpi")
class GalleryTest {
    @get:Rule val compose = createComposeRule()

    private val sectionCount = 12 // header + 11 sections in LifaGallery

    @Test fun screenshotLight() {
        compose.setContent { LifaGallery(systemDark = false) }
        capturePages("light")
    }

    @Test fun screenshotDark() {
        compose.setContent { LifaGallery(systemDark = false, initialTheme = GalleryTheme.Dark) }
        capturePages("dark")
    }

    @Test fun screenshotFontScale200() {
        compose.setContent { LifaGallery(systemDark = false, initialFontScale = 2f) }
        capturePages("font200")
    }

    /** Every clickable node is at least 48 x 48 dp (Android guidance; brief requires 44 or more). */
    @Test fun touchTargetsAtLeast48dp() {
        compose.setContent { LifaGallery(systemDark = false) }
        val minPx = with(compose.density) { 48f * density } - 0.5f
        val tooSmall = mutableSetOf<String>()
        for (i in 0 until sectionCount) {
            compose.onNodeWithTag("gallery").performScrollToIndex(i)
            compose.onAllNodesWithClick().forEach { node ->
                // Measure the unclipped layout size: boundsInRoot is clipped by the scroll viewport, and
                // lazy items kept for reuse report 0 x 0 while not placed.
                if (!node.layoutInfo.isPlaced) return@forEach
                val b = node.size
                if (b.width < minPx || b.height < minPx) {
                    tooSmall += (node.config.getOrElseNullable(SemanticsProperties.Text) { null }?.joinToString()
                        ?: node.config.getOrElseNullable(SemanticsProperties.ContentDescription) { null }?.joinToString()
                        ?: "node ${node.id}") +
                        " ${b.width}x${b.height}px"
                }
            }
        }
        assertTrue("Touch targets under 48dp: $tooSmall", tooSmall.isEmpty())
    }

    @Test fun switchRowHasSwitchRoleAndToggles() {
        compose.setContent { LifaGallery(systemDark = false) }
        compose.onNodeWithTag("gallery").performScrollToNode(hasText("Pause while I travel", substring = true))
        val node = compose.onNode(hasText("Pause while I travel", substring = true) and hasClickAction())
        node.assertIsOff()
        node.performClick()
        node.assertIsOn()
    }

    /** AT-WIL-01 wording, shown by the gallery's allocation specimen. */
    @Test fun residueOver100ShowsBlockingMessage() {
        compose.setContent { LifaGallery(systemDark = false) }
        val gallery = compose.onNodeWithTag("gallery")
        listOf("Sipho Mokoena" to "60", "Lerato Mokoena" to "50", "Kabelo Mokoena" to "0", "Hope Children’s Home" to "0").forEach { (name, v) ->
            gallery.performScrollToNode(hasContentDescription("Share for $name"))
            compose.onNode(hasContentDescription("Share for $name")).performTextReplacement(v)
        }
        gallery.performScrollToNode(hasText("Allocations total 110%; they must total 100%"))
        compose.onNode(hasText("Allocations total 110%; they must total 100%")).assertExists()
    }

    private fun capturePages(name: String) {
        for (i in 0 until sectionCount step 2) {
            compose.onNodeWithTag("gallery").performScrollToIndex(i)
            compose.onRoot().captureRoboImage("build/outputs/roborazzi/gallery-$name-$i.png")
        }
    }

    private fun androidx.compose.ui.test.junit4.ComposeContentTestRule.onAllNodesWithClick() =
        onAllNodes(hasClickAction()).fetchSemanticsNodes()
}

class FormatTest {
    @Test fun zarMatchesWebFormatting() {
        assertEquals("R8,920,000", formatZar(892_000_000))
        assertEquals("−R2,230,000", formatZar(-223_000_000))
        assertEquals("R8.92m", formatZar(892_000_000, compact = true))
        assertEquals("R510k", formatZar(51_000_000, compact = true))
    }

    @Test fun saDate() {
        assertEquals("17 Nov 2026", formatDate(java.time.LocalDate.of(2026, 11, 17)))
    }
}
