import UIKit

/// Marks for the open day and recent days.
@MainActor
final class HistoryScreen: UITableViewController {
    private let session: ClusterSession
    private var lines: [(String, String)] = []

    init(session: ClusterSession) {
        self.session = session
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History"
        tableView.backgroundColor = GaugeChrome.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "mark")
        lines = HistoryScreen.lines(from: session.cabinet.root.days)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if session.writeFailed { return 1 }
        return max(lines.count, 1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mark", for: indexPath)
        var config = UIListContentConfiguration.subtitleCell()
        config.textProperties.font = GaugeChrome.headline(for: traitCollection)
        config.secondaryTextProperties.font = GaugeChrome.caption(for: traitCollection)
        config.textProperties.color = GaugeChrome.ink
        config.secondaryTextProperties.color = GaugeChrome.muted
        if session.writeFailed {
            config.text = "History is waiting on the save"
            config.secondaryText = "The cluster still holds today's marks. Try again after the next Tick."
        } else if lines.isEmpty {
            config.text = "No marks filed"
            config.secondaryText = "Today's ticks, seats, wobbles, and overruns will list here."
            config.image = UIImage(named: "rou_EmptyList")
        } else {
            config.text = lines[indexPath.row].0
            config.secondaryText = lines[indexPath.row].1
        }
        cell.contentConfiguration = config
        cell.backgroundColor = GaugeChrome.surface
        cell.selectionStyle = .none
        return cell
    }

    static func lines(from days: [ClusterDay]) -> [(String, String)] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        var rows: [(Date, String, String)] = []
        for day in days {
            for mark in day.runs {
                rows.append((mark.filedAt, "Run mark", formatter.string(from: mark.filedAt)))
            }
            for mark in day.seats {
                rows.append((mark.filedAt, "Seat mark", formatter.string(from: mark.filedAt)))
            }
            for mark in day.wobbles {
                rows.append((mark.filedAt, "Wobble mark", formatter.string(from: mark.filedAt)))
            }
            for mark in day.overs {
                rows.append((mark.filedAt, "Over mark", formatter.string(from: mark.filedAt)))
            }
        }
        return rows.sorted { $0.0 > $1.0 }.prefix(40).map { ($0.1, $0.2) }
    }
}
