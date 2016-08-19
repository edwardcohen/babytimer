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

class MainViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    var setting: Setting!
    
    var timerStarted = false
    var brightMoon = false
    var fadingStarted = false
    
    var count = 0
    var timer = NSTimer()
    
    var flowTimer = NSTimer()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSetting()
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        initAudioPlayer()
        
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        commandCenter.playCommand.enabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(MainViewController.playCommandSelector))
        commandCenter.pauseCommand.enabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(MainViewController.pauseCommandSelector))
        
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.05
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data: CMDeviceMotion?, error: NSError?) -> Void in
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
        let vc = storyboard.instantiateViewControllerWithIdentifier("SettingViewController") as! SettingViewController
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        vc.preferredContentSize = CGSizeMake(325, 350)
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.permittedArrowDirections = .Any
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = CGRect(x: 20, y: 20, width: 1, height: 1)
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        loadSetting()
        initAudioPlayer()
    }
    
    func timerAction(min: Int) {
        if (timerStarted) {
            count += min * 60
        } else {
            countDownLabel.alpha = 1.0
            count = min * 60 + 1
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            timerStarted = true
            update()
        }
//        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    @IBAction func btnFive(sender: UIButton) {
        timerAction(5)
    }
    
    @IBAction func btnFifteen(sender: UIButton) {
        timerAction(15)
    }
    
    @IBAction func btnTimer(sender: UIButton) {
        self.fifteenButton.alpha = 1.0
        self.fiveButton.alpha = 1.0
        self.timerButton.alpha = 0.0
        timerAction(setting.timerDefault.integerValue)
    }
    
    func getStarPos() -> (posX: CGFloat, posY: CGFloat) {
        let screenSize = UIScreen.mainScreen().bounds
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
            if star.frame.origin.x > UIScreen.mainScreen().bounds.width {
                star.frame.origin.x = 0
            } else if star.frame.origin.x < 0 {
                star.frame.origin.x = UIScreen.mainScreen().bounds.width
            }
        }
    }
    
    func disappearStars() {
        flowTimer.invalidate()
        UIView.animateWithDuration(0.5, animations: {
            for star in self.starList {
                star.transform = CGAffineTransformMakeTranslation(0, -30-star.frame.origin.y)
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

        UIView.animateWithDuration(setting.fadeTime.doubleValue, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.moonButton.alpha = 0.27
            self.moonButton.transform = CGAffineTransformIdentity
            }, completion: { finish in
                self.moonButton.setImage(UIImage(named: "MoonOff"), forState: UIControlState.Normal)
        })
        fader.stop()
        fader.fade(fromVolume: Double(AVAudioSession.sharedInstance().outputVolume), toVolume: 0, duration: setting.fadeTime.doubleValue, velocity: 0) { finished in
            self.audioPlayer.volume = 0
            self.audioPlayer.stop()
        }
        
        countDownLabel.alpha = 1.0
        count = setting.fadeTime.integerValue
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
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
            self.moonButton.setImage(UIImage(named: "MoonOn"), forState: UIControlState.Normal)
            UIView.animateWithDuration(0.5, animations: {
                self.moonButton.alpha = 1.0
                self.moonButton.transform = CGAffineTransformMakeScale(1.15, 1.15)
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
                star.frame = CGRectMake(x, y, size, size)
                self.view.addSubview(star)
                starList.append(star)
            }
            flowTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(flowStars), userInfo: nil, repeats: true)
            fader.fade(fromVolume: 0, toVolume: Double(AVAudioSession.sharedInstance().outputVolume), duration: 1, velocity: 0) { finished in
                self.audioPlayer.volume = AVAudioSession.sharedInstance().outputVolume
            }
            audioPlayer.play()
        } else {
            moonButton.layer.removeAllAnimations()
            self.moonButton.setImage(UIImage(named: "MoonOn"), forState: UIControlState.Normal)
            self.moonButton.alpha = 1.0
            UIView.animateWithDuration(0.5, animations: {
                self.moonButton.alpha = 0.27
                self.moonButton.transform = CGAffineTransformIdentity
                self.countDownLabel.alpha = 0.0
                self.timerButton.alpha = 0.0
                self.fifteenButton.alpha = 0.0
                self.fiveButton.alpha = 0.0
                self.timerImage.alpha = 0.0
                self.volumeView.alpha = 0.0
                self.settingButton.alpha = 1.0
            }, completion: { finish in
                self.moonButton.setImage(UIImage(named: "MoonOff"), forState: UIControlState.Normal)
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
        }
    }

    func backgroundAction(sender: UITapGestureRecognizer) {
        if (!brightMoon) {
            updateState()
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
        return .None
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
                    setting!.showTimer = NSNumber(bool: true)
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
