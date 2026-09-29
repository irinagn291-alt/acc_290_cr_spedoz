import Foundation

/// A Tick attempted at or above the Limit. Adds no unit and folds the day to Over.
struct OverMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var daykey: Int
    var filedAt: Date
}
