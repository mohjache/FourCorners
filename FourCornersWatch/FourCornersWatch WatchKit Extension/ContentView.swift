//
//  ContentView.swift
//  FourCornersWatch WatchKit Extension
//
//  Created by Anaru Herbert on 15/11/19.
//  Copyright © 2019 Anaru Herbert. All rights reserved.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var cornerLabel = "Ready!"
    @State private var workoutInProgess = false;
    @State private var timer : Timer? = Timer()
    
    let restTime: Double = 3.0
    let maxIntervals : Int = 10
    let speech = AVSpeechSynthesizer()
  
    
    var body: some View {
        VStack{
            Text(cornerLabel)
            Button(action: {
                self.startTimer(maxIntervals: self.maxIntervals, restTime: self.restTime)
            }){
                Text("Start")
                
            }
            .background(Color.green)
            
            Button(action: {
                self.stopTimer()
            }){
                Text("Stop")
        
            }
            .background(Color.red)
            
        }
    }
    
    
    func chooseAndSpeakRandomCorner() {
        let directions = ["front-left", "front-right", "back-left", "back-right"]
        let randomNumber = Int.random(in: 0 ... 3)
        let chosenDirection = directions[randomNumber]
        
        self.cornerLabel = chosenDirection
        
        utterTextToSpeech(utteredText: chosenDirection)
    }
    
    func startTimer(maxIntervals: Int, restTime: Double) {
        guard self.timer == nil else { return }
        var startingIntervals = 0
        
        self.timer = Timer.scheduledTimer(withTimeInterval: restTime, repeats: true){
            timer in
            if startingIntervals < maxIntervals {
                self.chooseAndSpeakRandomCorner()
                startingIntervals += 1
            } else {
                let finishMessage = "Workout Complete!"
                self.cornerLabel = finishMessage
                
                self.utterTextToSpeech(utteredText: finishMessage)
                
                self.stopTimer()
            }
        }
    }
    
    func stopTimer(){
        speech.stopSpeaking(at: .word)
        timer?.invalidate()
        timer = Timer()
    }
    
    private func utterTextToSpeech(utteredText: String) {
        let utterance = AVSpeechUtterance(string: utteredText)
        self.speech.speak(utterance)
    }
}







struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
