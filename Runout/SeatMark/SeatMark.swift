import Foundation

/// A completed two-second bezel hold while the cluster was Braced.
struct SeatMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var daykey: Int
    var filedAt: Date
}
