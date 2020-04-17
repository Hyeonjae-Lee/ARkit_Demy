//
//  Missile.swift
//  MissileLauncher
//
//  Created by apple on 2020/04/17.
//  Copyright © 2020 odyflame. All rights reserved.
//

import Foundation
import SceneKit
import ARKit


class Missile: SCNNode {
    private var scene: SCNScene!
    
    init(scene: SCNScene) {
        super.init()
        self.scene = scene
        setup()
    }
    
    init(missileNode :SCNNode) {
        super.init()
        // self.missileNode = missileNode
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        guard let missileNode = self.scene.rootNode.childNode(withName: "Missile", recursively: true),
            let smokeNode = self.scene.rootNode.childNode(withName: "smokeNode", recursively: true)
            else {
                fatalError("Node not found!")
        }
        
        let smoke = SCNParticleSystem(named: "art.scnassets/smoke.scnp", inDirectory: nil)
        smokeNode.addParticleSystem(smoke!)
        
        self.addChildNode(missileNode)
        self.addChildNode(smokeNode)
    }
}



