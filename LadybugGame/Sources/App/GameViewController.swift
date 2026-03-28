import UIKit
import SpriteKit

class GameViewController: UIViewController {

    private var hasPresented = false

    override func loadView() {
        self.view = SKView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !hasPresented, let skView = view as? SKView, view.bounds.width > 0 else { return }
        hasPresented = true

        let scene = MenuScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
