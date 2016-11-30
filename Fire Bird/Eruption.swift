//
//  Eruption.swift
//  Fire Bird
//
//  Created by Jan Anthony Miranda on 6/16/15.
//  Copyright (c) 2015 Jan Anthony Miranda. All rights reserved.
//

import Foundation
import SpriteKit

class Eruption {
    var step = 0
    var lastUpdate:CFTimeInterval = 0
    var Node: SKSpriteNode
    var id = 0
    
    init(node: SKSpriteNode, ID: Int){
        Node = node
        id = ID
    }
    
    func getStep() -> Int {
        return step
    }
    
    func incStep() {
        step++
    }
    
    func getLast() -> CFTimeInterval {
        return lastUpdate
    }
    
    func getNode() -> SKSpriteNode {
        return Node
    }
    
    func getID() -> Int {
        return id
    }
    
    func setLast(time: CFTimeInterval){
        lastUpdate = time
    }
    
    func setID(ID: Int){
        id = ID
    }
}