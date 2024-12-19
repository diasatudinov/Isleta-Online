//
//  GameScene.swift
//  Isleta Online
//
//  Created by Dias Atudinov on 18.12.2024.
//


import Foundation
import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func restart()
    func pause()
    func resume()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let settingsVM = SettingsModel()
    var shopVM = ShopViewModel()
    private var eagle: SKSpriteNode!
    private var activePowerUpLabel: SKLabelNode!
    
    private var score = 0
    private var coins = 0
    private var isGameOver = false
    
    var coinsUpdateHandler: (() -> Void)?
    var starsUpdateHandler: (() -> Void)?
    var gameOverHandler: (() -> Void)?
    var bonusResetHandler: (() -> Void)?
    
    private var powerUpButtons = [String: SKSpriteNode]()
    let buttonNames = ["magnet", "acceleration", "shield"]
    let buttonImages = ["pic3", "pic2", "pic1"]
    let buttonLockedImages = ["pic3o", "pic2o", "pic1o"]
    
    var button: SKSpriteNode!
    
    var isInvulnerable = false
   // var item: SKSpriteNode!
    private var activePowerUp: String? {
        didSet {
            if let powerUp = activePowerUp {
                activePowerUpLabel.text = "Power-Up: \(powerUp)"
                run(SKAction.sequence([
                    SKAction.wait(forDuration: 6.0),
                    SKAction.run { [weak self] in
                        self?.activePowerUp = nil
                    }
                ]))
            } else {
                activePowerUpLabel.text = ""
            }
        }
    }

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupScene()
        startSpawning()
    }

    private func setupScene() {
        backgroundColor = .clear
        setupBonusButtons()
        // Setup eagle
        eagle = SKSpriteNode(imageNamed: "Eagle")
        eagle.size = CGSize(width: 150, height: 40)
        eagle.position = CGPoint(x: eagle.size.width, y: UIScreen.main.bounds.height / 2)
        eagle.physicsBody = SKPhysicsBody(rectangleOf: eagle.size)
        eagle.physicsBody?.affectedByGravity = false 
        eagle.physicsBody?.isDynamic = true
        eagle.physicsBody?.categoryBitMask = 1
        eagle.physicsBody?.collisionBitMask = 0
        eagle.physicsBody?.contactTestBitMask = 2 | 4 // Coins and obstacles
        addChild(eagle)

        activePowerUpLabel = createLabel(position: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 40), text: "")

        addChild(activePowerUpLabel)

        
    }
    
    private func setupBonusButtons() {
        let buttonSize = CGSize(width: 60, height: 60)
        let buttonYPosition: CGFloat = 60
        let buttonSpacing: CGFloat = 80
        
        for (index, bonus) in buttonNames.enumerated() {
            button = SKSpriteNode(imageNamed: shopVM.bonuses[index].purchased ? buttonImages[index] : buttonLockedImages[index])
            button.size = buttonSize
            button.position = CGPoint(x: UIScreen.main.bounds.width - 150 - CGFloat(index) * buttonSpacing, y: buttonYPosition)
            button.name = bonus
            powerUpButtons[bonus] = button
            addChild(button)
        }
    }

    private func startSpawning() {
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnItem()
        }
        let waitAction = SKAction.wait(forDuration: 1.0)
        let sequence = SKAction.sequence([spawnAction, waitAction])
        run(SKAction.repeatForever(sequence))
    }

    private func spawnItem(speed: TimeInterval = 5.0) {
        guard !isGameOver else { return }
        
        let isBonus = Bool.random()
        let item: SKSpriteNode
        let cloudNumber = Int.random(in: 1...4)
        let bonusNum = Int.random(in: 1...2)
        if isBonus {
            item = SKSpriteNode(imageNamed: bonusNum == 1 ? "coin" : "star")
            if bonusNum == 1 {
                item.name = "coin"
            } else {
                item.name = "star"
            }
            
            item.size = CGSize(width: 40, height: 40)
            item.physicsBody?.categoryBitMask = 2
        } else {
           
            item = SKSpriteNode(imageNamed: "cloud\(cloudNumber)")
            item.name = "obstacle"
            if cloudNumber > 1 && cloudNumber < 4 && item.name == "obstacle" {
                item.size = CGSize(width: 72, height: 130)
            } else if cloudNumber == 1 && item.name == "obstacle" {
                item.size = CGSize(width: 72, height: 46)
            } else if cloudNumber == 4 && item.name == "obstacle" {
                item.size = CGSize(width: 114, height: 46)
            }
            
            item.physicsBody?.categoryBitMask = 4
        }
        
        if cloudNumber > 1 && cloudNumber < 4 && item.name == "obstacle" {
            item.position = CGPoint(x: size.width + item.size.width / 2, y: item.size.height / 8)
        } else {
            item.position = CGPoint(x: size.width + item.size.width / 2, y: CGFloat.random(in: 100...(size.height - 100)))
        }
        
        item.physicsBody = SKPhysicsBody(rectangleOf: item.size)
        item.physicsBody?.isDynamic = false
        addChild(item)
        
        // Adjusted movement speed
        let moveAction = SKAction.moveTo(x: -item.size.width, duration: speed)
        let removeAction = SKAction.removeFromParent()
        item.run(SKAction.sequence([moveAction, removeAction]), withKey: "movement")
    }
   

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            
            
            eagle.position.y = location.y
            
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if let nodeName = node.name, ["magnet", "acceleration", "shield"].contains(nodeName) {
                if nodeName == "magnet" {
                    activateBonus(0)
                    changeButtonTexture(for: node, to: buttonLockedImages[0])
                    
                } else if nodeName == "acceleration" {
                    activateBonus(1)
                    changeButtonTexture(for: node, to: buttonLockedImages[1])

                } else if nodeName == "shield" {
                    activateBonus(2)
                    changeButtonTexture(for: node, to: buttonLockedImages[2])

                }
                
               
                
            } else {
                print("Tapped on something else: \(node.name ?? "unknown")")
            }
        }
    }
    
    private func changeButtonTexture(for node: SKNode, to textureName: String) {
        if let spriteNode = node as? SKSpriteNode {
            spriteNode.texture = SKTexture(imageNamed: textureName)
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        let nodes = [nodeA, nodeB]

        if nodes.contains(where: { $0.name == "coin" }) {
            // Collect a coin
            coinsUpdateHandler?()
            nodes.first(where: { $0.name == "coin" })?.removeFromParent()
        } else if nodes.contains(where: { $0.name == "star" }) {
            starsUpdateHandler?()
            nodes.first(where: { $0.name == "star" })?.removeFromParent()
        } else if nodes.contains(where: { $0.name == "obstacle" }) {
            // Hit an obstacle
            if !isInvulnerable {
                endGame()
            } else {
                isInvulnerable = false
                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
//                    self.changeLightningAppearance(name: self.thunderName)
//                   
//                }
                
            }
            
        }
    }

    private func endGame() {
        if settingsVM.soundEnabled {
            playSound(named: "crash.mp3")
        }
        self.isPaused = true
        gameOverHandler?()
        removeAllActions()
        eagle.removeFromParent()
        let gameOverLabel = createLabel(position: CGPoint(x: size.width / 2, y: size.height / 2), text: "Game Over")
        addChild(gameOverLabel)
    }

    private func createLabel(position: CGPoint, text: String) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.fontSize = 20
        label.fontColor = .white
        label.position = position
        label.text = text
        return label
    }
    
    func restartGame() {
        self.removeAllChildren()
        self.isPaused = false
        isGameOver = false
        setupScene()
        startSpawning()
    }
    
    private func collectCoinsOnScreen() {
        if settingsVM.soundEnabled {
            playSound(named: "useBonus.mp3")
        }
        enumerateChildNodes(withName: "coin") { (node, _) in
            node.removeFromParent()
            self.coinsUpdateHandler?()
        }
        
        enumerateChildNodes(withName: "star") { (node, _) in
            node.removeFromParent()
            self.starsUpdateHandler?()
        }
    }
    
    private func runMagnetEffect() {
        let collectAction = SKAction.run { [weak self] in
            self?.collectCoinsOnScreen()
        }
        let waitAction = SKAction.wait(forDuration: 1.0)
        let repeatAction = SKAction.repeat(SKAction.sequence([collectAction, waitAction]), count: 6)
        
        run(repeatAction) { [weak self] in
            print("Magnet effect ended")
            self?.activePowerUp = nil // Reset the power-up after 6 seconds
        }
    }
    
    private func accelerateEagle() {
        activePowerUp = "Acceleration"
        
        // Speed multiplier
        let speedMultiplier: CGFloat = 2.0
        
        // Adjust the speed of all current items
        for node in children {
            if let spriteNode = node as? SKSpriteNode {
                spriteNode.speed *= speedMultiplier
                if let action = spriteNode.action(forKey: "movement") {
                    spriteNode.removeAction(forKey: "movement")
                    let remainingTime = action.duration / Double(speedMultiplier)
                    let moveAction = SKAction.moveTo(x: -spriteNode.size.width, duration: remainingTime)
                    spriteNode.run(moveAction, withKey: "movement")
                }
            }
        }
        
        // Temporarily speed up newly spawned items
        let originalDuration: TimeInterval = 5.0 // Original move duration for items
        let acceleratedDuration = originalDuration / Double(speedMultiplier)
        
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnItem(speed: acceleratedDuration)
        }
        let waitAction = SKAction.wait(forDuration: 1.0)
        let acceleratedSpawnSequence = SKAction.sequence([spawnAction, waitAction])
        let acceleratedSpawning = SKAction.repeat(acceleratedSpawnSequence, count: 6)
        
        run(acceleratedSpawning) { [weak self] in
            print("Acceleration effect ended")
            self?.activePowerUp = nil
        }
    }
    
    
    private func activateBonus(_ index: Int) {
        activePowerUp = nil
        guard shopVM.bonuses[index].purchased == true, activePowerUp == nil else {
            print("Button tapped: \(shopVM.bonuses[index]), but it's not available or another bonus is active.")
            return
        }
        
        print("Button tapped: \(shopVM.bonuses[index]) - activating bonus")
        
        
        if settingsVM.soundEnabled {
            playSound(named: "useBonus.mp3")
        }
        switch index {
        case 0:
            activePowerUp = "Magnet"
            runMagnetEffect()
            shopVM.useBonus(name: "Magnet")
//            button = SKSpriteNode(imageNamed: buttonLockedImages[index])
            
        case 1:
            activePowerUp = "Acceleration"
            accelerateEagle()
            shopVM.useBonus(name: "Acceleration")
            
        case 2:
            activePowerUp = "Shield"
            shopVM.useBonus(name: "Shield")
            isInvulnerable = true
        default:
            break
        }
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

extension GameScene: GameSceneDelegate {
    func pause() {
        self.isPaused = true
    }
    
    func resume() {
        self.isPaused = false
    }
    
    func restart() {
        print("restart")
        restartGame()
    }
}
