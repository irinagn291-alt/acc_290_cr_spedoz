import UIKit

/// Three pages that write the default Limit and mark onboarding complete. Skip does the same.
@MainActor
final class OnboardingScreen: UIViewController {
    private let session: ClusterSession
    private let finished: () -> Void
    private var page = 0
    private let art = UIImageView()
    private let headline = UILabel()
    private let line = UILabel()
    private let nextButton = GaugeChrome.filledButton("Next")
    private let skipButton = GaugeChrome.filledButton("Skip")

    init(session: ClusterSession, finished: @escaping () -> Void) {
        self.session = session
        self.finished = finished
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GaugeChrome.background
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = GaugeChrome.space(2)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        art.contentMode = .scaleAspectFit
        art.heightAnchor.constraint(greaterThanOrEqualToConstant: 180).isActive = true
        headline.font = GaugeChrome.title(for: traitCollection)
        headline.textColor = GaugeChrome.ink
        headline.numberOfLines = 0
        line.font = GaugeChrome.body(for: traitCollection)
        line.textColor = GaugeChrome.muted
        line.numberOfLines = 0
        nextButton.addTarget(self, action: #selector(advance), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skip), for: .touchUpInside)
        stack.addArrangedSubview(art)
        stack.addArrangedSubview(headline)
        stack.addArrangedSubview(line)
        let spacer = UIView()
        stack.addArrangedSubview(spacer)
        stack.addArrangedSubview(nextButton)
        stack.addArrangedSubview(skipButton)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: GaugeChrome.space(2)),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -GaugeChrome.space(2)),
            stack.topAnchor.constraint(equalTo: guide.topAnchor, constant: GaugeChrome.space(3)),
            stack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -GaugeChrome.space(2))
        ])
        render()
        GaugeChrome.reveal([art, headline, line])
    }

    private func render() {
        let pages: [(String, String, String, String)] = [
            ("rou_Onboarding1", "Seat the bezel, then tick the day", "Runout keeps today's measure inside a limit you choose.", "Next"),
            ("rou_Onboarding2", "Hold Seat, then Tick", "From the bracing band, a two second hold files a seat and opens one Tick.", "Next"),
            ("rou_Onboarding3", "The cluster stays on this device", "Calendar and charts read the same marks. Nothing leaves the phone.", "Continue")
        ]
        let item = pages[page]
        art.image = UIImage(named: item.0)
        headline.text = item.1
        line.text = item.2
        nextButton.configuration?.title = item.3
        nextButton.accessibilityLabel = item.3
        skipButton.accessibilityLabel = "Skip onboarding and use the standard limit"
    }

    @objc private func advance() {
        if page < 2 {
            page += 1
            render()
        } else {
            finish()
        }
    }

    @objc private func skip() {
        finish()
    }

    private func finish() {
        session.completeOnboarding(limit: .standard)
        finished()
    }
}
