//
//  Common.swift
//  tesuup
//
//  Created by 成沢淳史 on 2016/12/10.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import SceneKit



func  - (left : SCNVector3, right : SCNVector3) -> SCNVector3
{   
    let x  = left.x - right.x
    let y = left.y - right.y
    let z = left.z - right.z    
    return SCNVector3Make(x, y, z)
}

func  + (left : SCNVector3, right : SCNVector3) -> SCNVector3
{   
    let x  = left.x + right.x
    let y = left.y + right.y
    let z = left.z + right.z    
    return SCNVector3Make(x, y, z)
}


func  / (left : SCNVector3, right : SCNVector3) -> SCNVector3
{   
    let x  = left.x / right.x
    let y = left.y / right.y
    let z = left.z / right.z    
    return SCNVector3Make(x, y, z)
}


func / (left : SCNVector3, right : Double) -> SCNVector3
{
    let x  = left.x / CGFloat(right)
    let y = left.y / CGFloat(right)
    let z = left.z / CGFloat(right)
    return SCNVector3Make(x, y, z)
}

func / (left : SCNVector3, right : CGFloat) -> SCNVector3
{
    let x  = left.x / CGFloat(right)
    let y = left.y / CGFloat(right)
    let z = left.z / CGFloat(right)
    return SCNVector3Make(x, y, z)
}


func * (left : SCNVector3, right : Double) -> SCNVector3
{
    let x  = left.x * CGFloat(right)
    let y = left.y * CGFloat(right)
    let z = left.z * CGFloat(right)
    return SCNVector3Make(x, y, z)
}

func * (left : SCNVector3, right : CGFloat) -> SCNVector3
{
    let x  = left.x * right
    let y = left.y * right
    let z = left.z * right
    return SCNVector3Make(x, y, z)
}

func  * (left : SCNVector3, right : SCNVector3) -> SCNVector3
{   
    let x  = right.x * left.x
    let y = right.y * left.y
    let z = right.z * left.z    
    return SCNVector3Make(x, y, z)
}

func * (left : CGFloat, right : Double) -> CGFloat
{
    return left * CGFloat(right)
}

func += (left : inout SCNVector3, right : SCNVector3)
{
    left.x += right.x
    left.y += right.y
    left.z += right.z
}

func -= (left : inout SCNVector3, right : SCNVector3)
{
    left.x -= right.x
    left.y -= right.y
    left.z -= right.z
}

func + (left : SCNVector3, right : Double) -> SCNVector3
{
    let x = left.x + CGFloat(right)
    let y = left.y + CGFloat(right)
    let z = left.z + CGFloat(right)
    return SCNVector3Make(x, y, z)
}

func == (left : SCNVector3, right : SCNVector3) -> Bool
{
    if left.x == right.x && left.y == right.y && left.z == right.z
    {
        return true
    } else {
        return false
    }
}

func + (left : CGPoint, right : CGPoint) -> CGPoint
{
    let x = left.x + right.x
    let y = left.y + right.y
    return CGPoint.init(x: x, y: y)
}

func / (left : CGFloat, right : Double) -> CGFloat
{
    return left / CGFloat(right)
}


var M_PI : CGFloat
{
    return 3.141529
}

var M_PI_2 : CGFloat
{
    return M_PI / 2.0
}

var M_PI_4 : CGFloat
{
    return M_PI / 4.0
}


func sign(_ x : CGFloat) -> CGFloat
{
    return x < 0 ? -1.0 : 1.0
}

extension CGFloat 
{
    var degree : CGFloat {
        return self * 180.0 / M_PI
    }
}


var SCNVector3Ones : SCNVector3 {
    return SCNVector3.init(1.0, 1.0, 1.0)
}

extension SCNVector3
{
    var norm : CGFloat {
        return sqrt(pow(self.x, 2.0) + pow(self.y, 2.0) + pow(self.z, 2.0))
    }
    
    func expand(w : CGFloat) -> SCNVector4
    {
        return SCNVector4Make(self.x, self.y, self.z, w)
    }
    
    var theta : CGFloat {
        var r = atan2(-self.x, -self.z)
        r = ((M_PI - abs(r)) * sign(r)) * -1.0
        
        if r == -M_PI {
            r = M_PI
        }
        return r
    }
}

extension SCNVector4
{
    var vec3 : SCNVector3 {
        return SCNVector3Make(self.x, self.y, self.z)
    }
}




extension SCNScene
{
    /*
     the list of camera nodes in the scene.
     */
    var cameraList : [SCNNode] {
        var ret : [SCNNode] = []
        
        for node in self.rootNode.childNodes
        {
            guard let name = node.name else {
                continue
            }
            
            if name.lowercased().contains("camera") 
            {
                ret.append(node)
            }
        }
        return ret
    }
    
    /**
     move the camera to another camera specified by Id in the scene.
     */
    func setCamera(Id id : Int) 
    {
        if self.cameraList.count < 2 || self.cameraList.count <= id || id < 0 {
            return
        }
        
        let camera = self.cameraList[0]
        let s_camera = self.cameraList[id]
        camera.position = s_camera.position
        camera.rotation = s_camera.rotation
    }
    
    var camera : SCNNode? {
        if self.cameraList.count == 0 
        {
            print("camera is not set.")
            return nil
        }
        return self.cameraList[0]
    }
    
