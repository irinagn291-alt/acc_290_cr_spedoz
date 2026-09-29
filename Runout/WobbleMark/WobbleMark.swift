import Foundation

/// A Tick inside the bracing band with no Seat in that pulse. Adds no unit.
struct WobbleMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var daykey: Int
    var filedAt: Date
}
