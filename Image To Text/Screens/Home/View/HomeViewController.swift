//
//  HomeViewController.swift
//  Image To Text
//
//  Created by Shishir_Mac on 14/3/23.
//

import UIKit
import Vision
import PhotosUI

class HomeViewController: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var showTextLabel: UILabel!
    @IBOutlet weak var getTextButton: UIButton!
    @IBOutlet weak var getPhotoButton: UIButton!
    
    var imageArray = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    // MARK: - Function
    
    private func recognizeText(image: UIImage?){
        guard let cgImage = image?.cgImage else { return }
        
        // Handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Request
        let request = VNRecognizeTextRequest{ [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                      return
                  }
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ", ")
            self?.showTextLabel.text = text
        }
        
        // Process request
        do {
            try handler.perform([request])
        } catch let error {
            showTextLabel.text = error.localizedDescription
            print(error.localizedDescription)
        }
        
    }
    
    // MARK: - IBAction
    @IBAction func getTextButtonAction(_ sender: UIButton) {
        recognizeText(image: imageArray)
    }
    
    @IBAction func getPhotoButtonAction(_ sender: UIButton) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        
        let pickerVC = PHPickerViewController(configuration: config)
        pickerVC.delegate = self
        self.present(pickerVC, animated: true)
    }
    
}
// MARK: - PHPickerViewControllerDelegate
extension HomeViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    self.imageArray = image
                }
                
                DispatchQueue.main.async { [self] in
                    self.photoImageView.image = imageArray
                }
            }
        }
    }
}
