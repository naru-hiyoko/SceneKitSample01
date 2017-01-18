//
//  GSUtil.swift
//  partA
//
//  Created by 成沢淳史 on 2016/12/29.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

extension GameView
{
    
    func save()
    {
        if self.sceneFrags & 0b010 == 0
        {
            self.sceneFrags = 0b010   // タイトルシーンに入るフラグを立てる (load & save)
            
            // データに現在の状態をコピー
            self.gameData.hp = self.player?.hp
            self.gameData.position = self.player!.node.position
            self.gameData.sceneName = self.sceneName
            
            self.openTitleMenu()
            self.titleMenuScene?.savePane()
        }
    }
    
    func gameOver() {
        if self.sceneFrags & 0x04 == 0 {
            self.sceneFrags = 0x04
            self.overlaySKScene = SKScene.init(fileNamed: "GameOverScene") as? GameOverScene
            self.overlaySKScene?.isHidden = false
            self.timeAtGameOver = CACurrentMediaTime()
        }
    }
    
    func openTitleMenu()
    {
        self.titleMenuScene = SKScene.init(fileNamed: "TitleMenuScene") as! TitleMenuScene
        self.titleMenuScene?.gameView = self
        self.overlaySKScene = self.titleMenuScene
        self.overlaySKScene?.scaleMode = SKSceneScaleMode.fill
        self.sceneFrags = 0x02
        self.overlaySKScene?.isHidden = false
        self.titleMenuScene?.openTitlePane()
        
    }
    
    
}
