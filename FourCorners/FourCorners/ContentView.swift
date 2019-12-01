//
//  ContentView.swift
//  FourCorners
//
//  Created by Anaru Herbert on 28/11/19.
//  Copyright © 2019 Anaru Herbert. All rights reserved.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var cornerLabel = "Ready!"
    @State private var workoutInProgess = false
    
    
    // Set Interval Values
    @State private var intervalTimer : Timer? = Timer()
    @State private var intervalRestTimeIndex: Int = 0
    @State private var intervalIndex : Int = 0
    
    let minimumIntervalRestTimeInSeconds = 4
    let minimumIntervals = 5
    
    var intervalRestTimeValue : Int {
        return intervalRestTimeIndex + minimumIntervalRestTimeInSeconds
    }
    
    var intervalValue : Int {
        return intervalIndex + minimumIntervals
    }
    
    var totalTime : String {
        let totalTimerInt = intervalRestTimeValue * intervalValue * roundsValue + roundRestTimeValue + roundsValue
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated

        let formattedString = formatter.string(from: TimeInterval(totalTimerInt))!
        
        return formattedString
    }
    
    //Set Round Values
    @State private var roundTimer : Timer? = Timer()
    @State private var roundRestTimeIndex : Int = 0
    @State private var roundIndex : Int = 4
    @State private var currentRoundCount : Int  = 1
    
    let minimumRoundRestTimeInSeconds = 10 // up to 59 second
    let minimumRounds = 4 // go up to 12
    
    var roundRestTimeValue : Int {
        return roundRestTimeIndex + minimumRoundRestTimeInSeconds
    }
    
    var roundsValue : Int {
        return roundIndex + minimumRounds
    }
    
    let speech = AVSpeechSynthesizer()
    
    var body: some View {
        VStack{
            if workoutInProgess {
                GeometryReader { geometry in
                    Text(self.cornerLabel)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(height: geometry.size.height / 2)
                }
                
                Button(action: {
                    self.stopWorkout()
                }){
                    TimerButton(textMessage: "Stop", gradient: LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .leading, endPoint: .trailing))
                    
                }
            } else {
                NavigationView{
                Form{
                    Section(header: Text("Intervals").font(.headline)) {
                        Picker("Total", selection: $intervalIndex) {
                            ForEach(minimumIntervals ..< 21) {
                                Text("\($0)")
                            }
                        }
                        
                        Picker("Rest", selection: $intervalRestTimeIndex) {
                            ForEach(minimumIntervalRestTimeInSeconds ..< 11) {
                                Text("\($0)s")
                            }
                        }
                    }
                    Section(header: Text("Rounds").font(.headline)) {
                        
                        Picker("Total", selection: $roundIndex) {
                            ForEach(minimumRounds ..< 12) {
                                Text("\($0)")
                            }
                        }
                        Picker("Rest", selection: $roundRestTimeIndex) {
                            ForEach(minimumRoundRestTimeInSeconds ..< 60) {
                                Text("\($0)s")
                            }
                        }
                    }
                    
                    Section(header: Text("Total Time").font(.headline)){
                        Text("\(totalTime)")
                            .font(.title)
                            .bold()
                    }
                    
                    
                    }.navigationBarTitle("FourCorners")
                
                }
                
                Button(action: {
                    self.startTimer(intervals: self.intervalValue
                        , rounds: self.roundsValue
                        , intervalRestTime: Double(self.intervalRestTimeValue)
                        , roundRestTime: Double(self.roundRestTimeValue))
                }){
                    TimerButton(textMessage: "Start")
                }
                
            }
                
        }
        
        
        
    }
    
    func chooseAndSpeakRandomCorner() {
        let directions = ["Front Left", "Front Right", "Back Left", "Back Right"]
        let randomNumber = Int.random(in: 0 ... 3)
        let chosenDirection = directions[randomNumber]
        
        self.cornerLabel = chosenDirection
        
        utterTextToSpeech(utteredText: chosenDirection)
    }
    
    
    func startTimer(intervals: Int, rounds: Int, intervalRestTime: Double, roundRestTime: Double) {
        guard self.intervalTimer == nil else { return }
        
        cornerLabel = "Ready!"
        self.utterTextToSpeech(utteredText: cornerLabel)
        
        workoutInProgess = true
        
        var startingIntervals = 0
        
        
        self.intervalTimer = Timer.scheduledTimer(withTimeInterval: intervalRestTime, repeats: true){
            timer in
            if startingIntervals < intervals {
                self.chooseAndSpeakRandomCorner()
                startingIntervals += 1
            } else {
                self.cornerLabel = "R\(self.currentRoundCount) Complete"
                self.utterTextToSpeech(utteredText: "Round \(self.currentRoundCount) Complete.")
                
                self.stopIntervalTimer()
                
                if self.currentRoundCount < rounds {
                    self.roundTimer = Timer.scheduledTimer(withTimeInterval: roundRestTime, repeats: false){
                        timer in
                        self.currentRoundCount += 1
                        self.startTimer(intervals: self.intervalValue, rounds: self.roundsValue, intervalRestTime: Double(self.intervalRestTimeValue), roundRestTime: Double(self.roundRestTimeValue))
                    }
                } else {
                    self.stopWorkout()
                }
            }
        }
        
    }
    
    
    
    
    func stopIntervalTimer(){
        intervalTimer?.invalidate()
        intervalTimer = Timer()
        
        // TODO: put workout in progress in stop Round Timer
    }
    
    func stopWorkout() {
        workoutInProgess = false
        self.utterTextToSpeech(utteredText: "Workout Complete!")
        
        
        
        intervalTimer?.invalidate()
        intervalTimer = Timer()
        
        roundTimer?.invalidate()
        roundTimer = Timer()
        
        self.speech.stopSpeaking(at: .word)
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

struct TimerButton: View {
    var textMessage: String = ""
    var gradient = LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        Text(textMessage)
            .foregroundColor(.white)
            .font(.title)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(20.0)
            .background(gradient)
            .cornerRadius(40)
            .padding()
        
    }
}
