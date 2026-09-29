import Foundation

/// Bracing is 85 percent of the Limit. The band is a threshold, not a stored total.
enum BracingBand {
    static let percent = 85

    static func threshold(limit: Int) -> Int {
        (limit * percent) / 100
    }

    /// True when today's filed units sit in the warning band and still under the Limit.
    static func contains(total: Int, limit: Int) -> Bool {
        guard limit > 0, total > 0 else { return false }
        return total >= threshold(limit: limit) && total < limit
    }
}
