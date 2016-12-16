//
//  ViewController.swift
//  AGGeometryKitIssue
//
//  Created by Alexander Edunov on 16/12/2016.
//  Copyright © 2016 Alexander Edunov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var tlControl: UIView!
    @IBOutlet weak var trControl: UIView!
    @IBOutlet weak var brControl: UIView!
    @IBOutlet weak var blControl: UIView!
    
    @IBOutlet weak var target: UIView!
    
    fileprivate var initialQuadrilateral: AGKQuad?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        target.layer.ensureAnchorPointIsSetToZero()
    }
    
    // MARK: Gesture handlers
    
    @IBAction func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let t = recognizer.translation(in: view)
        
        if let view = recognizer.view {
            applyTranslation(t, toView: view)
            
            if (view == target) {
                applyTranslation(t, toView: tlControl)
                applyTranslation(t, toView: trControl)
                applyTranslation(t, toView: brControl)
                applyTranslation(t, toView: blControl)
            }
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        
        target.layer.quadrilateral = AGKQuadMake(tlControl.center,
                                                 trControl.center,
                                                 brControl.center,
                                                 blControl.center)
    }
    
    @IBAction func handlePinch(_ recognizer : UIPinchGestureRecognizer) {
        if (recognizer.state == .began) {
            initialQuadrilateral = target.layer.quadrilateral
        }
        
        let transform = CGAffineTransform.identity.scaledBy(x: recognizer.scale, y: recognizer.scale)
        target.layer.quadrilateral = AGKQuadApplyCGAffineTransform(initialQuadrilateral!, transform)
        
        updateControlPointsPosition()
    }
    
    @IBAction func handleRotation(_ recognizer : UIRotationGestureRecognizer) {
        if (recognizer.state == .began) {
            initialQuadrilateral = target.layer.quadrilateral
        }
        
        let transform = CGAffineTransform.identity.rotated(by: recognizer.rotation)
        target.layer.quadrilateral = AGKQuadApplyCGAffineTransform(initialQuadrilateral!, transform)
        
        updateControlPointsPosition()
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    // MARK: Private
    
    fileprivate func applyTranslation(_ translation: CGPoint, toView view: UIView) {
        view.center = CGPoint(x: view.center.x + translation.x,
                              y: view.center.y + translation.y)
    }

    fileprivate func updateControlPointsPosition() {
        tlControl.center = target.layer.quadrilateral.tl
        trControl.center = target.layer.quadrilateral.tr
        brControl.center = target.layer.quadrilateral.br
        blControl.center = target.layer.quadrilateral.bl
    }
}

