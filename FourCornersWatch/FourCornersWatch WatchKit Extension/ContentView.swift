//
//  ContentView.swift
//  FourCornersWatch WatchKit Extension
//
//  Created by Anaru Herbert on 15/11/19.
//  Copyright © 2019 Anaru Herbert. All rights reserved.
//

import SwiftUI
import AVFoundation
import HealthKit

struct ContentView: View {
    @State private var cornerLabel = "Ready!"
    @State private var workoutInProgess = false;
    @State private var timer : Timer? = Timer()
    
    @State private var restTime: Int = 0
    var restTimeSelected : Int {
        return restTime + 5
    }
    @State private var maxIntervals : Int = 10
    @State private var healthStore  = HKHealthStore()
    
    let speech = AVSpeechSynthesizer()
    let configuration = HKWorkoutConfiguration()
    
    @State private var session: HKWorkoutSession!
    @State private var builder: HKLiveWorkoutBuilder!
    
    
    var body: some View {
        VStack{
            if workoutInProgess {
                Text(cornerLabel)
                    .font(.title)
                Button(action: {
                    self.stopTimer()
                }){
                    Text("Stop")
                }
            } else {
                
                Form{
                    Picker("Rest", selection: $restTime) {
                        ForEach(5 ..< 11) {
                            Text("\($0) seconds")
                        }
                    }
                    Picker("Intervals", selection: $maxIntervals) {
                        ForEach(0 ..< 21) {
                            Text("\($0)")
                        }
                    }
                    
                    
                }
                Button(action: {
                    self.startTimer(maxIntervals: self.maxIntervals, restTime: Double(self.restTimeSelected))
                }){
                    Text("Start")
                }
                
            }
            
        }.onAppear{
            self.requestHealthKit()
        }
    }
    
    func requestHealthKit(){
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
            
            let allTypes = Set([HKObjectType.workoutType(),
                                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                HKObjectType.quantityType(forIdentifier: .heartRate)!])
            
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                } else {
                    self.configuration.activityType = .badminton
                    self.configuration.locationType = .unknown
                    
                    
                    
                    
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
        guard self.timer == nil else { return }
        
        do {
            self.session = try HKWorkoutSession(healthStore: self.healthStore, configuration: self.configuration)
            self.builder = self.session.associatedWorkoutBuilder()
            self.builder.dataSource = HKLiveWorkoutDataSource(healthStore: self.healthStore,
                                                              workoutConfiguration: self.configuration)
            
            self.session.startActivity(with: Date())
            self.builder.beginCollection(withStart: Date()) { (success, error) in
            }
        } catch {
            return
        }
        
        
        var startingIntervals = 0
        cornerLabel = "Ready!"
        workoutInProgess = true
        
        self.timer = Timer.scheduledTimer(withTimeInterval: restTime, repeats: true){
            timer in
            if startingIntervals < maxIntervals {
                self.chooseAndSpeakRandomCorner()
                startingIntervals += 1
            } else {
                let finishMessage = "Done!"
                self.cornerLabel = finishMessage
                
                self.utterTextToSpeech(utteredText: finishMessage)
                
                self.stopTimer()
            }
        }
    }
    
    func stopTimer(){
        
        session.end()
        builder.endCollection(withEnd: Date()) { (success, error) in
            self.builder.finishWorkout { (workout, error) in
                // Dispatch to main, because we are updating the interface.
                DispatchQueue.main.async() {
                }
            }
        }
        
        workoutInProgess = false;
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
