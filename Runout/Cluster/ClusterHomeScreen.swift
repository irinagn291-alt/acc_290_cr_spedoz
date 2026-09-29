import SwiftUI
import UIKit

/// Home. The instrument cluster never leaves. Seat and Tick fuse here. Sheets cover Calendar, Charts, History, and Settings.
@MainActor
final class ClusterHomeScreen: UIViewController {
    private let session: ClusterSession
    private var token: UUID?
    private var didPresentReview = false
    private let scroll = UIScrollView()
    private let column = UIStackView()
    private let needle = NeedlePlate()
    private let figure = UILabel()
    private let job = UILabel()
    private let nextTap = UILabel()
    private let notice = UILabel()
    private let seatButton = GaugeChrome.filledButton("Seat")
    private let tickButton = GaugeChrome.filledButton("Tick")
    private let verbs = UIStackView()
    private let statusCard = RaisedCard()
    private let destinationCard = RaisedCard()
    private let statusStack = UIStackView()
    private let bracingLine = UILabel()
    private let yesterdayLine = UILabel()
    private let emptyPage = UIStackView()
    private let emptyArt = UIImageView()
    private let emptyTitle = UILabel()
    private let emptyLine = UILabel()
    private let emptyTick = GaugeChrome.filledButton("Tick")
    private let success = UIImageView()
    private var hold: UILongPressGestureRecognizer?

