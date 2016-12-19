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
import SVProgressHUD

class SettingViewController: UIViewController {
    
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
    @IBOutlet weak var removeAdsButton: UIButton!
    @IBOutlet weak var restorePurchacesButton: UIButton!
    @IBOutlet weak var inAppInfomrationLabel: UILabel!
    @IBOutlet weak var inAppPurchaseInfoView: UIView!
    
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
        
        removeAdsButton.backgroundColor = .clear
        removeAdsButton.layer.cornerRadius = 5
        removeAdsButton.layer.borderWidth = 2
        removeAdsButton.layer.borderColor = UIColor(colorLiteralRed: 19.0/255.0, green: 29.0/255.0, blue: 119.0/255.0, alpha: 1.0).cgColor
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        
        let attrString = NSMutableAttributedString(string: "If you love to use Goodnig.ht,\nplease upgrade. You'll: \n\n• Get rid of ads. \n• Get access to a timer. \n• Get 5 new sounds. \n• Be able to tweak the defaults. \n• Support future development.")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        inAppInfomrationLabel.attributedText = attrString
        
        if InAppHelper.shared.isRemoveAdPurchased() {
            inAppPurchaseInfoView.isHidden = true
        }
    }

    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
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
    
    @IBAction func removeAds(_ sender: Any) {
        let productIdentifiers: Set<ProductIdentifier> = [InAppHelper.shared.getRemoveAdProductId()]
        InAppManager.shared.productIdentifiers = productIdentifiers
        InAppManager.shared.delegate = self
        if InAppManager.canMakePayments() == true {
            SVProgressHUD.show()
            InAppManager.shared.requestProducts(completionHandler: { (success, products) in
                if success && products != nil {
                    if (products?.count)! > 0 {
                        InAppManager.shared.buyProduct(product: products!.first!)
                        return
                    }
                } else {
                    
                }
                SVProgressHUD.dismiss()
            })
        } else {
            let alert : UIAlertController = UIAlertController.init(title: "Failed", message: "Can not make payments. Please try after some time", preferredStyle: .alert)
            let okAction : UIAlertAction = UIAlertAction.init(title: "Ok", style: .cancel, handler: { (UIAlertAction) in
                return
            })
            alert.addAction(okAction)
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = self.view
                presenter.sourceRect = self.view.bounds
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func restorePurchases(_ sender: Any) {
        if InAppManager.canMakePayments() == true {
            InAppManager.shared.delegate = self
            InAppManager.shared.restorePurchases()
            SVProgressHUD.show()
        } else {
            let alert : UIAlertController = UIAlertController.init(title: "Failed", message: "Failed to Restore the Purchases", preferredStyle: .alert)
            let okAction : UIAlertAction = UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                return
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

//    MARK: - InAppManagerDelegate

extension SettingViewController : InAppManagerDelegate {
    
    func completeTranscation(transaction: SKPaymentTransaction) {
        SVProgressHUD.dismiss()
        InAppHelper.shared.setRemoveAdPurchased()
        inAppPurchaseInfoView.isHidden = true
        let alert = UIAlertController(title: "Purchase Complete", message: "Thank you", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(UIAlertAction) in
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func restoreTransaction(transaction: SKPaymentTransaction) {
        if let productIdentifier = transaction.original?.payment.productIdentifier {
            UserDefaults.standard.set(true, forKey: productIdentifier)
            if productIdentifier == InAppHelper.shared.getRemoveAdProductId() {
                InAppHelper.shared.setRemoveAdPurchased()
                inAppPurchaseInfoView.isHidden = true
                let alert : UIAlertController = UIAlertController.init(title: "Congratulations", message: "Your Purchase is Successfully Restored", preferredStyle: UIAlertControllerStyle.alert)
                let okAction : UIAlertAction = UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                    
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        SVProgressHUD.dismiss()
    }
    
    func failedRestoringPurchaseWithError(errorString: String) {
        SVProgressHUD.dismiss()
    }
    
    func failedTransaction(transaction: SKPaymentTransaction) {
        SVProgressHUD.dismiss()
        let alert = UIAlertController(title: "Transaction is Failed", message: transaction.error?.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(UIAlertAction) in
            
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
