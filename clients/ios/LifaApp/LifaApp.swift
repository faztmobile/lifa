import SwiftUI
import LifaDesign

/// Step 2: the app opens the design-system gallery. With `-LifaDemo <id>` it opens one demo journey screen instead
/// (sample data, used for the end-to-end screenshots). Feature navigation replaces both in step 4.
@main
struct LifaApp: App {
    init() { LifaFonts.register() }
    var body: some Scene {
        WindowGroup {
            if let demo = UserDefaults.standard.string(forKey: "LifaDemo") {
                DemoScreen(id: demo)
            } else {
                LifaGalleryView(theme: ProcessInfo.processInfo.arguments.contains("-LifaForceDark") ? .dark : .system)
            }
        }
    }
}
