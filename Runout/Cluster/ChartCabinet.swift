import Foundation
import os

/// In-memory fold is the source of truth. UserDefaults is a debounced projection.
/// Views talk to this seam and never to UserDefaults.
@MainActor
final class ChartCabinet {
    nonisolated static let storageKey = "rou.chart.root"
    nonisolated static let backupKey = "rou.chart.root.backup"

    private let defaults: UserDefaults
    private let debounce: Duration
    private let tasks = TaskHandle()
    private(set) var root: ChartRoot
    private(set) var loadNotice: ChartLoadNotice?
    private(set) var writeFailed = false
    private var generation = 0

    init(defaults: UserDefaults, debounce: Duration = .milliseconds(500)) {
        self.defaults = defaults
        self.debounce = debounce
        let loaded = ChartCabinet.load(from: defaults)
        root = loaded.root
        loadNotice = loaded.notice
    }

    deinit {
        tasks.cancel()
    }

    func day(for date: Date, calendar: Calendar = .current) -> ClusterDay {
        root.day(Daykey.make(from: date, calendar: calendar))
    }

    @discardableResult
    func tick(on date: Date, now: Date = .now, id: UUID = UUID(), calendar: Calendar = .current) -> TickVerb {
        let key = Daykey.make(from: date, calendar: calendar)
        let (next, verb) = ClusterFold.tick(day: root.day(key), limit: root.limit, now: now, id: id)
        root.replace(next)
        scheduleSave()
        return verb
    }

    @discardableResult
    func seat(on date: Date, now: Date = .now, id: UUID = UUID(), calendar: Calendar = .current) -> SeatHold {
        let key = Daykey.make(from: date, calendar: calendar)
        let (next, verb) = ClusterFold.seat(day: root.day(key), limit: root.limit, now: now, id: id)
        root.replace(next)
        scheduleSave()
        return verb
    }

    func updateLimit(_ limit: LimitGauge) {
        root.limit = limit
        scheduleSave()
    }

    /// Drops the chart key and the backup. Used by tests and Settings.
    func resetAllData() {
        generation += 1
        tasks.cancel()
        defaults.removeObject(forKey: Self.storageKey)
        defaults.removeObject(forKey: Self.backupKey)
        root = .empty
        loadNotice = nil
        writeFailed = false
    }

    func flush() async {
        generation += 1
        let generation = generation
        tasks.cancel()
        await write(generation)
    }

    func sceneBecameInactiveOrBackground() async {
        await flush()
    }

    private func scheduleSave() {
        generation += 1
        let generation = generation
        let wait = debounce
        tasks.store(Task { [weak self] in
            do {
                try await Task.sleep(for: wait)
            } catch {
                return
            }
            await self?.write(generation)
        })
    }

    private func write(_ generation: Int) async {
        guard generation == self.generation else { return }
        let snapshot = root
        let encoded = await ChartCabinet.encodeOffMain(snapshot)
        guard generation == self.generation else { return }
        guard let data = encoded else {
            writeFailed = true
            return
        }
        writeFailed = false
        if let previous = defaults.data(forKey: Self.storageKey),
           case .success = ChartCoding.decode(previous) {
            defaults.set(previous, forKey: Self.backupKey)
        }
        defaults.set(data, forKey: Self.storageKey)
    }

    /// Encoding leaves the main actor so a large chart cannot hitch the cluster.
    private static func encodeOffMain(_ snapshot: ChartRoot) async -> Data? {
        await Task.detached(priority: .utility) {
            switch ChartCoding.encode(snapshot) {
            case .success(let data):
                return data
            case .failure:
                return nil
            }
        }.value
    }

    private static func load(from defaults: UserDefaults) -> (root: ChartRoot, notice: ChartLoadNotice?) {
        if let data = defaults.data(forKey: storageKey) {
            switch ChartCoding.decode(data) {
            case .success(let root):
                return (root, nil)
            case .failure:
                break
            }
        } else {
            return (.empty, nil)
        }
        if let backup = defaults.data(forKey: backupKey) {
            switch ChartCoding.decode(backup) {
            case .success(let root):
                return (root, .recoveredBackup)
            case .failure:
                break
            }
        }
        return (.empty, .startedEmpty)
    }
}

/// Holds the debounce task so deinit can cancel it without touching main-actor state.
final class TaskHandle: Sendable {
    private let lock = OSAllocatedUnfairLock<Task<Void, Never>?>(initialState: nil)

    func store(_ task: Task<Void, Never>) {
        lock.withLock { current in
            current?.cancel()
            current = task
        }
    }

    func cancel() {
        lock.withLock { current in
            current?.cancel()
            current = nil
        }
    }
}
