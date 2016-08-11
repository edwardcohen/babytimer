//
//  SettingViewController.swift
//  Goodnight Moon
//
//  Created by Eddie Cohen & Jason Toff on 8/11/16.
//  Copyright © 2016 zelig. All rights reserved.
//

import UIKit
import CoreData

class SettingViewController: UIViewController {
    @IBOutlet var aboutButton: UIButton!
    @IBOutlet var playOnLaunchSwitch: UISwitch!
    
    var setting: Setting?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSetting()
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
    
    @IBAction func switchPlayOnLaunch() {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            if setting == nil {
                setting = NSEntityDescription.insertNewObjectForEntityForName("Setting", inManagedObjectContext: managedObjectContext) as? Setting
            }
            setting!.playOnLaunch = NSNumber(bool: playOnLaunchSwitch.on)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
                return
            }
        }
    }
    
    func loadSetting() {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "Setting")
            
            do {
                let settings = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Setting]
                setting = settings.first
                if setting != nil {
                    playOnLaunchSwitch.on = setting!.playOnLaunch.boolValue
                }
            } catch {
                print(error)
                return
            }
        }
    }
}
