//
//  souvenirViewController.swift
//  MuseumTourGuide
//
//  Created by Jeffrey Cheung on 18/3/2019.
//  Copyright © 2019 Jeffrey Cheung. All rights reserved.
//

import UIKit
let new_defaults = UserDefaults.standard

class souvenirViewController: UIViewController {
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func getButton(_ sender: Any) {
        let aaa = new_defaults.string(forKey: "mint")
        let bbb = new_defaults.string(forKey: "coconut")
        if aaa != nil && bbb != nil {
            displayLabel.text = "You got the souvenir!"
            imageView.isHidden = false
        } else {
            displayLabel.text = "Sorry! You can't get the souvenir!"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        /*let aaa = new_defaults.string(forKey: "mint")
        if aaa != nil {
            displayLabel.text = "success"
        } else {
            
        }*/
        
        imageView.isHidden = true
    }

}
