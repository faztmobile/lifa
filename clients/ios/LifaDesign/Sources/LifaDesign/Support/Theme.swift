import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import CoreText

extension Color {
    /// A colour that resolves to `light` or `dark` with the current trait collection (brief: support dark mode).
    static func lifaDynamic(light: (UInt32, alpha: Double), dark: (UInt32, alpha: Double)) -> Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { traits in
            let (hex, alpha) = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
                           blue: CGFloat(hex & 0xFF) / 255, alpha: alpha)
        })
        #else
        let (hex, alpha) = light
        return Color(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255, opacity: alpha)
        #endif
    }
}

/// A text style from the token type scale. Sizes scale with Dynamic Type relative to `relativeTo` (NFR-ACC-001).
public struct LifaTextStyle: Sendable {
    public let fontName: String
    public let size: CGFloat
    public let lineHeight: CGFloat
    public let tracking: CGFloat
    public let relativeTo: Font.TextStyle

    public var font: Font { .custom(fontName, size: size, relativeTo: relativeTo) }
}

private struct LifaTextStyleModifier: ViewModifier {
    let style: LifaTextStyle
    @ScaledMetric private var extraLineSpacing: CGFloat

    init(style: LifaTextStyle) {
        self.style = style
        _extraLineSpacing = ScaledMetric(wrappedValue: max(0, style.lineHeight - style.size * 1.2), relativeTo: style.relativeTo)
    }

    func body(content: Content) -> some View {
        content.font(style.font).tracking(style.tracking).lineSpacing(extraLineSpacing)
    }
}

extension View {
    /// Applies a Lifa text style: font, tracking and line spacing, all scaled with Dynamic Type.
    public func lifaText(_ style: LifaTextStyle) -> some View { modifier(LifaTextStyleModifier(style: style)) }
}

/// Registers the bundled Sora and DM Sans fonts. Call once at app start (LifaApp does).
public enum LifaFonts {
    public static func register() {
        for name in lifaFontFiles {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf") else {
                assertionFailure("Missing bundled font \(name).ttf")
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
