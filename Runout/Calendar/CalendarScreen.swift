import UIKit

/// Month of days. Seat, wobble, and over are named on the day you tap.
@MainActor
final class CalendarScreen: UIViewController {
    private let session: ClusterSession
    private let legend = UILabel()
    private let detail = UILabel()
    private let nextLine = UILabel()
    private let grid = UIStackView()
    private let back = GaugeChrome.filledButton("Back to Tick")
    private var monthStart = Date()
    private var selectedKey: Int?

    init(session: ClusterSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"
        view.backgroundColor = GaugeChrome.background
        monthStart = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()

        legend.font = GaugeChrome.body(for: traitCollection)
        legend.textColor = GaugeChrome.ink
        legend.numberOfLines = 0
        legend.text = "Seat is a two-second hold that opens one Tick. Wobble is a Tick in the bracing band with no Seat, and it adds no unit. Over is a Tick at the limit, and it adds no unit."

        detail.font = GaugeChrome.headline(for: traitCollection)
        detail.textColor = GaugeChrome.ink
        detail.numberOfLines = 0

        nextLine.font = GaugeChrome.body(for: traitCollection)
        nextLine.textColor = GaugeChrome.ink
        nextLine.numberOfLines = 0
        nextLine.text = "Next tap: a day, or Back to Tick to file today's measure."

        grid.axis = .vertical
        grid.spacing = GaugeChrome.space(1)
        grid.distribution = .fillEqually

        back.addTarget(self, action: #selector(returnToTick), for: .touchUpInside)
        back.accessibilityLabel = "Back to Tick"

        let stack = UIStackView(arrangedSubviews: [legend, grid, detail, nextLine, back])
        stack.axis = .vertical
        stack.spacing = GaugeChrome.space(2)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: GaugeChrome.space(2)),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -GaugeChrome.space(2)),
            stack.topAnchor.constraint(equalTo: guide.topAnchor, constant: GaugeChrome.space(2)),
            stack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -GaugeChrome.space(2)),
            grid.heightAnchor.constraint(greaterThanOrEqualToConstant: 280),
            back.heightAnchor.constraint(greaterThanOrEqualToConstant: 52)
        ])
        if session.writeFailed {
            detail.text = "Calendar could not confirm the save. The marks on the cluster are still here. Next tap: Back to Tick."
        }
        buildGrid()
    }

    private func buildGrid() {
        grid.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let calendar = Calendar.current
        let symbols = calendar.veryShortWeekdaySymbols
        let header = UIStackView()
        header.axis = .horizontal
        header.distribution = .fillEqually
        for symbol in symbols {
            let label = UILabel()
            label.text = symbol
            label.font = GaugeChrome.caption(for: traitCollection)
            label.textColor = GaugeChrome.ink
            label.textAlignment = .center
            header.addArrangedSubview(label)
        }
        grid.addArrangedSubview(header)

        guard let range = calendar.range(of: .day, in: .month, for: monthStart) else { return }
        let weekday = calendar.component(.weekday, from: monthStart)
        var cells: [UIView] = []
        for _ in 1..<weekday {
            cells.append(UIView())
        }
        for day in range {
            var parts = calendar.dateComponents([.year, .month], from: monthStart)
            parts.day = day
            let date = calendar.date(from: parts) ?? monthStart
            let key = Daykey.make(from: date, calendar: calendar)
            let record = session.cabinet.root.days.first { $0.daykey == key }
            let button = dayButton(day: day, record: record)
            button.tag = key
            button.addTarget(self, action: #selector(tapDay(_:)), for: .touchUpInside)
            cells.append(button)
        }
        while cells.count % 7 != 0 {
            cells.append(UIView())
        }
        var index = 0
        while index < cells.count {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = GaugeChrome.space(1)
            for cell in cells[index..<(index + 7)] {
                row.addArrangedSubview(cell)
            }
            grid.addArrangedSubview(row)
            index += 7
        }
        let todayKey = Daykey.make(from: Date(), calendar: calendar)
        select(todayKey)
    }

    private func dayButton(day: Int, record: ClusterDay?) -> UIButton {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .fixed
        config.background.cornerRadius = GaugeChrome.Radius.chip
        config.baseForegroundColor = GaugeChrome.ink
        config.title = "\(day)"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = GaugeChrome.body(for: .current)
            return outgoing
        }
        let seats = record?.seats.count ?? 0
        let wobbles = record?.wobbles.count ?? 0
        let overs = record?.overs.count ?? 0
        let units = record?.unitTotal ?? 0
        if seats + wobbles + overs > 0 {
            config.baseBackgroundColor = GaugeChrome.accent
            config.baseForegroundColor = GaugeChrome.background
        } else {
            config.baseBackgroundColor = GaugeChrome.surface
        }
        button.configuration = config
        button.accessibilityLabel = access(day: day, seats: seats, wobbles: wobbles, overs: overs, units: units)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        return button
    }

    private func access(day: Int, seats: Int, wobbles: Int, overs: Int, units: Int) -> String {
        "\(day). \(GaugeChrome.count(units)) units. Seat \(GaugeChrome.count(seats)). Wobble \(GaugeChrome.count(wobbles)). Over \(GaugeChrome.count(overs))."
    }

    @objc private func tapDay(_ sender: UIButton) {
        select(sender.tag)
    }

    private func select(_ daykey: Int) {
        selectedKey = daykey
        let record = session.cabinet.root.days.first { $0.daykey == daykey } ?? .bare(daykey: daykey)
        let name = dayLabel(daykey)
        let seats = record.seats.count
        let wobbles = record.wobbles.count
        let overs = record.overs.count
        detail.text = "\(name). \(GaugeChrome.count(record.unitTotal)) \(session.limit.unitLabel) filed. Seat \(GaugeChrome.count(seats)): \(seats == 0 ? "no hold opened a Tick" : "a two-second hold opened one Tick"). Wobble \(GaugeChrome.count(wobbles)): \(wobbles == 0 ? "no Tick was refused in the bracing band" : "a Tick in the band added no unit"). Over \(GaugeChrome.count(overs)): \(overs == 0 ? "no Tick hit the limit" : "a Tick at the limit added no unit")."
    }

    private func dayLabel(_ daykey: Int) -> String {
        let year = daykey / 10_000
        let month = (daykey / 100) % 100
        let day = daykey % 100
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        let date = Calendar.current.date(from: parts) ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    @objc private func returnToTick() {
        dismiss(animated: !UIAccessibility.isReduceMotionEnabled)
    }
}
