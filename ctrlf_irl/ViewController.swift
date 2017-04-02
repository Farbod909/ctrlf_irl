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


//        Alamofire.request("https://westus.api.cognitive.microsoft.com/vision/v1.0/ocr?language=unk&detectOrientation=true", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
//            if let JSON = response.result.value {
//                //print("JSON: \(JSON)")
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    @IBAction func findClicked(_ sender: UIButton) {
        searchField.resignFirstResponder()

        let headers: HTTPHeaders = [
            "Content-Type": "application/octet-stream",
            "Ocp-Apim-Subscription-Key": "694773d0aa5d4f0b9ed096a2e8e1fc29"
        ]


        let imageData = UIImageJPEGRepresentation(pickedImage.image!, 0.99)!

//        let imageSize: Int = imageData.count
//        print("size of image in KB: %f ", imageSize / 1024)

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

            print(highlightedBoundingBoxes)


        }

    }
}

