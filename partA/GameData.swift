//
//  EventFrags.swift
//  partA
//
//  Created by 成沢淳史 on 2016/12/20.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import SpriteKit

/**
 save flag events.
 
 **/
import SceneKit

class GameData : NSObject, NSCoding
{
    var hp : Int?
    var flags : [String] = []
    var time : String!
    var position : SCNVector3!
    var sceneName : String!
    
    var checkPoints : [CheckPoint] = []
    
    private var itemCount : Dictionary<Int, Int> = [:]
    var itemList : ItemList = ItemList()
    
    override init() {
        super.init()
        //
    }
    
    required init?(coder aDecoder: NSCoder) {
        //
        self.itemList = ItemList()
        
        if let obj = aDecoder.decodeObject(forKey: "flags") {
            self.flags = obj as! [String]
        }
        
        if let obj = aDecoder.decodeObject(forKey: "hp")
        {
            self.hp = obj as? Int
        }
        
        if let obj = aDecoder.decodeObject(forKey: "time") {
            self.time = obj as? String
        }
        
        if let obj = aDecoder.decodeObject(forKey: "position")
        {
            self.position = obj as? SCNVector3
        }
        
        if let obj = aDecoder.decodeObject(forKey: "sceneName")
        {
            self.sceneName = obj as! String
        }
        
        if let obj = aDecoder.decodeObject(forKey: "itemCount")
        {
            self.itemCount = obj as! Dictionary<Int, Int>
            self.itemList.itemCount = self.itemCount
        }

    }
    
    func encode(with aCoder: NSCoder) {
        //
        aCoder.encode(self.hp, forKey: "hp")
        aCoder.encode(self.flags, forKey: "flags")
        aCoder.encode(self.position, forKey: "position")
        aCoder.encode(self.sceneName, forKey: "sceneName")
        aCoder.encode(self.itemList.itemCount, forKey: "itemCount")
        
        let today = Date.init()
        let cal = Calendar.current
        let s : Set<Calendar.Component> = [Calendar.Component.day, Calendar.Component.month, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second]
        let comp = cal.dateComponents(s, from: today)
        let str = "\(comp.month!)月\(comp.day!)日 \(comp.hour!)時\(comp.minute!)分\(comp.second!)秒"
        self.time = str
        aCoder.encode(self.time, forKey: "time")
    }
    

    
}

class Item
{
    var name = ""
    var id : Int! = 0
    var info : String = ""
    var icon : String? = nil
    var use : (() -> (Void)) = { _ in 
        print("何もおきなかった")
    }
    
    init(name : String, id : Int, icon : String? = nil) {
        self.name = name
        self.id = id
        self.icon = icon
    }
    
    init(name : String, id : Int, info: String , icon : String? = nil) {
        self.name = name
        self.id = id
        self.icon = icon
        self.info = info
    }

}



protocol ItemListProtocol {
    var itemCount : Dictionary<Int, Int> { get set }
    var items : [Item] { get }
}

extension ItemList
{
    
    
    func addItem(id : Int, m : Int = 1)
    {
        if self.itemCount[id] == nil {
            self.itemCount[id] = 0 
        }
        
        self.itemCount[id]! += 1 * m
        
        if self.itemCount[id]! < 0 
        {
            self.itemCount[id] = 0
        }
    }
    
    func reduceItem(id: Int)
    {
        self.addItem(id: id, m: -1)
    }
    
    func itemAt(id : Int) -> Item?
    {
        for item in self.items 
        {
            if item.id == id {
                return item
            }
        }
        return nil
    }
    
    func use(id : Int)
    {
        guard let item = self.itemAt(id: id) else {
            return
        }
        if self.itemCount[id] == 0 { return }
        self.reduceItem(id: id)
        item.use()
    }
    
}

