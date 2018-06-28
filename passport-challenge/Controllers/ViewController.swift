//
//  ViewController.swift
//  passport-challenge
//
//  Created by Holt, Robert on 6/25/18.
//  Copyright © 2018 Holt, Robert. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // send the user to the main screen after 3 seconds on the splash page
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: {_ in
            self.performSegue(withIdentifier: "ToProfiles", sender: self)
            }
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

