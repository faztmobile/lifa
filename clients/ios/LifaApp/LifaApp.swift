import SwiftUI
import LifaDesign

/// Step 2: the app opens the design-system gallery. Feature navigation replaces this in step 4.
@main
struct LifaApp: App {
    init() { LifaFonts.register() }
    var body: some Scene {
        WindowGroup {
            LifaGalleryView(theme: ProcessInfo.processInfo.arguments.contains("-LifaForceDark") ? .dark : .system)
        }
    }
}
