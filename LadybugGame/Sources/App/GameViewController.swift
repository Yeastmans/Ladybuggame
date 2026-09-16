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
            case "shop", "hat-preview": scene = ShopScene(size: view.bounds.size)
            case "tutorial": scene = FlightSchoolScene(size: view.bounds.size)
            case "meadow", "night", "space", "stage-clear", "game-over", "pause":
                let game = GameScene(size: view.bounds.size)
                game.campaignStageID = screen == "space" ? 14 : screen == "night" ? 1 : 0
                scene = game
            default:
                if screen.hasPrefix("biome-"), let id = Int(screen.dropFirst(6)), CampaignStage.stage(id: id) != nil {
                    let game = GameScene(size: view.bounds.size)
                    game.campaignStageID = id
                    scene = game
                }
            }
        }
#endif
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
#if DEBUG && targetEnvironment(simulator)
        if arguments.contains("map"), arguments.contains("--ui-testing"), let menu = scene as? MenuScene { menu.activate("map") }
        if arguments.contains("--ui-testing") {
            if let shop = scene as? ShopScene, arguments.contains("hat-preview") { shop.activate("item_hat_wizard") }
            if let game = scene as? GameScene {
                if arguments.contains("stage-clear") { game.previewResult(completed: true) }
                if arguments.contains("game-over") { game.previewResult(completed: false) }
                if arguments.contains("pause") { game.pauseForInterruption() }
            }
        }
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
