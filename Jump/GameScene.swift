//
//  GameScene.swift
//  Jump
//
//  Created by Xiulan Shi on 11/21/15.
//  Copyright (c) 2015 Xiulan Shi. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Layered Nodes
    
    // Background: a slow-moving layer that shows the distant landscape.
    var backgroundNode: SKNode!
    
    // Midground: faster-moving scenery made up of tree branches.
    var midgroundNode: SKNode!
    
    // Foreground: the fastest layer, containing the player character, stars and platforms that make up the core of the gameplay.
    var foregroundNode: SKNode!
    
    // HUD: the top layer that does not move and displays the score labels.
    var hudNode: SKNode!
    
    // Player
    var player: SKNode!
    
    // To Accommodate iPhone 6 -- This ensures that your graphics are scaled and positioned properly across all iPhone models.
    var scaleFactor: CGFloat!
    
    // Tap To Start node
    let tapToStartNode = SKSpriteNode(imageNamed: "TapToStart")
    
    // Height at which level ends
    var endLevelY = 0
    
    // Motion manager for accelerometer
    let motionManager = CMMotionManager()
    
    // Acceleration value from accelerometer
    var xAcceleration: CGFloat = 0.0
    
    // Labels for score and stars
    var lblScore: SKLabelNode!
    var lblStars: SKLabelNode!
    
    // Max y reached by player
    var maxPlayerY: Int!
    
    // Game over
    var gameOver = false
    
    // Second Step: This is the blank canvas onto which you’ll add your game nodes.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor.whiteColor()
        
        //Third Add some gravity -- Gravity has no influence along the x-axis, but produces a downward force along the y-axis.
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        
        // Set contact delegate
        physicsWorld.contactDelegate = self
        
        // The graphics are sized for the standard 320-point width of most iPhone models, so the scale factor here will help with the conversion on other screen sizes.
        scaleFactor = self.size.width / 320.0
        
        // Reset
        maxPlayerY = 80
        GameState.sharedInstance.score = 0
        gameOver = false
        
        // Create the game nodes
        // Background
        backgroundNode = createBackgroundNode()
        addChild(backgroundNode)
        
        // Midground
        midgroundNode = createMidgroundNode()
        addChild(midgroundNode)
        
        // Foreground
        foregroundNode = SKNode()
        addChild(foregroundNode)
        
        // HUD
        hudNode = SKNode()
        addChild(hudNode)
        
        // Load the level
        let levelPlist = NSBundle.mainBundle().pathForResource("Level01", ofType: "plist")
        let levelData = NSDictionary(contentsOfFile: levelPlist!)!
        
        // Height at which the player ends the level
        endLevelY = levelData["EndY"]!.integerValue!
        
//        // Add a platform
//        let platform = createPlatformAtPosition(CGPoint(x: 160, y: 320), ofType: .Normal)
//        foregroundNode.addChild(platform)
        
        // Add the platforms -- Load the platform dictionary from levelData
        let platforms = levelData["Platforms"] as! NSDictionary
        let platformPatterns = platforms["Patterns"] as! NSDictionary
        let platformPositions = platforms["Positions"] as! [NSDictionary]
        
        // Loop through the position array
        for platformPosition in platformPositions {
            let patternX = platformPosition["x"]?.floatValue
            let patternY = platformPosition["y"]?.floatValue
            let pattern = platformPosition["pattern"] as! NSString
            
            // Look up the pattern
            let platformPattern = platformPatterns[pattern] as! [NSDictionary]
            
            // For each item in the array, load the relevant pattern and instantiate a PlatformNode of the correct type at the specified (x, y) positions.
            for platformPoint in platformPattern {
                let x = platformPoint["x"]?.floatValue
                let y = platformPoint["y"]?.floatValue
                let type = PlatformType(rawValue: platformPoint["type"]!.integerValue)
                let positionX = CGFloat(x! + patternX!)
                let positionY = CGFloat(y! + patternY!)
                let platformNode = createPlatformAtPosition(CGPoint(x: positionX, y: positionY), ofType: type!)
                
                // Add all platformNode to the foregroundNode
                foregroundNode.addChild(platformNode)
            }
        }
        
