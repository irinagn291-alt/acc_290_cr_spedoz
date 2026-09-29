import UIKit

/// The one custom-drawn hero: needle readout and the bracing band, drawn together.
final class NeedlePlate: UIView {
    var total: Int = 0
    var limit: Int = 1
    var phase: ClusterPhase = .bare
    var wobbles: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = true
        backgroundColor = .clear
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        heightAnchor.constraint(equalToConstant: GaugeChrome.space(14)).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let plate = bounds.insetBy(dx: GaugeChrome.space(2), dy: GaugeChrome.space(1))
        layer.shadowPath = UIBezierPath(roundedRect: plate, cornerRadius: GaugeChrome.Radius.card).cgPath
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func bind(total: Int, limit: Int, phase: ClusterPhase, wobbles: Int) {
        self.total = total
        self.limit = max(limit, 1)
        self.phase = phase
        self.wobbles = wobbles
        let fraction = min(Double(total) / Double(self.limit), 1)
        var label = "Needle at \(GaugeChrome.percent(fraction)) of the daily limit. Bracing band."
        if wobbles > 0 {
            let word = wobbles == 1 ? "wobble" : "wobbles"
            label += " \(GaugeChrome.count(wobbles)) \(word), no unit added."
        }
        accessibilityLabel = label
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let plate = rect.insetBy(dx: GaugeChrome.space(2), dy: GaugeChrome.space(1))
        let radius = GaugeChrome.Radius.card
        let path = UIBezierPath(roundedRect: plate, cornerRadius: radius)
        context.saveGState()
        GaugeChrome.surface.setFill()
        path.fill()
        context.addPath(path.cgPath)
        context.clip()

        let colors = [GaugeChrome.background.cgColor, GaugeChrome.surface.cgColor, GaugeChrome.accent.withAlphaComponent(0.35).cgColor]
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 0.55, 1]) {
            context.drawLinearGradient(gradient, start: CGPoint(x: plate.minX, y: plate.minY), end: CGPoint(x: plate.maxX, y: plate.maxY), options: [])
        }
        context.restoreGState()

        let arcRadius = min(plate.width * 0.42, plate.height * 0.36)
        let center = CGPoint(x: plate.midX, y: plate.midY + arcRadius * 0.28)
        let start = CGFloat.pi
        let end = CGFloat.pi * 2
        let band = BracingBand.threshold(limit: limit)
        let bandFraction = CGFloat(band) / CGFloat(limit)
        let track = UIBezierPath(arcCenter: center, radius: arcRadius, startAngle: start, endAngle: end, clockwise: true)
        track.lineWidth = GaugeChrome.space(1)
        GaugeChrome.muted.setStroke()
        track.stroke()

        let bandStart = start + (end - start) * bandFraction
        let warning = UIBezierPath(arcCenter: center, radius: arcRadius, startAngle: bandStart, endAngle: end, clockwise: true)
        warning.lineWidth = GaugeChrome.space(1)
        GaugeChrome.accent.setStroke()
        warning.stroke()

        let fraction = min(CGFloat(total) / CGFloat(limit), 1)
        let angle = start + (end - start) * fraction
        let tip = CGPoint(x: center.x + cos(angle) * (arcRadius - GaugeChrome.space(1)), y: center.y + sin(angle) * (arcRadius - GaugeChrome.space(1)))
        let needle = UIBezierPath()
        needle.move(to: center)
        needle.addLine(to: tip)
        needle.lineWidth = GaugeChrome.space(1)
        needle.lineCapStyle = .round
        GaugeChrome.ink.setStroke()
        needle.stroke()

        let shown = min(wobbles, 6)
        if shown > 0 {
            for index in 0..<shown {
                let spread = CGFloat(index) - CGFloat(shown - 1) / 2
                let stubAngle = angle + spread * 0.18
                let inner = arcRadius * 0.55
                let outer = arcRadius * 0.72
                let stub = UIBezierPath()
                stub.move(to: CGPoint(x: center.x + cos(stubAngle) * inner, y: center.y + sin(stubAngle) * inner))
                stub.addLine(to: CGPoint(x: center.x + cos(stubAngle) * outer, y: center.y + sin(stubAngle) * outer))
                stub.lineWidth = GaugeChrome.space(1)
                stub.lineCapStyle = .round
                GaugeChrome.ink.setStroke()
                stub.stroke()
            }
        }

        let hubSize = GaugeChrome.space(2)
        let hub = UIBezierPath(ovalIn: CGRect(
            x: center.x - hubSize / 2,
            y: center.y - hubSize / 2,
            width: hubSize,
            height: hubSize
        ))
        GaugeChrome.accent.setFill()
        hub.fill()

        let word = "Bracing" as NSString
        let font = GaugeChrome.caption(for: traitCollection)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: GaugeChrome.ink
        ]
        let size = word.size(withAttributes: attributes)
        word.draw(at: CGPoint(x: plate.maxX - size.width - GaugeChrome.space(2), y: plate.minY + GaugeChrome.space(1)), withAttributes: attributes)
    }
}
