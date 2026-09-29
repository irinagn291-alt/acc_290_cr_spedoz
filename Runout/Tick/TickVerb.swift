import Foundation

/// Outcome of one Tick against the in-memory fold.
enum TickVerb: Equatable, Sendable {
    case filed
    case refused(ClusterRefusal)
}
