//
//  ViewController.swift
//  TargetApp
//
//  Created by apple on 2020/04/18.
//  Copyright © 2020 odyflame. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum BoxBodyType: Int {
    case bullet = 1
    case barrier = 2
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var lastContactNode: SCNNode!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        let box1 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0 )

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        box1.materials = [material ]
        let boxNode = SCNNode(geometry: box1)
        boxNode.name = "Barrier1"
        boxNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        boxNode.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
        
        boxNode.position = SCNVector3(0,-0.1,-0.4)
        
        let box2Node = SCNNode(geometry: box1)
        let box3Node = SCNNode(geometry: box1)
        
        box2Node .physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        box3Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        box2Node.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
        box3Node.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
        
        box2Node.name = "Barrier2"
        box3Node.name = "Barrier3"
        
        box2Node.position = SCNVector3(-0.2,-0.2,-0.4)
        box3Node.position = SCNVector3(0.2,0.2,-0.5)
        
        scene.rootNode.addChildNode(boxNode)
        scene.rootNode.addChildNode(box2Node)
        scene.rootNode.addChildNode(box3Node)
        
        // Set the scene to the view
        sceneView.scene = scene
         
        registerGestureRecognizers()
        
        self.sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shoot))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func shoot(recognizer: UITapGestureRecognizer) {
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }//translation matrix allow you to place the element allow to make sure that your element is at the correct level
        
        var transaction = matrix_identity_float4x4
        transaction.columns.3.z = -0.3
        
        let box1 = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0 )
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow
        box1.materials = [material]
        
        let boxNode = SCNNode(geometry: box1)
        boxNode.name = "Bullet"
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil )//means that going to help me to find the shape for this particular body
        boxNode.physicsBody?.isAffectedByGravity = false

        boxNode.simdTransform = matrix_multiply(currentFrame.camera.transform, transaction)
        
        boxNode.physicsBody?.categoryBitMask = BoxBodyType.bullet.rawValue
        boxNode.physicsBody?.contactTestBitMask = BoxBodyType.barrier.rawValue
        
        let forceVector = SCNVector3(boxNode.worldFront.x * 2, boxNode.worldFront.y * 2, boxNode.worldFront.z * 2)
        
        boxNode.physicsBody?.applyForce(forceVector, asImpulse: true)
        
        self.sceneView.scene.rootNode.addChildNode(boxNode)
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

extension ViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        //going to get triggerd whenever a collision ro contact between the two objects happend
        //in order to call this function you have to ad one more specila thing which is the contact bit mask
        
        var conTactNode: SCNNode!
        
        if contact.nodeA.name == "Bullet" {
            //we know the nodeB is the Barrier
            conTactNode = contact.nodeB
        } else {
            conTactNode = contact.nodeA
            
        }
        
        if self.lastContactNode != nil && self.lastContactNode == conTactNode {
            return
        }
        
        self.lastContactNode = conTactNode
        
        let box1 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        
        box1.materials = [material]
        
        self.lastContactNode.geometry = box1  
        
    }
}
