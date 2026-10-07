import Testing
@testable import LifaDesign

@Suite("Format") struct FormatTests {
    @Test func zarMatchesWebAndAndroid() {
        #expect(formatZar(cents: 892_000_000) == "R8,920,000")
        #expect(formatZar(cents: -223_000_000) == "\u{2212}R2,230,000")
        #expect(formatZar(cents: 892_000_000, compact: true) == "R8.92m")
        #expect(formatZar(cents: 51_000_000, compact: true) == "R510k")
    }
    @Test func saDate() { #expect(formatDate(year: 2026, month: 11, day: 17) == "17 Nov 2026") }
}

@Suite("Resources") struct ResourceTests {
    @Test func everyFontIsBundled() {
        for name in lifaFontFiles { #expect(Bundle.module.url(forResource: name, withExtension: "ttf") != nil, "\(name).ttf") }
    }
    @Test func typeScaleUsesBundledFonts() {
        let styles = [LifaTypography.display, LifaTypography.title1, LifaTypography.body, LifaTypography.caption]
        for s in styles { #expect(lifaFontFiles.contains(s.fontName)) }
    }
}
