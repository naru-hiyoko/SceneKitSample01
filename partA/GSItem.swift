//
//  GSItem.swift
//  partA
//
//  Created by 成沢淳史 on 2016/12/28.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

extension GameView
{
 
    func useItem(id : Int)
    {
        Swift.print("selected item id : \(id)")
        switch id {
        case 0:
            //
            break
        default:
            self.print("nop")
        }
    }
    
    func useItemA()
    {
        self.gameData.itemList.use(id: 0)
    }
    
}
