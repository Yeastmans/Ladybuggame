import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {

    private var hasPresented = false
    private var previousInsets = UIEdgeInsets.zero

    override func loadView() {
        self.view = SKView()
        self.view.isMultipleTouchEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(interrupted),
            name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(interrupted),
            name: AVAudioSession.interruptionNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !hasPresented, let skView = view as? SKView, view.bounds.width > 0 else { return }
        hasPresented = true
        AppServices.shared.analytics.track(.appLaunched)
        AppServices.shared.ads.prepare()
        Task { await AppServices.shared.purchases.prepare() }

        var scene: SKScene = MenuScene(size: view.bounds.size)
#if DEBUG && targetEnvironment(simulator)
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--ui-testing"), let flag = arguments.firstIndex(of: "--preview-screen"), flag + 1 < arguments.count {
            let screen = arguments[flag + 1]
            switch screen {
            case "settings": scene = SettingsScene(size: view.bounds.size)
            case "collection": scene = BugopediaScene(size: view.bounds.size)
            case "shop": scene = ShopScene(size: view.bounds.size)
            case "tutorial": scene = FlightSchoolScene(size: view.bounds.size)
            case "meadow", "night", "space":
                let game = GameScene(size: view.bounds.size)
                game.campaignStageID = screen == "space" ? 14 : screen == "night" ? 1 : 0
                scene = game
            default: break
            }
        }
#endif
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
#if DEBUG && targetEnvironment(simulator)
        if arguments.contains("map"), arguments.contains("--ui-testing"), let menu = scene as? MenuScene { menu.activate("map") }
#endif
        skView.ignoresSiblingOrder = true
        skView.preferredFramesPerSecond = 60
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        guard view.safeAreaInsets != previousInsets else { return }
        previousInsets = view.safeAreaInsets
        if let scene = (view as? SKView)?.scene as? GameScreenScene { scene.rebuild() }
        ((view as? SKView)?.scene as? GameScene)?.refreshSafeAreaLayout()
    }

    @objc private func interrupted(_ notification: Notification) {
        if notification.name == AVAudioSession.interruptionNotification,
           let type = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
           type != AVAudioSession.InterruptionType.began.rawValue { return }
        ((view as? SKView)?.scene as? GameScene)?.pauseForInterruption()
        SoundManager.shared.stopMusic()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
