import UIKit

/// Explicit release switch for the temporary on-device monetization test.
/// Keep this enabled for sideload/TestFlight QA. Replace the service in
/// AppServices and set this to false before an App Store submission.
enum MonetizationConfiguration {
    static let usesSimulatedAds = true
    static let simulatedRewardedDuration: TimeInterval = 5
    static let simulatedInterstitialDuration: TimeInterval = 3
}

/// Exercises the exact rewarded/interstitial callbacks used by a future ad
/// network. The screen is intentionally black and grants rewards only after the
/// full timer finishes.
@MainActor
final class SimulatedAdService: AdServing {
    var isRewardedReady: Bool { true }
    var isInterstitialReady: Bool { true }

    func prepare() {}

    func showRewarded(from presenter: UIViewController, placement: RewardedAdPlacement) async -> Bool {
        await showBlankAd(from: presenter, duration: MonetizationConfiguration.simulatedRewardedDuration)
    }

    func showInterstitial(from presenter: UIViewController, placement: InterstitialAdPlacement) async -> Bool {
        await showBlankAd(from: presenter, duration: MonetizationConfiguration.simulatedInterstitialDuration)
    }

    private func showBlankAd(from presenter: UIViewController, duration: TimeInterval) async -> Bool {
        guard presenter.presentedViewController == nil,
              presenter.viewIfLoaded?.window != nil else { return false }

        return await withCheckedContinuation { continuation in
            let ad = SimulatedAdViewController(duration: duration) { completed in
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
    private var completion: ((Bool) -> Void)?
    private var delayTask: Task<Void, Never>?
    private var hasFinished = false

    init(duration: TimeInterval, completion: @escaping (Bool) -> Void) {
        self.duration = max(0.25, duration)
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let blankView = UIView(frame: .zero)
        blankView.backgroundColor = .black
        blankView.isAccessibilityElement = true
        blankView.accessibilityLabel = "Simulated advertisement"
        view = blankView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard delayTask == nil else { return }
        let nanoseconds = UInt64(duration * 1_000_000_000)
        delayTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }
            self?.finish(completed: true)
        }
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
