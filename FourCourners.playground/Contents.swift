//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import AVFoundation

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        //consts
        let directions = ["topleft", "topright", "bottomleft", "bottomright"]
        let restTime = 3.0
        let maxIntervals = 5
        var startingIntervals = 0
        
        let speech = AVSpeechSynthesizer()
        
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Ready....Go!"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view
        
        _ = Timer.scheduledTimer(withTimeInterval: restTime, repeats: true){
            timer in

            if(startingIntervals == maxIntervals) {
                label.text = "Workout Complete!"
                view.addSubview(label)
                self.view = view
                
                let utterance = AVSpeechUtterance(string: "Workout Complete")
                speech.speak(utterance)
                timer.invalidate()
            } else {
                let randomNumber = Int.random(in: 0 ... 3)
                print("direction next is: \(directions[randomNumber])")
                
                startingIntervals = startingIntervals + 1
                print("Interval Count is now: \(startingIntervals)")
                
                label.text = directions[randomNumber]
                view.addSubview(label)
                self.view = view
                
                let utterance = AVSpeechUtterance(string: directions[randomNumber])
                speech.speak(utterance)
            }
        }
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
