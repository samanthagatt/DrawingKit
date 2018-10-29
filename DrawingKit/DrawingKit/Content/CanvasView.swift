//
//  CanvasView.swift
//  DrawingKit
//
//  Created by Samantha Gatt on 10/29/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit

public class CanvasView: UIView {
    
    // MARK: - Inits
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Quick fix for palm rejection
        // Should be changed if I get to pinch to zoom
        self.isMultipleTouchEnabled = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Quick fix for palm rejection
        // Should be changed if I get to pinch to zoom
        self.isMultipleTouchEnabled = false
    }
    
    
    // MARK: - Private Properties
    
    private var currentPath = UIBezierPath()
    private var intermediateImage: UIImage?
    private var bezierPoints: [CGPoint] = []
    
//    private var backlog: [UIImage] = []
//    private var forwardLog: [UIImage] = []
    
    
    // MARK: - Public Properties
    
    public var defaultLineWidth = 4.0
    public var strokeColor = UIColor.black {
        didSet {
            strokeColor.setStroke()
        }
    }
    
    // MARK: - Private Functions
    
    private func convertToImage() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        if let intermediateImage = intermediateImage {
            intermediateImage.draw(at: .zero)
        }
        strokeColor.setStroke()
        currentPath.stroke()
        intermediateImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    private func addCurveToBezierPath() {
        if bezierPoints.count == 5 {
            // (x, y): exact middle of the theoretical line that connects the third and fifth points
            let x = (bezierPoints[2].x + bezierPoints[4].x) / 2.0
            let y = (bezierPoints[2].y + bezierPoints[4].y) / 2.0
            
            // Replaces the fourth point with a calculated point
            // Makes path smoother (not so jagged and pointy)
            bezierPoints[3] = CGPoint(x: x, y: y)
            
            currentPath.move(to: bezierPoints[0])
            
            // Draws a curve between first and fourth points instead of a line between all points
            // Makes path even smoother
            currentPath.addCurve(to: bezierPoints[3], controlPoint1: bezierPoints[1], controlPoint2: bezierPoints[2])
        }
    }
    
    
    // MARK: - Public Functions
    
    
    
    
    // MARK: - UIView Draw
    
    public override func draw(_ rect: CGRect) {
        if let intermediateImage = intermediateImage {
            intermediateImage.draw(in: rect)
        }
        
        // Should do nothing when called in touchesEnded since it's already been called in convertToImage()
        currentPath.stroke()
    }
    
    
    // MARK: - UIView Touch Handling
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        
        bezierPoints.append(point)
}
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        
        bezierPoints.append(point)
        
        addCurveToBezierPath()
        if bezierPoints.count == 5 {
            setNeedsDisplay()
            
            let firstPoint = bezierPoints[3]
            let secondPoint = bezierPoints[4]
            bezierPoints.removeAll()
            bezierPoints.append(firstPoint)
            bezierPoints.append(secondPoint)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        
        bezierPoints.append(point)
        addCurveToBezierPath()
        if bezierPoints.count == 4 {
            currentPath.move(to: bezierPoints[0])
            currentPath.addCurve(to: bezierPoints[3], controlPoint1: bezierPoints[1], controlPoint2: bezierPoints[2])
        } else if bezierPoints.count == 3 {
            currentPath.move(to: bezierPoints[0])
            currentPath.addQuadCurve(to: bezierPoints[2], controlPoint: bezierPoints[1])
        }
        
        convertToImage()
        setNeedsDisplay()
        bezierPoints.removeAll()
        currentPath = UIBezierPath()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}
