//
//  Enemy.swift
//  partA
//
//  Created by 成沢淳史 on 2016/12/18.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import SceneKit

class EnemyA : Charactor
{
    var timerAI : Timer!
    private var points : [SCNNode] = []
    private var point : Int = 0
    
    required init(node: SCNNode, hp: Int, assetNames assets: [String] = []) {
        super.init(node: node, hp: hp, assetNames: assets)
        self.step = 0.03
        self.timerAI = Timer.scheduledTimer(timeInterval: 1.00, target: self, selector: #selector(wandering), userInfo: nil, repeats: true)
        self.timerAI.fire()
        
        self.setPhysics()

    }
    
    class func setup() -> EnemyA
    {
        let n : SCNNode! = loadNode(Asset: "art.scnassets/EnemyA/walk.dae", Name: "Enemy")!
        let assets : [String] = ["art.scnassets/EnemyA/atk.dae"]
        n.scale = SCNVector3Ones * 0.6
        return EnemyA.init(node: n, hp: 3, assetNames: assets)
        
    }
    
    func setPhysics()
    {
        var options : Dictionary<SCNPhysicsShape.Option, Any> = [:]
        options[SCNPhysicsShape.Option.scale] = self.node.scale
        options[SCNPhysicsShape.Option.type] = SCNPhysicsShape.ShapeType.boundingBox
        let body = SCNPhysicsBody.init(type: SCNPhysicsBodyType.kinematic, shape: SCNPhysicsShape.init(node: self.node, options: options))
        body.categoryBitMask = 0b1000
        self.node.physicsBody = body
    }
    
    func rotation() {
        self.theta += M_PI_4
    }
    
    func wandering()
    {
        /** とりあえずコントロールポイントに沿って歩かせとく */
        if self.isPaused { return }
        if points.count == 0 { return }
        let d = distance(points[point], self.node)
        if d < 0.1 {
            point += 1
            if point >= points.count
            {
                point = 0
                self.points = points.reversed()
            }
            
        } else {
            let r = (points[point].position - self.node.position).theta
            self.theta = r
            self.moveForward(rot: r)
        }
    }
    
    override func update() {
        // 
        
        if self.isPaused { return }
        
        if self.hp < 0 {
            self.node.isHidden = true
            self.node.removeFromParentNode()
        }
        
        searchTarget(target: 0b0100)

    }
    
    func searchTarget(target mask: Int)
    {
        /**
         視角 45 度でプレイヤーを見つけたらそっちに歩かせる
        **/
        
        guard let parent = self.node.parent else { return }
        
        for child in parent.childNodes
        {
            guard let body = child.physicsBody else { continue }
            
            if body.categoryBitMask & mask > 0 
            {
                let r = child.position - self.node.position                
                let d = distance(self.node, child)
                let dr = deltaTheta(From: r.theta, To: self.theta)
                if d < 3.0 && abs(dr) < M_PI_4 
                {
                    self.timer.invalidate()
                    self.moveForward(rot: r.theta)
                    if d < 1.0
                    {
                        self.atack()
                    }
                    return 
                } else {
                    if !self.timer.isValid {
                        self.timer = Timer.scheduledTimer(timeInterval: 1.00, target: self, selector: #selector(rotation), userInfo: nil, repeats: true)                        
                        self.timer.fire()
                    }
                    return                    
                }
            }
        }
        return 
    }
    
    func atack() {
        if self.node.action(forKey: "atk") != nil  { return }

        self.moveForward(rot: self.theta, step: 1.0)
        self.runAnimation(id: 2, speed: 2.0)
        let a = SCNAction.wait(duration: 0.5)
        let b = SCNAction.run({_ in 
            self.runAnimation(id: 0)
        })
        let c = SCNAction.sequence([a, b])
        self.node.runAction(c, forKey: "atk")
        
        
    }
    
    override func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if (contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask) & 0b100000 > 0
        {
            if contact.nodeA.physicsBody!.categoryBitMask & 0x20 > 0{
                self.damaged(from: contact.nodeA)
            } else {
                self.damaged(from: contact.nodeB)
            }
            self.hp -= 1
            print("enemy hp \(hp)")
        }
    }
    
    func loadPositions(NodeNames names : [String])
    {
        guard let parent = self.node.parent else {
            print("WARN : PARENT NOT FOUND ")
            return 
        }
        
        let arr = parent.childNodes(passingTest: { (node, p) in
            return names.contains(node.name!) 
        })
        self.points = arr
        
        if self.points.count != 0 
        {
            self.node.position = self.points[0].position
        }
    }
}

class EnemyB : EnemyA 
{
    required init(node: SCNNode, hp: Int, assetNames assets: [String]) {
        super.init(node: node, hp: hp, assetNames: assets)
        self.timerAI = Timer.scheduledTimer(timeInterval: 1.00, target: self, selector: #selector(rotation), userInfo: nil, repeats: true)
        
    }
    
    override class func setup() -> EnemyB
    {
        let n : SCNNode! = loadNode(Asset: "art.scnassets/EnemyA/walk.dae", Name: "Enemy")!
        let assets : [String] = ["art.scnassets/EnemyA/atk.dae"]
        n.scale = SCNVector3Ones * 0.6
        return EnemyB.init(node: n, hp: 3, assetNames: assets)
        
    }

    
}


