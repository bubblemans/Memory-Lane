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
        self.init()
        if text == "Negative" { return }
        let bubbleDepth : Float = 0.01 // the 'depth' of 3D text
        
        // TEXT BILLBOARD CONSTRAINT
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        // BUBBLE-TEXT
        let bubble = SCNText(string: text, extrusionDepth: CGFloat(bubbleDepth))
        bubble.font = UIFont(name: "Futura", size: 0.08)?.withTraits(traits: .traitBold)
        bubble.alignmentMode = CATextLayerAlignmentMode.left.rawValue
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
        
        // get the relation and dob
        var relation = ""
        var dob = ""
        if let jsonData = jsonData {
            for contact in jsonData.items {
                print("contact: ", contact.username, "text ", text)
                if let username = contact.username, let rela = contact.relation, let dateOfBirth = contact.dob {
                    if username == text {
                        relation = rela
                        dob = dateOfBirth
                    }
                }
            }
        }
        
        // DETAIL-TEXT
        let detailInfoText = SCNText(string: "Relation: "+relation, extrusionDepth: CGFloat(bubbleDepth))
        detailInfoText.isWrapped = true
        detailInfoText.font = UIFont(name: "Futura", size: 0.08)?.withTraits(traits: .traitBold)
//        detailInfoText.containerFrame = CGRect(origin: .zero, size: CGSize(width: 100, height: 500))
        detailInfoText.alignmentMode = CATextLayerAlignmentMode.left.rawValue
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
        
        // DETAIL-TEXT
        let dobText = SCNText(string: "DOB: "+dob, extrusionDepth: CGFloat(bubbleDepth))
        dobText.isWrapped = true
        dobText.font = UIFont(name: "Futura", size: 0.08)?.withTraits(traits: .traitBold)
//        detailInfoText.containerFrame = CGRect(origin: .zero, size: CGSize(width: 100, height: 500))
        dobText.alignmentMode = CATextLayerAlignmentMode.left.rawValue
        dobText.firstMaterial?.diffuse.contents = UIColor.blue
        dobText.firstMaterial?.specular.contents = UIColor.white
        dobText.firstMaterial?.isDoubleSided = true
        dobText.chamferRadius = CGFloat(bubbleDepth)
                
        // DETAIL NODE
        let (minBoundDOB, maxBoundDOB) = bubble.boundingBox
        let dobNode = SCNNode(geometry: dobText)
        // Centre Node - to Centre-Bottom point
        dobNode.pivot = SCNMatrix4MakeTranslation( (maxBoundDOB.x - minBoundDOB.x)/2, minBoundDOB.y, bubbleDepth/2)
        // Reduce default text size
        dobNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        dobNode.simdPosition = simd_float3.init(x: 0.05, y: 0, z: 0)
        
        
        // CENTRE POINT NODE
        let sphere = SCNSphere(radius: 0.004)
        sphere.firstMaterial?.diffuse.contents = UIColor.gray
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.opacity = 0.6
        
//        addChildNode(boxNode)
        addChildNode(dobNode)
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
