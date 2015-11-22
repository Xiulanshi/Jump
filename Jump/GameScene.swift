//
//  GameScene.swift
//  Jump
//
//  Created by Xiulan Shi on 11/21/15.
//  Copyright (c) 2015 Xiulan Shi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    // Tap To Start node
    let tapToStartNode = SKSpriteNode(imageNamed: "TapToStart")
    
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
    
    // Second Step: This is the blank canvas onto which you’ll add your game nodes.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor.whiteColor()
        
        //Third Add some gravity -- Gravity has no influence along the x-axis, but produces a downward force along the y-axis.
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        
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
        
        // Add a star
        let star = createStarAtPosition(CGPoint(x: 160, y: 220))
        foregroundNode.addChild(star)
        
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
    
    func createStarAtPosition(position: CGPoint) -> StarNode {
        // 1
        // instantiate StarNode and set it position
        let node = StarNode()
        let thePosition = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.position = thePosition
        node.name = "NODE_STAR"
        
        // 2
        // Assign the star's graphic using an SKSpriteNode mode
        var sprite: SKSpriteNode
        sprite = SKSpriteNode(imageNamed: "Star")
        node.addChild(sprite)
        
        // 3
        // Give the node a circular physics body – use it for collision detection with other objects in the game.
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        
        // 4
        // Make the physics body static, because don’t want gravity or any other physics simulation to influence the stars.
        node.physicsBody?.dynamic = false
        
        return node
    }

    
    
}
