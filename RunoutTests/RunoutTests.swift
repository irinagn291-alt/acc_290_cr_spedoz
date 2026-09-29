import XCTest
@testable import Runout

@MainActor
final class RunoutTests: XCTestCase {
    private var suite = ""
    private var defaults: UserDefaults?

    override func setUp() {
        super.setUp()
        suite = "rou.tests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)
    }

    override func tearDown() {
        if !suite.isEmpty {
            defaults?.removePersistentDomain(forName: suite)
        }
        defaults = nil
        super.tearDown()
    }

    func testFamilyInvariantOneUnitAgainstCapacity() {
        let limit = LimitGauge(units: 100, unitLabel: "units")
        XCTAssertEqual(BracingBand.threshold(limit: limit.units), 85)
        var day = ClusterDay.bare(daykey: 20260922)
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let (filed, verb) = ClusterFold.tick(day: day, limit: limit, now: now, id: UUID())
        XCTAssertEqual(verb, .filed)
        XCTAssertEqual(filed.unitTotal, 1)
        XCTAssertEqual(filed.phase, .open)
        day = filed
        XCTAssertEqual(day.runs.count, day.unitTotal)
    }

    func testTickEmptyBareAndInvalidLimit() {
        let bare = ClusterDay.bare(daykey: 20260101)
        let invalid = LimitGauge(units: 0, unitLabel: "units")
        let (unchanged, refused) = ClusterFold.tick(day: bare, limit: invalid, now: .now, id: UUID())
        XCTAssertEqual(refused, .refused(.invalidLimit))
        XCTAssertEqual(unchanged, bare)

        let blankLabel = LimitGauge(units: 8, unitLabel: " ")
        XCTAssertEqual(ClusterFold.tick(day: bare, limit: blankLabel, now: .now, id: UUID()).1, .refused(.invalidLimit))

        let (filed, verb) = ClusterFold.tick(
            day: bare,
            limit: .standard,
            now: .now,
            id: UUID()
        )
        XCTAssertEqual(verb, .filed)
        XCTAssertEqual(filed.phase, .open)
        XCTAssertEqual(filed.unitTotal, 1)
    }

    func testPopulatedTicksStayOpenBelowBracing() {
        let limit = LimitGauge(units: 100, unitLabel: "pours")
        var day = ClusterDay.bare(daykey: 20260901)
        for index in 0..<84 {
            let (next, verb) = ClusterFold.tick(day: day, limit: limit, now: .now, id: UUID())
            XCTAssertEqual(verb, .filed, "tick \(index)")
            day = next
        }
        XCTAssertEqual(day.unitTotal, 84)
        XCTAssertEqual(day.phase, .open)
        XCTAssertTrue(day.wobbles.isEmpty)
    }

    func testSeatThenTickAtBracing() {
        let limit = LimitGauge(units: 100, unitLabel: "units")
        var day = ClusterDay.bare(daykey: 20260922)
        for _ in 0..<84 {
            day = ClusterFold.tick(day: day, limit: limit, now: .now, id: UUID()).0
        }
        let (crossed, crossVerb) = ClusterFold.tick(day: day, limit: limit, now: .now, id: UUID())
        XCTAssertEqual(crossVerb, .filed)
        XCTAssertEqual(crossed.unitTotal, 85)
        XCTAssertEqual(crossed.phase, .braced)
        day = crossed

        let (wobbled, wobble) = ClusterFold.tick(day: day, limit: limit, now: .now, id: UUID())
        XCTAssertEqual(wobble, .refused(.unbraced))
        XCTAssertEqual(wobbled.unitTotal, 85)
        XCTAssertEqual(wobbled.wobbles.count, 1)
        XCTAssertEqual(wobbled.phase, .braced)
        day = wobbled

        let (opened, seat) = ClusterFold.seat(day: day, limit: limit, now: .now, id: UUID())
        XCTAssertEqual(seat, .filed)
        XCTAssertEqual(opened.phase, .open)
        XCTAssertTrue(opened.seatPulse)
        XCTAssertEqual(opened.seats.count, 1)
        day = opened

        let (afterPulse, filed) = ClusterFold.tick(day: day, limit: limit, now: .now, id: UUID())
        XCTAssertEqual(filed, .filed)
        XCTAssertEqual(afterPulse.unitTotal, 86)
        XCTAssertEqual(afterPulse.phase, .braced)
        XCTAssertFalse(afterPulse.seatPulse)
        day = afterPulse

        day = ClusterFold.seat(day: day, limit: limit, now: .now, id: UUID()).0
        XCTAssertEqual(day.seats.count, 2)
        day = ClusterFold.tick(day: day, limit: limit, now: .now, id: UUID()).0
        let (blocked, third) = ClusterFold.seat(day: day, limit: limit, now: .now, id: UUID())
        XCTAssertEqual(third, .refused(.thirdSeat))
        XCTAssertEqual(blocked.seats.count, 2)
    }

