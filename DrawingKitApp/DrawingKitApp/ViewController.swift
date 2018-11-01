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
        _ = canvasView.toggleEditIsEnabled()
        canvasView.startingImage = UIImage(named: "arrow")
    }
    
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var eraserModeButton: UIButton!
    @IBOutlet weak var editDoneButton: UIButton!
    
    @IBAction func undo(_ sender: Any) {
        canvasView.undo()
    }
    
    @IBAction func redo(_ sender: Any) {
        canvasView.redo()
    }
    
    @IBAction func toggleEraserMode(_ sender: Any) {
        canvasView.strokeIsEraser = !canvasView.strokeIsEraser
        if canvasView.strokeIsEraser == true {
            eraserModeButton.setTitle("Draw", for: .normal)
        } else {
            eraserModeButton.setTitle("Erase", for: .normal)
        }
    }
    
    @IBAction func toggleEdit(_ sender: Any) {
        let status = canvasView.toggleEditIsEnabled()
        editDoneButton.setTitle(status ? "Done" : "Edit", for: .normal)
    }
}

