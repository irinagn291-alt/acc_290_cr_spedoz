import UIKit

/// Daily Limit, unit label, onboarding, confirmed reset, and the contact link.
@MainActor
final class SettingsScreen: UITableViewController, UITextFieldDelegate {
    private let session: ClusterSession
    private let limitField = UITextField()
    private let labelField = UITextField()
    private var token: UUID?

    /// A failed chart write is its own row. Limit validity does not hide it.
    static func showsChartError(writeFailed: Bool) -> Bool {
        writeFailed
    }

    init(session: ClusterSession) {
        self.session = session
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        tableView.backgroundColor = GaugeChrome.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "row")
        tableView.register(SettingsHeader.self, forHeaderFooterViewReuseIdentifier: "section")
        tableView.estimatedRowHeight = 52
        tableView.estimatedSectionHeaderHeight = GaugeChrome.space(6)
        limitField.keyboardType = .numberPad
        limitField.text = GaugeChrome.count(session.limit.units)
        limitField.textColor = GaugeChrome.ink
        limitField.font = GaugeChrome.body(for: traitCollection)
        limitField.accessibilityLabel = "Daily limit"
        labelField.text = session.limit.unitLabel
        labelField.textColor = GaugeChrome.ink
        labelField.font = GaugeChrome.body(for: traitCollection)
        labelField.delegate = self
        labelField.accessibilityLabel = "Unit label"
        limitField.delegate = self
        tableView.keyboardDismissMode = .interactive
        let bar = UIToolbar()
        bar.sizeToFit()
        let flex = UIBarButtonItem.flexibleSpace()
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(endEditingFields))
        done.accessibilityLabel = "Done editing"
        bar.items = [flex, done]
        limitField.inputAccessoryView = bar
        labelField.inputAccessoryView = bar
        labelField.returnKeyType = .done
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingFields))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
        token = session.observe { [weak self] in
            self?.tableView.reloadData()
        }
    }

    deinit {
        let token = token
        let session = session
        if let token {
            Task { @MainActor in session.removeObserver(token) }
        }
    }

    @objc private func endEditingFields() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField === limitField else { return true }
        return string.unicodeScalars.allSatisfy { CharacterSet.decimalDigits.contains($0) }
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 3 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return Self.showsChartError(writeFailed: session.writeFailed) ? 3 : 2
        case 1: return 2
        default: return 1
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "section") as? SettingsHeader
            ?? SettingsHeader(reuseIdentifier: "section")
        header.titleLabel.font = GaugeChrome.caption(for: traitCollection)
        header.titleLabel.textColor = GaugeChrome.muted
        header.titleLabel.text = ["Limit", "Care", "Contact"][section]
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        GaugeChrome.space(6)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        cell.backgroundColor = GaugeChrome.surface
        cell.contentConfiguration = nil
        cell.accessoryView = nil
        cell.accessoryType = .none
        cell.selectionStyle = .default
        var config = UIListContentConfiguration.cell()
        config.textProperties.font = GaugeChrome.body(for: traitCollection)
        config.textProperties.color = GaugeChrome.ink
        if indexPath.section == 0 && Self.showsChartError(writeFailed: session.writeFailed) && indexPath.row == 0 {
            var error = UIListContentConfiguration.subtitleCell()
            error.text = "The chart could not be saved"
            error.secondaryText = "Your limit is still here. Edit it, then leave the field to try again."
            error.textProperties.font = GaugeChrome.headline(for: traitCollection)
            error.secondaryTextProperties.font = GaugeChrome.body(for: traitCollection)
            error.textProperties.color = GaugeChrome.ink
            error.secondaryTextProperties.color = GaugeChrome.muted
            error.textProperties.numberOfLines = 0
            error.secondaryTextProperties.numberOfLines = 0
            cell.contentConfiguration = error
            cell.selectionStyle = .none
            return cell
        }
        let limitRow = Self.showsChartError(writeFailed: session.writeFailed) ? indexPath.row - 1 : indexPath.row
        if indexPath.section == 0 && session.cabinet.root.days.isEmpty && !session.limit.isValid {
            config.text = "Set a limit to start the cluster"
            cell.contentConfiguration = config
            return cell
        }
        if indexPath.section == 0 && limitRow == 0 {
            config.text = "Daily limit"
            cell.contentConfiguration = config
            limitField.frame = CGRect(x: 0, y: 0, width: 88, height: 44)
            cell.accessoryView = limitField
        } else if indexPath.section == 0 {
            config.text = "Unit label"
            cell.contentConfiguration = config
            labelField.frame = CGRect(x: 0, y: 0, width: 140, height: 44)
            cell.accessoryView = labelField
        } else if indexPath.section == 1 && indexPath.row == 0 {
            config.text = "Show onboarding again"
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.section == 1 {
            config.text = "Erase every mark and the limit"
            config.textProperties.color = GaugeChrome.ink
            config.image = UIImage(systemName: "trash")
            config.imageProperties.tintColor = GaugeChrome.muted
            cell.contentConfiguration = config
        } else {
            config.text = "Contact Runout"
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
        }
        cell.selectionStyle = .default
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 {
            session.rerunOnboarding()
            dismiss(animated: true)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            confirmReset()
        } else if indexPath.section == 2 {
            if let url = URL(string: "https://runout-limit.pro/contact-us") {
                UIApplication.shared.open(url)
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && Self.showsChartError(writeFailed: session.writeFailed) && indexPath.row == 0 {
            return UITableView.automaticDimension
        }
        return 52
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let parsed = Int(limitField.text ?? "")
        let units = (parsed != nil && (parsed ?? 0) > 0) ? (parsed ?? session.limit.units) : session.limit.units
        let label = (labelField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let resolved = label.isEmpty ? session.limit.unitLabel : label
        if parsed == nil || (parsed ?? 0) <= 0 || label.isEmpty {
            limitField.text = GaugeChrome.count(session.limit.units)
            labelField.text = session.limit.unitLabel
        }
        session.updateLimit(LimitGauge(units: units, unitLabel: resolved))
        tableView.reloadData()
    }

    private func confirmReset() {
        let alert = UIAlertController(
            title: "Erase the chart?",
            message: "This removes every mark and the daily limit. You cannot undo it.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Keep marks", style: .cancel))
        alert.addAction(UIAlertAction(title: "Erase chart", style: .destructive) { [weak self] _ in
            self?.session.resetAllData()
            self?.limitField.text = GaugeChrome.count(self?.session.limit.units ?? 0)
            self?.labelField.text = self?.session.limit.unitLabel
            self?.tableView.reloadData()
        })
        present(alert, animated: true)
    }
}

private final class SettingsHeader: UITableViewHeaderFooterView {
    let titleLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: GaugeChrome.space(2)),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -GaugeChrome.space(1))
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
