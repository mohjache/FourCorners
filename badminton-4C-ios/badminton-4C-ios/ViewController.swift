//
//  ViewController.swift
//  badminton-4C-ios
//
//  Created by anaru herbert on 17/7/19.
//  Copyright © 2019 Anaru Herbert. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet var cornerLabel: UILabel!
    @IBOutlet var startWorkoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func startButtonClicked(_ sender: UIButton) {
        self.startWorkoutButton.isHidden = true
        let restTime = 3.0
        let maxIntervals = 5
        
        self.cornerLabel.text = "Ready....Go!"
        startTimer(maxIntervals: maxIntervals, restTime: restTime)
    }
    
    func chooseAndSpeakRandomCorner(speech: AVSpeechSynthesizer) {
        let directions = ["front-left", "front-right", "back-left", "back-right"]
        let randomNumber = Int.random(in: 0 ... 3)
        let chosenDirection = directions[randomNumber]
        
        self.cornerLabel.text = chosenDirection
        
        self.utterTextToSpeech(utteredText: chosenDirection, speech: speech)
    }
    
    func startTimer(maxIntervals: Int, restTime: Double) {
        let speech = AVSpeechSynthesizer()
        var startingIntervals = 0
        
        Timer.scheduledTimer(withTimeInterval: restTime, repeats: true){
            timer in
            if startingIntervals < maxIntervals {
                self.chooseAndSpeakRandomCorner(speech: speech)
                startingIntervals += 1
            } else {
                
                let finishMessage = "Workout Complete!"
                self.cornerLabel.text = finishMessage
                
                self.utterTextToSpeech(utteredText: finishMessage, speech: speech)
                
                timer.invalidate()
                self.startWorkoutButton.isHidden = false;
            }
        }
    }

    private func utterTextToSpeech(utteredText: String, speech: AVSpeechSynthesizer) {
        let utterance = AVSpeechUtterance(string: utteredText)
        speech.speak(utterance)
    }
    
    
}

