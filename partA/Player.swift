//
//  Player.swift
//  partA
//
//  Created by 成沢淳史 on 2016/12/18.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import SceneKit

class Player : Charactor
{
    var timeAtDamaged :  CFTimeInterval = CACurrentMediaTime()
    var timeAtAtkEnd : CFTimeInterval = CACurrentMediaTime()
    
    required init(node: SCNNode, hp: Int, assetNames assets: [String] = []) {
        super.init(node: node, hp: hp, assetNames: assets)
        self.setPhysics()
    }
    
    class func setup() -> Player
    {
        let playerNode : SCNNode! = loadNode(Asset: "art.scnassets/charactorA/wait.dae", Name: "geometry")
        playerNode.scale = SCNVector3Make(30, 30, 30)
        let assets = ["art.scnassets/charactorA/dash.dae", "art.scnassets/charactorA/atk.dae"]
        return Player.init(node: playerNode, hp: 3, assetNames: assets)
    }
    
    
    func setPhysics()
    {
        // set physics body to player.
        var opt : Dictionary<SCNPhysicsShape.Option, Any> = [:]
        opt[SCNPhysicsShape.Option.type] = SCNPhysicsShape.ShapeType.boundingBox
        opt[SCNPhysicsShape.Option.scale] = self.node.scale * 0.7
        opt[SCNPhysicsShape.Option.keepAsCompound] = false
        
        let shape = SCNPhysicsShape.init(node: self.node, options: opt)
        let body = SCNPhysicsBody.init(type: SCNPhysicsBodyType.kinematic, shape: shape)
        self.node.physicsBody = body
        
        self.node.physicsBody?.categoryBitMask = 0b0100
        self.node.physicsBody?.contactTestBitMask = 0b1000

    }
    
    override func update() {
        // 
        if self.isPaused { return }
        
        if self.hp < 0 
        {
            if self.hp == -999 {
                return 
            } else {
                self.hp = -999
                self.delegate?.gameOver()
            }
        }
        
    }
    
    override func damaged(from: SCNNode) {
        super.damaged(from: from)
        self.runAnimation(id: 0)
        if (CACurrentMediaTime() - self.timeAtDamaged) > 1.0 {
            self.timeAtDamaged = CACurrentMediaTime()            
            self.hp -= 1
            print("hp : \(self.hp)")            
        }
    }
    
    func atack() {
        self.atkA()

    }
    
    func atkA()
    {
        let tolerance : CFTimeInterval = 1.5
        if CACurrentMediaTime() < self.timeAtAtkEnd - tolerance
        {
            self.node.physicsBody?.categoryBitMask |= 0x20
            return
        } else {
            self.moveForward(rot: self.theta, step: 0.2)
            self.timeAtAtkEnd = CACurrentMediaTime() + 2.0
            self.runAnimation(id: 2, speed: 3.0)
            let a = SCNAction.wait(duration: 0.25)
            let b = SCNAction.run({_ in 
                self.runAnimation(id: 0)
            })
            let c = SCNAction.sequence([a, b])
            self.node.runAction(c, completionHandler: { _ in
                self.node.physicsBody?.categoryBitMask = 0x04
            })
        }
        
    }
    
    func inspect()
    {
        /** 近くの物を調べるとき **/
        if let saveP = self.node.parent!.childNode(withName: "save", recursively: false) {
            if distance(saveP, self.node) < 0.5
            {
                self.delegate?.eventCall(event: "save")                    
            }
        }

    }
    
    override func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB

        
        if  (nodeA.physicsBody!.categoryBitMask | nodeB.physicsBody!.categoryBitMask) & 0b001000 > 0
        {
            if CACurrentMediaTime() < self.timeAtAtkEnd {
//                print("invalid damage")
                return
            } 
                
            
            if nodeA.physicsBody!.categoryBitMask & 0b1000 > 0 {
                self.damaged(from: nodeA)
            } else {
                self.damaged(from: nodeB)
            }
        }
    }
}
