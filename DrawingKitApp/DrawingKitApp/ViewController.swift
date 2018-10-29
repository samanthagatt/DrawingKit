//
//  ViewController.swift
//  DrawingKitApp
//
//  Created by Samantha Gatt on 10/29/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit
import DrawingKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBOutlet weak var canvasView: CanvasView!
    
    @IBAction func undo(_ sender: Any) {
        canvasView.undo()
    }
    
    @IBAction func redo(_ sender: Any) {
        canvasView.redo()
    }
    
}

