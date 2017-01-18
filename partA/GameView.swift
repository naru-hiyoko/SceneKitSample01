//
//  GameView.swift
//  partA
//
//  Created by 成沢淳史 on 2016/12/11.
//  Copyright (c) 2016 naru. All rights reserved.
//

import SceneKit
import SpriteKit

/**
 sceneFrag で input を切り替える.
 menuを開いている : 0x08 , gameOver 0x04, title 0x02, gama進行中 0x01
 
 
 */

class GameView: SCNView, GameViewProtocol
{
    var timer : Timer!
    var sceneName: String?    
    
    dynamic var player : Player? = nil
    var enemies: [Charactor]! = []
    
    // 保存用
    var gameData : GameData = GameData()

        
    // head up field
    var itemMenuScene : ItemMenuScene!
    var titleMenuScene : TitleMenuScene!

    // menuを開いている : 0x08 , gameOver 0x04, title 0x02, gama進行中 0x01
    var sceneFrags : Int = 0x02
    var timeAtGameOver = CACurrentMediaTime()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        self.timer.fire()

        self.addObserver(self, forKeyPath: "player", options: NSKeyValueObservingOptions.new, context: nil)

   }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "player"
        {
            self.player!.delegate = self
        }
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "player")
    }
    
    
    override func keyDown(with event: NSEvent) {
        
        if self.sceneFrags & 0x02 > 0 {
            /* タイトル画面にいるとき （セーブ＆ロード）*/
            self.titleMenuScene?.keyDown(with: event)
            return
        }
        
        if self.sceneFrags & 0x04 > 0 && ((CACurrentMediaTime() - self.timeAtGameOver) > 1.5)
        {
            /** ゲームオーバのフラグがあるとき*/
            self.openTitleMenu()
            return
        }
        
        if self.sceneFrags & 0x08 > 0
        {
            // アイテムメニューを開いているとき
            self.itemMenuScene?.keyDown(with: event)
            return 
        }
        
        
        
        switch event.keyCode {
        case 0x7b:
            // LEFT
            self.player!.theta += M_PI_4
            break
        case 0x7e:
            // UP
            self.player!.moveForward(rot: self.player!.theta)
            break
        case 0x7c:
            // RIGHT
            self.player!.theta -= M_PI_4            
            break
        case 0x7d:
            self.player!.moveForward(rot: adjustTheta(self.player!.theta + M_PI), step: 0.05)
            //BOTTOM
            break
        case 0x03:
            self.player!.inspect()
        case 0x00:
            self.player!.atack()
        case 0x2e:
            self.itemMenuScene!.openItemMenu()
            break
        case 0x06:
            break
        default:
            print(String.init(format: "0x%x", event.keyCode))            
            break
        }

        self.itemMenuScene!.textFrameNode!.next()

    }
    
    func update()
    {
        self.isPlaying = true
        if self.scene == nil { return }
            
        self.scene?.setNearCamera(target: self.player!.node)    
//        self.scene?.cameraLookAt(Node: self.player!.node)
        self.pointOfView = self.scene!.camera        

        if self.sceneFrags & 0010 > 0
        {
            self.pauseScene(true)
            return
        }
        
        if self.sceneFrags & 0x01 > 0
        {
            /** ゲーム進行中なら */
            self.overlaySKScene = self.itemMenuScene
            self.itemMenuScene?.isHidden = false
            self.pauseScene(false)
            self.eventCall()
        }
        
    }
    
    func pauseScene(_ t: Bool)
    {
        DispatchQueue.main.async {
            self.player!.isPaused = t
            for enemy in self.enemies
            {
                enemy.isPaused = t
            }
        }
    }
    

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        self.player!.physicsWorld(world, didBegin: contact)
        for enemy in  self.enemies {
            enemy.physicsWorld(world, didBegin: contact)
        }
    }
    
    
    override func print(_ sender: Any?) {
        Swift.print(sender!)
    }
}
