//
//  ViewController.swift
//  MissileLauncher
//
//  Created by apple on 2020/04/17.
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
        let missileScene = SCNScene(named: "art.scnassets/missile1.scn")!
        
        let missile = Missile(scene: missileScene)
        missile.position = SCNVector3(0,0,-4)

        let scene = SCNScene()
        
        scene.rootNode.addChildNode(missile)
        
        // Set the scene to the view
        sceneView.scene = scene
        
        registerGestureRecognizers()
    }
    
    private func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer){
        
        guard let missileNode = self.sceneView.scene.rootNode.childNode(withName: "Missile", recursively: true) else {
            fatalError("Missile not found")
        }
        
        guard let smokeNode = self.sceneView.scene.rootNode.childNode(withName: "smokeNode", recursively: true) else {
            fatalError("smoke not found")
        }
        
        smokeNode.removeAllParticleSystems()
        
        let fire = SCNParticleSystem(named: "art.scnassets/fire.scnp", inDirectory: nil)!
        
        smokeNode.addParticleSystem(fire)
        
        missileNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)//shape에 nil을 해주면 arkit이 모양을 나를 위해서 만들어준다.
        
        missileNode.physicsBody?.isAffectedByGravity = false
        missileNode.physicsBody?.damping = 0.0// air fiction, fluid fiction
        
        missileNode.physicsBody?.applyForce(SCNVector3(0,100,0), asImpulse: false)//impulse 는 가속도 느낌이 난다.
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

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
