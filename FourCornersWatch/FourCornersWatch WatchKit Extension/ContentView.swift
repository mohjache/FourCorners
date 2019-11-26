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
    @State private var workoutInProgess = false
    @State private var intervalTimer : Timer? = Timer()
    @State private var restTimeIndex: Int = 0
    @State private var intervalIndex : Int = 0
    
    let minimumRestTimeInSeconds = 3
    let minimumIntervals = 10
    
    var restTimeSelected : Int {
        return restTimeIndex + minimumRestTimeInSeconds
    }
    
    var intervalSelected : Int {
        return intervalIndex + minimumIntervals
    }
    
     
    let speech = AVSpeechSynthesizer()
    
    var body: some View {
        VStack{
            if workoutInProgess {
                Text(cornerLabel)
                    .font(.title)
                Button(action: {
                    self.stopIntervalTimer()
                }){
                    Text("Stop")
                }
            } else {
                
                Form{
                    Picker("Rest", selection: $restTimeIndex) {
                        ForEach(minimumRestTimeInSeconds ..< 11) {
                            Text("\($0) seconds")
                        }
                    }
                    Picker("Intervals", selection: $intervalIndex) {
                        ForEach(minimumIntervals ..< 21) {
                            Text("\($0)")
                        }
                    }
                    
                    
                }
                Button(action: {
                    self.startTimer(maxIntervals: self.intervalSelected, restTime: Double(self.restTimeSelected))
                }){
                    Text("Start")
                }
                
            }
            
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
        guard self.intervalTimer == nil else { return }
        
        
        var startingIntervals = 0
        cornerLabel = "Ready!"
        workoutInProgess = true
        
        self.intervalTimer = Timer.scheduledTimer(withTimeInterval: restTime, repeats: true){
            timer in
            if startingIntervals < maxIntervals {
                self.chooseAndSpeakRandomCorner()
                startingIntervals += 1
            } else {
                let finishMessage = "Done!"
                self.cornerLabel = finishMessage
                
                self.utterTextToSpeech(utteredText: finishMessage)
                
                self.stopIntervalTimer()
            }
        }
    }
    
    func stopIntervalTimer(){
        
        speech.stopSpeaking(at: .word)
        intervalTimer?.invalidate()
        intervalTimer = Timer()
        
        // TODO: put workout in progress in stop Round Timer
        
        workoutInProgess = false
      
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
