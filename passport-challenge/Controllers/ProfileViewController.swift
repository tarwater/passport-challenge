//
//  ProfileViewController.swift
//  passport-challenge
//
//  Created by Holt, Robert on 6/27/18.
//  Copyright © 2018 Holt, Robert. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseDatabase

class ProfileViewController: UIViewController {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var hobbiesTextView: UITextView!
    
    @IBOutlet weak var hobbiesHeight: NSLayoutConstraint!
    var profile: Profile?
    let blue = UIColor(red: 155/255, green: 212/255, blue: 214/255, alpha: 1)
    let pink = UIColor(red: 217/255, green: 187/255, blue: 215/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.bounds.width/2
        
        if(profile?.image != ""){ // if an image was provided, load it. otherwise keep the default
            let url = URL(string: (profile?.image)!)
            imageView?.kf.setImage(with: url)
        }
        
        background.backgroundColor = (profile?.gender == "male" ? blue : pink)  // set background color depending on gender
        
        nameLabel.text = profile?.name
        
        var ageText: String
        
        if (profile?.age)! > 1 {  // handle various age possibilities and create an appropriate string to display
            let age = String(profile!.age)
            ageText = "\(age) years old"
        } else if ((profile?.age) == 1) {
            ageText = "1 year old"
        } else if (profile?.age == -1){
            ageText = "Unknown age"
        } else {
            ageText = "Less than a year old"
        }
        ageLabel.text = ageText
        
        hobbiesTextView.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        hobbiesTextView.layer.borderWidth = 0.5
        hobbiesTextView.layer.cornerRadius = 5.0
        hobbiesTextView.text = profile?.hobbies
        
        let killKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))  // tap recognizer for dismissing the keyboard
        view.addGestureRecognizer(killKeyboardGesture)
        
        // register keyboard events, so the view can be adjusted accordingly
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let ref = Database.database().reference().child("profiles").child((profile?.id)!).child("hobbies")
        ref.setValue(hobbiesTextView.text) // update hobbies when leaving this screen
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    var keyboardSize: CGFloat? = nil;
    
    // methods for adjusting the hobbies text field height constraint when keyboard shows/hides
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            hobbiesHeight.constant = 315 - keyboardSize.height - 8
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            hobbiesHeight.constant = 315
        }
    }
}
