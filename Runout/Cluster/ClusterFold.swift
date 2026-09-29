import Foundation

/// Quota ADT. The cluster is a fold over today's ticks: Bare, Open, Braced, or Over.
/// Tick and Seat are the only transitions. The unit total is the count of RunMarks.
enum ClusterPhase: String, Codable, Equatable, Sendable {
    case bare
    case open
    case braced
    case over
}

/// Metric record for one daykey. Marks are stored; the unit total is derived.
struct ClusterDay: Codable, Equatable, Sendable, Identifiable {
    var daykey: Int
    var phase: ClusterPhase
    var runs: [RunMark]
    var seats: [SeatMark]
    var wobbles: [WobbleMark]
    var overs: [OverMark]
    /// Seat folded Braced to Open for exactly one following Tick.
    var seatPulse: Bool

    var id: Int { daykey }
    var unitTotal: Int { runs.count }

    static func bare(daykey: Int) -> ClusterDay {
        ClusterDay(
            daykey: daykey,
            phase: .bare,
            runs: [],
            seats: [],
            wobbles: [],
            overs: [],
            seatPulse: false
        )
    }
}

enum Daykey {
    static func make(from date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }
}

enum ClusterFold {
    static func tick(
        day: ClusterDay,
        limit: LimitGauge,
        now: Date,
        id: UUID
    ) -> (ClusterDay, TickVerb) {
        guard limit.isValid else {
            return (day, .refused(.invalidLimit))
        }
        var next = day
        if next.unitTotal >= limit.units || next.phase == .over {
            next.overs.append(OverMark(id: id, daykey: day.daykey, filedAt: now))
            next.phase = .over
            next.seatPulse = false
            return (next, .refused(.atLimit))
        }
        let belowBand = next.unitTotal < BracingBand.threshold(limit: limit.units)
        let mayFile = next.unitTotal == 0 || belowBand || next.seatPulse
        if mayFile {
            next.runs.append(RunMark(id: id, daykey: day.daykey, filedAt: now))
            next.seatPulse = false
            next.phase = phase(forTotal: next.unitTotal, limit: limit.units)
            return (next, .filed)
        }
        next.wobbles.append(WobbleMark(id: id, daykey: day.daykey, filedAt: now))
        next.phase = .braced
        next.seatPulse = false
        return (next, .refused(.unbraced))
    }

    static func seat(
        day: ClusterDay,
        limit: LimitGauge,
        now: Date,
        id: UUID
    ) -> (ClusterDay, SeatHold) {
        guard limit.isValid else {
            return (day, .refused(.invalidLimit))
        }
        var next = day
        if next.phase == .over || next.unitTotal >= limit.units {
            return (next, .refused(.seatOnOver))
        }
        if next.phase != .braced || next.seatPulse {
            return (next, .refused(.seatOnOpen))
        }
        if next.seats.count >= 2 {
            return (next, .refused(.thirdSeat))
        }
        next.seats.append(SeatMark(id: id, daykey: day.daykey, filedAt: now))
        next.seatPulse = true
        next.phase = .open
        return (next, .filed)
    }

    static func phase(forTotal total: Int, limit: Int) -> ClusterPhase {
        if total <= 0 { return .bare }
        if total >= limit { return .over }
        if total >= BracingBand.threshold(limit: limit) { return .braced }
        return .open
    }
}
