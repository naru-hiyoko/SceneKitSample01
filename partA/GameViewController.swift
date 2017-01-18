//
//  GameViewController.swift
//  partA
//
//  Created by 成沢淳史 on 2016/12/11.
//  Copyright (c) 2016 naru. All rights reserved.
//

import SpriteKit
import SceneKit
import QuartzCore


class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        // create a new scene
        self.gameView!.loadScene(name: "pre")        
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.black

        
    
        // load player model.
        self.gameView!.player = Player.setup()
        self.gameView!.player?.setPhysics()
        self.gameView.scene!.rootNode.addChildNode(self.gameView!.player!.node)  
        
        self.gameView!.firstSetup()
    }
    

}