    func testSeatOnOpenAndOverAreRefused() {
        let limit = LimitGauge(units: 10, unitLabel: "units")
        let open = ClusterFold.tick(day: .bare(daykey: 1), limit: limit, now: .now, id: UUID()).0
        XCTAssertEqual(ClusterFold.seat(day: open, limit: limit, now: .now, id: UUID()).1, .refused(.seatOnOpen))

        var day = ClusterDay.bare(daykey: 2)
        var guardTicks = 0
        while day.phase != .over && guardTicks < 20 {
            guardTicks += 1
            let (ticked, verb) = ClusterFold.tick(day: day, limit: limit, now: .now, id: UUID())
            if verb == .refused(.unbraced) {
                let (seated, seat) = ClusterFold.seat(day: ticked, limit: limit, now: .now, id: UUID())
                XCTAssertEqual(seat, .filed)
                day = seated
            } else {
                day = ticked
            }
        }
        XCTAssertEqual(day.phase, .over)
        XCTAssertEqual(day.unitTotal, 10)
        let (still, overTick) = ClusterFold.tick(day: day, limit: limit, now: .now, id: UUID())
        XCTAssertEqual(overTick, .refused(.atLimit))
        XCTAssertEqual(still.unitTotal, 10)
        XCTAssertEqual(still.overs.count, 1)
        XCTAssertEqual(ClusterFold.seat(day: still, limit: limit, now: .now, id: UUID()).1, .refused(.seatOnOver))
    }

    func testFoldPatternBareOpenBracedOver() {
        XCTAssertEqual(ClusterFold.phase(forTotal: 0, limit: 20), .bare)
        XCTAssertEqual(ClusterFold.phase(forTotal: 16, limit: 20), .open)
        XCTAssertEqual(BracingBand.threshold(limit: 20), 17)
        XCTAssertEqual(ClusterFold.phase(forTotal: 17, limit: 20), .braced)
        XCTAssertEqual(ClusterFold.phase(forTotal: 20, limit: 20), .over)
    }

    func testDaykeyUsesStartOfDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        var parts = DateComponents()
        parts.year = 2026
        parts.month = 9
        parts.day = 22
        parts.hour = 23
        parts.minute = 30
        parts.timeZone = calendar.timeZone
        let evening = calendar.date(from: parts) ?? Date()
        XCTAssertEqual(Daykey.make(from: evening, calendar: calendar), 20260922)
    }

    func testPersistenceRoundTripAndReset() async {
        guard let defaults else {
            XCTFail("Suite defaults unavailable")
            return
        }
        let cabinet = ChartCabinet(defaults: defaults, debounce: .milliseconds(20))
        let calendar = Calendar(identifier: .gregorian)
        var parts = DateComponents()
        parts.year = 2026
        parts.month = 4
        parts.day = 2
        parts.timeZone = calendar.timeZone
        let date = calendar.date(from: parts) ?? Date()
        cabinet.updateLimit(LimitGauge(units: 100, unitLabel: "marks"))
        XCTAssertEqual(cabinet.tick(on: date, id: UUID(), calendar: calendar), .filed)
        await cabinet.flush()

        let reloaded = ChartCabinet(defaults: defaults)
        XCTAssertEqual(reloaded.root.limit.units, 100)
        XCTAssertEqual(reloaded.root.limit.unitLabel, "marks")
        XCTAssertEqual(reloaded.day(for: date, calendar: calendar).unitTotal, 1)
        XCTAssertEqual(reloaded.root.schemaVersion, 1)
        XCTAssertNil(reloaded.loadNotice)

        reloaded.resetAllData()
        XCTAssertNil(defaults.data(forKey: ChartCabinet.storageKey))
        let afterReset = ChartCabinet(defaults: defaults)
        XCTAssertTrue(afterReset.root.days.isEmpty)
        XCTAssertEqual(afterReset.root.limit, .standard)
    }

    func testCorruptPayloadKeepsBackupOrStartsEmpty() {
        guard let defaults else {
            XCTFail("Suite defaults unavailable")
            return
        }
        let good = ChartRoot(
            schemaVersion: 1,
            limit: LimitGauge(units: 12, unitLabel: "units"),
            days: [.bare(daykey: 20260102)]
        )
        guard case .success(let payload) = ChartCoding.encode(good) else {
            XCTFail("Encode failed")
            return
        }
        defaults.set(payload, forKey: ChartCabinet.backupKey)
        defaults.set(Data("not-json".utf8), forKey: ChartCabinet.storageKey)
        let recovered = ChartCabinet(defaults: defaults)
        XCTAssertEqual(recovered.loadNotice, .recoveredBackup)
        XCTAssertEqual(recovered.root.limit.units, 12)
        XCTAssertEqual(defaults.data(forKey: ChartCabinet.storageKey), Data("not-json".utf8))

        defaults.set(Data("also-bad".utf8), forKey: ChartCabinet.backupKey)
        let empty = ChartCabinet(defaults: defaults)
        XCTAssertEqual(empty.loadNotice, .startedEmpty)
        XCTAssertTrue(empty.root.days.isEmpty)
    }

    func testDebounceDoesNotLetStaleWriteWin() async {
        guard let defaults else {
            XCTFail("Suite defaults unavailable")
            return
        }
        let cabinet = ChartCabinet(defaults: defaults, debounce: .milliseconds(80))
        cabinet.updateLimit(LimitGauge(units: 4, unitLabel: "a"))
        cabinet.updateLimit(LimitGauge(units: 9, unitLabel: "b"))
        do {
            try await Task.sleep(for: .milliseconds(200))
        } catch {
            XCTFail("Debounce wait was cancelled")
            return
        }
        let reloaded = ChartCabinet(defaults: defaults)
        XCTAssertEqual(reloaded.root.limit.units, 9)
        XCTAssertEqual(reloaded.root.limit.unitLabel, "b")
    }

    func testReviewLaunchParsesOnce() {
        XCTAssertEqual(ReviewLaunch.parse(["-ReviewScreen", "today"]), .today)
        XCTAssertEqual(ReviewLaunch.parse(["-ReviewScreen", "log"]), .log)
        XCTAssertEqual(ReviewLaunch.parse(["-ReviewScreen", "goals"]), .goals)
        XCTAssertEqual(ReviewLaunch.parse(["-ReviewScreen", "history"]), .history)
        XCTAssertEqual(ReviewLaunch.parse(["app", "-ReviewScreen", "settings"]), .settings)
        XCTAssertNil(ReviewLaunch.parse(["-ReviewScreen"]))
        XCTAssertNil(ReviewLaunch.parse(["-ReviewScreen", "game"]))
    }

    func testHistoryRowsUsePlainMarkNames() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let id = UUID()
        var day = ClusterDay.bare(daykey: 20260922)
        day.runs = [RunMark(id: id, daykey: day.daykey, filedAt: now)]
        day.seats = [SeatMark(id: id, daykey: day.daykey, filedAt: now)]
        day.wobbles = [WobbleMark(id: id, daykey: day.daykey, filedAt: now)]
        day.overs = [OverMark(id: id, daykey: day.daykey, filedAt: now)]
        let titles = Set(HistoryScreen.lines(from: [day]).map(\.0))
        XCTAssertEqual(titles, ["Run mark", "Seat mark", "Wobble mark", "Over mark"])
    }

    func testUnbracedTickMovesFigureNeedleAndNextTap() {
        let limit = LimitGauge(units: 100, unitLabel: "units")
        var day = ClusterDay.bare(daykey: 20260922)
        for _ in 0..<85 {
            day = ClusterFold.tick(day: day, limit: limit, now: .now, id: UUID()).0
        }
        let beforeFigure = ClusterHomeScreen.figureLine(day: day, limit: limit)
        let beforeTap = ClusterHomeScreen.nextTapLine(day: day, limit: limit)
        let plate = NeedlePlate()
        plate.bind(total: day.unitTotal, limit: limit.units, phase: day.phase, wobbles: 0)
        let (wobbled, verb) = ClusterFold.tick(day: day, limit: limit, now: .now, id: UUID())
        XCTAssertEqual(verb, .refused(.unbraced))
        XCTAssertEqual(wobbled.unitTotal, day.unitTotal)
        XCTAssertNotEqual(ClusterHomeScreen.figureLine(day: wobbled, limit: limit), beforeFigure)
        XCTAssertNotEqual(ClusterHomeScreen.nextTapLine(day: wobbled, limit: limit), beforeTap)
        plate.bind(total: wobbled.unitTotal, limit: limit.units, phase: wobbled.phase, wobbles: wobbled.wobbles.count)
        XCTAssertEqual(plate.wobbles, 1)
        let again = ClusterFold.tick(day: wobbled, limit: limit, now: .now, id: UUID()).0
        XCTAssertNotEqual(ClusterHomeScreen.figureLine(day: again, limit: limit), ClusterHomeScreen.figureLine(day: wobbled, limit: limit))
        XCTAssertNotEqual(ClusterHomeScreen.nextTapLine(day: again, limit: limit), ClusterHomeScreen.nextTapLine(day: wobbled, limit: limit))
    }

    func testSettingsChartErrorShowsWhenTheLimitIsValid() {
        XCTAssertTrue(SettingsScreen.showsChartError(writeFailed: true))
        XCTAssertFalse(SettingsScreen.showsChartError(writeFailed: false))
    }

    func testUnsupportedSchemaDoesNotCrash() {
        let raw = #"{"schemaVersion":9,"limit":{"units":1,"unitLabel":"u"},"days":[]}"#
        let decoded = ChartCoding.decode(Data(raw.utf8))
        guard case .failure = decoded else {
            XCTFail("Unsupported schema should fail closed")
            return
        }
    }
}
