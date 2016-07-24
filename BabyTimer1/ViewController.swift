//
//  ViewController.swift
//  BabyTimer
//
//  Created by Eddie Cohen & Jason Toff on 7/20/16.
//  Copyright © 2016 zelig. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import CoreMotion

class ViewController: UIViewController {
    var timerStarted = false
    var brightMoon = false
    
    var count = 0
    var timer = NSTimer()
    
    var flowTimer = NSTimer()
    
    var audioPlayer: AVAudioPlayer!
    var volumeView: UIView!

    let motionManager = CMMotionManager()
    
    @IBOutlet weak var backgroundView: UIView!

    @IBOutlet var countDownLabel: UILabel!
    
    @IBOutlet weak var timerImage: UIImageView!
    @IBOutlet weak var moonButton: UIButton!

    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var fifteenButton: UIButton!
    
    var starList = [UIImageView]()
    
    var rotation: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.05
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data: CMDeviceMotion?, error: NSError?) -> Void in
                self.rotation = CGFloat(atan2(data!.gravity.x, data!.gravity.z))
                print ("Rotation=\(self.rotation)")
                })
            }
            
        countDownLabel.text = ""
        
        if let sound = NSDataAsset(name: "white_noise") {
            do {
                try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try! AVAudioSession.sharedInstance().setActive(true)
                try audioPlayer = AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeMPEGLayer3)
            } catch {
                print("error initializing AVAudioPlayer")
            }
        }
        audioPlayer.numberOfLoops = -1
        audioPlayer.prepareToPlay()
        audioPlayer.volume = 0.5
        
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.backgroundAction(_:)))
        backgroundView.addGestureRecognizer(backgroundTap)
        
        let wrapperView = UIView(frame: CGRectMake(67, 658, 280, 31))
        self.view.backgroundColor = UIColor.clearColor()
        self.view.addSubview(wrapperView)
        
        volumeView = MPVolumeView(frame: wrapperView.bounds)
        wrapperView.addSubview(volumeView)
        
        self.countDownLabel.alpha = 0.0
        self.fifteenButton.alpha = 0.0
        self.fiveButton.alpha = 0.0
        self.timerImage.alpha = 0.0
        self.volumeView.alpha = 0.0
        
    }
    
    @IBAction func btnMoon(sender: UIButton) {
        updateState()
    }

    @IBAction func btnFive(sender: UIButton) {
        if (timerStarted) {
            count += 5 * 60
        } else {
            count = 5 * 60 + 1
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            timerStarted = true
            update()
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    @IBAction func btnFifteen(sender: UIButton) {
        if (timerStarted) {
            count += 15 * 60
        } else {
            count = 15 * 60 + 1
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            timerStarted = true
            update()
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
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
            star.frame.origin.x += 3.0 * star.frame.height/20 * speed
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
    
    func updateState() {
        if (timerStarted) {
            timer.invalidate()
            count = 0
            countDownLabel.text = ""
            timerStarted = false
        }
        brightMoon = !brightMoon
        
        if (brightMoon) {
            let image1:UIImage = UIImage(named: "MoonOn")!;
            self.moonButton.setImage(image1, forState: UIControlState.Normal)
            UIView.animateWithDuration(0.5, animations: {
                self.moonButton.alpha = 1.0
                self.moonButton.transform = CGAffineTransformMakeScale(1.15, 1.15)
                self.countDownLabel.alpha = 1.0
                self.fifteenButton.alpha = 1.0
                self.fiveButton.alpha = 1.0
                self.timerImage.alpha = 1.0
                self.volumeView.alpha = 1.0
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
            audioPlayer.play()
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.moonButton.alpha = 0.27
                self.moonButton.transform = CGAffineTransformIdentity
                self.countDownLabel.alpha = 0.0
                self.fifteenButton.alpha = 0.0
                self.fiveButton.alpha = 0.0
                self.timerImage.alpha = 0.0
                self.volumeView.alpha = 0.0
            }, completion: { finish in
                let image1:UIImage = UIImage(named: "MoonOff")!;
                self.moonButton.setImage(image1, forState: UIControlState.Normal)
            })
            disappearStars()
            audioPlayer.stop()
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
            countDownLabel.text = String(format: "%02d:%02d", count/60, count%60)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}

