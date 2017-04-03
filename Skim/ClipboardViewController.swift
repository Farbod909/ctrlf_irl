//
//  ClipboardViewController.swift
//  Skim
//
//  Created by Farbod Rafezy on 4/2/17.
//  Copyright © 2017 Farbod Rafezy. All rights reserved.
//

import Foundation
import UIKit

class ClipboardViewController: UIViewController {

    @IBOutlet weak var clipboard: UITextView!
    var clipboardText: String = ""

    override func viewDidLoad() {
        clipboard.isEditable = false
        clipboard.text = clipboardText
    }

    override func didReceiveMemoryWarning() {
        //
    }

    @IBAction func cancelPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
