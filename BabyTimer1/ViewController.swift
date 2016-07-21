//
//  ViewController.swift
//  BabyTimer
//
//  Created by Eddie Cohen & Jason Toff on 7/20/16.
//  Copyright © 2016 zelig. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {
    var timerStarted = false
    var brightMoon = false
    
    var count = 0
    var timer = NSTimer()
    
    var flowTimer = NSTimer()
    
    var audioPlayer: AVAudioPlayer!
    var volumeView: UIView!
    
    @IBOutlet var countDownLabel: UILabel!
    @IBOutlet weak var fiveLabel: UILabel!
    @IBOutlet weak var fifteenLabel: UILabel!
    
    @IBOutlet weak var star9: UIImageView!
    @IBOutlet weak var star8: UIImageView!
    @IBOutlet weak var star7: UIImageView!
    @IBOutlet weak var star6: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star1: UIImageView!
    
    @IBOutlet weak var star9LeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var star8LeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var star7LeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var star6LeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var star5LeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var star4LeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var star3LeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var star2LeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var star1LeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var star9TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var star8TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var star6TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var star7TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var star5TopConstraint: NSLayoutConstraint!    
    @IBOutlet weak var star4TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var star3TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var star2TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var star1TopConstraint: NSLayoutConstraint!

    @IBOutlet weak var timerImage: UIImageView!
    @IBOutlet weak var moonButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        
        let fifteenTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.fifteenAction(_:)))
        fifteenLabel.addGestureRecognizer(fifteenTap)
        
        let fiveTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.fiveAction(_:)))
        fiveLabel.addGestureRecognizer(fiveTap)

        let wrapperView = UIView(frame: CGRectMake(67, 658, 280, 31))
        self.view.backgroundColor = UIColor.clearColor()
        self.view.addSubview(wrapperView)
        
        volumeView = MPVolumeView(frame: wrapperView.bounds)
        wrapperView.addSubview(volumeView)
        
        self.countDownLabel.alpha = 0.0
        self.fifteenLabel.alpha = 0.0
        self.fiveLabel.alpha = 0.0
        self.timerImage.alpha = 0.0
        self.volumeView.alpha = 0.0
        
        self.star1.alpha = 0.0
        self.star2.alpha = 0.0
        self.star3.alpha = 0.0
        self.star4.alpha = 0.0
        self.star5.alpha = 0.0
        self.star6.alpha = 0.0
        self.star7.alpha = 0.0
        self.star8.alpha = 0.0
        self.star9.alpha = 0.0
        
    }
    
    @IBAction func btnMoon(sender: UIButton) {
        if (timerStarted) {
            timer.invalidate()
            count = 0
            countDownLabel.text = ""
            timerStarted = false
        }
        
        brightMoon = !brightMoon
        updateUI()
    }

    func getStarPos() -> (posX: CGFloat, posY: CGFloat) {
        let screenSize = UIScreen.mainScreen().bounds
        let randomXPos = CGFloat(arc4random_uniform(UInt32(screenSize.width)))
        let randomYPos = CGFloat(arc4random_uniform(UInt32(screenSize.height)/2))
        return (randomXPos, randomYPos)
    }
    
    func flowStars() {
        self.star1.layer.removeAllAnimations()
        self.star2.layer.removeAllAnimations()
        self.star3.layer.removeAllAnimations()
        self.star4.layer.removeAllAnimations()
        self.star5.layer.removeAllAnimations()
        self.star6.layer.removeAllAnimations()
        self.star7.layer.removeAllAnimations()
        self.star8.layer.removeAllAnimations()
        self.star9.layer.removeAllAnimations()
        
        (self.star1LeadingConstraint.constant, self.star1TopConstraint.constant) = getStarPos()
        (self.star2LeadingConstraint.constant, self.star2TopConstraint.constant) = getStarPos()
        (self.star3LeadingConstraint.constant, self.star3TopConstraint.constant) = getStarPos()
        (self.star4LeadingConstraint.constant, self.star4TopConstraint.constant) = getStarPos()
        (self.star5LeadingConstraint.constant, self.star5TopConstraint.constant) = getStarPos()
        (self.star6LeadingConstraint.constant, self.star6TopConstraint.constant) = getStarPos()
        (self.star7LeadingConstraint.constant, self.star7TopConstraint.constant) = getStarPos()
        (self.star8LeadingConstraint.constant, self.star8TopConstraint.constant) = getStarPos()
        (self.star9LeadingConstraint.constant, self.star9TopConstraint.constant) = getStarPos()
        
        self.star1.alpha = 1.0
        self.star2.alpha = 1.0
        self.star3.alpha = 1.0
        self.star4.alpha = 1.0
        self.star5.alpha = 1.0
        self.star6.alpha = 1.0
        self.star7.alpha = 1.0
        self.star8.alpha = 1.0
        self.star9.alpha = 1.0

        self.view.layoutIfNeeded()
        
        self.star1LeadingConstraint.constant = arc4random_uniform(2)==0 ? UIScreen.mainScreen().bounds.width+50 : -50
        UIView.animateWithDuration(Double(arc4random_uniform(50)+50), delay: 0, options: .CurveLinear, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        self.star2LeadingConstraint.constant = arc4random_uniform(2)==0 ? UIScreen.mainScreen().bounds.width+50 : -50
        UIView.animateWithDuration(Double(arc4random_uniform(50)+50), delay: 0, options: .CurveLinear, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        self.star3LeadingConstraint.constant = arc4random_uniform(2)==0 ? UIScreen.mainScreen().bounds.width+50 : -50
        UIView.animateWithDuration(Double(arc4random_uniform(50)+50), delay: 0, options: .CurveLinear, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        self.star4LeadingConstraint.constant = arc4random_uniform(2)==0 ? UIScreen.mainScreen().bounds.width+50 : -50
        UIView.animateWithDuration(Double(arc4random_uniform(50)+50), delay: 0, options: .CurveLinear, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        self.star5LeadingConstraint.constant = arc4random_uniform(2)==0 ? UIScreen.mainScreen().bounds.width+50 : -50
        UIView.animateWithDuration(Double(arc4random_uniform(50)+50), delay: 0, options: .CurveLinear, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        self.star6LeadingConstraint.constant = arc4random_uniform(2)==0 ? UIScreen.mainScreen().bounds.width+50 : -50
        UIView.animateWithDuration(Double(arc4random_uniform(50)+50), delay: 0, options: .CurveLinear, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        self.star7LeadingConstraint.constant = arc4random_uniform(2)==0 ? UIScreen.mainScreen().bounds.width+50 : -50
        UIView.animateWithDuration(Double(arc4random_uniform(50)+50), delay: 0, options: .CurveLinear, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        self.star8LeadingConstraint.constant = arc4random_uniform(2)==0 ? UIScreen.mainScreen().bounds.width+50 : -50
        UIView.animateWithDuration(Double(arc4random_uniform(50)+50), delay: 0, options: .CurveLinear, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        self.star9LeadingConstraint.constant = arc4random_uniform(2)==0 ? UIScreen.mainScreen().bounds.width+50 : -50
        UIView.animateWithDuration(Double(arc4random_uniform(50)+50), delay: 0, options: .CurveLinear, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func disappearStars() {
        self.star1TopConstraint.constant = -50
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
        self.star2TopConstraint.constant = -50
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
        self.star3TopConstraint.constant = -50
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
        self.star4TopConstraint.constant = -50
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
        self.star5TopConstraint.constant = -50
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
        self.star6TopConstraint.constant = -50
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
        self.star7TopConstraint.constant = -50
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
        self.star8TopConstraint.constant = -50
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
        self.star9TopConstraint.constant = -50
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
        
        flowTimer.invalidate()
    }
    
    func updateUI() {
        if (brightMoon) {
            let image1:UIImage = UIImage(named: "MoonOn")!;
            self.moonButton.setImage(image1, forState: UIControlState.Normal)
            UIView.animateWithDuration(0.5, animations: {
                self.moonButton.alpha = 1.0
                self.moonButton.transform = CGAffineTransformMakeScale(1.15, 1.15)
                self.countDownLabel.alpha = 1.0
                self.fifteenLabel.alpha = 1.0
                self.fiveLabel.alpha = 1.0
                self.timerImage.alpha = 1.0
                self.volumeView.alpha = 1.0
            }, completion: nil
            )
            flowTimer = NSTimer.scheduledTimerWithTimeInterval(50, target: self, selector: #selector(flowStars), userInfo: nil, repeats: true)
            flowStars()
            audioPlayer.play()
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.moonButton.alpha = 0.27
                self.moonButton.transform = CGAffineTransformIdentity
                self.countDownLabel.alpha = 0.0
                self.fifteenLabel.alpha = 0.0
                self.fiveLabel.alpha = 0.0
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
    
    func fifteenAction(sender: UITapGestureRecognizer) {
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

    func fiveAction(sender: UITapGestureRecognizer) {
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

