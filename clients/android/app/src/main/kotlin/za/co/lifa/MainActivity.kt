package za.co.lifa

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.ui.Modifier
import za.co.lifa.demo.DemoScreen
import za.co.lifa.design.LifaTheme
import za.co.lifa.design.gallery.LifaGallery

/**
 * Step 2: the app opens the design-system gallery. With the `lifa.demo` extra it opens one demo journey screen
 * instead (sample data, used for the end-to-end screenshots). Feature navigation replaces both in step 4.
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        val demo = intent.getStringExtra(EXTRA_DEMO)
        setContent {
            if (demo != null) {
                LifaTheme {
                    Box(Modifier.fillMaxSize().background(LifaTheme.colors.background).safeDrawingPadding()) { DemoScreen(demo) }
                }
            } else {
                Box(Modifier.safeDrawingPadding()) {
                    LifaGallery(systemDark = isSystemInDarkTheme(), platform = "Android · ${Distribution.STORE}")
                }
            }
        }
    }

    companion object {
        const val EXTRA_DEMO = "lifa.demo"
    }
}
