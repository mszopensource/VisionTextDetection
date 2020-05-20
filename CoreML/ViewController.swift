//
//  ViewController.swift
//  CoreML
//
//  Created by Shunzhe Ma on 5/20/20.
//  Copyright © 2020 Shunzhe Ma. All rights reserved.
//

import UIKit
import Vision
import VisionKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleToFill
    }
    
    @IBAction func actionPresentVision(){
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
    
    func processImage(input: CGImage) {
        let request = VNDetectTextRectanglesRequest { (request, error) in
            //We have the result here
            if let results = request.results as? [VNTextObservation] {
                for result in results {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(cgImage: input)
                        self.drawBoundingBox(forResult: result)
                    }
                }
            }
        }
        //Now pass the image to the request
        let handler = VNImageRequestHandler(cgImage: input, options: [:])
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                 print(error)
            }
        }
    }
    
    func drawBoundingBox(forResult: VNTextObservation) {
        
        let outline = CALayer()
        //The `boundingBox` is provided as a percentage.
        //we need to convert it to the actual point
        ///`topLeft` is the origin
        let x = forResult.topLeft.x * imageView.frame.width
        let y = (1 - forResult.topLeft.y) * imageView.frame.height
        ///Width and Height can be fetched from the `boundingBox`
        let width = forResult.boundingBox.width * imageView.frame.width
        let height = forResult.boundingBox.height * imageView.frame.height
        outline.frame = CGRect(x: x, y: y, width: width, height: height)
        outline.borderColor = UIColor.green.cgColor
        outline.borderWidth = 3
        imageView.layer.addSublayer(outline)
    }


}

extension ViewController: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        if let firstImage = scan.imageOfPage(at: 0).cgImage {
            //TODO
            processImage(input: firstImage)
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
}



