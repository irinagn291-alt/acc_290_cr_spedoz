import UIKit

/// Twist surface. Explains seat-then-tick. The cluster already carries the same verb.
@MainActor
final class BracingGuideScreen: UITableViewController {
    private let session: ClusterSession

    init(session: ClusterSession) {
        self.session = session
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bracing"
        tableView.backgroundColor = GaugeChrome.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "row")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        var config = UIListContentConfiguration.subtitleCell()
        config.textProperties.font = GaugeChrome.headline(for: traitCollection)
        config.secondaryTextProperties.font = GaugeChrome.body(for: traitCollection)
        config.textProperties.color = GaugeChrome.ink
        config.secondaryTextProperties.color = GaugeChrome.muted
        config.textProperties.numberOfLines = 0
        config.secondaryTextProperties.numberOfLines = 0
        if session.writeFailed {
            config.text = "Bracing notes are waiting"
            config.secondaryText = "The cluster still shows the band. Save will catch up on the next mark."
        } else if indexPath.row == 0 {
            config.image = UIImage(named: "rou_TwistHero")
            config.imageProperties.maximumSize = CGSize(width: 72, height: 72)
            config.text = "Hold Seat, then Tick"
            let band = BracingBand.threshold(limit: session.limit.units)
            config.secondaryText = "Bracing starts at \(GaugeChrome.count(band)) \(session.limit.unitLabel). A two second hold files a seat and opens one Tick."
        } else if session.today.phase == .bare {
            config.text = "The band is quiet"
            config.secondaryText = "Tick under the limit until the needle reaches bracing."
            config.image = UIImage(named: "rou_EmptyList")
        } else {
            config.text = "Today"
            config.secondaryText = "\(GaugeChrome.count(session.today.unitTotal)) filed, \(GaugeChrome.count(session.today.seats.count)) seats, \(GaugeChrome.count(session.today.wobbles.count)) wobbles."
        }
        cell.contentConfiguration = config
        cell.backgroundColor = GaugeChrome.surface
        cell.selectionStyle = .none
        return cell
    }
}
