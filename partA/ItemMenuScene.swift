//
//  MenuScene.swift
//  partA
//
//  Created by 成沢淳史 on 2016/12/27.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

class ItemMenuScene : SKScene
{
    var textFrameNode : TextFrameNode!
    var gameView : GameView?
    
    var cursorAt : Int = 0
    let s = 50.0
    let pad = 25.0  
    let _y = -80.0
    
    var itemNameNode : SKSpriteNode!
    
    var iconNodes : [IconNode] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.textFrameNode =  TextFrameNode.init(size: CGSize.init(width: 600, height: 150), FrameImageName: "frame")
        self.textFrameNode?.anchorPoint = CGPoint.init(x: 0.5, y: 0)
        self.textFrameNode?.position = CGPoint.init(x: 0, y: -300)
        self.addChild(self.textFrameNode!)
        
        self.itemNameNode = SKSpriteNode.init(color: NSColor.black, size: CGSize.init(width: 300, height: 240))
        self.itemNameNode.alpha = 0.7
        self.itemNameNode.position = CGPoint.init(x: 0, y: 0.0)
        
        let textNameNode =  SKLabelNode.init()
        textNameNode.name = "name"
        textNameNode.fontSize = 28
        textNameNode.position = CGPoint.init(x: 0, y: 0)
        self.itemNameNode.addChild(textNameNode)
        
        let textInfoNode =  SKLabelNode.init()
        textInfoNode.name = "info"
        textInfoNode.fontSize = 18
        textInfoNode.position = CGPoint.init(x: 0, y: -30)
        self.itemNameNode.addChild(textInfoNode)
        self.itemNameNode.isHidden = true
        
        self.addChild(self.itemNameNode)
    }
    
    override func keyDown(with event: NSEvent) {
        //
        switch event.keyCode {
        case 0x7b:
            // left
            self.selectPressed(-1.0)
            break
        case 0x7c:
            // right           
            self.selectPressed(1.0)
            break
        case 0x2e:
            // M
            self.close()
            break
        case 0x24:
            self.itemSelected()
            break
        default:
            break
        }
        
    }
    
    func itemSelected()
    {
        let keys = self.gameView!.gameData.itemList.itemCount.keys
        for (i, id) in keys.enumerated()
        {
            if i == self.cursorAt
            {
                self.gameView!.useItem(id: id)
                break
            }
        }

    }
    
    func selectPressed(_ m : Double = 1.0)
    {
        guard let v = self.gameView else {
            print("WARN : gameView is not set")
            return
        }
        
        let n = v.gameData.itemList.itemCount.keys.count

        let cursor_pre = self.cursorAt
        
        if m > 0 {
            self.cursorAt += 1
        } else {
            self.cursorAt -= 1
        }
        
        self.cursorAt = self.cursorAt >= n ? (n - 1) : self.cursorAt
        self.cursorAt = self.cursorAt < 0 ? 0 : self.cursorAt
        
        if self.cursorAt == cursor_pre
        {
            return
        }
        
        
        let action = SKAction.move(by: CGVector.init(dx: (s + pad) * m * -1.0, dy: 0.0), duration: 0.25)
        for iconNode in self.iconNodes
        {
            iconNode.node.run(action)
        }
        self.setIcons()
    }
    
    func setIcons()
    {

        
        for (i, iconNode) in self.iconNodes.enumerated()
        {
            if i == self.cursorAt
            {
                iconNode.node.alpha = 1.0
            }
            
            if abs(i - self.cursorAt) == 1
            {
                iconNode.node.alpha = 0.7
            }
        }
        
        let nNode : SKLabelNode = self.itemNameNode.childNode(withName: "name")! as! SKLabelNode
        let iNode : SKLabelNode = self.itemNameNode.childNode(withName: "info")! as! SKLabelNode 
        let id = iconNodes[self.cursorAt].id
        let item  = self.gameView!.gameData.itemList.itemAt(id: id)!
        let n = self.gameView!.gameData.itemList.itemCount[id]!
        
        nNode.text = "\(item.name) x\(n)"

        iNode.text = "\(item.info)"
        
   
    }
    
    struct IconNode {
        var node : SKSpriteNode
        var id : Int
    }
    
    func openItemMenu()
    {
        guard let v = self.gameView else {
            print("WARN : gameView is not set")
            return
        }
        
        v.sceneFrags = 0x08
        
        for (i, key) in v.gameData.itemList.itemCount.keys.enumerated()
        {
            
            let item = v.gameData.itemList.itemAt(id: key)

            var icon = item!.icon
            if icon == nil { icon = "hatena" }
            let node = SKSpriteNode.init(imageNamed: icon!)


            node.size = CGSize.init(width: s, height: s)
            node.position = CGPoint.init(x: (s + pad) * Double(i), y: self._y)
            self.addChild(node)
            self.iconNodes.append(IconNode.init(node: node, id: key))
            
        }
        
        self.itemNameNode.isHidden = false
        self.setIcons()

        
    }
    
    func close()
    {
        for iconNode in iconNodes
        {
            iconNode.node.alpha = 0.0
        }
        
        if let v = self.gameView {
            v.sceneFrags = 0x01
        }
        
        self.itemNameNode.isHidden = true
    }


}
