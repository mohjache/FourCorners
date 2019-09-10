//
//  FourCornerExerciseScreen.swift
//  badminton-4C-ios
//
//  Created by Anaru Herbert on 10/9/19.
//  Copyright © 2019 Anaru Herbert. All rights reserved.
//

import UIKit

class FourCornerExerciseScreen: UIViewController {

    let startExcerciseButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Four Corners"
        
        SetupView()
       
    }
    

    func SetupView() {
        self.SetupExerciseButton()
        view.backgroundColor = .darkGray
    }
    
    func SetupExerciseButton() {
        startExcerciseButton.backgroundColor = .blue
        startExcerciseButton.setTitleColor(.white, for: .normal)
        startExcerciseButton.setTitle("Start", for: .normal)
        
        view.addSubview(startExcerciseButton)
        
        setupExerciseButtonConstraints()
    }
    
    func setupExerciseButtonConstraints() {
        startExcerciseButton.translatesAutoresizingMaskIntoConstraints = false
        startExcerciseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        startExcerciseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        startExcerciseButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        startExcerciseButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70).isActive = true
    }

}