//        // Add a star
//        let star = createStarAtPosition(CGPoint(x: 160, y: 220), ofType: .Special)
//        foregroundNode.addChild(star)
        
        // Add the stars
        let stars = levelData["Stars"] as! NSDictionary
        let starPatterns = stars["Patterns"] as! NSDictionary
        let starPositions = stars["Positions"] as! [NSDictionary]
        
        for starPosition in starPositions {
            let patternX = starPosition["x"]?.floatValue
            let patternY = starPosition["y"]?.floatValue
            let pattern = starPosition["pattern"] as! NSString
            
            // Look up the pattern
            let starPattern = starPatterns[pattern] as! [NSDictionary]
            for starPoint in starPattern {
                let x = starPoint["x"]?.floatValue
                let y = starPoint["y"]?.floatValue
                let type = StarType(rawValue: starPoint["type"]!.integerValue)
                let positionX = CGFloat(x! + patternX!)
                let positionY = CGFloat(y! + patternY!)
                let starNode = createStarAtPosition(CGPoint(x: positionX, y: positionY), ofType: type!)
                foregroundNode.addChild(starNode)
            }
        }
        
        // Add the player
        player = createPlayer()
        foregroundNode.addChild(player)
        
        // Tap to Start
        tapToStartNode.position = CGPoint(x: self.size.width / 2, y: 180.0)
        hudNode.addChild(tapToStartNode)
        
        // Build the HUD
        
        // Stars
        // 1
        // add a star graphic in the top-left corner of the scene to tell the player that the following number is the collected star count.
        let star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPoint(x: 25, y: self.size.height-30)
        hudNode.addChild(star)
        
        // 2
        // place a left-aligned SKLabelNode
        lblStars = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblStars.fontSize = 30
        lblStars.fontColor = SKColor.whiteColor()
        lblStars.position = CGPoint(x: 50, y: self.size.height-40)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        // 3
        // initialize the label with the number of stars from GameState
        lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
        hudNode.addChild(lblStars)
        
        // Score
        // 4
        //add a right-aligned SKLabelNode in the top-right corner of the scene
        lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 30
        lblScore.fontColor = SKColor.whiteColor()
        lblScore.position = CGPoint(x: self.size.width-20, y: self.size.height-40)
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        
        // 5
        // initialize that label to zero
        lblScore.text = "0"
        hudNode.addChild(lblScore)
        
        // CoreMotion
        // 1
        // accelerometerUpdateInterval defines the number of seconds between updates from the accelerometer. A value of 0.2 produces a smooth update rate for accelerometer changes.
        motionManager.accelerometerUpdateInterval = 0.2
        
        // 2
        // enable the accelerometer and provide a block of code to execute upon every accelerometer update.
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler:
            {
                (accelerometerData: CMAccelerometerData?, error: NSError?) in
                // 3 
                // get the acceleration details from the latest accelerometer data passed into the block
                let acceleration = accelerometerData!.acceleration
                // 4
                // calculate the player node’s x-axis acceleration. could use the x-value directly from the accelerometer data, but get much smoother movement using a value derived from three quarters of the accelerometer’s x-axis acceleration (say that three times fast!) and one quarter of the current x-axis acceleration.
                self.xAcceleration = (CGFloat(acceleration.x) * 0.75) + (self.xAcceleration * 0.25)
            })
        
    }
    
    // First add the background node
    
    func createBackgroundNode() -> SKNode {
        // 1 
        // Create the background node. SKNode’s have no visual content, but do have a position in the scene. This means you can move the node around and its child nodes will move with it.

        let backgroundNode = SKNode()
        let ySpacing = 64.0 * scaleFactor
        
        // 2
        // Go through images until the entire background is built
        for index in 0...19 {
            
            // 3
            // Each child node is made up of an SKSpriteNode with the sequential background image loaded from your resources.
            let node = SKSpriteNode(imageNamed:String(format: "Background%02d", index + 1))
            
            // 4
            // Changing each node’s anchor point to its bottom center makes it easy to stack in sections.
            node.setScale(scaleFactor)
            node.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            node.position = CGPoint(x: self.size.width / 2, y: ySpacing * CGFloat(index))
            
            // 5
            // Add each child node to the background node.
            backgroundNode.addChild(node)
        }
        
        // 6
        // Return the completed background node
        return backgroundNode
    }
    
    // Second add the player node
    
    func createPlayer() -> SKNode {
        
        // create the player node and position the player horizontally centered and just above the bottom of the scene
        let playerNode = SKNode()
        playerNode.position = CGPoint(x: self.size.width / 2, y: 80.0)
        
        // add the SKSpriteNode containing the player sprite to it as a child.
        let sprite = SKSpriteNode(imageNamed: "Player")
        playerNode.addChild(sprite)
        
        // 1 
        // Each physics body needs a shape that the physics engine can use to test for collisions. The most efficient body shape to use in collision detection is a circle (easier to detect if overlaps another circle), and fortunately a circle fits the player node very well. The radius of the circle is half the width of the sprite.
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        
        // 2
        // Physics bodies can be static or dynamic. Dynamic bodies are influenced by the physics engine and are thus affected by forces and impulses. Static bodies are not, but can still use them in collision detection. A static body such as a wall or a solid platform will never move, but things can bump into it. Since we want the player node to be affected by gravity, you set its dynamic property to true.
       // playerNode.physicsBody?.dynamic = true
        
        // change it to false
        playerNode.physicsBody?.dynamic = false
        
        // 3
        // the player node need to remain upright at all times and so disable rotation of the node.
        playerNode.physicsBody?.allowsRotation = false
        
        // 4
        // Adjust the settings on the player node’s physics body so that it has no friction or damping. However, set its restitution to 1, which means the physics body will not lose any of its momentum during collisions.
        playerNode.physicsBody?.restitution = 1.0
        playerNode.physicsBody?.friction = 0.0
        playerNode.physicsBody?.angularDamping = 0.0
        playerNode.physicsBody?.linearDamping = 0.0
        
        
        // 1
        // Since this is a fast-moving game, ask Sprite Kit to use precise collision detection for the player node’s physics body. After all, the gameplay for Uber Jump is all about the player node’s collisions, so want it to be as accurate as possible!
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
        
        // 2
        // This defines the physics body’s category bit mask
        playerNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        
        // 3
        // By setting collisionBitMask to zero, tell Sprite Kit that we don't want its physics engine to simulate any collisions for the player node. That’s because we’re going to handle those collisions ourselves!
        playerNode.physicsBody?.collisionBitMask = 0
        
        // 4
        // Want to be informed when the player node touches any stars or platforms.
        playerNode.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Star | CollisionCategoryBitmask.Platform
        
        return playerNode
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 1
        // If we're already playing, ignore touches
        if player.physicsBody!.dynamic {
            return
        }
        
        // 2
        // Remove the Tap to Start node
        tapToStartNode.removeFromParent()
        
        // 3
        // Start the player by putting them into the physics simulation
        player.physicsBody?.dynamic = true
        
        // 4
        // Give the player node an initial upward impulse to get them started
        player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 20.0))
    }
    
    func createStarAtPosition(position: CGPoint, ofType type: StarType) -> StarNode {
        // 1
        // instantiate StarNode and set it position
        let node = StarNode()
        let thePosition = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.position = thePosition
        node.name = "NODE_STAR"
        
        // 2
        // Assign the star's graphic using an SKSpriteNode mode
//        var sprite: SKSpriteNode
//        sprite = SKSpriteNode(imageNamed: "Star")
//        node.addChild(sprite)
        
        // Set the star type and assign the graphic
        node.starType = type
        var sprite: SKSpriteNode
        if type == .Special {
            sprite = SKSpriteNode(imageNamed: "StarSpecial")
        } else {
            sprite = SKSpriteNode(imageNamed: "Star")
        }
        node.addChild(sprite)
        
        // 3
        // Give the node a circular physics body – use it for collision detection with other objects in the game.
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        
        // 4
        // Make the physics body static, because don’t want gravity or any other physics simulation to influence the stars.
        node.physicsBody?.dynamic = false
        
        // assign the star’s category and clear its collisionBitMask so it won’t collide with anything
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        // 1
        // initialize the updateHUD flag, which we will use at the end of the method to determine whether or not to update the HUD for collisions that result in points.
        var updateHUD = false
        
        // 2
        // SKPhysicsContact does not guarantee which physics body will be in bodyA and bodyB.
        //  this line figures out which one is not the player node
        let whichNode = (contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node
        let other = whichNode as! GameObjectNode
        
        // 3
        // Call collisionWithPlayer once identified which object is not the player
        updateHUD = other.collisionWithPlayer(player)
        
        // Update the HUD if necessary
        if updateHUD {
            lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
            lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        }
    }
    
    func createPlatformAtPosition(position: CGPoint, ofType type: PlatformType) -> PlatformNode {
        // 1
        // instantiate the PlatformNode and set its position, name and type.
        let node = PlatformNode()
        let thePosition = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.position = thePosition
        node.name = "NODE_PLATFORM"
        node.platformType = type
        
        // 2
        // choose the correct graphic for the SKSpriteNode based on the platform type.
        var sprite: SKSpriteNode
        if type == .Break {
            sprite = SKSpriteNode(imageNamed: "PlatformBreak")
        } else {
            sprite = SKSpriteNode(imageNamed: "Platform")
        }
        node.addChild(sprite)
        
        // 3
        // set up the platform’s physics, including its collision category.
        node.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        node.physicsBody?.dynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Platform
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }
    
    func createMidgroundNode() -> SKNode {
        // Create the node
        let theMidgroundNode = SKNode()
        var anchor: CGPoint!
        var xPosition: CGFloat!
        
        // 1
        // Add some branches to the midground
        for index in 0...9 {
            var spriteName: String
            // 2
            // There are two different branch images, one showing branches coming in from the left of the screen and the other from the right.
            let r = arc4random() % 2
            if r > 0 {
                spriteName = "BranchRight"
                anchor = CGPoint(x: 1.0, y: 0.5)
                xPosition = self.size.width
            } else {
                spriteName = "BranchLeft"
                anchor = CGPoint(x: 0.0, y: 0.5)
                xPosition = 0.0
            }
            // 3
            // space the branches at 500-point intervals on the y-axis of the midground node
            let branchNode = SKSpriteNode(imageNamed: spriteName)
            branchNode.anchorPoint = anchor
            branchNode.position = CGPoint(x: xPosition, y: 500.0 * CGFloat(index))
            theMidgroundNode.addChild(branchNode)
        }
        
        // Return the completed midground node
        return theMidgroundNode
    }
    
    override func update(currentTime: NSTimeInterval) {
        if gameOver {
            return
        }
        
        // New max height ?
        // 1
        // check whether the player node has travelled higher than it has yet travelled in this play-through
        if Int(player.position.y) > maxPlayerY! {
            // 2
            // add to the score the difference between the player node’s current y-coordinate and the max y-value
            GameState.sharedInstance.score += Int(player.position.y) - maxPlayerY!
            // 3
            // set the new max y-value
            maxPlayerY = Int(player.position.y)
            // 4
            // update the score label with the new score
            lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        }
        
        // Remove game objects that have passed by
        foregroundNode.enumerateChildNodesWithName("NODE_PLATFORM", usingBlock: {
            (node, stop) in
            let platform = node as! PlatformNode
            platform.checkNodeRemoval(self.player.position.y)
        })
        
        foregroundNode.enumerateChildNodesWithName("NODE_STAR", usingBlock: {
            (node, stop) in
            let star = node as! StarNode
            star.checkNodeRemoval(self.player.position.y)
        })
        
        // Calculate player y offset
        if player.position.y > 200.0 {
            backgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0)/10))
            midgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0)/4))
            foregroundNode.position = CGPoint(x: 0.0, y: -(player.position.y - 200.0))
        }
        
        // 1
        // Check if we've finished the level
        if Int(player.position.y) > endLevelY {
            endGame()
        }
        
        // 2
        // Check if we've fallen too far
        if Int(player.position.y) < maxPlayerY - 800 {
            endGame()
        }
    }
    
    override func didSimulatePhysics() {
        // 1
        // Set velocity based on x-axis acceleration
        player.physicsBody?.velocity = CGVector(dx: xAcceleration * 400.0, dy: player.physicsBody!.velocity.dy)
        // 2
        // Check x bounds
        if player.position.x < -20.0 {
            player.position = CGPoint(x: self.size.width + 20.0, y: player.position.y)
        } else if (player.position.x > self.size.width + 20.0) {
            player.position = CGPoint(x: -20.0, y: player.position.y)
        }
    }
    
    func endGame() {
        // 1
        // set gameOver to true
        gameOver = true
        
        // 2
        // Save stars and high score
        GameState.sharedInstance.saveState()
        
        // 3
        // instantiate an EndGameScene and transition to it by fading over a period of 0.5 seconds
        let reveal = SKTransition.fadeWithDuration(0.5)
        let endGameScene = EndGameScene(size: self.size)
        self.view!.presentScene(endGameScene, transition: reveal)
    }


    
    
}
