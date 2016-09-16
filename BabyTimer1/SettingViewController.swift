//
//  SettingViewController.swift
//  Goodnight Moon
//
//  Created by Eddie Cohen & Jason Toff on 8/11/16.
//  Copyright © 2016 zelig. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import StoreKit

class SettingViewController: UIViewController, UIPopoverPresentationControllerDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    var purchasedProductIDs = [String]()
    var productsArray = [SKProduct]()
    var selectedProductIndex: Int!
    var transactionInProgress = false
    
    @IBOutlet var aboutButton: UIButton!
    @IBOutlet var playOnLaunchSwitch: UISwitch!
    @IBOutlet var showTimerSwitch: UISwitch!
    @IBOutlet var timerDefaultLabel: UILabel!
    @IBOutlet var timerDefaultButton: UIButton!
    @IBOutlet var fadeTimeButton: UIButton!
    @IBOutlet var soundButton: UIButton!
    
    var audioPlayer: AVAudioPlayer!
    
    var setting: Setting?
    
    var fadeTimes = [15: "15 Seconds", 30: "30 Seconds", 60: "1 Minute"]
    var timerDefaults = [5: "5 Minutes", 15: "15 Minutes"]
    let soundNames = ["White Noise", "Brown Noise", "Pink Noise", "Water", "Thunder"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadSetting()
        
        requestProductInfo()
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productRequest = SKProductsRequest(productIdentifiers: Set(["settings"]))
            
            productRequest.delegate = self
            productRequest.start()
        } else {
            print("Cannot perform In App Purchases.")
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product)
                
                let purchased = NSUserDefaults.standardUserDefaults().boolForKey(product.productIdentifier)
                if purchased {
                    purchasedProductIDs.append(product.productIdentifier)
                }
                
            }
        } else {
            print("There are no products.")
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                purchasedProductIDs.append(productsArray[selectedProductIndex].productIdentifier)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: productsArray[selectedProductIndex].productIdentifier)
                transactionInProgress = false
            case .Failed:
                print("Transaction Failed")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                transactionInProgress = false
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    func initAudioPlayer() {
        if let sound = NSDataAsset(name: setting!.soundName as String) {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(AVAudioSessionCategoryPlayback)
                do {
                    try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
                } catch {
                    print(error)
                }
                try session.setActive(true)
                
                try audioPlayer = AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeMPEGLayer3)
            } catch {
                print(error)
            }
        }
        audioPlayer.numberOfLoops = -1
        audioPlayer.prepareToPlay()
        audioPlayer.volume = AVAudioSession.sharedInstance().outputVolume
    }
    
    func showErrorMessage(message: String) {
        let alertController = UIAlertController(title: "Error",
                                                message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style:
            UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion:
            nil)
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

    @IBAction func switchShowTimer() {
        if productsArray.count==0 {
            showTimerSwitch.on = !showTimerSwitch.on
            print("In-App purchase Error")
            return
        }
        
        if transactionInProgress {
            showTimerSwitch.on = !showTimerSwitch.on
            return
        }
        
        selectedProductIndex = 0
        
        if purchasedProductIDs.contains(productsArray[selectedProductIndex].productIdentifier) {
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                setting!.showTimer = NSNumber(bool: showTimerSwitch.on)
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                    return
                }
            }
            timerDefaultButton.hidden = !showTimerSwitch.on
            timerDefaultLabel.hidden = !showTimerSwitch.on
        } else {
            showTimerSwitch.on = !showTimerSwitch.on
            let payment = SKPayment(product: productsArray[selectedProductIndex])
            SKPaymentQueue.defaultQueue().addPayment(payment)
            transactionInProgress = true
        }
    }
    
    @IBAction func buttonFadeTime() {
        if productsArray.count==0 {
            print("In-App purchase Error")
            return
        }
        
        if transactionInProgress {
            return
        }
        
        selectedProductIndex = 0
        
        if purchasedProductIDs.contains(productsArray[selectedProductIndex].productIdentifier) {
            let fadeTimeMenu = UIAlertController(title: nil, message: "Select Fade Time", preferredStyle: .ActionSheet)
            
            let times = Array(fadeTimes.keys.sort())
            for time in times {
                let timeAction = UIAlertAction(title: fadeTimes[time], style: .Default, handler: { action in
                    if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                        self.setting!.fadeTime = time
                        do {
                            try managedObjectContext.save()
                            self.fadeTimeButton.setTitle(self.fadeTimes[self.setting!.fadeTime.integerValue], forState: UIControlState.Normal)
                        } catch {
                            print(error)
                            return
                        }
                    }
                })
                fadeTimeMenu.addAction(timeAction)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            fadeTimeMenu.addAction(cancelAction)
            
            presentViewController(fadeTimeMenu, animated: true, completion: nil)
        } else {
            let payment = SKPayment(product: productsArray[selectedProductIndex])
            SKPaymentQueue.defaultQueue().addPayment(payment)
            transactionInProgress = true
        }
    }
    
    @IBAction func buttonTimerDefault() {
        if productsArray.count==0 {
            print("In-App purchase Error")
            return
        }
        
        if transactionInProgress {
            return
        }
        
        selectedProductIndex = 0
        
        if purchasedProductIDs.contains(productsArray[selectedProductIndex].productIdentifier) {
            let timerMenu = UIAlertController(title: nil, message: "Select Timer Default", preferredStyle: .ActionSheet)
            
            let timers = Array(timerDefaults.keys)
            for timer in timers {
                let timerAction = UIAlertAction(title: timerDefaults[timer], style: .Default, handler: { action in
                    if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                        self.setting!.timerDefault = timer
                        do {
                            try managedObjectContext.save()
                            self.timerDefaultButton.setTitle(self.timerDefaults[timer], forState: UIControlState.Normal)
                        } catch {
                            print(error)
                            return
                        }
                    }
                })
                timerMenu.addAction(timerAction)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            timerMenu.addAction(cancelAction)
            
            presentViewController(timerMenu, animated: true, completion: nil)
        } else {
            let payment = SKPayment(product: productsArray[selectedProductIndex])
            SKPaymentQueue.defaultQueue().addPayment(payment)
            transactionInProgress = true
        }
        
    }
    
    @IBAction func buttonSound() {
        if productsArray.count==0 {
            print("In-App purchase Error")
            return
        }
        
        if transactionInProgress {
            return
        }
        
        selectedProductIndex = 0
        
        if purchasedProductIDs.contains(productsArray[selectedProductIndex].productIdentifier) {
            let soundMenu = UIAlertController(title: nil, message: "Select Noise Sound", preferredStyle: .ActionSheet)
            
            for soundName in soundNames {
                let soundAction = UIAlertAction(title: soundName, style: .Default, handler: { action in
                    if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                        self.setting!.soundName = soundName
                        do {
                            try managedObjectContext.save()
                            self.soundButton.setTitle(soundName, forState: UIControlState.Normal)
                            self.initAudioPlayer()
                            self.audioPlayer.stop()
                            self.audioPlayer.play()
                        } catch {
                            print(error)
                            return
                        }
                    }
                })
                soundMenu.addAction(soundAction)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            soundMenu.addAction(cancelAction)
            
            presentViewController(soundMenu, animated: true, completion: nil)
        } else {
            let payment = SKPayment(product: productsArray[selectedProductIndex])
            SKPaymentQueue.defaultQueue().addPayment(payment)
            transactionInProgress = true
        }
        
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
                    setting!.showTimer = NSNumber(bool: false)
                    setting!.timerDefault = 5
                    setting!.fadeTime = 60
                    setting!.soundName = "White Noise"
                }
                
                playOnLaunchSwitch.on = setting!.playOnLaunch.boolValue
                showTimerSwitch.on = setting!.showTimer.boolValue
                timerDefaultButton.hidden = !showTimerSwitch.on
                timerDefaultLabel.hidden = !showTimerSwitch.on
                timerDefaultButton.setTitle(timerDefaults[setting!.timerDefault.integerValue], forState: UIControlState.Normal)
                fadeTimeButton.setTitle(fadeTimes[setting!.fadeTime.integerValue], forState: UIControlState.Normal)
                soundButton.setTitle(String(setting!.soundName), forState: UIControlState.Normal)
            } catch {
                print(error)
                return
            }
        }
    }
}