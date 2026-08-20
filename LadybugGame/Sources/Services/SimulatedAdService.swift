import UIKit

/// Explicit release switch for the temporary on-device monetization test.
/// Keep this enabled for sideload/TestFlight QA. Replace the service in
/// AppServices and set this to false before an App Store submission.
enum MonetizationConfiguration {
    static let usesSimulatedAds = true
    static let simulatedRewardedDuration: TimeInterval = 5
    static let simulatedInterstitialDuration: TimeInterval = 3
}

private struct SimulatedAdContent {
    let eyebrow: String
    let icon: String
    let rewardText: String
    let accent: UIColor

    static func rewarded(_ placement: RewardedAdPlacement) -> SimulatedAdContent {
        switch placement {
        case .revive:
            return SimulatedAdContent(
                eyebrow: "SIMULATED REWARDED AD",
                icon: "♥",
                rewardText: "REVIVE • 1 LIFE + SAFE START",
                accent: UIColor(red: 0.28, green: 0.86, blue: 0.48, alpha: 1)
            )
        case .doubleRunReward:
            return SimulatedAdContent(
                eyebrow: "SIMULATED REWARDED AD",
                icon: "×2",
                rewardText: "DOUBLE YOUR STAGE GEMS",
                accent: UIColor(red: 0.72, green: 0.42, blue: 1.0, alpha: 1)
            )
        case .dailyBonus:
            return SimulatedAdContent(
                eyebrow: "SIMULATED REWARDED AD",
                icon: "◆",
                rewardText: "+5 DAILY GEMS",
                accent: UIColor(red: 1.0, green: 0.72, blue: 0.18, alpha: 1)
            )
        }
    }

    static let interstitial = SimulatedAdContent(
        eyebrow: "SIMULATED AD BREAK",
        icon: "🐞",
        rewardText: "YOUR NEXT RUN IS ALMOST READY",
        accent: UIColor(red: 0.98, green: 0.28, blue: 0.32, alpha: 1)
    )
}

/// Exercises the same completion callbacks used by a future ad network. The
/// placeholder grants a reward only after its full timer finishes.
@MainActor
final class SimulatedAdService: AdServing {
    var isRewardedReady: Bool { true }
    var isInterstitialReady: Bool { true }

    func prepare() {}

    func showRewarded(from presenter: UIViewController, placement: RewardedAdPlacement) async -> Bool {
        await showPlaceholder(
            from: presenter,
            duration: MonetizationConfiguration.simulatedRewardedDuration,
            content: .rewarded(placement)
        )
    }

    func showInterstitial(from presenter: UIViewController, placement: InterstitialAdPlacement) async -> Bool {
        await showPlaceholder(
            from: presenter,
            duration: MonetizationConfiguration.simulatedInterstitialDuration,
            content: .interstitial
        )
    }

    private func showPlaceholder(
        from presenter: UIViewController,
        duration: TimeInterval,
        content: SimulatedAdContent
    ) async -> Bool {
        guard presenter.presentedViewController == nil,
              presenter.viewIfLoaded?.window != nil else { return false }

        return await withCheckedContinuation { continuation in
            let ad = SimulatedAdViewController(duration: duration, content: content) { completed in
                continuation.resume(returning: completed)
            }
            ad.modalPresentationStyle = .fullScreen
            ad.isModalInPresentation = true
            presenter.present(ad, animated: false)
        }
    }
}

@MainActor
private final class SimulatedAdViewController: UIViewController {
    private let duration: TimeInterval
    private let content: SimulatedAdContent
    private var completion: ((Bool) -> Void)?
    private var delayTask: Task<Void, Never>?
    private var hasFinished = false

    private let gradientLayer = CAGradientLayer()
    private let iconContainer = UIView()
    private let iconLabel = UILabel()
    private let rewardLabel = UILabel()
    private let countdownPill = UIView()
    private let countdownLabel = UILabel()
    private let progressTrack = UIView()
    private let progressFill = UIView()
    private var progressWidthConstraint: NSLayoutConstraint!

