//
//  ProfileViewController.swift
//  passport-challenge
//
//  Created by Holt, Robert on 6/27/18.
//  Copyright © 2018 Holt, Robert. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var hobbiesTextView: UITextView!
    
    var profile: Profile?
    let blue = UIColor(red: 155/255, green: 212/255, blue: 214/255, alpha: 1)
    let pink = UIColor(red: 217/255, green: 187/255, blue: 215/255, alpha: 1)
    
    var keyboardSize: CGFloat? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.bounds.width/2
        let url = URL(string: (profile?.image)!)
        imageView?.kf.setImage(with: url)
        
        background.backgroundColor = (profile?.gender == "male" ? blue : pink)
        
        nameLabel.text = profile?.name
        
        var ageText: String
        
        if (profile?.age)! > 1 {
            let age = String(profile!.age)
            ageText = "\(age) years old"
        } else if ((profile?.age) == 1) {
            ageText = "1 year old"
        } else {
            ageText = "Less than a year old"
        }
        ageLabel.text = ageText
        
        hobbiesTextView.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        hobbiesTextView.layer.borderWidth = 0.5
        hobbiesTextView.layer.cornerRadius = 5.0
        hobbiesTextView.text = profile?.hobbies
        
        let killKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(killKeyboardGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
