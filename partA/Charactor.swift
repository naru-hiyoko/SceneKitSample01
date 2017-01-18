//
//  Charactor.swift
//  partA
//
//  Created by 成沢淳史 on 2016/12/12.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import SceneKit

protocol CharactorProtocol {
    
    init(node : SCNNode, hp : Int, assetNames assets : [String])
    
    var hp : Int { set get }
    var theta : CGFloat { get set }
    var node : SCNNode { set get }
    var pauses : [SCNNode] { get set }
    var height : CGFloat { get set }
//    var step : CGFloat { get set }
    var init_eulerAngles : SCNVector3 { get }
    
//    var flags : [String] { get set }
    var delegate : GameView? { get set } 
    
    func update()
    
    func moveForward(rot : CGFloat, step : CGFloat)
    func heightAt(_ at : SCNVector3, mask : Int) -> CGFloat
    func isFaceWall(los : SCNVector3, mask : Int) -> Bool

    func loadAssets(assets : [String])
    var hasAnimations : Bool { get }    
    func runAnimation(id : Int, speed : Float)
    func runAnimationAction(id : Int, duration : CFTimeInterval)
    func pauseAnimation()
    func resumeAnimation()
    
    func nearestNode(mask : Int) -> (SCNNode, CGFloat)?    
    
}

// [z, x]
public let directions : [(CGFloat, CGFloat)] = [
    (1, 0),
    (1, 1),
    (0, 1),
    (-1, 1),
    (-1, 0),
    (-1, -1),
    (0, -1),
    (1, -1),
    (-1, 0),
]


public class Charactor : NSObject, CharactorProtocol
{
    var hp : Int

    var node : SCNNode
    /** animation node*/
    var pauses: [SCNNode] = []
    
    /** SCNNode.geometry boundingBox に置き換え予定*/
    var height : CGFloat
    var step : CGFloat = 0.1
    
//    var flags: [String] = []
    var delegate: GameView? = nil
    
    var isPaused = false
    
    var init_eulerAngles : SCNVector3
    
    dynamic var theta : CGFloat = 0.0
    
    var timer : Timer!
    
