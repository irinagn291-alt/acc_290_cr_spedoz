import Foundation

/// Capacity record for the quota fold. The daily Limit and the unit label
/// are the only capacity the cluster measures against. Bracing is derived.
struct LimitGauge: Codable, Equatable, Sendable {
    var units: Int
    var unitLabel: String

    static let standard = LimitGauge(units: 10, unitLabel: "units")

    var isValid: Bool { units > 0 && !unitLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}
