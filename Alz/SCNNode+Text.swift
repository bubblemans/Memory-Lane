//
//  SCNNode+Text.swift
//  faceIT
//
//  Created by Michael Ruhl on 18.08.17.
//  Copyright © 2017 NovaTec GmbH. All rights reserved.
//

import Foundation
import ARKit
import Async
import HoundifySDK


public extension SCNNode {
    convenience init(withText text : String, position: SCNVector3) {
        let bubbleDepth : Float = 0.01 // the 'depth' of 3D text
        
        // TEXT BILLBOARD CONSTRAINT
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        // BUBBLE-TEXT
        let bubble = SCNText(string: text, extrusionDepth: CGFloat(bubbleDepth))
        bubble.font = UIFont(name: "Futura", size: 0.08)?.withTraits(traits: .traitBold)
        bubble.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        bubble.firstMaterial?.diffuse.contents = UIColor.orange
        bubble.firstMaterial?.specular.contents = UIColor.white
        bubble.firstMaterial?.isDoubleSided = true
        bubble.chamferRadius = CGFloat(bubbleDepth)
        
//        // BUBBLE NODE
        let (minBound, maxBound) = bubble.boundingBox
        let bubbleNode = SCNNode(geometry: bubble)
        // Centre Node - to Centre-Bottom point
        bubbleNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, bubbleDepth/2)
        // Reduce default text size
        bubbleNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        bubbleNode.simdPosition = simd_float3.init(x: 0.05, y: 0.04, z: 0)
        
        // get the relation
        
        var relation = ""
        if let jsonData = jsonData {
            for contact in jsonData.items {
                print("contact: ", contact.username, "text ", text)
                if contact.username == text {
                    relation = contact.relation
                }
            }
        }
        print("realtion", relation)
        
        
        
        // DETAIL-TEXT
        let detailInfoText = SCNText(string: relation, extrusionDepth: CGFloat(bubbleDepth))
        detailInfoText.isWrapped = true
        detailInfoText.font = UIFont(name: "Futura", size: 0.08)?.withTraits(traits: .traitBold)
//        detailInfoText.containerFrame = CGRect(origin: .zero, size: CGSize(width: 100, height: 500))
        detailInfoText.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        detailInfoText.firstMaterial?.diffuse.contents = UIColor.blue
        detailInfoText.firstMaterial?.specular.contents = UIColor.white
        detailInfoText.firstMaterial?.isDoubleSided = true
        detailInfoText.chamferRadius = CGFloat(bubbleDepth)
                
        // DETAIL NODE
        let (minBoundDetail, maxBoundDetail) = bubble.boundingBox
        let detailNode = SCNNode(geometry: detailInfoText)
        // Centre Node - to Centre-Bottom point
        detailNode.pivot = SCNMatrix4MakeTranslation( (maxBoundDetail.x - minBoundDetail.x)/2, minBoundDetail.y, bubbleDepth/2)
        // Reduce default text size
        detailNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        detailNode.simdPosition = simd_float3.init(x: 0.05, y: 0.02, z: 0)
        
        // IMAGE NODE
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage.init(named: text)
//        material.isDoubleSided = true
//        let box = SCNBox.init(width: 0.5, height: 0.5, length: 0.01, chamferRadius: 0)
//        let boxNode = SCNNode(geometry: box)
//        box.firstMaterial = material
//        boxNode.scale = SCNVector3Make(0.1, 0.1, 0.1)
//        boxNode.simdPosition = simd_float3.init(x: 0.05, y: 0, z: 0)
        
        // CENTRE POINT NODE
        let sphere = SCNSphere(radius: 0.004)
        sphere.firstMaterial?.diffuse.contents = UIColor.gray
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.opacity = 0.6
        
        self.init()
//        addChildNode(boxNode)
        addChildNode(detailNode)
        addChildNode(bubbleNode)
        addChildNode(sphereNode)
        constraints = [billboardConstraint]
        self.position = position
    }
    
    func move(_ position: SCNVector3)  {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.2
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)
        self.position = position
        opacity = 1
        SCNTransaction.commit()
    }
    
    func hide()  {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.4
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)
        opacity = 0
        SCNTransaction.commit()
    }
    
    func show()  {
        opacity = 0
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.4
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)
        opacity = 1
        SCNTransaction.commit()
    }
}

private extension UIFont {
    // Based on: https://stackoverflow.com/questions/4713236/how-do-i-set-bold-and-italic-on-uilabel-of-iphone-ipad
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
}
