//
//  GameObjectNode.swift
//  Jump
//
//  Created by Xiulan Shi on 11/21/15.
//  Copyright © 2015 Xiulan Shi. All rights reserved.
//

import SpriteKit

// Define categories
struct CollisionCategoryBitmask {
    static let Player: UInt32 = 0x00
    static let Star: UInt32 = 0x01
    static let Platform: UInt32 = 0x02
}

// Identify the StarType
enum StarType: Int {
    case Normal = 0
    case Special
}


class GameObjectNode: SKNode {
    
    //call collisionWithPlayer whenever the player node collides with this object
    func collisionWithPlayer(player: SKNode) -> Bool {
        return false
    }
    
    //call checkNodeRemoval every frame to give the node a chance to remove itself
    func checkNodeRemoval(playerY: CGFloat) {
        // check to see if the player node has traveled more than 300 points beyond this node.
        // If so, then the method removes the node from its parent node and thus, removes it from the scene.
        if playerY > self.position.y + 300.0 {
            self.removeFromParent()
        }
    }

}

// Add the Star Class
class StarNode: GameObjectNode {
    // Store the starType
    var starType: StarType!
    
    // Add the starSound property
    let starSound = SKAction.playSoundFileNamed("StarPing.wav", waitForCompletion: false)
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        // Boost the player up
        player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 400.0)
        
//        // Remove this Star
//        self.removeFromParent()
        
        // Play sound
        runAction(starSound, completion: {
            // Remove this Star
            self.removeFromParent()
        })
        
        // The HUD needs updating to show the new stars and score
        return true
    }
}
