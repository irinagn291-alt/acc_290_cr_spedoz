import SwiftUI

/// SwiftUI aliases for the asset palette. Hex lives in the catalog; GaugeChrome is the only reader.
enum DesignTokens {
    static var background: Color { Color(uiColor: GaugeChrome.background) }
    static var surface: Color { Color(uiColor: GaugeChrome.surface) }
    static var ink: Color { Color(uiColor: GaugeChrome.ink) }
    static var accent: Color { Color(uiColor: GaugeChrome.accent) }
    static var muted: Color { Color(uiColor: GaugeChrome.muted) }
}
