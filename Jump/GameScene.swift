//
//  GameScene.swift
//  Jump
//
//  Created by Xiulan Shi on 11/21/15.
//  Copyright (c) 2015 Xiulan Shi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    // Layered Nodes
    
    // Background: a slow-moving layer that shows the distant landscape.
    var backgroundNode: SKNode!
    
    // Midground: faster-moving scenery made up of tree branches.
    var midgroundNode: SKNode!
    
    // Foreground: the fastest layer, containing the player character, stars and platforms that make up the core of the gameplay.
    var foregroundNode: SKNode!
    
    // HUD: the top layer that does not move and displays the score labels.
    var hudNode: SKNode!
    
    // To Accommodate iPhone 6 -- This ensures that your graphics are scaled and positioned properly across all iPhone models.
    var scaleFactor: CGFloat!
    
    // Second Step: This is the blank canvas onto which you’ll add your game nodes.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor.whiteColor()
        
        // The graphics are sized for the standard 320-point width of most iPhone models, so the scale factor here will help with the conversion on other screen sizes.
        scaleFactor = self.size.width / 320.0
        
        // Create the game nodes
        // Background
        backgroundNode = createBackgroundNode()
        addChild(backgroundNode)
    }
    
    // First add the background node
    
    func createBackgroundNode() -> SKNode {
        // 1 
        // Create the node. SKNode’s have no visual content, but do have a position in the scene. This means you can move the node around and its child nodes will move with it.

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
}
