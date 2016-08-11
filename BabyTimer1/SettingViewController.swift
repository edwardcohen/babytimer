//
//  SettingViewController.swift
//  Goodnight Moon
//
//  Created by Eddie Cohen & Jason Toff on 8/11/16.
//  Copyright © 2016 zelig. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    @IBOutlet var aboutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btnAbout() {
        let message = "Goodnig.ht was made by a Dad to help put his newborn son to sleep. We’ve optimized the experience to help put your child to sleep instantaneously. Goodnight!"
        let alertController = UIAlertController(title: "About",
                                                message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style:
            UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion:
            nil)
    }
}
