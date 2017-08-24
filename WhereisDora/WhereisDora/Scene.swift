//
//  Scene.swift
//  WhereisDora
//
//  Created by 黄少华 on 2017/8/23.
//  Copyright © 2017年 黄少华. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit

class Scene: SKScene {
    
    let remainingDoraNode = SKLabelNode()
    
    var doraCreated = 0
    var doraRemains = 0 {
        didSet {
            remainingDoraNode.text = "\(doraRemains) Doras left in your room"
        }
    }
    
    var doraGameTimer: Timer?
    
    func generateDora() {
        if doraCreated == 10 {
            doraGameTimer?.invalidate()
            doraGameTimer = nil
            return
        }
        doraCreated += 1
        doraRemains += 1
        
        guard let sceneView = self.view as? ARSKView else { return  }
        
        let randNumber = GKRandomSource.sharedRandom()
        let xRotation = simd_float4x4(SCNMatrix4MakeRotation(randNumber.nextUniform() * Float.pi * 2, 1, 0, 0))
        let yRotation = simd_float4x4(SCNMatrix4MakeRotation(randNumber.nextUniform() * Float.pi * 2, 0, 1, 0))
        let rotation = simd_mul(xRotation, yRotation)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1
        
        let transform = simd_mul(rotation, translation)
        
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
    }
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        remainingDoraNode.fontSize = 25
        remainingDoraNode.fontName = "BradleyHandITCTT-Bold"
        remainingDoraNode.color = .white
        remainingDoraNode.position = CGPoint(x: 0, y: view.frame.midY - 50)
        
        addChild(remainingDoraNode)
        doraRemains = 0
        
        doraGameTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { timer in
            self.generateDora()
        })
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let hittedDora = nodes(at: location)
        
        if let dora = hittedDora.first {
            doraRemains -= 1;
            
            let scaleOut = SKAction.scale(by: 2, duration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let group = SKAction.group([scaleOut,fadeOut])
            let sequence = SKAction.sequence([group,SKAction.removeFromParent()])
            
            dora.run(sequence)
            
            if doraRemains == 0 && doraCreated == 10 {
                remainingDoraNode.removeFromParent()
                addChild(SKSpriteNode(imageNamed: "game_over"))
            }
        }
    }
}
