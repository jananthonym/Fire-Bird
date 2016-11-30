//
//  Coin.swift
//  Fire Bird
//
//  Created by Jan Anthony Miranda on 6/18/15.
//  Copyright (c) 2015 Jan Anthony Miranda. All rights reserved.
//

import Foundation
import SpriteKit

class Coin {
    var node: SKSpriteNode
    var pos: Int
    var time: Int = 2
    var red: Bool = false
    
    init (Node: SKSpriteNode, Pos: Int){
        node = Node
        pos = Pos
        time = 2
    }
    
    func getNode() -> SKSpriteNode {
        return node
    }
    
    func getPos() -> Int {
        return pos
    }
    
    func getTime() -> Int {
        return time
    }
    
    func decTime() {
        time -= 1
    }
    
    func setRed(){
        red = true
    }
    
    func isRed() -> Bool {
        return red
    }
}