    required public init(node : SCNNode, hp : Int, assetNames assets : [String] = []) {
        
        self.hp = hp
        self.node = node
        self.height = 0.5
        self.init_eulerAngles = self.node.eulerAngles
        
        super.init()        
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        self.timer.fire()
        
        self.addObserver(self, forKeyPath: "theta", options: NSKeyValueObservingOptions.new, context: nil)        
        self.loadAssets(assets: assets)


    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "theta")
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "theta"
        {
            let tr = adjustTheta(self.theta)
            self.removeObserver(self, forKeyPath: "theta")
            self.theta = tr
            self.addObserver(self, forKeyPath: "theta", options: NSKeyValueObservingOptions.new, context: nil)

            self.node.eulerAngles = SCNVector3Make(self.init_eulerAngles.x, self.theta, self.init_eulerAngles.z)
        }
    }
    
    func keyDown(with event: NSEvent) {    


    }
    
    func keyUp(with event: NSEvent) {        
        self.node.removeAction(forKey: "move")
        self.node.removeAction(forKey: "rotate_2d")

    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        //

        if (contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask) & 0b01100 == 0b01100
        {
            if contact.nodeA == self {
                self.damaged(from: contact.nodeB)
            } else {
                self.damaged(from: contact.nodeA)
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        //
    }
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact)
    {
        //
        
    }
    
    func update()
    {
        
    }

//    func moveTo()
    func moveForward(rot : CGFloat, step : CGFloat = 0.1)
    {
      
        var arr = directions.map({ (z, x) -> CGFloat in
            var r = -1.0 * ((M_PI - abs(atan2(-x, -z))) * sign(atan2(-x, -z)))
            if r == -M_PI {
                r = M_PI
            }
            
            return abs(rot - r)
        })
        arr.append(abs(-M_PI - rot))
        arr.remove(at: arr.count - 2)
        
        
        let index = arr.index(of: arr.min()!)!
        let (dz, dx) = directions[index]
        
        if self.isFaceWall(los: SCNVector3Make(dx * step, 0.0, dz * step)) { return }
        
        let nh = heightAt(SCNVector3Make(self.node.position.x + dx * step,
                                         self.node.position.y,
                                         self.node.position.z + dz * step))
//        print(nh)
        if nh != -999.0 {
            self.node.position.y = nh
            self.node.position.x += dx * step
            self.node.position.z += dz * step
        }

    }
    

    func rotate2d(by th : CGFloat, duration d : CFTimeInterval = 0.1)
    {
        if self.node.action(forKey: "rotate_2d") != nil { return }
        let action = SCNAction.rotate(by: th, around: SCNVector3Make(0, 1, 0), duration: d)
        self.node.runAction(SCNAction.repeatForever(action), forKey: "rotate_2d")
    }
    
    func rotate2d(to th : CGFloat, duration d : CFTimeInterval = 0.1)
    {
        let w = deltaTheta(From: self.theta, To: th)
        let action = SCNAction.rotate(by: w, around: SCNVector3Make(0, 1.0, 0), duration: d)
        self.node.runAction(action)
        
    }
    
    
    func heightAt(_ at : SCNVector3, mask : Int = 0b0011) -> CGFloat
    {
        let hits = self.node.parent!.hitTestWithSegment(from: at + SCNVector3Make(0, self.height, 0),
                                                        to: at + SCNVector3Make(0, -self.height, 0), options: nil)
        for hit in hits 
        {
            guard let body = hit.node.physicsBody else {
                continue
            }
//                        print(hit.node.name)
            if body.categoryBitMask & 0b0011 > 0 {
                return hit.worldCoordinates.y
            }
        }
        
        return -999.0
    }
    
    
    /*
     whether charactor faces a wall.
     mask for Wall's physics body
     */
    func isFaceWall(los : SCNVector3, mask : Int = 0b0010) -> Bool
    {
        guard let parent = self.node.parent else { return true }
        let from = self.node.position + SCNVector3Make(0, self.height, 0)
        
        let to = self.node.position + los
        let hits = parent.hitTestWithSegment(from: from, to: to, options: nil)

        for hit in hits {
            guard let body = hit.node.physicsBody else { continue }
            if body.categoryBitMask == mask {
                return true
            }
        }
        
        return false
    }
    
    
    
    func nearestNode(mask : Int = 0xFF) -> (SCNNode, CGFloat)? {
        guard let parent = self.node.parent else { return nil }
        var ret : SCNNode = self.node
        var val : CGFloat = CGFloat.greatestFiniteMagnitude
        for child in parent.childNodes {
            guard let body = child.physicsBody else { continue }
            let d = distance(child, self.node)
            if d == 0.0 { continue }
            if d < val && body.categoryBitMask & mask > 0
            {
                val = d
                ret = child
            }
            
        }
        if val == CGFloat.greatestFiniteMagnitude {
            return nil
        } else {
            return (ret, val)
        }
    }
    

    func damaged(from : SCNNode)
    {
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        SCNTransaction.completionBlock = { () in
            self.emmition(color: NSColor.black.cgColor)
        }
        self.emmition(color: NSColor.red.cgColor)
        SCNTransaction.commit()
        self.node.removeAllActions()

    }
    
    
    func emmition(color c : CGColor)
    {
        
        if self.node.geometry!.materials.count != 0 {
            self.node.geometry!.firstMaterial?.emission.contents = c
        } else {
            for child in self.node.childNodes
            {
                guard let geometry = child.geometry else { continue }
                for materials in geometry.materials 
                {
                    materials.emission.contents = c
                }
            }
        }
    }
    
    
    /**
     load animations from assets.
 
     */
    func loadAssets(assets : [String])
    {
        /** Scene で使われるノードは先頭に */
        self.pauses = [self.node]
        
        for assetName in assets
        {
            if assetName.contains(".dae") {
                let pose = loadNode(Asset: assetName, Name: self.node.name!)!
                self.pauses.append(pose)
            }
            
            if assetName.contains(".mp3") 
            {
                //
            }
            
        }
    }
    

    
    func runAnimation(id : Int, speed : Float = 1.0)
    {
        
        if self.node.parent == nil { return }
        if id >= self.pauses.count { return }
        
        self.pauses[id].scale = self.node.scale
        self.pauses[id].position = self.node.position
        self.pauses[id].rotation = self.node.rotation

        for key in self.pauses[id].animationKeys {
            let animation = self.pauses[id].animation(forKey: key)
            self.node.addAnimation(animation!, forKey: key)
        }
        
        let childA = self.node.childNodes(passingTest: {(node, p) in 
            node.removeAllAnimations()
            return true
        })
        
        let childB = self.pauses[id].childNodes(passingTest: { (node, p) in
             return true
        })
        
        
        for (a, b) in zip(childA, childB)
        {
            a.removeAllAnimations()
            for key in b.animationKeys {
                let animation = b.animation(forKey: key)!
                animation.speed = speed
                a.addAnimation(animation, forKey: key)
            }
        }

    }
    
    func pauseAnimation()
    {
        for key in self.node.animationKeys
        {
            self.node.pauseAnimation(forKey: key)
        }
        
        self.node.childNodes(passingTest: { (_node, p) -> Bool in
            for key in _node.animationKeys
            {
                print(key)
                _node.pauseAnimation(forKey: key)
            }
            return true
        })
    }
    
    func resumeAnimation()
    {
        for key in self.node.animationKeys
        {
            self.node.resumeAnimation(forKey: key)
        }
        
        self.node.childNodes(passingTest: { (_node, p) -> Bool in
            for key in _node.animationKeys
            {
                _node.resumeAnimation(forKey: key)
            }
            return true
        }) 
    }
    
    func runAnimationAction(id : Int, duration : CFTimeInterval)
    {
        
        if id >= self.pauses.count { return }
        self.runAnimation(id: id)
        
        let actionA = SCNAction.wait(duration: duration)
        let actionB = SCNAction.run({ _ in
            self.runAnimation(id: 0)
        })
        
        self.node.runAction(SCNAction.sequence([actionA, actionB]))
        
        return 
    }
    

    
    var hasAnimations : Bool {
        var ret = false
        self.node.childNodes(passingTest: { (n, p) in
            if n.animationKeys.count > 0 {
                ret = true
            }
            return true
        })
        return ret
    }

    
}
