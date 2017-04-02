//
//  ViewController.swift
//  ctrlf_irl
//
//  Created by Farbod Rafezy on 4/1/17.
//  Copyright © 2017 Farbod Rafezy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var searchField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func cameraButtonAction(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    @IBAction func photoLibraryAction(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!){
        pickedImage.image = image
        pickedImage.contentMode = .scaleAspectFit
        self.dismiss(animated: true, completion: nil);
    }

    func drawCustomImage(size: CGSize) -> UIImage {
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        let opaque = false
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()

        context!.setStrokeColor(UIColor.yellow.cgColor)
        context!.setLineWidth(2.0)

        context!.stroke(bounds)
        context!.setFillColor(UIColor(red: 1, green: 1, blue: 0, alpha: 0.5).cgColor)
        context?.fill(bounds)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }


    @IBAction func findClicked(_ sender: UIButton) {
        searchField.resignFirstResponder()

        let headers: HTTPHeaders = [
            "Content-Type": "application/octet-stream",
            "Ocp-Apim-Subscription-Key": "694773d0aa5d4f0b9ed096a2e8e1fc29"
        ]

        let imageData = UIImageJPEGRepresentation(pickedImage.image!, 0.99)!

        var wordStore = [(String, String)]()

        Alamofire.upload(imageData, to: "https://westus.api.cognitive.microsoft.com/vision/v1.0/ocr?language=unk&detectOrientation=true", headers: headers).responseJSON { response in

            let json = JSON(data: response.data!)
            for region in json["regions"].arrayValue {
                for line in region["lines"].arrayValue {
                    for word in line["words"].arrayValue {
                        wordStore.append((word["text"].stringValue, word["boundingBox"].stringValue))
                    }
                }
            }

            var highlightedBoundingBoxes = [String]()

            for wordTuple in wordStore {
                if wordTuple.0 == self.searchField.text! {
                    highlightedBoundingBoxes.append(wordTuple.1)
                }
            }

//            print(highlightedBoundingBoxes)

            DispatchQueue.main.async { [unowned self] in
                for box in highlightedBoundingBoxes {
                    let box_vals = box.components(separatedBy: ",")

                    print(box_vals)

                    let x: CGFloat = CGFloat(Int(box_vals[0])!)/6.2
                    let y: CGFloat = CGFloat(Int(box_vals[1])!)/5.8
                    let w: CGFloat = CGFloat(Int(box_vals[2])!)/4.0
                    let h: CGFloat = CGFloat(Int(box_vals[3])!)/4.0

                    let imageSize = CGSize(width: w, height: h)
                    let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: x, y: y), size: imageSize))
                    self.pickedImage.addSubview(imageView)
                    let image = self.drawCustomImage(size: imageSize)
                    imageView.image = image
                }
            }
        }
    }
}

