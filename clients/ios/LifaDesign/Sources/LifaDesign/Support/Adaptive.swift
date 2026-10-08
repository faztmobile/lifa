import SwiftUI

/// A row that becomes a column at accessibility text sizes (Dynamic Type AX1–AX5), so side-by-side
/// controls never squeeze their labels into broken words (NFR-ACC-001).
public struct LifaAdaptiveStack<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    let spacing: CGFloat; let content: Content
    public init(spacing: CGFloat = LifaSpace.space3, @ViewBuilder content: () -> Content) { self.spacing = spacing; self.content = content() }
    public var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: spacing))
            : AnyLayout(HStackLayout(spacing: spacing))
        layout { content }
    }
}

/// Home quick actions: four across, two across at accessibility text sizes.
public struct QuickActionGrid<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: LifaSpace.space3), count: typeSize.isAccessibilitySize ? 2 : 4)
        LazyVGrid(columns: columns, spacing: LifaSpace.space3) { content }
    }
}
