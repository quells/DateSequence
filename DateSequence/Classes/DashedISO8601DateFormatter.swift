import Foundation

/// A helper that parses and generates dash-separated date strings using the ISO-8601 standard.
/// For example, 2018-05-12.
///
/// - Note: Always uses the UTC time zone
public struct DashedISO8601DateFormatter {
    private static var formatter: ISO8601DateFormatter! = nil
    
    /// A DateFormatter singleton that handles dash-separated date strings using the ISO-8601 standard.
    ///
    /// - SeeAlso: `ISO8601DateFormatter`, `DateFormatter`
    ///
    /// - Note: Always uses the UTC time zone
    public static var shared: ISO8601DateFormatter {
        get {
            if let formatter = formatter { return formatter }
            let df = ISO8601DateFormatter()
            df.formatOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]
            df.timeZone = TimeZone(abbreviation: "UTC")!
            formatter = df
            return formatter
        }
    }
}
