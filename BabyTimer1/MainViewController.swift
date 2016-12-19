//
//  MainViewController.swift
//  Goodnight Moon
//
//  Created by Eddie Cohen & Jason Toff on 7/20/16.
//  Copyright © 2016 zelig. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import CoreMotion
import CoreData
import MediaPlayer
import GoogleMobileAds

class MainViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    var setting: Setting!
    
    var timerStarted = false
    var brightMoon = false
    var fadingStarted = false
    
    var count = 0
    var timer = Timer()
    
    var flowTimer = Timer()
    
    var audioPlayer: AVAudioPlayer!
    var fader: iiFaderForAvAudioPlayer!
    @IBOutlet var volumeView: MPVolumeView!

    let motionManager = CMMotionManager()
    
    @IBOutlet var countDownLabel: UILabel!
    
    @IBOutlet weak var timerImage: UIImageView!
    @IBOutlet weak var moonButton: UIButton!

    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var fifteenButton: UIButton!
    
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet var settingButton: UIButton!
    
    var starList = [UIImageView]()
    
    var rotation: CGFloat = CGFloat(M_PI)
    

    @IBOutlet weak var nativeExpressAdView: GADNativeExpressAdView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if InAppHelper.shared.isRemoveAdPurchased() == false {
            nativeExpressAdView.adUnitID = "ca-app-pub-6922191625271813/2741871089"
            nativeExpressAdView.rootViewController = self
            
            let request = GADRequest()
            request.testDevices = [kGADSimulatorID]
            nativeExpressAdView.load(request)
        }
        
        loadSetting()
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        initAudioPlayer()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(MainViewController.playCommandSelector))
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(MainViewController.pauseCommandSelector))
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.05
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { (data: CMDeviceMotion?, error: Error?) -> Void in
                self.rotation = CGFloat(atan2(data!.gravity.x, data!.gravity.z))
                })
            }
            
        self.countDownLabel.alpha = 0.0
        self.fifteenButton.alpha = 0.0
        self.fiveButton.alpha = 0.0
        self.timerButton.alpha = 0.0
        self.timerImage.alpha = 0.0
        self.volumeView.alpha = 0.0

        self.volumeView.showsRouteButton = false
        
        self.moonButton.layer.zPosition = 1
        
        if setting.playOnLaunch.boolValue {
            updateState()
        }
    }
    
    func initAudioPlayer() {
        if let sound = NSDataAsset(name: setting.soundName as String) {
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
        
        fader = iiFaderForAvAudioPlayer(player: audioPlayer)
    }
    
    func playCommandSelector() {
        audioPlayer.play()
    }

    func pauseCommandSelector() {
        audioPlayer.pause()
    }

    @IBAction func btnMoon(sender: UIButton) {
        if brightMoon && !fadingStarted {
            fadeMoon()
        } else {
            updateState()
        }
    }

    @IBAction func btnSetting(sender: UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        vc.preferredContentSize = CGSize(width: 320, height: 360)
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.permittedArrowDirections = .up
        popover.backgroundColor = UIColor(colorLiteralRed: 209.0/255.0, green: 205.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = CGRect(x: sender.frame.size.width * 0.5, y: sender.frame.size.height * 0.5, width: 0, height: 0)
        present(vc, animated: true, completion: nil)
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        loadSetting()
        initAudioPlayer()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func timerAction(min: Int) {
        if (timerStarted) {
            count += min * 60
        } else {
            countDownLabel.alpha = 1.0
            count = min * 60 + 1
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            timerStarted = true
            update()
        }
//        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    @IBAction func btnFive(sender: UIButton) {
        timerAction(min: 5)
    }
    
    @IBAction func btnFifteen(sender: UIButton) {
        timerAction(min: 15)
    }
    
    @IBAction func btnTimer(sender: UIButton) {
        self.fifteenButton.alpha = 1.0
        self.fiveButton.alpha = 1.0
        self.timerButton.alpha = 0.0
        timerAction(min: setting.timerDefault.intValue)
    }
    
    func getStarPos() -> (posX: CGFloat, posY: CGFloat) {
        let screenSize = UIScreen.main.bounds
        let randomXPos = CGFloat(arc4random_uniform(UInt32(screenSize.width)))
        let randomYPos = CGFloat(arc4random_uniform(UInt32(screenSize.height)/2))
        return (randomXPos, randomYPos)
    }
    
    func flowStars() {
        var speed: CGFloat = 0
        switch rotation {
        case CGFloat(-M_PI) ... CGFloat(-M_PI_2):
            speed = -(rotation + CGFloat(M_PI))
        case CGFloat(-M_PI_2) ... CGFloat(0):
            speed = rotation
        case CGFloat(0) ... CGFloat(M_PI_2):
            speed = rotation
        case CGFloat(M_PI_2) ... CGFloat(M_PI):
            speed = CGFloat(M_PI) - rotation
        default:
            print("Unexpected value")
        }
        
        for star in starList {
            star.frame.origin.x += 1.0 * star.frame.height/20 * speed
            if star.frame.origin.x > UIScreen.main.bounds.width {
                star.frame.origin.x = 0
            } else if star.frame.origin.x < 0 {
                star.frame.origin.x = UIScreen.main.bounds.width
            }
        }
    }
    
    func disappearStars() {
        flowTimer.invalidate()
        UIView.animate(withDuration: 0.5, animations: {
            for star in self.starList {
                star.transform = CGAffineTransform(translationX: 0, y: -30-star.frame.origin.y)
            }
        }, completion: nil
        )
    }
    
    func fadeMoon() {
        fadingStarted = true
        
        self.timerButton.alpha = 0.0
        self.fifteenButton.alpha = 0.0
        self.fiveButton.alpha = 0.0
        self.timerImage.alpha = 0.0

        UIView.animate(withDuration: setting.fadeTime.doubleValue, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.moonButton.alpha = 0.27
            self.moonButton.transform = CGAffineTransform.identity
            }, completion: { finish in
                if finish {
                    self.moonButton.setImage(UIImage(named: "MoonOff"), for: UIControlState.normal)
                }
        })
        fader.stop()
        fader.fade(fromVolume: Double(AVAudioSession.sharedInstance().outputVolume), toVolume: 0, duration: setting.fadeTime.doubleValue, velocity: 0) { finished in
            self.audioPlayer.volume = 0
            self.audioPlayer.stop()
        }
        
        countDownLabel.alpha = 1.0
        count = setting.fadeTime.intValue
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        timerStarted = true
        update()

    }
    
    func updateState() {
        if (timerStarted) {
            timer.invalidate()
            count = 0
            countDownLabel.alpha = 0.0
            timerStarted = false
        }
        brightMoon = !brightMoon
        
        if (brightMoon) {
            self.moonButton.setImage(UIImage(named: "MoonOn"), for: UIControlState.normal)
            UIView.animate(withDuration: 0.5, animations: {
                self.moonButton.alpha = 1.0
                self.moonButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                if self.setting.showTimer.boolValue {
                    self.timerButton.alpha = 1.0
                    self.timerImage.alpha = 1.0
                }
                self.volumeView.alpha = 1.0
                self.settingButton.alpha = 0.0
            }, completion: nil
            )
            starList.removeAll()
            for _ in 1...10 {
                let star = UIImageView(image: UIImage(named: "Star"))
                let (x,y) = getStarPos()
                let size = 10+CGFloat(arc4random_uniform(10))
                star.frame = CGRect(x: x, y: y, width: size, height: size)
                self.view.addSubview(star)
                starList.append(star)
            }
            flowTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(flowStars), userInfo: nil, repeats: true)
            fader.fade(fromVolume: 0, toVolume: Double(AVAudioSession.sharedInstance().outputVolume), duration: 1, velocity: 0) { finished in
                self.audioPlayer.volume = AVAudioSession.sharedInstance().outputVolume
            }
            audioPlayer.play()
            if InAppHelper.shared.isRemoveAdPurchased() == false {
                nativeExpressAdView.isHidden = false
            } else {
                nativeExpressAdView.isHidden = true
            }
        } else {
            moonButton.layer.removeAllAnimations()
            self.moonButton.alpha = 1.0
            self.moonButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            UIView.animate(withDuration: 0.5, animations: {
                self.moonButton.alpha = 0.27
                self.moonButton.transform = CGAffineTransform.identity
                self.countDownLabel.alpha = 0.0
                self.timerButton.alpha = 0.0
                self.fifteenButton.alpha = 0.0
                self.fiveButton.alpha = 0.0
                self.timerImage.alpha = 0.0
                self.volumeView.alpha = 0.0
                self.settingButton.alpha = 1.0
            }, completion: { finish in
                self.moonButton.setImage(UIImage(named: "MoonOff"), for: UIControlState.normal)
            })
            disappearStars()
            
            if fadingStarted {
                fader.stop()
                fader.fade(fromVolume: Double(AVAudioSession.sharedInstance().outputVolume), toVolume: 0, duration: 1, velocity: 0) { finished in
                    self.audioPlayer.volume = 0
                    self.audioPlayer.stop()
                }
                fadingStarted = false
            } else {
                self.audioPlayer.stop()
            }
            nativeExpressAdView.isHidden = true
        }
    }

    func update() {
        if(count > 0) {
            count = count - 1
            if count >= 60 {
                countDownLabel.text = String(format: "%02d:%02d", count/60, count%60)
            } else {
                countDownLabel.text = String(count)
            }
        } else {
            fadingStarted = false
            updateState()
        }
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
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
                    setting!.fadeTime = 60
                    setting!.timerDefault = 5
                    setting!.soundName = "White Noise"
                }
            } catch {
                print(error)
                return
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