    init(duration: TimeInterval, content: SimulatedAdContent, completion: @escaping (Bool) -> Void) {
        self.duration = max(0.25, duration)
        self.content = content
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let root = UIView(frame: .zero)
        root.backgroundColor = UIColor(red: 0.055, green: 0.035, blue: 0.12, alpha: 1)
        root.clipsToBounds = true
        view = root

        gradientLayer.colors = [
            UIColor(red: 0.08, green: 0.04, blue: 0.18, alpha: 1).cgColor,
            UIColor(red: 0.20, green: 0.08, blue: 0.34, alpha: 1).cgColor,
            UIColor(red: 0.06, green: 0.12, blue: 0.24, alpha: 1).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        root.layer.insertSublayer(gradientLayer, at: 0)

        addBackgroundOrb(
            diameter: 230,
            color: content.accent.withAlphaComponent(0.15),
            centerX: root.leadingAnchor,
            xOffset: 45,
            centerY: root.topAnchor,
            yOffset: 20
        )
        addBackgroundOrb(
            diameter: 280,
            color: UIColor(red: 0.35, green: 0.18, blue: 0.72, alpha: 0.16),
            centerX: root.trailingAnchor,
            xOffset: -25,
            centerY: root.bottomAnchor,
            yOffset: -5
        )

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(red: 0.10, green: 0.075, blue: 0.19, alpha: 0.96)
        card.layer.cornerRadius = 24
        card.layer.borderWidth = 2
        card.layer.borderColor = content.accent.withAlphaComponent(0.72).cgColor
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.38
        card.layer.shadowRadius = 22
        card.layer.shadowOffset = CGSize(width: 0, height: 12)
        root.addSubview(card)

        let preferredWidth = card.widthAnchor.constraint(equalToConstant: 520)
        preferredWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: root.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: root.centerYAnchor, constant: -8),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: root.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(lessThanOrEqualTo: root.trailingAnchor, constant: -24),
            preferredWidth,
            card.heightAnchor.constraint(equalToConstant: 260),
        ])

        let eyebrowLabel = UILabel()
        eyebrowLabel.translatesAutoresizingMaskIntoConstraints = false
        eyebrowLabel.text = content.eyebrow
        eyebrowLabel.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        eyebrowLabel.textColor = content.accent
        eyebrowLabel.textAlignment = .center
        eyebrowLabel.accessibilityLabel = content.eyebrow
        card.addSubview(eyebrowLabel)

        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = content.accent.withAlphaComponent(0.15)
        iconContainer.layer.cornerRadius = 34
        iconContainer.layer.borderWidth = 2
        iconContainer.layer.borderColor = content.accent.withAlphaComponent(0.65).cgColor
        card.addSubview(iconContainer)

        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = content.icon
        iconLabel.font = UIFont.systemFont(ofSize: content.icon.count > 1 ? 25 : 31, weight: .black)
        iconLabel.textColor = content.accent
        iconLabel.textAlignment = .center
        iconContainer.addSubview(iconLabel)

        let headlineLabel = UILabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.text = "YOUR AD HERE"
        headlineLabel.font = UIFont.systemFont(ofSize: 29, weight: .black)
        headlineLabel.textColor = .white
        headlineLabel.textAlignment = .center
        card.addSubview(headlineLabel)

        rewardLabel.translatesAutoresizingMaskIntoConstraints = false
        rewardLabel.text = content.rewardText
        rewardLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        rewardLabel.textColor = UIColor(white: 0.86, alpha: 1)
        rewardLabel.textAlignment = .center
        card.addSubview(rewardLabel)

        countdownPill.translatesAutoresizingMaskIntoConstraints = false
        countdownPill.backgroundColor = UIColor(white: 1, alpha: 0.09)
        countdownPill.layer.cornerRadius = 16
        countdownPill.layer.borderWidth = 1
        countdownPill.layer.borderColor = UIColor(white: 1, alpha: 0.14).cgColor
        card.addSubview(countdownPill)

        let countdownCaption = UILabel()
        countdownCaption.translatesAutoresizingMaskIntoConstraints = false
        countdownCaption.text = "Reward in"
        countdownCaption.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        countdownCaption.textColor = UIColor(white: 0.70, alpha: 1)
        countdownPill.addSubview(countdownCaption)

        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.text = "\(Int(ceil(duration)))s"
        countdownLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .heavy)
        countdownLabel.textColor = .white
        countdownPill.addSubview(countdownLabel)

        progressTrack.translatesAutoresizingMaskIntoConstraints = false
        progressTrack.backgroundColor = UIColor(white: 1, alpha: 0.10)
        progressTrack.layer.cornerRadius = 3
        progressTrack.clipsToBounds = true
        card.addSubview(progressTrack)

        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressFill.backgroundColor = content.accent
        progressFill.layer.cornerRadius = 3
        progressTrack.addSubview(progressFill)
        progressWidthConstraint = progressFill.widthAnchor.constraint(equalToConstant: 0)

        let footer = UILabel()
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.text = "TEST PLACEHOLDER • NO AD NETWORK CONNECTED"
        footer.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        footer.textColor = UIColor(white: 1, alpha: 0.48)
        footer.textAlignment = .center
        root.addSubview(footer)

        NSLayoutConstraint.activate([
            eyebrowLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            eyebrowLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            iconContainer.topAnchor.constraint(equalTo: eyebrowLabel.bottomAnchor, constant: 8),
            iconContainer.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 68),
            iconContainer.heightAnchor.constraint(equalToConstant: 68),
            iconLabel.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),

            headlineLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 7),
            headlineLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            headlineLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            rewardLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 1),
            rewardLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            rewardLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            countdownPill.topAnchor.constraint(equalTo: rewardLabel.bottomAnchor, constant: 8),
            countdownPill.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            countdownPill.widthAnchor.constraint(equalToConstant: 142),
            countdownPill.heightAnchor.constraint(equalToConstant: 32),
            countdownCaption.centerYAnchor.constraint(equalTo: countdownPill.centerYAnchor),
            countdownCaption.leadingAnchor.constraint(equalTo: countdownPill.leadingAnchor, constant: 18),
            countdownLabel.centerYAnchor.constraint(equalTo: countdownPill.centerYAnchor),
            countdownLabel.trailingAnchor.constraint(equalTo: countdownPill.trailingAnchor, constant: -17),

            progressTrack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 26),
            progressTrack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -26),
            progressTrack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            progressTrack.heightAnchor.constraint(equalToConstant: 6),
            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),
            progressWidthConstraint,

            footer.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 11),
            footer.centerXAnchor.constraint(equalTo: root.centerXAnchor),
        ])

        root.isAccessibilityElement = true
        root.accessibilityLabel = "Advertisement placeholder. \(content.rewardText)"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard delayTask == nil else { return }

        view.layoutIfNeeded()
        progressWidthConstraint.constant = progressTrack.bounds.width
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear]) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        UIView.animate(
            withDuration: 0.72,
            delay: 0,
            options: [.autoreverse, .repeat, .allowUserInteraction]
        ) { [weak self] in
            self?.iconContainer.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        }

        let finishDate = Date().addingTimeInterval(duration)
        delayTask = Task { @MainActor [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                let remaining = max(0, finishDate.timeIntervalSinceNow)
                self.countdownLabel.text = remaining > 0 ? "\(max(1, Int(ceil(remaining))))s" : "✓"
                if remaining <= 0 { break }
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            guard !Task.isCancelled else { return }
            self.countdownPill.backgroundColor = self.content.accent.withAlphaComponent(0.22)
            self.rewardLabel.text = "REWARD READY"
            self.rewardLabel.textColor = self.content.accent
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            self.finish(completed: true)
        }
    }

    private func addBackgroundOrb(
        diameter: CGFloat,
        color: UIColor,
        centerX: NSLayoutXAxisAnchor,
        xOffset: CGFloat,
        centerY: NSLayoutYAxisAnchor,
        yOffset: CGFloat
    ) {
        let orb = UIView()
        orb.translatesAutoresizingMaskIntoConstraints = false
        orb.backgroundColor = color
        orb.layer.cornerRadius = diameter / 2
        view.addSubview(orb)
        NSLayoutConstraint.activate([
            orb.widthAnchor.constraint(equalToConstant: diameter),
            orb.heightAnchor.constraint(equalToConstant: diameter),
            orb.centerXAnchor.constraint(equalTo: centerX, constant: xOffset),
            orb.centerYAnchor.constraint(equalTo: centerY, constant: yOffset),
        ])
    }

    private func finish(completed: Bool) {
        guard !hasFinished else { return }
        hasFinished = true
        delayTask?.cancel()
        delayTask = nil
        let callback = completion
        completion = nil
        dismiss(animated: false)
        callback?(completed)
    }

    override var prefersStatusBarHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
}
