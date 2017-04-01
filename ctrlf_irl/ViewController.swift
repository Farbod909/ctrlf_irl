//
//  ViewController.swift
//  ctrlf_irl
//
//  Created by Farbod Rafezy on 4/1/17.
//  Copyright © 2017 Farbod Rafezy. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Ocp-Apim-Subscription-Key": "694773d0aa5d4f0b9ed096a2e8e1fc29"
        ]

        let parameters: Parameters = [
            "url": "http://i.imgur.com/OGrX8GC.png"
        ]

        Alamofire.request("https://westus.api.cognitive.microsoft.com/vision/v1.0/ocr?language=unk&detectOrientation=true", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

