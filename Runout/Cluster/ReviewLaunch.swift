import Foundation

/// Launch keys are not tabs. Parsed once after onboarding.
enum ReviewScreen: String, Equatable, Sendable {
    case today
    case log
    case goals
    case history
    case settings
}

enum ReviewLaunch {
    /// Reads `ProcessInfo` once. Call this only after onboarding.
    static func parse(_ arguments: [String] = ProcessInfo.processInfo.arguments) -> ReviewScreen? {
        guard let flag = arguments.firstIndex(of: "-ReviewScreen") else { return nil }
        let valueIndex = arguments.index(after: flag)
        guard valueIndex < arguments.endIndex else { return nil }
        return ReviewScreen(rawValue: arguments[valueIndex])
    }
}
