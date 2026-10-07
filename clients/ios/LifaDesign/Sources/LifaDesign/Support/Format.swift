import Foundation

/// How a figure is known (FRS principle 4, FR-AST-004).
public enum ValueBasis: String, Sendable, CaseIterable {
    case declared = "Declared", evidenced = "Evidenced", estimated = "Estimated"
}

/// "R8,920,000", "−R2,230,000"; compact: "R8.92m", "R510k". Same rules as web format.ts and Android Format.kt.
public func formatZar(cents: Int64, compact: Bool = false) -> String {
    let rands = (Double(cents) / 100).rounded()
    let sign = rands < 0 ? "\u{2212}" : ""
    let a = abs(rands)
    func trim(_ v: Double) -> String {
        let r = (v * 100).rounded() / 100
        return r == r.rounded() ? String(Int(r)) : String(format: "%g", r)
    }
    if compact && a >= 1_000_000 { return "\(sign)R\(trim(a / 1_000_000))m" }
    if compact && a >= 1_000 { return "\(sign)R\(trim(a / 1_000))k" }
    let f = NumberFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.numberStyle = .decimal
    f.groupingSeparator = ","
    f.usesGroupingSeparator = true
    f.maximumFractionDigits = 0
    return "\(sign)R\(f.string(from: NSNumber(value: a)) ?? String(Int(a)))"
}

/// "17 Nov 2026" (SA date format, NFR-LOC-001).
public func formatDate(year: Int, month: Int, day: Int) -> String {
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    return "\(day) \(months[month - 1]) \(year)"
}
