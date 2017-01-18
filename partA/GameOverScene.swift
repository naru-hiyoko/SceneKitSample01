//
//  GameOver.swift
//  partA
//
//  Created by 成沢淳史 on 2016/12/26.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene : SKScene
{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.camera = self.scene!.childNode(withName: "camera") as? SKCameraNode
    }
    
    override func keyDown(with event: NSEvent) {
        if self.isHidden {
            return
        }
    
    }
}
