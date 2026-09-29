import Foundation

/// A filed unit. One RunMark is one tick that stayed under the Limit.
struct RunMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var daykey: Int
    var filedAt: Date
}
