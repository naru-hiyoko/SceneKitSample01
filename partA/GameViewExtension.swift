//
//  GameViewExtension.swift
//  partA
//
//  Created by 成沢淳史 on 2016/12/17.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import SceneKit


protocol GameViewProtocol : SCNPhysicsContactDelegate
{
    var timer : Timer! { get set }
    var player : Player? { get set }
    var enemies : [Charactor]! { get set }

    var sceneName : String? { get set }
    
    // ゲームルーチン
    func update()
    
    /** ステージごとのイベントの処理 */
    func eventCall()
    func extraSetups(sceneName name : String)
    
    /**/
    func gameOver()

}

extension GameView
{
    
    var sceneNames : [String] {
        let names = Bundle.main.paths(forResourcesOfType: "dae", inDirectory: "stage")
        var ret : [String] = []
        for name in names {
            let url = URL.init(fileURLWithPath: name)
            let bn = url.deletingPathExtension().lastPathComponent
            ret.append(bn)
        }
        
        return ret
    }
    
    func removeCharactors()
    {
        self.player!.node.removeFromParentNode()
        for e in self.enemies
        {
            e.node.removeFromParentNode()
        }
    }
    
    func loadScene(name : String, ck : CheckPoint? = nil)
    {
        /**
         mask : 
         floor, stair : 0b0001
         wall : 0b0010
         player : 0b0100
         enemy : 0b1000
         atk VolumeBox : 0b10000
         
         */

        self.sceneName = name        
        let filename = Bundle.main.path(forResource: name, ofType: "dae", inDirectory: "stage")!

        let url = URL.init(fileURLWithPath: filename)

        let s = try! SCNScene.init(url: url, options: nil)
        
        if self.scene == nil {
            self.scene = SCNScene.init(named: "stage/pre.dae")
        }
        
        for child in self.scene!.rootNode.childNodes 
        {
            child.removeFromParentNode()
        }
        
        for child in s.rootNode.childNodes
        {
            self.scene!.rootNode.addChildNode(child)
        }
        

        self.scene!.physicsWorld.contactDelegate = self
        
        var option : Dictionary<String, Any> = [:]
        option["category"] = 0b0001
        option["collision"] = 0b1111
        self.scene?.setPhysics(WhiteList: ["plane", "stair"], Type: SCNPhysicsBodyType.static, Options: option)
        
        option["category"] = 0b0010
        option["collision"] = 0b1111
        self.scene?.setPhysics(WhiteList: ["wall"], Type: SCNPhysicsBodyType.static, Options: option)
        

        self.enemies = []

        if let player = self.player {
            self.scene?.rootNode.addChildNode(player.node)
        }
        
        for c in self.scene!.rootNode.childNodes
        {
            guard let name = c.name else {
                continue
            }
            if self.gameData.flags.contains(name)
            {
                c.removeFromParentNode()
            }
        }

            
        if ck != nil {
            /** チェックポイントがあればそこに移動 */
            let tNode = self.scene!.rootNode.childNode(withName: ck!.toNodeName, recursively: false)!
            self.player!.node.position = tNode.position
            self.player!.theta = convertRadian(r: tNode.rotation.w)
                
        }

        

        /* Transaction 用の チェックポイントをセット*/
        self.gameData.checkPoints = []
        for c in self.scene!.rootNode.childNodes {
            guard let name = c.name else { continue }
            guard let check_p = CheckPoint.setCheckPoint(str: name, CheckPointNode: c) else {
                continue
            } 
            self.gameData.checkPoints.append(check_p)
        }
        

        
        extraSetups(sceneName: self.sceneName!)
    }
    

}

func convertRadian(r : CGFloat) -> CGFloat
{
    var w : CGFloat = r
    if abs(w) > M_PI {
        w = (2.0 * M_PI - abs(w)) * sign(w)
    }
    
    if w == -M_PI {
        w = M_PI
    }
    
    let arr = directions.map({ (a, b) -> CGFloat in 
        let r = ((M_PI - abs(atan2(b, a))) * sign(atan2(b, a))) * -1.0
        return abs(r - w)
    })
    
    let rot = directions.map({ (a, b) -> CGFloat in 
        let r = ((M_PI - abs(atan2(b, a))) * sign(atan2(b, a))) * -1.0
        return r
    })
    
    let m = arr.min()
    let i = arr.index(of: m!)!
    return rot[i]
}
