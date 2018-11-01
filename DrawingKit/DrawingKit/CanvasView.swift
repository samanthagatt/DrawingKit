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
        
        // Appends an empty image to backlog so first stroke can be undone
        UIGraphicsBeginImageContext(frame.size)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        backlog.append(image)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Quick fix for palm rejection
        // Should be changed if I get to pinch to zoom
        self.isMultipleTouchEnabled = false
        
        // Appends an empty image to backlog so first stroke can be undone
        UIGraphicsBeginImageContext(frame.size)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        backlog.append(image)
    }
    
    
    // MARK: - Private Properties
    
    private var currentPath = UIBezierPath()
    private var bezierPoints: [CGPoint] = []
    
    private var backlog: [UIImage] = [] {
        didSet {
            if backlog.count > numberOfUndosSupported + 1 {
                backlog.removeFirst()
            }
        }
    }
    private var forwardLog: [UIImage] = []
    private var undoCount = 0
    
    
    // MARK: - Public Properties
    
    public var strokeLineWidth: CGFloat = 2.0
    public var strokeColor = UIColor.blue
    public var strokeAlpha: CGFloat = 1.0
    public var strokeBlendMode: CGBlendMode = .normal
    public var strokeIsEraser = false
    public var numberOfUndosSupported = 10
    
    // MARK: - Private Functions
    
    private func convertToImage() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        if let lastImage = backlog.last {
            lastImage.draw(at: .zero)
        }
        strokeCurrentPath()
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            backlog.append(image)
        }
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
    
    private func strokeCurrentPath() {
        strokeColor.setStroke()
        currentPath.lineCapStyle = .round
        currentPath.lineWidth = strokeLineWidth
        
        let blendMode: CGBlendMode = strokeIsEraser ? .clear : strokeBlendMode
        currentPath.stroke(with: blendMode, alpha: strokeAlpha)
    }
    
    
    // MARK: - Public Functions
    
    public func undo() {
        // Conditional statement makes sure there is always one image in the backlog so you can't undo too many times and erase the entire user drawn image
        // Requires there to be one image in the backlog in the init calls so the first stroke the user makes can be undone
        if backlog.count > 1 {
            guard let image = backlog.popLast() else { return }
            forwardLog.append(image)
            setNeedsDisplay()
        }
    }
    
    public func redo() {
        guard let image = forwardLog.popLast() else { return }
        backlog.append(image)
        setNeedsDisplay()
    }
    
    public func getCurrentImage() -> UIImage? {
        return backlog.last
    }
    
    /// Returns the current status of editability AFTER it has been toggled
    public func toggleEditIsEnabled() -> Bool {
        let status = self.isUserInteractionEnabled
        self.isUserInteractionEnabled = !status
        return !status
    }
    
    
    // MARK: - UIView Draw
    
    public override func draw(_ rect: CGRect) {
        if let lastImage = backlog.last {
            lastImage.draw(in: rect)
        }
        
        strokeCurrentPath()
    }
    
    
    // MARK: - UIView Touch Handling
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        
        forwardLog.removeAll()
        
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
        currentPath.move(to: bezierPoints[0])
        if bezierPoints.count == 4 {
            currentPath.addCurve(to: bezierPoints[3], controlPoint1: bezierPoints[1], controlPoint2: bezierPoints[2])
        } else if bezierPoints.count == 3 {
            currentPath.addQuadCurve(to: bezierPoints[2], controlPoint: bezierPoints[1])
        } else if bezierPoints.count == 2 {
            currentPath.addLine(to: bezierPoints[1])
        }
        
        convertToImage()
        setNeedsDisplay()
        bezierPoints.removeAll()
        currentPath.removeAllPoints()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}
