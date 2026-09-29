import Foundation

/// Seat is a completed two-second hold. The gesture lives on the cluster;
/// this type is the domain result of that hold.
enum SeatHold: Equatable, Sendable {
    static let duration: TimeInterval = 2
    case filed
    case refused(ClusterRefusal)
}

enum ClusterRefusal: Equatable, Sendable {
    case invalidLimit
    case seatOnOpen
    case seatOnOver
    case thirdSeat
    case unbraced
    case atLimit
}
