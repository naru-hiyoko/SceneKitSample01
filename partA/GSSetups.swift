//
//  GSExSetups.swift
//  partA
//
//  Created by 成沢淳史 on 2016/12/28.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

extension GameView
{
    func firstSetup()
    {
        /*ゲーム起動時タイトル画面を表示します*/
        self.openTitleMenu()
        
        self.itemMenuScene = SKScene.init(fileNamed: "ItemMenuScene") as? ItemMenuScene
        self.itemMenuScene!.gameView = self
        
    }
    
    /**
     データを初期化した状態にする
    */
    func initGameData()
    {
        self.loadScene(name: "tutorial")
        self.sceneFrags = 0x01
        self.player!.node.isHidden = false
        self.player!.hp = 3
        self.gameData.flags = []
        self.player!.node.position = self.scene!.rootNode.childNode(withName: "p1", recursively: false)!.position + SCNVector3.init(0, 0.01, 0)
    }
    

    
    func extraSetups(sceneName name: String) {
        /** シーンロード後に呼ばれる. 敵を追加 etc.. */
        print("\(name)") 
    
        if name == "stageA"
        {

            let enemy = EnemyA.setup()
            self.scene!.rootNode.addChildNode(enemy.node)
            
            enemy.loadPositions(NodeNames: ["p1", "p2", "p3"])
            self.enemies.append(enemy)
            
            
        }
    }
   
}

