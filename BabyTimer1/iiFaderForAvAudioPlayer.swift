//
//  iiFaderForAvAudioPlayer.swift
//  Goodnight Moon
//
//  Created by Eddie Cohen & Jason Toff on 8/3/16.
//  Copyright © 2016 zelig. All rights reserved.
//

import Foundation
import AVFoundation

let iiFaderForAvAudioPlayer_defaultFadeDurationSeconds = 3.0
let iiFaderForAvAudioPlayer_defaultVelocity = 2.0

public class iiFaderForAvAudioPlayer: NSObject {
    let player: AVAudioPlayer
    private var timer: Timer?
    
    // The higher the number - the higher the quality of fade
    // and it will consume more CPU.
    var volumeAlterationsPerSecond = 30.0
    
    private var fadeDurationSeconds = iiFaderForAvAudioPlayer_defaultFadeDurationSeconds
    private var fadeVelocity = iiFaderForAvAudioPlayer_defaultVelocity
    
    private var fromVolume = 0.0
    private var toVolume = 0.0
    
    private var currentStep = 0
    
    private var onFinished: ((Bool)->())? = nil
    
    init(player: AVAudioPlayer) {
        self.player = player
    }
    
    deinit {
        callOnFinished(finished: false)
        stop()
    }
    
    private var fadeIn: Bool {
        return fromVolume < toVolume
    }
    
    func fadeIn(duration: Double = iiFaderForAvAudioPlayer_defaultFadeDurationSeconds,
                velocity: Double = iiFaderForAvAudioPlayer_defaultVelocity, onFinished: ((Bool)->())? = nil) {
        
        fade(
            fromVolume: Double(player.volume), toVolume: 1,
            duration: duration, velocity: velocity, onFinished: onFinished)
    }
    
    func fadeOut(duration: Double = iiFaderForAvAudioPlayer_defaultFadeDurationSeconds,
                 velocity: Double = iiFaderForAvAudioPlayer_defaultVelocity, onFinished: ((Bool)->())? = nil) {
        
        fade(
            fromVolume: Double(player.volume), toVolume: 0,
            duration: duration, velocity: velocity, onFinished: onFinished)
    }
    
    func fade(fromVolume: Double, toVolume: Double,
                         duration: Double = iiFaderForAvAudioPlayer_defaultFadeDurationSeconds,
                         velocity: Double = iiFaderForAvAudioPlayer_defaultVelocity, onFinished: ((Bool)->())? = nil) {
        
        self.fromVolume = iiFaderForAvAudioPlayer.makeSureValueIsBetween0and1(value: fromVolume)
        self.toVolume = iiFaderForAvAudioPlayer.makeSureValueIsBetween0and1(value: toVolume)
        self.fadeDurationSeconds = duration
        self.fadeVelocity = velocity
        
        callOnFinished(finished: false)
        self.onFinished = onFinished
        
        player.volume = Float(self.fromVolume)
        
        if self.fromVolume == self.toVolume {
            callOnFinished(finished: true)
            return
        }
        
        startTimer()
    }
    
    // Stop fading. Does not stop the sound.
    func stop() {

        stopTimer()
    }
    
    private func callOnFinished(finished: Bool) {
        onFinished?(finished)
        onFinished = nil
    }
    
    private func startTimer() {
        stopTimer()
        currentStep = 0
        
        timer = Timer.scheduledTimer(timeInterval: 1 / volumeAlterationsPerSecond, target: self,
                                                       selector: #selector(iiFaderForAvAudioPlayer.timerFired), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        if let currentTimer = timer {
            currentTimer.invalidate()
            timer = nil
        }
    }
    
    func timerFired(timer: Timer) {
        if shouldStopTimer {
            player.volume = Float(toVolume)
            stopTimer()
            callOnFinished(finished: true)
            return
        }
        
        let currentTimeFrom0To1 = iiFaderForAvAudioPlayer.timeFrom0To1(
            currentStep: currentStep, fadeDurationSeconds: fadeDurationSeconds, volumeAlterationsPerSecond: volumeAlterationsPerSecond)
        
        var volumeMultiplier: Double
        
        var newVolume: Double = 0
        
        if fadeIn {
            volumeMultiplier = iiFaderForAvAudioPlayer.fadeInVolumeMultiplier(timeFrom0To1: currentTimeFrom0To1,
                                                                              velocity: fadeVelocity)
            
            newVolume = fromVolume + (toVolume - fromVolume) * volumeMultiplier
            
        } else {
            volumeMultiplier = iiFaderForAvAudioPlayer.fadeOutVolumeMultiplier(timeFrom0To1: currentTimeFrom0To1,
                                                                               velocity: fadeVelocity)
            
            newVolume = toVolume - (toVolume - fromVolume) * volumeMultiplier
        }
        
        player.volume = Float(newVolume)
        
        currentStep += 1
    }
    
    var shouldStopTimer: Bool {
        let totalSteps = fadeDurationSeconds * volumeAlterationsPerSecond
        return Double(currentStep) > totalSteps
    }
    
    public class func timeFrom0To1(currentStep: Int, fadeDurationSeconds: Double,
                                   volumeAlterationsPerSecond: Double) -> Double {
        
        let totalSteps = fadeDurationSeconds * volumeAlterationsPerSecond
        var result = Double(currentStep) / totalSteps
        
        result = makeSureValueIsBetween0and1(value: result)
        
        return result
    }
    
    // Graph: https://www.desmos.com/calculator/wnstesdf0h
    public class func fadeOutVolumeMultiplier(timeFrom0To1: Double, velocity: Double) -> Double {
        let time = makeSureValueIsBetween0and1(value: timeFrom0To1)
        return pow(M_E, -velocity * time) * (1 - time)
    }
    
    public class func fadeInVolumeMultiplier(timeFrom0To1: Double, velocity: Double) -> Double {
        let time = makeSureValueIsBetween0and1(value: timeFrom0To1)
        return pow(M_E, velocity * (time - 1)) * time
    }
    
    private class func makeSureValueIsBetween0and1(value: Double) -> Double {
        if value < 0 { return 0 }
        if value > 1 { return 1 }
        return value
    }
}
