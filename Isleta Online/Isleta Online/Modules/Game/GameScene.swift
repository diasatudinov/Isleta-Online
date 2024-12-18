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
    private var eagle: SKSpriteNode!
    private var activePowerUpLabel: SKLabelNode!
    
    private var score = 0
    private var coins = 0
    private var isGameOver = false
    
    var coinsUpdateHandler: (() -> Void)?
    var starsUpdateHandler: (() -> Void)?
    var gameOverHandler: (() -> Void)?
    var bonusResetHandler: (() -> Void)?
    
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

    private func startSpawning() {
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnItem()
        }
        let waitAction = SKAction.wait(forDuration: 1.0)
        let sequence = SKAction.sequence([spawnAction, waitAction])
        run(SKAction.repeatForever(sequence))
    }

    private func spawnItem() {
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

        // Move the item across the screen
        let moveAction = SKAction.moveTo(x: -item.size.width, duration: 5.0)
        let removeAction = SKAction.removeFromParent()
        item.run(SKAction.sequence([moveAction, removeAction]))
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }
        
    }

//    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
//        guard !isGameOver else { return }
//        let moveAction: SKAction
//        if gesture.direction == .up {
//            moveAction = SKAction.moveBy(x: 0, y: 100, duration: 0.2)
//        } else {
//            moveAction = SKAction.moveBy(x: 0, y: -100, duration: 0.2)
//        }
//        eagle.run(moveAction)
//    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        if let touch = touches.first {
            let location = touch.location(in: self)
            eagle.position.y = location.y
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
            endGame()
        }
    }

    private func endGame() {
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
