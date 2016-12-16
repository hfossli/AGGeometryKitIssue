//
//  ViewController.swift
//  AGGeometryKitIssue
//
//  Created by Alexander Edunov on 16/12/2016.
//  Copyright © 2016 Alexander Edunov. All rights reserved.
//

import UIKit

func - (first: CGPoint, second: CGPoint) -> CGPoint {
    return CGPoint(x: first.x - second.x, y: first.y - second.y)
}

func + (first: CGPoint, second: CGPoint) -> CGPoint {
    return CGPoint(x: first.x + second.x, y: first.y + second.y)
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var tlControl: UIView!
    @IBOutlet weak var trControl: UIView!
    @IBOutlet weak var brControl: UIView!
    @IBOutlet weak var blControl: UIView!
    
    @IBOutlet weak var target: UIView!
    
    @IBOutlet weak var pinchRecognizer: UIPinchGestureRecognizer!
    @IBOutlet weak var rotationRecognizer: UIRotationGestureRecognizer!
    @IBOutlet weak var panRecognizer: UIPanGestureRecognizer!
    
    fileprivate var initialQuad: AGKQuad?
    fileprivate var initialTouchLocation: CGPoint?
    
    fileprivate var lastScale: CGFloat = 1.0
    fileprivate var lastRotation: CGFloat = 0.0
    fileprivate var lastTranslation: CGPoint = CGPoint.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        target.layer.ensureAnchorPointIsSetToZero()
        
        let quad = target.layer.quadrilateral
        target.center = CGPoint.zero
        target.layer.quadrilateral = quad
    }
    
    // MARK: Gesture handlers
    
    @IBAction func handlePanInControlPoint(_ recognizer: UIPanGestureRecognizer) {
        recognizer.view!.center = recognizer.view!.center + recognizer.translation(in: view)
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view!)
        updateQuadrilateralByControlPoints()
    }
    
    @IBAction func handlePan(_ recognizer: UIPanGestureRecognizer) {
        handleRecognizer(recognizer)
    }
    
    @IBAction func handlePinch(_ recognizer : UIPinchGestureRecognizer) {
        handleRecognizer(recognizer)
    }
    
    @IBAction func handleRotation(_ recognizer : UIRotationGestureRecognizer) {
        handleRecognizer(recognizer)
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: Private
    
    fileprivate func handleRecognizer(_ recognizer: UIGestureRecognizer) {
        if initialQuad == nil, initialTouchLocation == nil {
            initialQuad = target.layer.quadrilateral
            initialTouchLocation = recognizer.location(in: view)
            lastTranslation = CGPoint.zero
            lastRotation = 0.0
            lastScale = 1.0
        }
        
        if isActive(recognizer: pinchRecognizer) {
            lastScale = pinchRecognizer.scale
        }
        
        if isActive(recognizer: rotationRecognizer) {
            lastRotation = rotationRecognizer.rotation
        }
        
        if isActive(recognizer: panRecognizer) {
            lastTranslation = panRecognizer.translation(in: view)
        }
        
        if let initialQuad = initialQuad, let initialTouchLocation = initialTouchLocation {
            
            let transform = CGAffineTransform.identity
                .translatedBy(x: initialTouchLocation.x, y: initialTouchLocation.y)
                .translatedBy(x: lastTranslation.x, y: lastTranslation.y)
                .scaledBy(x: lastScale, y: lastScale)
                .rotated(by: lastRotation)
                .translatedBy(x: -initialTouchLocation.x, y: -initialTouchLocation.y)
            
            let quad = AGKQuadApplyCGAffineTransform(initialQuad, transform)
            
            target.layer.quadrilateral = quad
            
            updateControlPoints()
        }
        
        if !isActive(recognizer: pinchRecognizer) && !isActive(recognizer: rotationRecognizer) && !isActive(recognizer: panRecognizer) {
            initialQuad = nil
            initialTouchLocation = nil
        }
    }
    
    fileprivate func isActive(recognizer: UIGestureRecognizer) -> Bool {
        return recognizer.state == .began || recognizer.state == .changed
    }
    
    fileprivate func updateQuad(_ quad: AGKQuad, translation: CGPoint, scale: CGFloat, rotation: CGFloat) {
        
    }
    
    fileprivate func updateQuadrilateralByControlPoints() {
        let quad = AGKQuadMake(tlControl.center, trControl.center, brControl.center, blControl.center)
        target.layer.quadrilateral = quad
    }

    fileprivate func updateControlPoints() {
        tlControl.center = target.layer.quadrilateral.tl
        trControl.center = target.layer.quadrilateral.tr
        brControl.center = target.layer.quadrilateral.br
        blControl.center = target.layer.quadrilateral.bl
    }
}

