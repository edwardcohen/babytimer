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
    @IBOutlet var fadeTimeButton: UIButton!
    
    var setting: Setting?
    
    var fadeTimes = [60: "1 Minute", 15: "15 Seconds"]
    
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
            setting!.playOnLaunch = NSNumber(bool: playOnLaunchSwitch.on)
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
                return
            }
        }
    }
    
    @IBAction func buttonFadeTime() {
        let fadeTimeMenu = UIAlertController(title: nil, message: "Select Fade Time", preferredStyle: .ActionSheet)

        let oneMinAction = UIAlertAction(title: "1 Minute", style: .Default, handler: { action in
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                self.setting!.fadeTime = 60
                do {
                    try managedObjectContext.save()
                    self.fadeTimeButton.setTitle(self.fadeTimes[self.setting!.fadeTime.integerValue], forState: UIControlState.Normal)
                } catch {
                    print(error)
                    return
                }
            }
        })
        fadeTimeMenu.addAction(oneMinAction)

        let fifteenSecAction = UIAlertAction(title: "15 Seconds", style: .Default, handler: { action in
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                self.setting!.fadeTime = 15
                do {
                    try managedObjectContext.save()
                    self.fadeTimeButton.setTitle(self.fadeTimes[self.setting!.fadeTime.integerValue], forState: UIControlState.Normal)
                } catch {
                    print(error)
                    return
                }
            }
        })
        fadeTimeMenu.addAction(fifteenSecAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        fadeTimeMenu.addAction(cancelAction)
        
        presentViewController(fadeTimeMenu, animated: true, completion: nil)
    }
    
    func loadSetting() {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "Setting")
            
            do {
                let settings = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Setting]
                setting = settings.first
                if setting == nil {
                    setting = NSEntityDescription.insertNewObjectForEntityForName("Setting", inManagedObjectContext: managedObjectContext) as? Setting
                    setting!.playOnLaunch = NSNumber(bool: true)
                    setting!.fadeTime = 60
                }
                
                playOnLaunchSwitch.on = setting!.playOnLaunch.boolValue
                fadeTimeButton.setTitle(fadeTimes[setting!.fadeTime.integerValue], forState: UIControlState.Normal)
            } catch {
                print(error)
                return
            }
        }
    }
}
