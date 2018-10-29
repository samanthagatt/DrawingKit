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
        currentPath.move(to: point)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let point = touch.location(in: self)
        currentPath.addLine(to: point)
        setNeedsDisplay()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let point = touch.location(in: self)
        currentPath.addLine(to: point)
        convertToImage()
        setNeedsDisplay()
        currentPath = UIBezierPath()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}
