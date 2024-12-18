import Foundation
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let settingsVM = SettingsModel()
    var currentValueUpdateHandler: ((_ name: String) -> Void)?
    var finished3rdLevel: ((_ mistakeDone: Bool) -> Void)?
    
    private var basket: SKSpriteNode!
    private var sequence: [String] = [] // Хранит текущую последовательность
    private var currentSequenceIndex = 0
    private var isGameOver = false
    private var currentLevel = 1
    private var fallDuration = 5.0
    private var mistakeDone = false
    
    override func didMove(to view: SKView) {
        setupScene()
        startLevel(currentLevel)
    }
    
    private func setupScene() {
        // Добавляем фон
        backgroundColor = .clear
        
        // Добавляем корзину
        //basket = SKSpriteNode(color: .brown, size: CGSize(width: 100, height: 50))
        let newTexture =  SKSpriteNode(imageNamed: "basket")
        basket = SKSpriteNode(imageNamed: "basket")
        
        // Rescale the node to match the new texture while maintaining its current size
        let aspectRatio = newTexture.size.width / newTexture.size.height
        let newHeight = 50.0
        let newWidth = newHeight * aspectRatio
        basket.size = CGSize(width: newWidth, height: newHeight)
        
        basket.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 75)
        addChild(basket)
        
        // Добавляем управление
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.view?.addGestureRecognizer(panGesture)
        
        mistakeDone = false
    }
    
    private func startLevel(_ level: Int) {
        print("Starting Level \(level)")

        // Set the sequence based on the level
        switch level {
        case 1:
            sequence = ["1", "2", "3", "4", "5"]
        case 2:
            sequence = ["A", "B", "C", "D", "E"]
        case 3:
            sequence = ["1", "A", "2", "B", "3", "C", "4", "D", "5", "E"]
        default:
            sequence = ["1", "2", "3", "4", "5", "A", "B", "C", "D", "E"] // Default sequence for higher levels
        }

        // Reset sequence progress
        currentSequenceIndex = 0

        // Increase the speed of falling stars
        fallDuration = max(1.0, fallDuration - 0.5) // Reduce duration with a minimum cap

        // Start spawning stars if not already running
        if !isGameOver {
            spawnStars()
        }
        currentValueUpdateHandler?("-")
        showLevelBanner(level)
        if level == 4 {
            print(mistakeDone)
            finished3rdLevel?(mistakeDone)
        }
    }
    
    private func spawnStars() {
        let spawnAction = SKAction.run {
            guard !self.isGameOver else { return }
            self.createStar()
        }
        let waitAction = SKAction.wait(forDuration: 1.0) // Time between stars
        let sequenceAction = SKAction.sequence([spawnAction, waitAction])
        run(SKAction.repeatForever(sequenceAction), withKey: "spawningStars")
    }
    
    private func createStar() {
        // Выбираем случайное значение из возможных для текущего уровня
        guard let randomValue = sequence.randomElement() else { return }

        // Создаем спрайт звезды
        let star = SKSpriteNode(imageNamed: "whiteStar")
        star.size = CGSize(width: 60, height: 60)
        star.name = randomValue
        star.position = CGPoint(x: CGFloat.random(in: 40...(size.width - 40)), y: size.height)

        // Добавляем метку (значение звезды)
        let label = SKLabelNode(text: randomValue)
        label.fontName = Fonts.tiltWarp.rawValue
        label.fontSize = 16
        label.fontColor = .mainBlue
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        star.addChild(label)

        // Добавляем звезду на сцену
        addChild(star)

        // Анимация падения
        let fallAction = SKAction.moveTo(y: 0, duration: fallDuration)
        let removeAction = SKAction.removeFromParent()
        star.run(SKAction.sequence([fallAction, removeAction]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Проверяем пересечение звезд и корзины
        for star in children where star is SKSpriteNode && star.name != nil {
            if star.frame.intersects(basket.frame) {
                handleCollectedStar(star as! SKSpriteNode)
            }
        }
    }
    
    private func handleCollectedStar(_ star: SKSpriteNode) {
        guard let starName = star.name else { return }
        
        if starName == sequence[safe: currentSequenceIndex] {
            if settingsVM.soundEnabled {
                playSound(named: "takeStar.mp3")
            }
            currentValueUpdateHandler?(starName)
            currentSequenceIndex += 1
            if currentSequenceIndex >= sequence.count {
                // Уровень завершен
                currentLevel += 1
                print("Level \(currentLevel - 1) Complete!")
                startLevel(currentLevel) // Переход к следующему уровню
            }
        } else {
            // Игрок выбрал неправильную звезду
            if settingsVM.soundEnabled {
                playSound(named: "incorrectStar.mp3")
            }
            mistakeDone = true
            currentValueUpdateHandler?("-")
            print("Wrong star collected!")
            currentSequenceIndex = 0 // Сброс последовательности
        }

        star.removeFromParent()
    }
    
    private func showLevelBanner(_ level: Int) {
        if settingsVM.soundEnabled {
            playSound(named: "newLevel.mp3")
        }
        let banner = SKLabelNode(text: "Level \(level)")
        banner.fontName = "AvenirNext-Bold"
        banner.fontSize = 40
        banner.fontColor = .white
        banner.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        banner.zPosition = 10
        addChild(banner)

        let fadeOut = SKAction.fadeOut(withDuration: 2.0)
        banner.run(fadeOut) {
            banner.removeFromParent()
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        gesture.setTranslation(.zero, in: self.view)
        
        let newPositionX = basket.position.x + translation.x
        basket.position.x = max(min(newPositionX, size.width - basket.size.width / 2), basket.size.width / 2)
    }
    
    func playSound(named name: String) {
        run(SKAction.playSoundFileNamed(name, waitForCompletion: false))
        
    }
    
}

// Helper для безопасного доступа к массиву
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
