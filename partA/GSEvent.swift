//
//  gameSceneEvent.swift
//  partA
//
//  Created by 成沢淳史 on 2016/12/17.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

extension GameView
{
    /**
     一定時間毎に eventCall が呼ばれる
     
    **/
    
    func eventCall(event e : String)
    {
        if e == "save" { 
            self.save()
        }
        
        
        switch self.sceneName! {
        case "stageA":
            break
        default:
            break
        }
        
    }
    
    func eventCall() {
        if self.scene == nil { return }
        
        /**
         transaction
        **/
        for ck in self.gameData.checkPoints {
            let d = distance(self.player!.node, ck.node)
            if d < 0.5 {
                self.loadScene(name: ck.toScene, ck: ck)
                return
            }
        }
        
        
        switch self.sceneName! {
        case "stageA":
            if let p4 = self.scene!.rootNode.childNode(withName: "p4", recursively: false) {
                if distance(p4, self.player!.node) < 1.0
                {
                    p4.isHidden = true
                    p4.removeFromParentNode()
                    self.itemMenuScene!.textFrameNode.setPhrases("アイテムを獲得\n")
                    self.itemMenuScene!.textFrameNode.next()
                    self.gameData.itemList.addItem(id: 1)

                }
            }
            
            break

        default:
            break
        }
    }
    
    

}
