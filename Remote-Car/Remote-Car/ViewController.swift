//
//  ViewController.swift
//  Remote-Car
//
//  Created by apple on 2020/04/26.
//  Copyright © 2020 odyflame. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var planes = [OverlayPlane]()
    private var truckNode: SCNNode!
    
    private var truck: Truck!
    var boxes = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        //self.view.addSubview(self.sceneView)
        
        let truckScene = SCNScene(named: "art.scnassets/truck.dae")
        self.truckNode = truckScene?.rootNode.childNode(withName: "truck", recursively: true)
        
        self.truck = Truck(node: self.truckNode)
//        self.truckNode?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
//        self.truckNode?.physicsBody?.categoryBitMask = BodyType.car.rawValue
//
        let scene = SCNScene()
        //self.truckNode?.position = SCNVector3(0,-1,-1)
        //scene.rootNode.addChildNode(truckNode!)
        // Set the scene to the view
        sceneView.scene = scene
        
        setUpControlPad()
        registerGestureRecognizers()
    }
    
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer :UIGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation =  recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            guard let hitResult = hitTestResult.first else {
                return
            }
            
            //to place the car
            self.truck.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y + 0.1, hitResult.worldTransform.columns.3.z)
            
            self.sceneView.scene.rootNode.addChildNode(self.truck )
        }
    }
    
    private func turnLeft() {
        self.truck.turnLeft()
        //self.truckNode.physicsBody?.applyTorque(SCNVector4(0,1,0,1.0), asImpulse: false)
    }
    
    private func turnRight() {
        self.truck.turnRight()
        //self.truckNode.physicsBody?.applyTorque(SCNVector4(0,1,0,-1.0), asImpulse: false)
    }
    
    private func accerlate() {
       let force = simd_make_float4(0,0,-10,0)
        let rotatedForce = simd_mul(self.truckNode.presentation.simdTransform,force)
        let vectorForce = SCNVector3(rotatedForce.x, rotatedForce.y, rotatedForce.z)
        self.truck.physicsBody?.applyForce(vectorForce, asImpulse: false)
    }
    
    func setUpControlPad() {
        let leftButton =
            GameButton(frame: CGRect(x: 0, y: self.sceneView.frame.height-40, width: 50, height: 50)) {
            self.truck.turnLeft()
            //self.turnLeft()
        }
        
        leftButton.setTitle("Left", for: .normal)
        let rightButton = GameButton(frame: CGRect(x: self.sceneView.frame.width - 40, y: self.sceneView.frame.height, width: 50, height: 50)) {
            //self.turnRight()
            self.truck.turnRight()
        }
        
        rightButton.setTitle("Right", for: .normal)
        
        let accerlatorButton = GameButton(frame: CGRect(x: self.sceneView.frame.width/2, y: self.sceneView.frame.height, width: 50, height: 50)) {
            
            self.truck.accelerate()
        }
        
        accerlatorButton.backgroundColor = UIColor.red
        accerlatorButton.layer.cornerRadius = 10.0
        accerlatorButton.layer.masksToBounds = true
        
        self.sceneView.addSubview(accerlatorButton)
        self.sceneView.addSubview(rightButton)
        self.sceneView.addSubview(leftButton)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let plane = self.planes.filter{ plane in
            return plane.anchor.identifier == anchor.identifier
        }.first
        
        if plane == nil {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

}
