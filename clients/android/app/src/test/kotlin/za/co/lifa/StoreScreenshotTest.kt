package za.co.lifa

import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onRoot
import androidx.compose.ui.test.performScrollToIndex
import com.github.takahirom.roborazzi.captureRoboImage
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Store screenshots: launches the real MainActivity of the flavour under test (gms or hms), so each image
 * shows that build's own shell and store label. Light and dark come from the system night mode.
 * Run: ./gradlew :app:testGmsDebugUnitTest :app:testHmsDebugUnitTest -Proborazzi.test.record=true
 */
abstract class StoreScreenshotTest(private val mode: String) {
    @get:Rule val compose = createAndroidComposeRule<MainActivity>()

    @Test fun storeScreenshots() {
        for (i in 0 until 12 step 2) {
            compose.onNodeWithTag("gallery").performScrollToIndex(i)
            compose.onRoot().captureRoboImage("build/outputs/roborazzi/${BuildConfig.FLAVOR}-$mode-$i.png")
        }
    }
}

@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [35], qualifiers = "w411dp-h914dp-notnight-xxhdpi")
class StoreScreenshotLightTest : StoreScreenshotTest("light")

@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [35], qualifiers = "w411dp-h914dp-night-xxhdpi")
class StoreScreenshotDarkTest : StoreScreenshotTest("dark")
