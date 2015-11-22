//
//  GameObjectNode.swift
//  Jump
//
//  Created by Xiulan Shi on 11/21/15.
//  Copyright © 2015 Xiulan Shi. All rights reserved.
//

import SpriteKit

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
