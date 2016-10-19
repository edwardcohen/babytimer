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
//import StoreKit

class SettingViewController: UIViewController {
//class SettingViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
//    var purchasedProductIDs = [String]()
//    var productsArray = [SKProduct]()
//    var selectedProductIndex: Int!
//    var transactionInProgress = false
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var aboutButton: UIButton!
    @IBOutlet var playOnLaunchSwitch: UISwitch!
    @IBOutlet var showTimerSwitch: UISwitch!
    @IBOutlet var timerDefaultLabel: UILabel!
    @IBOutlet var timerDefaultButton: UIButton!
    @IBOutlet var fadeTimeButton: UIButton!
    @IBOutlet var fadeTimeLabel:UILabel!
    @IBOutlet var soundButton: UIButton!
    @IBOutlet var soundLabel: UILabel!
    @IBOutlet var showTimerLabel: UILabel!
    @IBOutlet var upgradeButton: UIButton!
    
    var audioPlayer: AVAudioPlayer!
    
    var setting: Setting?
    
    var fadeTimes = [15: "15 Seconds", 30: "30 Seconds", 60: "1 Minute"]
    var timerDefaults = [5: "5 Minutes", 15: "15 Minutes"]
    let soundNames = ["White Noise", "Brown Noise", "Pink Noise", "Water", "Thunder"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spinner.hidesWhenStopped = true
        spinner.center = view.center
        view.addSubview(spinner)

        loadSetting()
        
//        showTimerLabel.alpha = 0.5
//        timerDefaultLabel.alpha = 0.5
//        fadeTimeLabel.alpha = 0.5
//        soundLabel.alpha = 0.5
//        
//        showTimerSwitch.alpha = 0.5
//        timerDefaultButton.alpha = 0.5
//        fadeTimeButton.alpha = 0.5
//        soundButton.alpha = 0.5
//        
//        showTimerSwitch.isEnabled = false
//        timerDefaultButton.isEnabled = false
//        fadeTimeButton.isEnabled = false
//        soundButton.isEnabled = false
        
//        requestProductInfo()
        
//        SKPaymentQueue.default().add(self)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
//    func requestProductInfo() {
//        if SKPaymentQueue.canMakePayments() {
//            let productRequest = SKProductsRequest(productIdentifiers: Set(["settingz"]))
//            
//            productRequest.delegate = self
//            productRequest.start()
//            spinner.startAnimating()
//            view.isUserInteractionEnabled = false
//        } else {
//            showErrorMessage(message: "Cannot perform In App Purchases.")
//        }
//    }
    
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        spinner.stopAnimating()
//        view.isUserInteractionEnabled = true
//        if response.products.count != 0 {
//            for product in response.products {
//                productsArray.append(product)
//                
//                let purchased = UserDefaults.standard.bool(forKey: product.productIdentifier)
//                if purchased {
//                    purchasedProductIDs.append(product.productIdentifier)
//                    
//                    upgradeButton.alpha = 0.0
//                    
//                    showTimerLabel.alpha = 1.0
//                    timerDefaultLabel.alpha = 1.0
//                    fadeTimeLabel.alpha = 1.0
//                    soundLabel.alpha = 1.0
//                    
//                    showTimerSwitch.alpha = 1.0
//                    timerDefaultButton.alpha = 1.0
//                    fadeTimeButton.alpha = 1.0
//                    soundButton.alpha = 1.0
//                    
//                    showTimerSwitch.isEnabled = true
//                    timerDefaultButton.isEnabled = true
//                    fadeTimeButton.isEnabled = true
//                    soundButton.isEnabled = true
//                }
//                
//            }
//        } else {
//            let alertDialog = UIAlertController(title: "Error", message: "There are no in-app purchase products", preferredStyle: UIAlertControllerStyle.alert)
//            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alertDialog.addAction(okAction)
//            present(alertDialog, animated: true, completion: nil)
//            upgradeButton.alpha = 0.0
//        }
//        
//        if response.invalidProductIdentifiers.count != 0 {
//            print(response.invalidProductIdentifiers.description)
//        }
//    }
//    
//    func request(_ request: SKRequest, didFailWithError error: Error) {
//        showErrorMessage(message: "Failed to load list of products.")
//        print("Error: \(error.localizedDescription)")
//        view.isUserInteractionEnabled = true
//        spinner.stopAnimating()
//        upgradeButton.alpha = 0.0
//    }
//    
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for transaction in transactions {
//            switch transaction.transactionState {
//            case .purchased:
//                showErrorMessage(message: "Transaction completed successfully.")
//                SKPaymentQueue.default().finishTransaction(transaction)
//                purchasedProductIDs.append(productsArray[selectedProductIndex].productIdentifier)
//                
//                upgradeButton.alpha = 0.0
//                
//                showTimerLabel.alpha = 1.0
//                timerDefaultLabel.alpha = 1.0
//                fadeTimeLabel.alpha = 1.0
//                soundLabel.alpha = 1.0
//                
//                showTimerSwitch.alpha = 1.0
//                timerDefaultButton.alpha = 1.0
//                fadeTimeButton.alpha = 1.0
//                soundButton.alpha = 1.0
//                
//                showTimerSwitch.isEnabled = true
//                timerDefaultButton.isEnabled = true
//                fadeTimeButton.isEnabled = true
//                soundButton.isEnabled = true
//                
//                UserDefaults.standard.set(true, forKey: productsArray[selectedProductIndex].productIdentifier)
//                transactionInProgress = false
//            case .failed:
//                showErrorMessage(message: "Transaction Failed")
//                SKPaymentQueue.default().finishTransaction(transaction)
//                transactionInProgress = false
//            default:
//                print(transaction.transactionState.rawValue)
//            }
//        }
//    }
    
    func initAudioPlayer() {
        if let sound = NSDataAsset(name: setting!.soundName as String) {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(AVAudioSessionCategoryPlayback)
                do {
                    try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
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
                                                message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style:
            UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion:
            nil)
    }
    
    @IBAction func btnAbout() {
        let message = "Goodnig.ht was made by a Dad to help put his newborn son to sleep. We’ve optimized the experience to help put your child to sleep instantaneously. Goodnight!"
        let alertController = UIAlertController(title: "About",
                                                message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style:
            UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion:
            nil)
    }
    
    @IBAction func switchPlayOnLaunch() {
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
            setting!.playOnLaunch = NSNumber(value: playOnLaunchSwitch.isOn)
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
                return
            }
        }
    }

    @IBAction func switchShowTimer() {
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
            setting!.showTimer = NSNumber(value: showTimerSwitch.isOn)
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
                return
            }
        }
        timerDefaultButton.isHidden = !showTimerSwitch.isOn
        timerDefaultLabel.isHidden = !showTimerSwitch.isOn
    }
    
    @IBAction func buttonFadeTime() {
        let fadeTimeMenu = UIAlertController(title: nil, message: "Select Fade Time", preferredStyle: .actionSheet)
        
        let times = Array(fadeTimes.keys.sorted())
        for time in times {
            let timeAction = UIAlertAction(title: fadeTimes[time], style: .default, handler: { action in
                if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
                    self.setting!.fadeTime = time as NSNumber!
                    do {
                        try managedObjectContext.save()
                        self.fadeTimeButton.setTitle(self.fadeTimes[self.setting!.fadeTime.intValue], for: UIControlState.normal)
                    } catch {
                        print(error)
                        return
                    }
                }
            })
            fadeTimeMenu.addAction(timeAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        fadeTimeMenu.addAction(cancelAction)
        
        present(fadeTimeMenu, animated: true, completion: nil)
    }
    
    @IBAction func buttonTimerDefault() {
        let timerMenu = UIAlertController(title: nil, message: "Select Timer Default", preferredStyle: .actionSheet)
        
        let timers = Array(timerDefaults.keys)
        for timer in timers {
            let timerAction = UIAlertAction(title: timerDefaults[timer], style: .default, handler: { action in
                if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
                    self.setting!.timerDefault = timer as NSNumber!
                    do {
                        try managedObjectContext.save()
                        self.timerDefaultButton.setTitle(self.timerDefaults[timer], for: UIControlState.normal)
                    } catch {
                        print(error)
                        return
                    }
                }
            })
            timerMenu.addAction(timerAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        timerMenu.addAction(cancelAction)
        
        present(timerMenu, animated: true, completion: nil)
    }
    
    @IBAction func buttonSound() {
        let soundMenu = UIAlertController(title: nil, message: "Select Noise Sound", preferredStyle: .actionSheet)
        
        for soundName in soundNames {
            let soundAction = UIAlertAction(title: soundName, style: .default, handler: { action in
                if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
                    self.setting!.soundName = soundName as NSString!
                    do {
                        try managedObjectContext.save()
                        self.soundButton.setTitle(soundName, for: UIControlState.normal)
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
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        soundMenu.addAction(cancelAction)
        
        present(soundMenu, animated: true, completion: nil)
    }
    
    @IBAction func buttonUpgrade() {
//        selectedProductIndex = 0
//        let payment = SKPayment(product: productsArray[selectedProductIndex])
//        SKPaymentQueue.default().add(payment)
//        transactionInProgress = true
    }
    
    func loadSetting() {
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Setting")
            
            do {
                let settings = try managedObjectContext.fetch(fetchRequest) as! [Setting]
                setting = settings.first
                if setting == nil {
                    setting = NSEntityDescription.insertNewObject(forEntityName: "Setting", into: managedObjectContext) as? Setting
                    setting!.playOnLaunch = NSNumber(value: true)
                    setting!.showTimer = NSNumber(value: false)
                    setting!.timerDefault = 5
                    setting!.fadeTime = 60
                    setting!.soundName = "White Noise"
                }
                
                playOnLaunchSwitch.isOn = setting!.playOnLaunch.boolValue
                showTimerSwitch.isOn = setting!.showTimer.boolValue
                timerDefaultButton.isHidden = !showTimerSwitch.isOn
                timerDefaultLabel.isHidden = !showTimerSwitch.isOn
                timerDefaultButton.setTitle(timerDefaults[setting!.timerDefault.intValue], for: UIControlState.normal)
                fadeTimeButton.setTitle(fadeTimes[setting!.fadeTime.intValue], for: UIControlState.normal)
                soundButton.setTitle(String(setting!.soundName), for: UIControlState.normal)
            } catch {
                print(error)
                return
            }
        }
    }
}
