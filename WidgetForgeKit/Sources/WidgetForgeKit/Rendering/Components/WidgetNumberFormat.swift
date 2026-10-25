#if canImport(SwiftUI)
import Foundation

/// Formatting helpers shared by the count and metric components so large values
/// stay legible in tight cells. Values below 1,000 render in full (so hours,
/// small counts, and percentages are untouched); larger values abbreviate to
/// K / M / B with one significant decimal, trailing ".0" trimmed.
enum WidgetNumberFormat {
    /// Abbreviates an integer count. e.g. 1234 -> "1.2K", 4_500_000 -> "4.5M".
    static func abbreviate(_ value: Int) -> String {
        abbreviate(Double(value))
    }

    /// Abbreviates a metric value. Below 1,000 uses up to one fraction digit
    /// (37.5 -> "37.5", 12 -> "12"); at/above 1,000 abbreviates.
    static func abbreviate(_ value: Double) -> String {
        let magnitude = abs(value)
        if magnitude < 1_000 {
            return smallFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
        }
        let units: [(threshold: Double, suffix: String)] = [
            (1_000_000_000, "B"),
            (1_000_000, "M"),
            (1_000, "K"),
        ]
        for unit in units where magnitude >= unit.threshold {
            let scaled = value / unit.threshold
            let str = abbrevFormatter.string(from: NSNumber(value: scaled)) ?? "\(scaled)"
            return str + unit.suffix
        }
        return smallFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// Full value below 1,000: up to one fraction digit, grouped.
    private static let smallFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 1
        return f
    }()

    /// Scaled abbreviation: one fraction digit, no grouping ("1.2", "4.5").
    private static let abbrevFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 1
        f.usesGroupingSeparator = false
        return f
    }()
}
#endif
