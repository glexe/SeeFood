//
//  ViewController.swift
//  SeeFood2
//
//  Created by Ilya Gladyshev on 8/12/24.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet var mainView: UIView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            ImageView.image = userPickedImage
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Couldn't convert image to CIImage")
            }
            detect(image: ciimage)
            
        }
        
        imagePicker.dismiss(animated: true)
        
    }
    
    
    func detect (image: CIImage) {
        let config = MLModelConfiguration()
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: config).model) else {
               fatalError("Error loading Core ML model")
           }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let result = request.results as? [VNClassificationObservation] else {
                fatalError("There is no correct result")
            }
            if let firstResult = result.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                    self.mainView.backgroundColor = UIColor.green
                } else {
                    self.navigationItem.title = "Not hotdog!"
                    self.mainView.backgroundColor = UIColor.red
                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print("Baaad")
        }
    }

   
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true)
    }
    
}