    init(session: ClusterSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GaugeChrome.background
        if session.isOnboarded {
            buildCluster()
        } else {
            showOnboarding()
        }
        token = session.observe { [weak self] in
            self?.refresh()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentReviewIfNeeded()
    }

    deinit {
        let token = token
        let session = session
        if let token {
            Task { @MainActor in session.removeObserver(token) }
        }
    }

    private func showOnboarding() {
        let pages = OnboardingScreen(session: session) { [weak self] in
            self?.children.forEach { child in
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
            self?.buildCluster()
            self?.presentReviewIfNeeded()
        }
        addChild(pages)
        pages.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pages.view)
        NSLayoutConstraint.activate([
            pages.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pages.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pages.view.topAnchor.constraint(equalTo: view.topAnchor),
            pages.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        pages.didMove(toParent: self)
    }

    private func buildCluster() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.keyboardDismissMode = .interactive
        view.addSubview(scroll)
        column.axis = .vertical
        column.spacing = GaugeChrome.space(2)
        column.alignment = .fill
        column.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(column)

        job.font = GaugeChrome.title(for: traitCollection)
        job.textColor = GaugeChrome.ink
        job.numberOfLines = 0
        job.textAlignment = .left
        job.text = "Keep today's measure inside the limit"

        figure.font = GaugeChrome.monospaced(GaugeChrome.display(for: traitCollection))
        figure.textColor = GaugeChrome.accent
        figure.adjustsFontForContentSizeCategory = true
        figure.numberOfLines = 1
        figure.lineBreakMode = .byTruncatingTail

        nextTap.font = GaugeChrome.body(for: traitCollection)
        nextTap.textColor = GaugeChrome.ink
        nextTap.numberOfLines = 0

        notice.font = GaugeChrome.callout(for: traitCollection)
        notice.textColor = GaugeChrome.ink
        notice.numberOfLines = 0

        verbs.axis = .vertical
        verbs.spacing = GaugeChrome.space(1)
        verbs.alignment = .fill
        let press = UILongPressGestureRecognizer(target: self, action: #selector(holdSeat(_:)))
        press.minimumPressDuration = SeatHold.duration
        seatButton.addGestureRecognizer(press)
        hold = press
        seatButton.accessibilityLabel = "Seat. Hold for two seconds."
        seatButton.clipsToBounds = true
        tickButton.addTarget(self, action: #selector(tapTick), for: .touchUpInside)
        tickButton.accessibilityLabel = "Tick. File one unit toward today's limit."
        tickButton.clipsToBounds = true
        verbs.addArrangedSubview(tickButton)
        verbs.addArrangedSubview(seatButton)
        tickButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true

        buildStatusCard()
        buildDestinations()

        success.isHidden = true
        success.isAccessibilityElement = false

        [job, figure, needle, nextTap, verbs, notice, statusCard, destinationCard].forEach {
            column.addArrangedSubview($0)
        }
        needle.setContentHuggingPriority(.required, for: .vertical)
        needle.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        buildEmptyPage()

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: guide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            column.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: GaugeChrome.space(2)),
            column.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -GaugeChrome.space(2)),
            column.topAnchor.constraint(equalTo: scroll.topAnchor, constant: GaugeChrome.space(2)),
            column.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -GaugeChrome.space(2)),
            column.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -GaugeChrome.space(4))
        ])
        GaugeChrome.applyShadow(needle.layer)
        refresh()
        GaugeChrome.reveal([figure, needle, verbs, statusCard])
    }

    private func buildStatusCard() {
        statusStack.axis = .vertical
        statusStack.spacing = GaugeChrome.space(1)
        statusStack.translatesAutoresizingMaskIntoConstraints = false
        statusCard.addSubview(statusStack)
        bracingLine.font = GaugeChrome.headline(for: traitCollection)
        bracingLine.textColor = GaugeChrome.ink
        bracingLine.numberOfLines = 0
        yesterdayLine.font = GaugeChrome.body(for: traitCollection)
        yesterdayLine.textColor = GaugeChrome.muted
        yesterdayLine.numberOfLines = 0
        let bracing = GaugeChrome.rowButton("How bracing works", symbol: "dot.circle")
        bracing.addTarget(self, action: #selector(openBracing), for: .touchUpInside)
        bracing.accessibilityLabel = "How bracing works"
        statusStack.addArrangedSubview(bracingLine)
        statusStack.addArrangedSubview(yesterdayLine)
        statusStack.addArrangedSubview(bracing)
        NSLayoutConstraint.activate([
            statusStack.leadingAnchor.constraint(equalTo: statusCard.leadingAnchor, constant: GaugeChrome.space(2)),
            statusStack.trailingAnchor.constraint(equalTo: statusCard.trailingAnchor, constant: -GaugeChrome.space(2)),
            statusStack.topAnchor.constraint(equalTo: statusCard.topAnchor, constant: GaugeChrome.space(2)),
            statusStack.bottomAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: -GaugeChrome.space(2))
        ])
    }

    private func buildDestinations() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = GaugeChrome.space(1)
        stack.translatesAutoresizingMaskIntoConstraints = false
        destinationCard.addSubview(stack)
        let items: [(String, String, Selector)] = [
            ("Calendar", "calendar", #selector(openCalendar)),
            ("Charts", "chart.bar", #selector(openCharts)),
            ("History", "clock", #selector(openHistory)),
            ("Settings", "gearshape", #selector(openSettings))
        ]
        for item in items {
            let button = GaugeChrome.rowButton(item.0, symbol: item.1)
            button.addTarget(self, action: item.2, for: .touchUpInside)
            button.accessibilityLabel = item.0
            stack.addArrangedSubview(button)
        }
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: destinationCard.leadingAnchor, constant: GaugeChrome.space(2)),
            stack.trailingAnchor.constraint(equalTo: destinationCard.trailingAnchor, constant: -GaugeChrome.space(2)),
            stack.topAnchor.constraint(equalTo: destinationCard.topAnchor, constant: GaugeChrome.space(2)),
            stack.bottomAnchor.constraint(equalTo: destinationCard.bottomAnchor, constant: -GaugeChrome.space(2))
        ])
    }

    private func buildEmptyPage() {
        emptyPage.axis = .vertical
        emptyPage.spacing = GaugeChrome.space(2)
        emptyPage.translatesAutoresizingMaskIntoConstraints = false
        emptyPage.isHidden = true
        view.addSubview(emptyPage)
        emptyTitle.font = GaugeChrome.title(for: traitCollection)
        emptyTitle.textColor = GaugeChrome.ink
        emptyTitle.numberOfLines = 0
        emptyTitle.text = "Nothing logged today"
        emptyLine.font = GaugeChrome.body(for: traitCollection)
        emptyLine.textColor = GaugeChrome.muted
        emptyLine.numberOfLines = 0
        emptyLine.text = "Tick once to start today's measure inside the limit."
        emptyTick.addTarget(self, action: #selector(tapTick), for: .touchUpInside)
        emptyTick.accessibilityLabel = "Tick. File the first unit today."
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        [emptyTitle, emptyLine, spacer, emptyTick].forEach { emptyPage.addArrangedSubview($0) }
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            emptyPage.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: GaugeChrome.space(2)),
            emptyPage.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -GaugeChrome.space(2)),
            emptyPage.topAnchor.constraint(equalTo: guide.topAnchor, constant: GaugeChrome.space(3)),
            emptyPage.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -GaugeChrome.space(2))
        ])
    }

    private func refresh() {
        guard session.isOnboarded, column.superview != nil else {
            if !session.isOnboarded, children.isEmpty {
                showOnboarding()
            }
            return
        }
        let day = session.today
        let limit = session.limit
        let bare = day.phase == .bare && day.unitTotal == 0
        scroll.isHidden = bare
        emptyPage.isHidden = !bare
        figure.text = Self.figureLine(day: day, limit: limit)
        needle.bind(total: day.unitTotal, limit: limit.units, phase: day.phase, wobbles: day.wobbles.count)
        nextTap.text = Self.nextTapLine(day: day, limit: limit)
        notice.text = noticeCopy()
        notice.isHidden = notice.text?.isEmpty != false
        let band = BracingBand.threshold(limit: limit.units)
        bracingLine.text = "Bracing starts at \(GaugeChrome.count(band)) \(limit.unitLabel). Hold Seat, then Tick."
        yesterdayLine.text = yesterdayCopy(limit: limit)

        let seatReady = day.phase == .braced && !day.seatPulse && day.seats.count < 2
        seatButton.isEnabled = seatReady
        let tickReady = day.phase != .over && day.unitTotal < limit.units
        tickButton.isEnabled = tickReady
        emptyTick.isEnabled = tickReady
    }

    private func yesterdayCopy(limit: LimitGauge) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let date = calendar.date(byAdding: .day, value: -1, to: today) else {
            return "Yesterday has no marks yet."
        }
        let day = session.cabinet.day(for: date, calendar: calendar)
        if day.unitTotal == 0 && day.seats.isEmpty && day.wobbles.isEmpty {
            return "Yesterday has no marks yet."
        }
        return "Yesterday filed \(GaugeChrome.count(day.unitTotal)) \(limit.unitLabel)."
    }

    static func figureLine(day: ClusterDay, limit: LimitGauge) -> String {
        var line = "\(GaugeChrome.count(day.unitTotal)) of \(GaugeChrome.count(limit.units)) \(limit.unitLabel)"
        if day.wobbles.count > 0 {
            line += ", \(countWord(day.wobbles.count, singular: "wobble", plural: "wobbles"))"
        }
        return line
    }

    static func nextTapLine(day: ClusterDay, limit: LimitGauge) -> String {
        if day.phase == .over || day.unitTotal >= limit.units {
            return "Today is at the limit. Tick stays closed until tomorrow."
        }
        if day.seatPulse {
            return "Seat is filed. Next tap: Tick, one unit."
        }
        if day.phase == .braced {
            if day.wobbles.isEmpty {
                return "You are in the bracing band. Hold Seat for two seconds, then Tick."
            }
            return "\(countWord(day.wobbles.count, singular: "wobble", plural: "wobbles")) filed and no unit added. Hold Seat for two seconds, then Tick."
        }
        let remaining = BracingBand.threshold(limit: limit.units) - day.unitTotal
        if remaining <= 1 {
            return "Next tap: Tick. That unit enters the bracing band and asks for Seat."
        }
        return "Next tap: Tick. File one \(limit.unitLabel) while you are still under bracing."
    }

    private static func countWord(_ count: Int, singular: String, plural: String) -> String {
        "\(GaugeChrome.count(count)) \(count == 1 ? singular : plural)"
    }

    private func noticeCopy() -> String {
        if session.writeFailed {
            return "The chart could not be saved. Your latest mark is still on this screen. Try the verb again."
        }
        switch session.loadNotice {
        case .recoveredBackup:
            return "Recovered the last good chart after a bad save."
        case .startedEmpty:
            return "The saved chart could not be read, so today starts empty."
        case nil:
            return ""
        }
    }

    @objc private func tapTick() {
        let verb = session.tick()
        if verb == .filed {
            pulseSuccess()
        } else if case .refused(.unbraced) = verb {
            signalRefusal()
        }
        refresh()
    }

    @objc private func holdSeat(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let verb = session.seat()
        if verb == .filed {
            pulseSuccess()
        }
        refresh()
    }

    private func signalRefusal() {
        let dim: () -> Void = {
            self.figure.alpha = 0.4
            self.needle.alpha = 0.4
            self.nextTap.alpha = 0.4
        }
        let restore: () -> Void = {
            self.figure.alpha = 1
            self.needle.alpha = 1
            self.nextTap.alpha = 1
        }
        UIView.animate(withDuration: 0.2, animations: dim) { _ in
            UIView.animate(withDuration: 0.2, animations: restore)
        }
    }

    private func pulseSuccess() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        success.isHidden = false
        success.alpha = 1
        let fade = {
            self.success.alpha = 0
        }
        let hide = { (done: Bool) in
            if done { self.success.isHidden = true }
        }
        if UIAccessibility.isReduceMotionEnabled {
            UIView.animate(withDuration: 0.2, animations: fade, completion: hide)
        } else {
            UIView.animate(withDuration: 0.35, delay: 0.4, options: [.curveEaseInOut], animations: fade, completion: hide)
        }
    }

    private func presentReviewIfNeeded() {
        guard session.isOnboarded, !didPresentReview else { return }
        didPresentReview = true
        switch session.takeReviewScreen() {
        case .log: openCalendar()
        case .goals: openCharts()
        case .history: openHistory()
        case .settings: openSettings()
        case .today, nil: break
        }
    }

    @objc private func openCalendar() { presentSheet(CalendarScreen(session: session)) }
    @objc private func openCharts() { presentSheet(ChartsScreen(session: session)) }
    @objc private func openHistory() { presentSheet(HistoryScreen(session: session)) }
    @objc private func openSettings() { presentSheet(SettingsScreen(session: session)) }
    @objc private func openBracing() { presentSheet(BracingGuideScreen(session: session)) }

    private func presentSheet(_ screen: UIViewController) {
        let nav = UINavigationController(rootViewController: screen)
        nav.modalPresentationStyle = .pageSheet
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = GaugeChrome.surface
        appearance.titleTextAttributes = [
            .foregroundColor: GaugeChrome.ink,
            .font: GaugeChrome.headline(for: traitCollection)
        ]
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.tintColor = GaugeChrome.accent
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = GaugeChrome.Radius.card
        }
        let close = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeSheet)
        )
        close.accessibilityLabel = "Close"
        screen.navigationItem.rightBarButtonItem = close
        present(nav, animated: !UIAccessibility.isReduceMotionEnabled)
    }

    @objc private func closeSheet() {
        dismiss(animated: true)
    }
}

struct ClusterHost: UIViewControllerRepresentable {
    let session: ClusterSession

    func makeUIViewController(context: Context) -> ClusterHomeScreen {
        ClusterHomeScreen(session: session)
    }

    func updateUIViewController(_ uiViewController: ClusterHomeScreen, context: Context) {}
}
