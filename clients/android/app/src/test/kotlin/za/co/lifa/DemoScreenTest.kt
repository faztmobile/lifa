package za.co.lifa

import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onRoot
import com.github.takahirom.roborazzi.captureRoboImage
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import za.co.lifa.demo.DemoScreen
import za.co.lifa.demo.demoScreenIds
import za.co.lifa.design.LifaTheme

/** Renders every demo journey screen on the JVM, so a broken screen fails fast before the emulator capture runs. */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [35], qualifiers = "w412dp-h915dp-notnight-xxhdpi")
class DemoScreenTest {
    @get:Rule val compose = createComposeRule()

    @Test fun rendersEveryDemoScreen() {
        val id = mutableStateOf(demoScreenIds.first())
        compose.setContent { LifaTheme(darkTheme = false) { DemoScreen(id.value) } }
        demoScreenIds.forEachIndexed { i, screen ->
            compose.runOnIdle { id.value = screen }
            compose.waitForIdle()
            compose.onRoot().captureRoboImage("build/outputs/roborazzi/demo-${"%02d".format(i + 1)}-$screen.png")
        }
    }
}