    /**
     the camera constrain. camera orients for the specified object.
     */
    func cameraLookAt(Node node : SCNNode?)
    {
        if self.cameraList.count < 1 { return }
        let camera = self.cameraList[0]
        
        if node == nil {
            camera.constraints = []
        }
        
        let constraint = SCNLookAtConstraint(target: node)
        camera.constraints = [constraint]
    }
    
    /**
     set physics bodies for partially matching given names.
     options ("category", "collision", "contact" for masks. and "scale" for scale of physics body)
    */
    func setPhysics(WhiteList wl : [String], Type type : SCNPhysicsBodyType, Options options : Dictionary<String, Any>)
    {
        
        func isInList(_ str : String, List list : [String]) -> Bool
        {
            for line in list {
                if str.lowercased().contains(line.lowercased()) { return true }
            }
            return false
        }
        
        for node in self.rootNode.childNodes
        {
            guard let name = node.name else { continue }

            if isInList(name, List: wl) {
                
                node.physicsBody = nil
                
                var opts : Dictionary<SCNPhysicsShape.Option, Any> = [:]
                opts[SCNPhysicsShape.Option.type] = SCNPhysicsShape.ShapeType.boundingBox
                opts[SCNPhysicsShape.Option.keepAsCompound] = false

                if options["scale"] != nil {
//                    opts[SCNPhysicsShape.Option.scale] =  options["scale"]
                    opts[SCNPhysicsShape.Option.scale] = node.scale
                }
                
                if options["margin"] != nil {
                    opts[SCNPhysicsShape.Option.collisionMargin] = options["margin"]
                }
                
                let shape = SCNPhysicsShape.init(node: node, options: opts)
                
                
                let body = SCNPhysicsBody.init(type: type, shape: shape)
                for o in options.keys {
                    switch o {
                    case "category":
                        body.categoryBitMask = options[o] as! Int
                    case "collision":
                        body.collisionBitMask = options[o] as! Int
                    case "contact" :
                        body.contactTestBitMask = options[o] as! Int
                    default:
                        break
                    }
                }
                body.friction = 0.5
                body.restitution = 0.0
                node.physicsBody = body
                
            }
        }
    }
    
    func setNearCamera(target : SCNNode) 
    {
        if self.cameraList.count <= 1 { return }
        for (i, cam) in self.cameraList.enumerated() {
            if i == 0 { continue }
            let d1 = (target.position - cam.position).norm
            let d2 = (target.position - self.camera!.position).norm
            if d1 < d2 {
                self.setCamera(Id: i)
            }
        }
    }
    
    func cameraAngle(target : SCNNode) -> CGFloat
    {
        let dx = target.position.x - self.camera!.position.x
        //        let dy = target.position.y - self.camera!.position.y
        let dz = target.position.z - self.camera!.position.z
        let r = atan2(-dx, -dz)
        return (M_PI - abs(r)) * sign(r)
    }
    

    
    
}



class CheckPoint
{
    var toNodeName : String!
    var toScene : String!
    
    var node : SCNNode!
    
    var position : SCNVector3
    {
        return self.node.position
    }
    
    init(name : String, To to : String, CheckPointNode node: SCNNode)
    {
        self.toNodeName = name
        self.toScene = to
        self.node = node
    }
    
    class func setCheckPoint(str : String, CheckPointNode node : SCNNode) -> CheckPoint?
    {
        if str.contains("JCT") {
            let components = str.components(separatedBy: "JCT")
            if components.count != 2 { return nil }
            return CheckPoint.init(name: components[0], To: components[1], CheckPointNode: node)
        } else {
            return nil
        }
    }
}




/**
 load the node specified name in the asset.
 */
public func loadNode(Asset asset : String, Name name : String) -> SCNNode?
{
    guard let scene = SCNScene(named: asset) else { return nil }
    guard let node = scene.rootNode.childNode(withName: name, recursively: false) else { return nil }
    
    return node
}

func distance(_ nodeA : SCNNode, _ nodeB : SCNNode) -> CGFloat
{
    return (nodeA.position - nodeB.position).norm
}


func adjustTheta(_ th : CGFloat) -> CGFloat
{
    var _th = th
    
    if abs(th) > M_PI {
        let s = th > 0 ? -1.0 : 1.0
        _th = (2.0 * M_PI - abs(th)) * s
    } 

    
    if _th == -M_PI {
        _th = M_PI
    }
    
    return _th

}

func addTheta(_ th1 : CGFloat,_ th2 : CGFloat) -> CGFloat
{
    // -M_PI <= ret <= M_PI
    let th = th1 + th2
    return adjustTheta(th)

}

func deltaTheta(From th1 : CGFloat,To th2 : CGFloat) -> CGFloat
{
    if sign(th1) == sign(th2) {
        return adjustTheta(th2 - th1)
    } else {
        // 0 を通るルート
        let r_0 = abs(th1) + abs(th2)
        
        // M_PI を通るルート
        let r_pi = (M_PI - abs(th1)) + (M_PI - abs(th2))
        
        if r_0 < r_pi {
            return sign(th1) > 0 ? -1.0 * r_0 : r_0
        } else {
            return sign(th1) > 0 ? r_pi : -1.0 * r_pi
        }
    }
}




