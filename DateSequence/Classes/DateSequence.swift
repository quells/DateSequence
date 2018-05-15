import Foundation

/// A generator for infinite and bounded `Date` sequences.
///
/// Intended for generating ISO-8601 date strings while ignoring inconvenient things like Daylight Savings Time,
/// so it uses the Gregorian calendar and UTC time zone
///
/// Correctness is not guaranteed for intervals shorter than one day, but it may still be useful for that level of granularity.
public class DateSequence: Sequence, IteratorProtocol {
    public typealias Element = Date
    
    public enum DGError: Error {
        /// The given string could not be parsed.
        case InvalidString(String)
        
        /// Intervals must be positive and non-zero.
        case InvalidInterval(Interval)
        
        /// The start date must be less than or equal to the end date.
        case InvalidBounds
        
        /// The end date was unexpectedly nil.
        case EndDateNotFound
        
        /// Some things are not possible.
        case InvalidRequest(String)
    }
    
    /// Quantity and units of the interval between elements.
    public typealias Interval = (quantity: Int, units: Calendar.Component)
    
    private var current: Date
    private let end: Date?
    private let shouldStop: (Date, Date?) -> Bool
    private let interval: Int
    private let intervalUnits: Calendar.Component
    
    public static var calendar: Calendar {
        get {
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone(abbreviation: "UTC")!
            return cal
        }
    }
    
    /// Parses date `String`s into `Date`s.
    ///
    /// Edit this function if a different input date format is desired.
    private static func parse(_ date: String) -> Date? {
        return DashedISO8601DateFormatter.shared.date(from: date)
    }
    
    /// Produces an infinite `Date` sequence.
    ///
    /// - Parameter starting: First date in the sequence.
    /// - Parameter every: Quantity and units of the interval between elements.
    ///
    /// - Throws: If the given date cannot be parsed.
    public init(starting startDate: String, every interval: Interval) throws {
        guard let start = DateSequence.parse(startDate) else { throw DGError.InvalidString(startDate) }
        
        self.current = start
        self.end = nil
        self.shouldStop = { _, _ in false }
        self.interval = interval.0
        self.intervalUnits = interval.1
    }
    
    /// Produces a bounded `Date` sequence.
    ///
    /// - Parameter start: First date in the sequence.
    /// - Parameter end: End date in the sequence. Inclusion in the sequence depends on `shouldStop`.
    /// - Parameter interval: Quantity of the interval between elements.
    /// - Parameter units: Units of the interval between elements.
    ///
    /// - Parameter shouldStop: Predicate determining whether the sequence should terminate.
    /// - Parameter currentDate: Current date element.
    /// - Parameter endDate: End date, which is nil for infinite sequences.
    ///
    /// - Throws: If the given dates cannot be parsed.
    internal init(_ start: String, _ end: String, _ interval: Int, _ units: Calendar.Component, shouldStop: @escaping (_ currentDate: Date, _ endDate: Date?) -> Bool) throws {
        guard let startDate = DateSequence.parse(start) else { throw DGError.InvalidString(start) }
        self.current = startDate
        
        guard let endDate = DateSequence.parse(end) else { throw DGError.InvalidString(end) }
        self.end = endDate
        
        guard endDate >= startDate else { throw DGError.InvalidBounds }
        guard interval > 0 else { throw DGError.InvalidInterval((interval, units)) }
        
        self.shouldStop = shouldStop
        self.interval = interval
        self.intervalUnits = units
    }
    
    /// Produces a bounded `Date` sequence which cannot include the specified end date.
    ///
    /// - Parameter start: First date in the sequence.
    /// - Parameter end: End date in the sequence. Cannot be included in the sequence.
    /// - Parameter every: Quantity and units of the interval between elements.
    ///
    /// - Throws: If the given dates cannot be parsed.
    public convenience init(from start: String, to end: String, every interval: Interval) throws {
        try self.init(start, end, interval.0, interval.1) { current, end in
            guard let end = end else { fatalError("end date cannot be nil") }
            return current >= end
        }
    }
    
    /// Produces a bounded `Date` sequence which might include the specified end date.
    ///
    /// - Parameter startDate: First date in the sequence.
    /// - Parameter endDate: End date in the sequence. Might be included if it is the last date in the sequence.
    /// - Parameter every: Quantity and units of the interval between elements.
    ///
    /// - Throws: If the given dates cannot be parsed.
    public convenience init(from startDate: String, through endDate: String, every interval: Interval) throws {
        try self.init(startDate, endDate, interval.0, interval.1) { current, end in
            guard let end = end else { fatalError("end date cannot be nil") }
            return current > end
        }
    }
    
    // MARK: Sequence Protocol Compliance
    
    public func next() -> Date? {
        let n = self.current
        
        if self.shouldStop(n, self.end) {
            return nil
        }
        
        self.current = DateSequence.calendar.date(byAdding: self.intervalUnits, value: self.interval, to: current)!
        return n
    }
    
    // MARK: Override Sequence Methods
    
    /// Returns a Boolean value indicating whether the sequence contains the given element.
    ///
    /// This method is non-destructive; the sequence will reset to the position before it was called.
    ///
    /// This method is semi-safe to use on infinite sequence since it is always ordered. It will only search dates up to the given one.
    ///
    /// - Parameter element: Date to search for.
    /// - Returns: Boolean value indicating whether the sequence contains the given element.
    public func contains(_ element: Date) -> Bool {
        let bookmark = self.current
        var found = false
        
        while let n = self.next(), n <= element {
            if n == element {
                found = true
                break
            }
        }
        
        self.current = bookmark
        return found
    }
    
    /// Returns a Boolean value indicating whether the sequence contains an element corresponding to the given value.
    ///
    /// This method is non-destructive; the sequence will reset to the position before it was called.
    ///
    /// This method is semi-safe to use on infinite sequence since it is always ordered. It will only search dates up to the given one.
    ///
    /// - Parameter element: Date to search for
    /// - Returns: Boolean value indicating whether the sequence contains an element corresponding to the given value.
    /// - Throws: If the given date cannot be parsed.
    ///
    /// - SeeAlso: `contains(Date)`
    public func contains(_ element: String) throws -> Bool {
        guard let date = DateSequence.parse(element) else { throw DGError.InvalidString(element) }
        return self.contains(date)
    }
    
    /// Returns a Boolean value indicating whether the sequence contains an element matching the given predicate.
    ///
    /// This method is non-destructive; the sequence will reset to the position before it was called.
    ///
    /// Note: This method is not safe to use on infinite sequence since no end date can be specified.
    ///
    /// - Parameter element: Date to search for
    /// - Returns: Boolean value indicating whether the sequence contains an element corresponding to the given value.
    public func contains(where predicate: (Date) throws -> Bool) throws -> Bool {
        guard let _ = end else { throw DGError.InvalidRequest("cannot guarantee an infinite sequence will return") }
        return try Array(self).contains(where: predicate)
    }
    
    /// Returns an array containing the sequence in reverse order. Cannot be used with infinite sequences.
    ///
    /// - Returns: The sequence in reverse order.
    /// - Throws: If the sequence is infinite.
    public func reversed() throws -> [Date] {
        guard let _ = self.end else { throw DGError.InvalidRequest("cannot reverse infinite sequence") }
        return Array(self).reversed()
    }
}
