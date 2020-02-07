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
    //@State private var roundTimer : Timer? = Timer()
    @State private var roundRestTimeIndex : Int = 0
    @State private var roundIndex : Int = 4
    @State private var currentRoundCount : Int  = 0
    
    let minimumRoundRestTimeInSeconds = 10 // up to 59 second
    let minimumRounds = 4 // go up to 12
    
    var roundRestTimeValue : Int {
        return roundRestTimeIndex + minimumRoundRestTimeInSeconds
    }
    
    var roundsValue : Int {
        return roundIndex + minimumRounds
    }
    // speech stuff
    let speech = AVSpeechSynthesizer()
    
    // timedIntervals
    @State private var timedIntervalCollection = [TimedSpokenInterval]()
    
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
                    self.timedIntervalCollection = self.createTimedIntervalsCollection()
                    self.startTimer()
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
        
        self.utterTextToSpeech(utteredText: chosenDirection)
    }
    
    func chooseRandomCorner() -> String {
        let directions = ["Front Left", "Front Right", "Back Left", "Back Right"]
        let randomNumber = Int.random(in: 0 ... 3)
        let chosenDirection = directions[randomNumber]
        
        return chosenDirection
    }
    
    
    func startTimer() {
        guard self.intervalTimer == nil else { return }
        workoutInProgess = true
        
        let maxCount = self.timedIntervalCollection.count
        
        if self.currentRoundCount < maxCount {
            
            self.intervalTimer = Timer.scheduledTimer(withTimeInterval: self.timedIntervalCollection[self.currentRoundCount].intervalInSeconds, repeats: false){
                timer in
                
                self.cornerLabel = self.timedIntervalCollection[self.currentRoundCount].message
                
                self.utterTextToSpeech(utteredText: self.cornerLabel)
                
                self.intervalTimer?.invalidate()
                self.intervalTimer = Timer()
                self.currentRoundCount += 1
                
                self.startTimer()
                
            }
            
            
        }else {
            self.stopWorkout()
        }
        
    }
    
    
    func createTimedIntervalsCollection() -> [TimedSpokenInterval]{
        
        var timedIntervalCollection = [TimedSpokenInterval]()
        
        let firstRound = TimedSpokenInterval.init(intervalInSeconds: 1.0, message: "Round 1")
        
        timedIntervalCollection.append(firstRound)
        
        
        for roundNumber in 0 ..< self.roundsValue {
            
            if roundNumber != 0 {
                let beginningRound = TimedSpokenInterval.init(intervalInSeconds: Double(self.roundRestTimeValue), message: "Round \(roundNumber + 1)")
                
                
                timedIntervalCollection.append(beginningRound)
            }
            
            for _ in 0 ..< self.intervalValue {
                let randomCorner = self.chooseRandomCorner()
                
                let timedInterval = TimedSpokenInterval.init(intervalInSeconds: Double(self.intervalRestTimeValue), message: randomCorner)
                
                timedIntervalCollection.append(timedInterval)
            }
            
            let restNotification = TimedSpokenInterval.init(intervalInSeconds: Double(self.intervalRestTimeValue), message: "Rest for \(self.roundRestTimeValue) seconds.")
            
            timedIntervalCollection.append(restNotification)
            
        }
        
        return timedIntervalCollection
    }
    
    func stopWorkout() {
        workoutInProgess = false
        self.utterTextToSpeech(utteredText: "Workout Complete!")
        
        self.cornerLabel = "Ready!"
        
        intervalTimer?.invalidate()
        intervalTimer = Timer()
        
        self.speech.stopSpeaking(at: .word)
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

struct TimedSpokenInterval {
    var intervalInSeconds: Double;
    var message : String;
    
    init(intervalInSeconds: Double, message: String) {
        self.intervalInSeconds = intervalInSeconds
        self.message = message
    }
}
