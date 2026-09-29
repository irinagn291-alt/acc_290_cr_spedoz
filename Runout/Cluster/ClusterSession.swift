import Foundation
import UIKit

/// Presentation seam over the chart cabinet. Screens fold through this type and never touch UserDefaults.
@MainActor
final class ClusterSession {
    nonisolated static let onboardKey = "rou.onboarding.done"
    nonisolated static let demoKey = "rou.demo.v1"

    let cabinet: ChartCabinet
    private let defaults: UserDefaults
    private var observers: [UUID: () -> Void] = [:]
    private var launchConsumed = false
    private var pendingReview: ReviewScreen?

    init(cabinet: ChartCabinet, defaults: UserDefaults = .standard) {
        self.cabinet = cabinet
        self.defaults = defaults
        DemoSeed.applyIfNeeded(to: cabinet, defaults: defaults)
        if isOnboarded {
            captureLaunch()
        }
    }

    var isOnboarded: Bool { defaults.bool(forKey: Self.onboardKey) }

    var today: ClusterDay { cabinet.day(for: Date()) }

    var limit: LimitGauge { cabinet.root.limit }

    var writeFailed: Bool { cabinet.writeFailed }

    var loadNotice: ChartLoadNotice? { cabinet.loadNotice }

    func observe(_ body: @escaping () -> Void) -> UUID {
        let token = UUID()
        observers[token] = body
        return token
    }

    func removeObserver(_ token: UUID) {
        observers.removeValue(forKey: token)
    }

    func tick() -> TickVerb {
        let verb = cabinet.tick(on: Date())
        notify()
        return verb
    }

    func seat() -> SeatHold {
        let verb = cabinet.seat(on: Date())
        notify()
        return verb
    }

    func updateLimit(_ limit: LimitGauge) {
        cabinet.updateLimit(limit)
        notify()
    }

    func resetAllData() {
        cabinet.resetAllData()
        notify()
    }

    func completeOnboarding(limit: LimitGauge) {
        if cabinet.root.days.isEmpty {
            cabinet.updateLimit(limit)
        }
        defaults.set(true, forKey: Self.onboardKey)
        captureLaunch()
        notify()
    }

    func rerunOnboarding() {
        defaults.set(false, forKey: Self.onboardKey)
        notify()
    }

    /// Parsed once, only after onboarding, then cleared.
    func takeReviewScreen() -> ReviewScreen? {
        let screen = pendingReview
        pendingReview = nil
        return screen
    }

    private func captureLaunch() {
        guard !launchConsumed else { return }
        launchConsumed = true
        pendingReview = ReviewLaunch.parse()
    }

    private func notify() {
        observers.values.forEach { $0() }
    }
}

@MainActor
enum DemoSeed {
    /// Simulator only. Files prior days and today at 84 percent so Tick is the opening verb.
    static func applyIfNeeded(to cabinet: ChartCabinet, defaults: UserDefaults) {
        #if targetEnvironment(simulator)
        guard !defaults.bool(forKey: ClusterSession.demoKey) else { return }
        defaults.set(true, forKey: ClusterSession.demoKey)
        defaults.set(true, forKey: ClusterSession.onboardKey)
        let limit = LimitGauge(units: 100, unitLabel: "units")
        cabinet.updateLimit(limit)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        file(runs: 40, on: calendar.date(byAdding: .day, value: -3, to: today), cabinet: cabinet)
        fileBraced(on: calendar.date(byAdding: .day, value: -2, to: today), cabinet: cabinet, limit: limit)
        fileSeated(on: calendar.date(byAdding: .day, value: -1, to: today), cabinet: cabinet, limit: limit)
        let opening = (limit.units * 84) / 100
        file(runs: opening, on: today, cabinet: cabinet)
        #endif
    }

    private static func file(runs: Int, on date: Date?, cabinet: ChartCabinet) {
        guard let date else { return }
        for _ in 0..<runs {
            _ = cabinet.tick(on: date)
        }
    }

    private static func fileBraced(on date: Date?, cabinet: ChartCabinet, limit: LimitGauge) {
        guard let date else { return }
        let band = BracingBand.threshold(limit: limit.units)
        file(runs: band, on: date, cabinet: cabinet)
        _ = cabinet.tick(on: date)
    }

    private static func fileSeated(on date: Date?, cabinet: ChartCabinet, limit: LimitGauge) {
        guard let date else { return }
        let band = BracingBand.threshold(limit: limit.units)
        file(runs: band, on: date, cabinet: cabinet)
        _ = cabinet.seat(on: date)
        _ = cabinet.tick(on: date)
    }
}
