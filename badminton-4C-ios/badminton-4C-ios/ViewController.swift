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
    @IBOutlet weak var cornerLabel: UILabel!
    let directions = ["top-left", "top-right", "bottom-left", "bottom-right"]
    let restTime = 3.0
    let maxIntervals = 10
    var startingIntervals = 0
    
    let speech = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cornerLabel.text = "Ready....Go!"
        self.startTimer()
        // Do any additional setup after loading the view.
    }

   
    func startTimer() {
        _ = Timer.scheduledTimer(withTimeInterval: self.restTime, repeats: true){
            timer in
            
            if(self.startingIntervals == self.maxIntervals) {
                self.cornerLabel.text = "Workout Complete!"
                
                let utterance = AVSpeechUtterance(string: "Workout Complete")
                self.speech.speak(utterance)
                timer.invalidate()
            } else {
                let randomNumber = Int.random(in: 0 ... 3)
                print("direction next is: \(self.directions[randomNumber])")
                
                self.startingIntervals = self.startingIntervals + 1
                print("Interval Count is now: \(self.startingIntervals)")
                
                self.cornerLabel.text = self.directions[randomNumber]
              
                let utterance = AVSpeechUtterance(string: self.directions[randomNumber])
                self.speech.speak(utterance)
            }
        }
    }
    
    
}

