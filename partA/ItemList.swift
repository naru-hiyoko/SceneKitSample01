//
//  ItemList.swift
//  partA
//
//  Created by 成沢淳史 on 2017/01/07.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation

class ItemList : NSObject , ItemListProtocol
{
    
    // key : id, value : n
    var itemCount : Dictionary<Int, Int> = [:]
    
    var items : [Item] {
        let arr : [Item] = [self.itemA,
                            self.itemB]
        return arr
    }

    
    private var item0 = Item.init(name: "戻る", id: 0, info: "メニューを閉じます", icon: "return")
    private var itemA = Item.init(name: "回復薬", id: 1)
    private var itemB = Item.init(name: "手榴弾", id: 2)
    
    override init() {
        super.init()
        self.itemA.info = "回復します"
        self.itemB.info = "爆発物です"
//        self.itemCount[item0.id] = 1
        self.itemCount[itemA.id] = 1
        self.itemCount[itemB.id] = 1        
    }
    
}
