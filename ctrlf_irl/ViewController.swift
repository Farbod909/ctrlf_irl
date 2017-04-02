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

let debugMode = true

func printDebug(_ str: String) {
    print("************ START DEBUG INFO ************")
    print(str)
    print("************ END   DEBUG INFO ************")
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var findButton: UIButton!

    var wordStore = [(String, String)]()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate = self

        findButton.setTitleColor(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1), for: .disabled)
        findButton.isEnabled = false
        searchField.isEnabled = false
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
        pickedImage.contentMode = .scaleAspectFit
        pickedImage.image = image
        self.dismiss(animated: true, completion: nil);

        clearHighlights()
        searchField.text = ""
        findButton.isEnabled = false
        searchField.isEnabled = false
        self.getWordStore()
    }

    func getWordStore() {
        let headers: HTTPHeaders = [
            "Content-Type": "application/octet-stream",
            "Ocp-Apim-Subscription-Key": "694773d0aa5d4f0b9ed096a2e8e1fc29"
        ]

        let imageData = UIImageJPEGRepresentation(pickedImage.image!, 0.99)!

        if debugMode {
            let imageSize: Int = imageData.count
            printDebug("size of image uploaded (kb): \(Double(imageSize) / 1024.0) ")
        }


        Alamofire.upload(imageData, to: "https://westus.api.cognitive.microsoft.com/vision/v1.0/ocr?language=unk&detectOrientation=true", headers: headers).responseJSON { response in

            let json = JSON(data: response.data!)
            for region in json["regions"].arrayValue {
                for line in region["lines"].arrayValue {
                    for word in line["words"].arrayValue {
                        self.wordStore.append((word["text"].stringValue, word["boundingBox"].stringValue))
                    }
                }
            }
            self.searchField.isEnabled = true
            self.findButton.isEnabled = true
        }

    }

    func drawCustomImage(size: CGSize) -> UIImage {
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        let opaque = false
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()

        context!.setStrokeColor(UIColor.yellow.cgColor)
        context!.setLineWidth(2.0)

//        context!.stroke(bounds)
        context!.setFillColor(UIColor(red: 1, green: 1, blue: 0, alpha: 0.5).cgColor)
        context?.fill(bounds)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    func imageSizeAspectFit(imgview: UIImageView) -> CGSize {
        var newwidth: CGFloat
        var newheight: CGFloat
        let image: UIImage = imgview.image!

        if image.size.height >= image.size.width {
            newheight = imgview.frame.size.height;
            newwidth = (image.size.width / image.size.height) * newheight
            if newwidth > imgview.frame.size.width {
                let diff: CGFloat = imgview.frame.size.width - newwidth
                newheight = newheight + diff / newheight * newheight
                newwidth = imgview.frame.size.width
            }
        }
        else {
            newwidth = imgview.frame.size.width
            newheight = (image.size.height / image.size.width) * newwidth
            if newheight > imgview.frame.size.height {
                let diff: CGFloat = imgview.frame.size.height - newheight
                newwidth = newwidth + diff / newwidth * newwidth
                newheight = imgview.frame.size.height
            }
        }

        if debugMode {
            print("BELOW IS NEW WIDTH, NEW HEIGHT")
            print(newwidth, newheight)
            print("BELOW IS OLD WIDTH, OLD HEIGHT")
            print(self.pickedImage.frame.size.width, self.pickedImage.frame.size.height)
        }


        //adapt UIImageView size to image size
        return CGSize(width: newwidth, height: newheight)
    }


    @IBAction func findClicked(_ sender: UIButton) {
        searchField.resignFirstResponder()

        let photoSize = imageSizeAspectFit(imgview: self.pickedImage)
        let topMargin = (self.pickedImage.frame.size.height-photoSize.height)/2
        let box_max_width: CGFloat = 2432.0
        let box_max_height: CGFloat = 3243.0
        let padding: CGFloat = 5.0

        var highlightedBoundingBoxes = [String]()

        for wordTuple in self.wordStore {
            if wordTuple.0.lowercased().contains(self.searchField.text!.lowercased()) {
                highlightedBoundingBoxes.append(wordTuple.1)
            }
        }

        if debugMode {
            printDebug("all words: \(self.wordStore)")
            printDebug("boxes that should be highlighted: \(highlightedBoundingBoxes)")
        }

        DispatchQueue.main.async { [unowned self] in
            for box in highlightedBoundingBoxes {
                let box_vals = box.components(separatedBy: ",")

                let x: CGFloat = CGFloat(Int(box_vals[0])!)*(photoSize.width/box_max_width)-padding     // /6.2
                let y: CGFloat = CGFloat(Int(box_vals[1])!)*(photoSize.height/box_max_height)+topMargin-padding     // /5.8
                let w: CGFloat = CGFloat(Int(box_vals[2])!)*(photoSize.width/box_max_width)+padding     // /5.2
                let h: CGFloat = CGFloat(Int(box_vals[3])!)*(photoSize.height/box_max_height)+padding     // /4.0

                let imageSize = CGSize(width: w, height: h)
                let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: x, y: y), size: imageSize))

                self.pickedImage.addSubview(imageView)
                let image = self.drawCustomImage(size: imageSize)
                imageView.image = image
            }
        }
    }
    func clearHighlights() {
        DispatchQueue.main.async { [unowned self] in
            print("editing started")
            for subview in self.pickedImage.subviews {
                subview.removeFromSuperview()
            }
        }
    }
    @IBAction func startEditingSearch(_ sender: UITextField) {
        clearHighlights()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        if self.wordStore.count > 0 {
            self.findClicked(findButton)
            return true
        }
        return false
    }
}

