//
//  ViewController.swift
//  SimpleBox
//
//  Created by apple on 2020/04/06.
//  Copyright © 2020 odyflame. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
            
        // Set the scene to the view
        sceneView.scene = scene
        
        let box = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0)
        let material = SCNMaterial() //some color can wrap your quve
        material.diffuse.contents = UIColor.red//materail은 한 면이고 그 면은 빨간색이다.
        material.name = "Color"
         
        box.materials = [material]//이미지들을 모두 빨간색로 바꾼다. 박스는 6가지의 면이 있으니 6개의 면이 바뀔 것이다.
        
        let boxNode = SCNNode(geometry: box)//박스를 어디로 놔둘 것인지 노드를 정하는것
        boxNode.position = SCNVector3(0, 0, 0)//위치
        
        self.sceneView.scene.rootNode.addChildNode(boxNode)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer: UIGestureRecognizer) {
        
        let sceneView = recognizer.view as! SCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitResult = sceneView.hitTest(touchLocation, options: [:])
        if !hitResult.isEmpty {
            let node = hitResult[0].node
            let material = node.geometry?.material(named: "Color")
            
            material?.diffuse.contents = UIColor.random()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}
