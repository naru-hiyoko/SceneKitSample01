//
//  EnemyB.swift
//  partA
//
//  Created by 成沢淳史 on 2016/12/24.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class EnemyB : EnemyA 
{
    required init(node: SCNNode, hp: Int, assetNames assets: [String]) {
        super.init(node: node, hp: hp, assetNames: assets)
        self.timer = Timer.scheduledTimer(timeInterval: 1.00, target: self, selector: #selector(rotation), userInfo: nil, repeats: true)
        
    }
    
}
