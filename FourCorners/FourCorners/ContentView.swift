//
//  ContentView.swift
//  FourCorners
//
//  Created by Anaru Herbert on 28/11/19.
//  Copyright © 2019 Anaru Herbert. All rights reserved.
//

import SwiftUI
import AVFoundation

class FourCornersViewModel: ObservableObject {
    @Published var cornerLabel = "Ready!"
    @Published var workoutInProgress = false
    
    @Published var intervalTimer : Timer? = Timer()
    @Published var intervalRestTimeIndex: Int = 0
    @Published var intervalIndex : Int = 0
    
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
    
    var totalTime : String {
        let totalTimerInt = intervalRestTimeValue * intervalValue * roundsValue + roundRestTimeValue + roundsValue
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        
        let formattedString = formatter.string(from: TimeInterval(totalTimerInt))!
        
        return formattedString
    }
    
    
}


struct ContentView: View {

    @ObservedObject var fourCornersVm = FourCornersViewModel()
    // speech stuff
    let speech = AVSpeechSynthesizer()
    
    // timedIntervals
    @State private var timedIntervalCollection = [TimedSpokenInterval]()
    
    var body: some View {
        VStack{
            if self.fourCornersVm.workoutInProgress {
                GeometryReader { geometry in
                    Text(self.fourCornersVm.cornerLabel)
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
                            Picker("Total", selection: self.$fourCornersVm.intervalIndex) {
                                ForEach(self.fourCornersVm.minimumIntervals ..< 21) {
                                    Text("\($0)")
                                }
                            }
                            
                            Picker("Rest", selection: self.$fourCornersVm.intervalRestTimeIndex) {
                                ForEach(self.fourCornersVm.minimumIntervalRestTimeInSeconds ..< 11) {
                                    Text("\($0)s")
                                }
                            }
                        }
                        Section(header: Text("Rounds").font(.headline)) {
                            
                            Picker("Total", selection: self.$fourCornersVm.roundIndex) {
                                ForEach(self.fourCornersVm.minimumRounds ..< 12) {
                                    Text("\($0)")
                                }
                            }
                            Picker("Rest", selection: self.$fourCornersVm.roundRestTimeIndex) {
                                ForEach(self.fourCornersVm.minimumRoundRestTimeInSeconds ..< 60) {
                                    Text("\($0)s")
                                }
                            }
                        }
                        
                        Section(header: Text("Total Time").font(.headline)){
                            Text("\(self.fourCornersVm.totalTime)")
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
        
        self.fourCornersVm.cornerLabel = chosenDirection
        
        self.utterTextToSpeech(utteredText: chosenDirection)
    }
    
    func chooseRandomCorner() -> String {
        let directions = ["Front Left", "Front Right", "Back Left", "Back Right"]
        let randomNumber = Int.random(in: 0 ... 3)
        let chosenDirection = directions[randomNumber]
        
        return chosenDirection
    }
    
    
    func startTimer() {
        guard self.fourCornersVm.intervalTimer == nil else { return }
        self.fourCornersVm.workoutInProgress = true
        
        let maxCount = self.timedIntervalCollection.count
        
        if self.fourCornersVm.currentRoundCount < maxCount {
            
            self.fourCornersVm.intervalTimer = Timer.scheduledTimer(withTimeInterval: self.timedIntervalCollection[self.fourCornersVm.currentRoundCount].intervalInSeconds, repeats: false){
                timer in
                
                self.fourCornersVm.cornerLabel = self.timedIntervalCollection[self.fourCornersVm.currentRoundCount].message
                
                self.utterTextToSpeech(utteredText: self.fourCornersVm.cornerLabel)
                
                self.fourCornersVm.intervalTimer?.invalidate()
                self.fourCornersVm.intervalTimer = Timer()
                self.fourCornersVm.currentRoundCount += 1
                
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
        
        
        for roundNumber in 0 ..< self.fourCornersVm.roundsValue {
            
            if roundNumber != 0 {
                let beginningRound = TimedSpokenInterval.init(intervalInSeconds: Double(self.fourCornersVm.roundRestTimeValue), message: "Round \(roundNumber + 1)")
                
                
                timedIntervalCollection.append(beginningRound)
            }
            
            for _ in 0 ..< self.fourCornersVm.intervalValue {
                let randomCorner = self.chooseRandomCorner()
                
                let timedInterval = TimedSpokenInterval.init(intervalInSeconds: Double(self.fourCornersVm.intervalRestTimeValue), message: randomCorner)
                
                timedIntervalCollection.append(timedInterval)
            }
            
            let restNotification = TimedSpokenInterval.init(intervalInSeconds: Double(self.fourCornersVm.intervalRestTimeValue), message: "Rest for \(self.fourCornersVm.roundRestTimeValue) seconds.")
            
            timedIntervalCollection.append(restNotification)
            
        }
        
        return timedIntervalCollection
    }
    
    func stopWorkout() {
        self.fourCornersVm.workoutInProgress = false
        self.utterTextToSpeech(utteredText: "Workout Complete!")
        
        self.fourCornersVm.cornerLabel = "Ready!"
        
        self.fourCornersVm.intervalTimer?.invalidate()
        self.fourCornersVm.intervalTimer = Timer()
        
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
