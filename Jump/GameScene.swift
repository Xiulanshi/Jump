//
//  GameScene.swift
//  Jump
//
//  Created by Xiulan Shi on 11/21/15.
//  Copyright (c) 2015 Xiulan Shi. All rights reserved.
//

import SpriteKit

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
        
        // Create the game nodes
        // Background
        backgroundNode = createBackgroundNode()
        addChild(backgroundNode)
        
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
            // 4 TODO: Update HUD in Part 2
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

    
    
}
