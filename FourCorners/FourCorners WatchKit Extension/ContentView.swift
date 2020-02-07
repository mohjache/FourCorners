//
//  ContentView.swift
//  FourCorners WatchKit Extension
//
//  Created by Anaru Herbert on 28/11/19.
//  Copyright © 2019 Anaru Herbert. All rights reserved.
//

import SwiftUI
import AVFoundation

class workoutViewModel: ObservableObject {
    @Published var cornerLabel = "Ready!"
    @Published var workoutInProgress = false
    
    @Published var intervalTimer : Timer? = Timer()
    @Published var intervalRestTimeIndex: Int = 0
    @Published var intervalIndex : Int = 0
    
    @Published var roundTimer : Timer? = Timer()
    @Published var roundRestTimeIndex : Int = 0
    @Published var roundIndex : Int = 4
    @Published var currentRoundCount : Int  = 1
    
    @Published var minimumIntervalRestTimeInSeconds = 4
    @Published var minimumIntervals = 5
    @Published var minimumRoundRestTimeInSeconds = 10 // up to 59 second
    @Published var minimumRounds = 4 // go up to 12
    
    var intervalRestTimeValue : Int {
        return intervalRestTimeIndex + minimumIntervalRestTimeInSeconds
    }
    
    var intervalValue : Int {
        return intervalIndex + minimumIntervals
    }
    
    var roundRestTimeValue : Int {
        return roundRestTimeIndex + minimumRoundRestTimeInSeconds
    }
    
    var roundsValue : Int {
        return roundIndex + minimumRounds
    }
    
    
}

struct ContentView: View {
    @ObservedObject var workoutVm = workoutViewModel()
    
    let speech = AVSpeechSynthesizer()
    
    var body: some View {
        VStack{
            if self.workoutVm.workoutInProgress {
                Text(self.workoutVm.cornerLabel)
                    .font(.title)
                Button(action: {
                    self.stopWorkout()
                }){
                    Text("Stop")
                    
                }
            } else {
                
                Form{
                    HStack {
                        Picker("Intervals", selection: self.$workoutVm.intervalIndex) {
                            ForEach(self.workoutVm.minimumIntervals ..< 21) {
                                Text("\($0)")
                            }
                        }
                        Picker("Rest", selection: self.$workoutVm.intervalRestTimeIndex) {
                            ForEach(self.workoutVm.minimumIntervalRestTimeInSeconds ..< 11) {
                                Text("\($0)s")
                            }
                        }
                    }

                    HStack {
                        Picker("Rounds", selection: self.$workoutVm.roundIndex) {
                            ForEach(self.workoutVm.minimumRounds ..< 12) {
                                Text("\($0)")
                            }
                        }
                        Picker("Rest", selection: self.$workoutVm.intervalRestTimeIndex) {
                            ForEach(self.workoutVm.minimumRoundRestTimeInSeconds ..< 60) {
                                Text("\($0)s")
                            }
                        }
                    }
                }
                Group {
                    Button(action: {
                        self.startTimer(intervals: self.workoutVm.intervalValue, rounds: self.workoutVm.roundsValue, intervalRestTime: Double(self.workoutVm.intervalRestTimeValue), roundRestTime: Double(self.workoutVm.roundRestTimeValue))
                    }){
                        Text("Start")
                    }


                }
                
                
            }
            
        }
    }
    
    func chooseAndSpeakRandomCorner() {
        let directions = ["front-left", "front-right", "back-left", "back-right"]
        let randomNumber = Int.random(in: 0 ... 3)
        let chosenDirection = directions[randomNumber]
        
        workoutVm.cornerLabel = chosenDirection
        
        utterTextToSpeech(utteredText: chosenDirection)
    }
    
    
    func startTimer(intervals: Int, rounds: Int, intervalRestTime: Double, roundRestTime: Double) {
        guard self.workoutVm.intervalTimer == nil else { return }
        
        workoutVm.cornerLabel = "Ready!"
        self.utterTextToSpeech(utteredText: workoutVm.cornerLabel)
        
        workoutVm.workoutInProgress = true
        
        var startingIntervals = 0
        
        
        self.workoutVm.intervalTimer = Timer.scheduledTimer(withTimeInterval: intervalRestTime, repeats: true){
            timer in
            if startingIntervals < intervals {
                self.chooseAndSpeakRandomCorner()
                startingIntervals += 1
            } else {
                self.workoutVm.cornerLabel = "R\(self.workoutVm.currentRoundCount) Done"
                self.utterTextToSpeech(utteredText: "Round \(self.workoutVm.currentRoundCount + 1) Done.")
                self.stopIntervalTimer()
                
                if self.workoutVm.currentRoundCount < rounds {
                    self.workoutVm.roundTimer = Timer.scheduledTimer(withTimeInterval: roundRestTime, repeats: false){
                        timer in
                        self.workoutVm.currentRoundCount += 1
                        self.startTimer(intervals: self.workoutVm.intervalValue, rounds: self.workoutVm.roundsValue, intervalRestTime: Double(self.workoutVm.intervalRestTimeValue), roundRestTime: Double(self.workoutVm.roundRestTimeValue))
                    }
                } else {
                    self.stopWorkout()
                }
            }
        }
        
    }
    
    func stopIntervalTimer(){
        speech.stopSpeaking(at: .word)
        self.workoutVm.intervalTimer?.invalidate()
        self.workoutVm.intervalTimer = Timer()
        
        // TODO: put workout in progress in stop Round Timer
    }
    
    func stopWorkout() {
        workoutVm.workoutInProgress = false
        
        speech.stopSpeaking(at: .word)
        
        self.workoutVm.intervalTimer?.invalidate()
        self.workoutVm.intervalTimer = Timer()
        
        self.workoutVm.roundTimer?.invalidate()
        self.workoutVm.roundTimer = Timer()
    }
    
    
    
    func utterTextToSpeech(utteredText: String) {
        let utterance = AVSpeechUtterance(string: utteredText)
        self.speech.speak(utterance)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
