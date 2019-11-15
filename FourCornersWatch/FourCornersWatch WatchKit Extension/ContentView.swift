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
    let restTime: Double = 5.0
    let maxIntervals : Int = 10
    
    var body: some View {
        VStack{
            Text(cornerLabel)
            Button(action: {
                self.startTimer(maxIntervals: self.maxIntervals, restTime: self.restTime)
            }){
                Text("Start Workout")
            }
            
        }
    }
    
    func chooseAndSpeakRandomCorner(speech: AVSpeechSynthesizer) {
        let directions = ["front-left", "front-right", "back-left", "back-right"]
        let randomNumber = Int.random(in: 0 ... 3)
        let chosenDirection = directions[randomNumber]
        
        self.cornerLabel = chosenDirection
        
        utterTextToSpeech(utteredText: chosenDirection, speech: speech)
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
                self.cornerLabel = finishMessage
                
                self.utterTextToSpeech(utteredText: finishMessage, speech: speech)
                
                timer.invalidate()
            }
        }
    }
    
    private func utterTextToSpeech(utteredText: String, speech: AVSpeechSynthesizer) {
        let utterance = AVSpeechUtterance(string: utteredText)
        speech.speak(utterance)
    }
}







struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
