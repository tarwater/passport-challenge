//
//  AddProfileViewController.swift
//  passport-challenge
//
//  Created by Holt, Robert on 6/26/18.
//  Copyright © 2018 Holt, Robert. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class AddProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var genderPicker: UISegmentedControl!
    @IBOutlet weak var hobbiesField: UITextView!
    
    let storage = Storage.storage()
    var storageRef: StorageReference?
    
    var gender = "male"
    
    let blue = UIColor(red: 155/255, green: 212/255, blue: 214/255, alpha: 1)
    let pink = UIColor(red: 217/255, green: 187/255, blue: 215/255, alpha: 1)
    let brown = UIColor(red: 204/255, green: 183/255, blue: 157/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = brown.cgColor
        imageView.layer.cornerRadius = imageView.bounds.width/2
        
        hobbiesField.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        hobbiesField.layer.borderWidth = 0.5
        hobbiesField.layer.cornerRadius = 5.0
        
        let killKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(killKeyboardGesture)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        storageRef = storage.reference()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func genderControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            gender = "male"
            sender.tintColor = blue
            imageView.layer.borderColor = blue.cgColor
        case 1:
            gender = "female"
            sender.tintColor = pink
            imageView.layer.borderColor = pink.cgColor
        default:
            break
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        NSLog("\(info)")
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imagePickerController(picker, pickedImage: image)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
        imageView.image = pickedImage
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        
        let name = nameField.text ?? ""
        let hobbies = hobbiesField.text ?? ""
        let age = Int(ageField.text!) ?? 0
        
        let profile = [
            "name": name,
            "age": age,
            "hobbies": hobbies,
            "gender": gender
            ] as [String : Any]
        
        let ref = Database.database().reference().child("profiles").childByAutoId() // get a reference to the newly saved profile
        ref.setValue(profile)  // save our pet's data
        
        let imageData = UIImagePNGRepresentation(imageView.image!) //get the profile image data
        let id = ref.key  // id = the id of the profile
        let imageRef = storageRef?.child(id) // the image will be stored under the pet's ID
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png" // set content type of upload
        
        imageRef?.putData(imageData!, metadata: metadata) { (metadata, error) in
            imageRef?.downloadURL { (url, error) in
                guard let downloadURL = url else {  // get the download URL of the newly uploaded image
                    // Uh-oh, an error occurred!
                    return
                }
                ref.child("image").setValue(downloadURL.absoluteString) // give the URL to the pet object in the database
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Keyboard show/hide stuff
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    var keyboardSize: CGFloat? = nil;
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                if(self.keyboardSize == nil) {self.keyboardSize = keyboardSize.height; }
                guard self.keyboardSize != nil else {return};
                self.view.frame.origin.y -= self.keyboardSize!;
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                guard self.keyboardSize != nil else {return}
                self.view.frame.origin.y += self.keyboardSize!
                
            }
        }
    }
}
