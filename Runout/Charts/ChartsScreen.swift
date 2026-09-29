import UIKit

/// Adherence and bracing frequency drawn as the chart, with a return to Tick.
@MainActor
final class ChartsScreen: UIViewController {
    private let session: ClusterSession
    private let board = ChartBoard()
    private let adherenceLine = UILabel()
    private let bracingLine = UILabel()
    private let nextLine = UILabel()
    private let back = GaugeChrome.filledButton("Back to Tick")

    init(session: ClusterSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Charts"
        view.backgroundColor = GaugeChrome.background

        adherenceLine.font = GaugeChrome.headline(for: traitCollection)
        adherenceLine.textColor = GaugeChrome.ink
        adherenceLine.numberOfLines = 0
        bracingLine.font = GaugeChrome.body(for: traitCollection)
        bracingLine.textColor = GaugeChrome.ink
        bracingLine.numberOfLines = 0
        nextLine.font = GaugeChrome.body(for: traitCollection)
        nextLine.textColor = GaugeChrome.ink
        nextLine.numberOfLines = 0
        nextLine.text = "Next tap: Back to Tick. That returns you to today's measure."

        back.addTarget(self, action: #selector(returnToTick), for: .touchUpInside)
        back.accessibilityLabel = "Back to Tick"

        let stack = UIStackView(arrangedSubviews: [board, adherenceLine, bracingLine, nextLine, back])
        stack.axis = .vertical
        stack.spacing = GaugeChrome.space(2)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: GaugeChrome.space(2)),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -GaugeChrome.space(2)),
            stack.topAnchor.constraint(equalTo: guide.topAnchor, constant: GaugeChrome.space(2)),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: guide.bottomAnchor, constant: -GaugeChrome.space(2)),
            board.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.52),
            back.heightAnchor.constraint(greaterThanOrEqualToConstant: 52)
        ])
        reload()
    }

    private func reload() {
        if session.writeFailed {
            board.samples = []
            board.limit = session.limit.units
            board.band = BracingBand.threshold(limit: session.limit.units)
            adherenceLine.text = "Charts could not read a saved chart"
            bracingLine.text = "Stay with the cluster and file the next mark after the save recovers."
            board.setNeedsDisplay()
            return
        }
        let days = session.cabinet.root.days.sorted { $0.daykey < $1.daykey }
        board.samples = days.map { day in
            ChartSample(title: shortDay(day.daykey), units: day.unitTotal, braced: Self.enteredBand(day, limit: session.limit.units))
        }
        board.limit = max(session.limit.units, 1)
        board.band = BracingBand.threshold(limit: session.limit.units)
        board.setNeedsDisplay()
        if days.isEmpty {
            adherenceLine.text = "No trend yet. Tick a few days and the bars will show units against the limit."
            bracingLine.text = "Bracing frequency appears once a day enters the band."
        } else {
            adherenceLine.text = "Rolling adherence \(GaugeChrome.percent(adherence)). Each bar is one day. The mint line is the \(GaugeChrome.count(session.limit.units)) \(session.limit.unitLabel) limit. Bars that stop under it stayed inside."
            bracingLine.text = "Bracing frequency \(GaugeChrome.percent(bracingFrequency)). The pale band starts at \(GaugeChrome.count(board.band)) \(session.limit.unitLabel). A marked bar entered that band."
        }
    }

    private var adherence: Double {
        let days = session.cabinet.root.days.filter { $0.unitTotal > 0 }
        guard !days.isEmpty else { return 0 }
        let inside = days.filter { $0.unitTotal < session.limit.units }.count
        return Double(inside) / Double(days.count)
    }

    private var bracingFrequency: Double {
        let days = session.cabinet.root.days
        guard !days.isEmpty else { return 0 }
        let band = days.filter { Self.enteredBand($0, limit: session.limit.units) }.count
        return Double(band) / Double(days.count)
    }

    static func enteredBand(_ day: ClusterDay, limit: Int) -> Bool {
        BracingBand.contains(total: day.unitTotal, limit: limit) || !day.wobbles.isEmpty || !day.seats.isEmpty
    }

    private func shortDay(_ daykey: Int) -> String {
        let month = (daykey / 100) % 100
        let day = daykey % 100
        return "\(month)/\(day)"
    }

    @objc private func returnToTick() {
        dismiss(animated: !UIAccessibility.isReduceMotionEnabled)
    }
}

struct ChartSample {
    var title: String
    var units: Int
    var braced: Bool
}

/// Bars, limit line, and bracing band. The story is the drawing.
final class ChartBoard: UIView {
    var samples: [ChartSample] = []
    var limit: Int = 100
    var band: Int = 85

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = GaugeChrome.surface
        layer.cornerRadius = GaugeChrome.Radius.card
        clipsToBounds = true
        isAccessibilityElement = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        let plot = rect.insetBy(dx: GaugeChrome.space(2), dy: GaugeChrome.space(4))
        guard plot.width > 8, plot.height > 8 else { return }
        let cap = CGFloat(max(limit, 1))
        let bandY = plot.maxY - plot.height * (CGFloat(band) / cap)
        let bandRect = CGRect(x: plot.minX, y: bandY, width: plot.width, height: max(plot.maxY - bandY, 1))
        GaugeChrome.accent.withAlphaComponent(0.22).setFill()
        UIBezierPath(rect: bandRect).fill()

        let limitPath = UIBezierPath()
        limitPath.move(to: CGPoint(x: plot.minX, y: plot.minY))
        limitPath.addLine(to: CGPoint(x: plot.maxX, y: plot.minY))
        limitPath.lineWidth = 2
        GaugeChrome.accent.setStroke()
        limitPath.stroke()

        let word = "Limit \(GaugeChrome.count(limit))" as NSString
        let font = GaugeChrome.caption(for: traitCollection)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: GaugeChrome.ink]
        word.draw(at: CGPoint(x: plot.minX, y: plot.minY - GaugeChrome.space(2)), withAttributes: attrs)

        let bandWord = "Bracing" as NSString
        bandWord.draw(at: CGPoint(x: plot.minX, y: max(bandY - GaugeChrome.space(2), plot.minY)), withAttributes: attrs)

        let count = max(samples.count, 1)
        let gap = GaugeChrome.space(1)
        let barWidth = max((plot.width - gap * CGFloat(count - 1)) / CGFloat(count), 8)
        for (index, sample) in samples.enumerated() {
            let height = plot.height * min(CGFloat(sample.units) / cap, 1)
            let x = plot.minX + CGFloat(index) * (barWidth + gap)
            let bar = CGRect(x: x, y: plot.maxY - height, width: barWidth, height: max(height, 2))
            let fill = sample.braced ? GaugeChrome.accent : GaugeChrome.ink
            fill.setFill()
            UIBezierPath(roundedRect: bar, cornerRadius: 4).fill()
            let label = sample.title as NSString
            let labelSize = label.size(withAttributes: attrs)
            label.draw(
                at: CGPoint(x: x + (barWidth - labelSize.width) / 2, y: min(plot.maxY + 2, rect.maxY - labelSize.height - 2)),
                withAttributes: attrs
            )
        }
        accessibilityLabel = samples.map { "\($0.title), \(GaugeChrome.count($0.units)) units" }.joined(separator: ". ")
    }
}
