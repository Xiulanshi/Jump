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

// Identify the PlatformType
enum PlatformType: Int {
    case Normal = 0
    case Break
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
        
        // Award score
        GameState.sharedInstance.score += (starType == .Normal ? 20 : 100)
        
        // Award stars
        GameState.sharedInstance.stars += (starType == .Normal ? 1 : 5)

        
        // The HUD needs updating to show the new stars and score
        return true
    }
}

class PlatformNode: GameObjectNode {
    var platformType: PlatformType!
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        // 1
        // Only bounce the player if he's falling
        if player.physicsBody?.velocity.dy < 0 {
            // 2
            //  give the player node a vertical boost to make it bounce off the platform, accomplish this the same way you did for the star, but with a less powerful boost.
            player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 250.0)
            
            // 3
            // Remove if it is a Break type platform
            if platformType == .Break {
                self.removeFromParent()
            }
        }
        
        // 4
        // No stars for platforms
        return false
    }
}
