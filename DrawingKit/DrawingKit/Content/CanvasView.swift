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
    
    
    
    
    // MARK: - Public Properties
    
    
    
    
    // MARK: - Private Functions
    
    
    
    
    // MARK: - Public Functions
    
    
}
