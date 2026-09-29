import UIKit

/// Surface that sits above the screen. Shadow only. The needle plate is the one drawn hero.
final class RaisedCard: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = GaugeChrome.surface
        layer.cornerRadius = GaugeChrome.Radius.card
        GaugeChrome.applyShadow(layer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: GaugeChrome.Radius.card).cgPath
    }
}

/// Typed palette, type, radius, and elevation. Screens read tokens only through here.
enum GaugeChrome {
    static let unit: CGFloat = 8

    /// Catalog names, with the SPEC palette as the fallback inside this accessor.
    static let backgroundHex = "#284833"
    static let surfaceHex = "#385742"
    static let inkHex = "#F4F6F4"
    static let accentHex = "#79D898"
    static let mutedHex = "#B6C3BA"

    enum Radius {
        static let card: CGFloat = 20
        static let chip: CGFloat = 12
    }

    static var background: UIColor { named("background", hex: backgroundHex) }
    static var surface: UIColor { named("surface", hex: surfaceHex) }
    static var ink: UIColor { named("ink", hex: inkHex) }
    static var accent: UIColor { named("accent", hex: accentHex) }
    static var muted: UIColor { named("muted", hex: mutedHex) }

    static func space(_ steps: CGFloat) -> CGFloat { unit * steps }

    static func applyShadow(_ layer: CALayer) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.28
        layer.shadowOffset = CGSize(width: 0, height: space(1))
        layer.shadowRadius = Radius.chip
        layer.masksToBounds = false
    }

    static func display(for traits: UITraitCollection) -> UIFont {
        let huge = traits.preferredContentSizeCategory >= .accessibilityExtraExtraLarge
        return scaled(.largeTitle, bold: !huge, traits: traits, dropTo: huge ? .title2 : nil)
    }

    static func title(for traits: UITraitCollection) -> UIFont {
        scaled(.title2, bold: true, traits: traits, dropTo: nil)
    }

    static func headline(for traits: UITraitCollection) -> UIFont {
        scaled(.title3, bold: true, traits: traits, dropTo: nil)
    }

    static func body(for traits: UITraitCollection) -> UIFont {
        scaled(.body, bold: false, traits: traits, dropTo: nil)
    }

    static func callout(for traits: UITraitCollection) -> UIFont {
        scaled(.callout, bold: false, traits: traits, dropTo: nil)
    }

    static func caption(for traits: UITraitCollection) -> UIFont {
        scaled(.caption1, bold: false, traits: traits, dropTo: nil)
    }

    static func count(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func percent(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0%"
    }

    static func monospaced(_ font: UIFont) -> UIFont {
        let descriptor = font.fontDescriptor.addingAttributes([
            .featureSettings: [[
                UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
                UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector
            ]]
        ])
        return UIFont(descriptor: descriptor, size: font.pointSize)
    }

    @MainActor
    static func filledButton(_ title: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.cornerStyle = .fixed
        config.background.cornerRadius = Radius.chip
        config.baseBackgroundColor = accent
        config.baseForegroundColor = background
        config.contentInsets = NSDirectionalEdgeInsets(
            top: space(1),
            leading: space(2),
            bottom: space(1),
            trailing: space(2)
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = GaugeChrome.body(for: .current)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.tintColor = accent
        button.titleLabel?.font = body(for: .current)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        button.configurationUpdateHandler = { item in
            let pressed = item.isHighlighted && item.isEnabled
            let scale: CGFloat = pressed && !UIAccessibility.isReduceMotionEnabled ? 0.97 : 1
            item.transform = CGAffineTransform(scaleX: scale, y: scale)
            item.alpha = item.isEnabled ? 1 : 0.45
        }
        return button
    }

    /// Navigation row. Surface fill, card radius, not the accent verb.
    @MainActor
    static func rowButton(_ title: String, symbol: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: symbol)
        config.imagePlacement = .leading
        config.imagePadding = space(2)
        config.cornerStyle = .fixed
        config.background.cornerRadius = Radius.chip
        config.baseBackgroundColor = background
        config.baseForegroundColor = ink
        config.contentInsets = NSDirectionalEdgeInsets(
            top: space(2),
            leading: space(2),
            bottom: space(2),
            trailing: space(2)
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = GaugeChrome.body(for: .current)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .leading
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        button.configurationUpdateHandler = { item in
            let pressed = item.isHighlighted && item.isEnabled
            item.alpha = item.isEnabled ? (pressed ? 0.72 : 1) : 0.45
        }
        return button
    }

    @MainActor
    static func reveal(_ views: [UIView]) {
        let reduce = UIAccessibility.isReduceMotionEnabled
        for (index, view) in views.enumerated() {
            view.alpha = 0
            let delay = reduce ? 0 : min(Double(index) * 0.05, 0.26)
            UIView.animate(withDuration: reduce ? 0.2 : 0.1, delay: delay, options: [.curveEaseOut]) {
                view.alpha = 1
            }
        }
    }

    private static func named(_ name: String, hex: String) -> UIColor {
        if let catalog = UIColor(named: name) {
            return catalog
        }
        var raw = hex
        if raw.hasPrefix("#") {
            raw.removeFirst()
        }
        var value: UInt64 = 0
        Scanner(string: raw).scanHexInt64(&value)
        return UIColor(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }

    private static func scaled(
        _ style: UIFont.TextStyle,
        bold: Bool,
        traits: UITraitCollection,
        dropTo: UIFont.TextStyle?
    ) -> UIFont {
        let resolved = dropTo ?? style
        let sample = UIFont.preferredFont(forTextStyle: resolved, compatibleWith: traits)
        let named = UIFont(name: bold ? "Georgia-Bold" : "Georgia", size: max(sample.pointSize, 12))
        let base = named ?? sample
        return UIFontMetrics(forTextStyle: resolved).scaledFont(for: base, compatibleWith: traits)
    }
}
